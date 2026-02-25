test_that("foodbank_sql() generates correct SQL", {
  expect_snapshot(
    writeLines(foodbank_sql()),
    transform = function(x) {
      gsub(system.file(package = "foodbank"), "<package>", x, fixed = TRUE)
    }
  )
})
