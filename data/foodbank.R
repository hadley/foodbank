read_table <- function(name) {
  path <- file.path("parquet", paste0(name, ".parquet"))
  # Hack to get shim, if loaded with pkgload
  sys_file <- get("system.file", envir = getNamespace("foodbank"))

  out <- nanoparquet::read_parquet(sys_file(path, package = "foodbank"))
  if (requireNamespace("tibble", quietly = TRUE)) {
    out <- tibble::as_tibble(out)
  }
  out
}

delayedAssign("food", read_table("food"))
delayedAssign("food_nutrient", read_table("food_nutrient"))
delayedAssign("nutrient", read_table("nutrient"))
delayedAssign("food_portion", read_table("food_portion"))
delayedAssign("measure_unit", read_table("measure_unit"))
delayedAssign("food_category", read_table("food_category"))
