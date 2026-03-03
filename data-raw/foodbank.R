url <- "https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_foundation_food_csv_2025-12-18.zip"
dir <- file.path(tempdir(), "foodbank")

if (!dir.exists(dir)) {
  tmp <- tempfile(fileext = ".zip")
  download.file(url, tmp)
  unzip(tmp, exdir = dir, junkpaths = TRUE)
}

xlsx <- list.files(dir, pattern = "\\.xlsx$", full.names = TRUE)
field_desc <- readxl::read_excel(xlsx, sheet = "Field Descriptions")
write.csv(field_desc, "data-raw/data-dictionary.txt", row.names = FALSE)
# data-dictionary.yaml produced by claude reading the .txt

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

dir.create("inst/parquet", recursive = TRUE, showWarnings = FALSE)

# Filter food to just foundation foods, and filter food_nutrient and
# food_portion to match
food <- read.csv(file.path(dir, "food.csv"))
food <- food[food$data_type == "foundation_food", ]
foundation_fdc_ids <- food$fdc_id

# Drop data_type since it's always "foundation_food"
food$data_type <- NULL

# Replace empty strings with NA in all character columns
replace_empty <- function(x) ifelse(x == "", NA_character_, x)

# Found by downloading supplemental data and then looking in food_nutrient_derivation.csv
# Replace derivation_id with a factor describing the derivation technique.
# Codes from food_nutrient_derivation table in the supporting data download.
derivation_levels <- c("1" = "Analytical", "4" = "Summed", "49" = "Calculated")

for (table in tables) {
  df <- if (table == "food") {
    food
  } else {
    read.csv(file.path(dir, paste0(table, ".csv")))
  }
  if ("fdc_id" %in% names(df) && table != "food") {
    df <- df[df$fdc_id %in% foundation_fdc_ids, ]
  }
  for (col in names(df)) {
    if (is.character(df[[col]])) {
      df[[col]] <- replace_empty(df[[col]])
    }
  }
  if ("derivation_id" %in% names(df)) {
    # Place derivation factor in the same position as derivation_id
    idx <- which(names(df) == "derivation_id")
    df[[idx]] <- factor(
      derivation_levels[as.character(df$derivation_id)],
      levels = derivation_levels
    )
    names(df)[idx] <- "derivation"
  }
  nanoparquet::write_parquet(
    df,
    paste0("inst/parquet/", table, ".parquet"),
    compression = "gzip"
  )
}
