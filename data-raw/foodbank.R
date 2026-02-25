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

for (table in tables) {
  df <- if (table == "food") {
    food
  } else {
    read.csv(file.path(dir, paste0(table, ".csv")))
  }
  if ("fdc_id" %in% names(df) && table != "food") {
    df <- df[df$fdc_id %in% foundation_fdc_ids, ]
  }
  nanoparquet::write_parquet(df, paste0("inst/parquet/", table, ".parquet"))
}
