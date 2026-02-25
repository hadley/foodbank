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
