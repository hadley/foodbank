url <- "https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_foundation_food_csv_2025-12-18.zip"
dir <- "~/Downloads/foodbank"

if (!dir.exists(dir)) {
  tmp <- tempfile(fileext = ".zip")
  download.file(url, tmp)
  unzip(tmp, exdir = dir, junkpaths = TRUE)
}

xlsx <- list.files(dir, pattern = "\\.xlsx$", full.names = TRUE)
field_desc <- readxl::read_excel(xlsx, sheet = "Field Descriptions")
write.csv(field_desc, "data-raw/data-dictionary.txt", row.names = FALSE)
# data-dictionary.yaml produced by claude reading the .txt and then
# a lot of human editing

# Minimal set of tables needed to look up nutrient info for a food:
# * food + food_category: identify foods and their categories
# * food_nutrient + nutrient: nutrient values and their names/units
# * food_portion + measure_unit: serving size conversions from per-100g
tables <- c(
  "food",
  "food_nutrient",
  "nutrient",
  "food_portion",
  "measure_unit",
  "food_category"
)

src_paths <- set_names(file.path(dir, paste0(tables, ".csv")), tables)
dfs <- purrr::map(src_paths, read.csv)
dfs <- purrr::map(dfs, tibble::as_tibble)

# Replace empty strings with NA in all character columns
dfs <- purrr::map(dfs, function(df) {
  df[] <- map_if(df, is.character, \(x) ifelse(x == "", NA_character_, x))
  df
})

# Filter food to just foundation foods, drop constant data_type column
dfs$food <- dfs$food[dfs$food$data_type == "foundation_food", ]
dfs$food$data_type <- NULL

# Filter food_nutrient and food_portion to foundation foods
dfs$food_nutrient <- dfs$food_nutrient[
  dfs$food_nutrient$fdc_id %in% dfs$food$fdc_id,
]
dfs$food_portion <- dfs$food_portion[
  dfs$food_portion$fdc_id %in% dfs$food$fdc_id,
]
dfs$food_portion$footnote <- NULL

# Replace derivation_id with a factor describing the derivation technique.
# Codes from food_nutrient_derivation table in the supporting data download.
derivation_levels <- c("1" = "Analytical", "4" = "Summed", "49" = "Calculated")
idx <- which(names(dfs$food_nutrient) == "derivation_id")
dfs$food_nutrient[[idx]] <- factor(
  derivation_levels[as.character(dfs$food_nutrient$derivation_id)],
  levels = derivation_levels
)
names(dfs$food_nutrient)[idx] <- "derivation"

# Convert publication_date to Date
dfs$food$publication_date <- as.Date(dfs$food$publication_date)

# Write parquet files
dir.create("inst/parquet", recursive = TRUE, showWarnings = FALSE)
out_paths <- paste0("inst/parquet/", names(dfs), ".parquet")
purrr::walk2(dfs, out_paths, function(df, path) {
  nanoparquet::write_parquet(df, path, compression = "gzip")
})
