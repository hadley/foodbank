library(yaml)
library(purrr)

enrich_data_dictionary <- function(dd) {
  dd$tables <- imap(dd$tables, function(spec, name) {
    df <- read_table(name)

    # Insert nrow before fields
    idx <- match("fields", names(spec))
    spec <- append(spec, list(nrow = nrow(df)), after = idx - 1)

    spec$fields <- map(spec$fields, function(fld) {
      field <- fld$name
      col <- df[[field]]
      info <- fld
      info$type <- field_type(col)
      n <- length(col)
      n_miss <- sum(is.na(col))
      if (n_miss > 0) {
        info$n_missing <- n_miss
      }
      if (is.numeric(col)) {
        vals <- col[!is.na(col)]
        r <- range(vals)
        info$range <- paste0("[", r[1], ", ", r[2], "]")
        info$mean <- signif(mean(vals), 4)
      } else {
        info$n_unique <- length(unique(col[!is.na(col)]))
      }
      info
    })

    spec
  })

  dd
}

field_type <- function(x) {
  if (is.factor(x)) {
    paste0("enum<", paste(levels(x), collapse = ", "), ">")
  } else if (inherits(x, "Date")) {
    "date"
  } else if (inherits(x, "POSIXct")) {
    "timestamp"
  } else if (is.numeric(x)) {
    "number"
  } else if (is.character(x)) {
    "string"
  } else if (is.logical(x)) {
    "boolean"
  } else {
    class(x)[[1]]
  }
}

devtools::load_all()
dd <- read_yaml("data-raw/data-dictionary.yaml")
enriched <- enrich_data_dictionary(dd)
write_yaml(enriched, "data-raw/data-dictionary-enriched.yaml")
