#' Generate SQL to create DuckDB views for all foodbank tables
#'
#' Returns a vector of SQL statements that create DuckDB views backed
#' by the parquet files included in the package.
#'
#' @return A character vector of SQL `CREATE VIEW` statements.
#' @export
#' @examples
#' foodbank_sql()
#'
#' if (requireNamespace("duckdb", quietly = TRUE)) {
#'   con <- DBI::dbConnect(duckdb::duckdb())
#'   for (sql in foodbank_sql()) DBI::dbExecute(con, sql)
#'   DBI::dbListTables(con)
#'   DBI::dbDisconnect(con)
#' }
foodbank_sql <- function() {
  parquet_dir <- system.file("parquet", package = "foodbank")
  files <- list.files(parquet_dir, pattern = "\\.parquet$", full.names = TRUE)
  tables <- tools::file_path_sans_ext(basename(files))
  sprintf("CREATE VIEW %s AS SELECT * FROM '%s'", tables, files)
}

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
