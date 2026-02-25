
<!-- README.md is generated from README.Rmd. Please edit that file -->

# foodbank

<!-- badges: start -->

<!-- badges: end -->

foodbank provides the [USDA FoodData Central](https://fdc.nal.usda.gov/)
Foundation Foods dataset as a set of data frames ready for analysis in
R. It includes 436 foods with nutrient values, serving size portions,
and food categories.

## Installation

You can install the development version of foodbank from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("hadley/foodbank")
```

## Datasets

foodbank provides six tables centered around `food`:

- `food`: 436 foundation foods with descriptions and categories.
  - Each food belongs to one `food_category` (join on
    `food_category_id = id`).
  - Each food has many rows in `food_nutrient` (join on `fdc_id`).
  - Some foods have rows in `food_portion` (join on `fdc_id`).
- `food_nutrient`: 19,828 nutrient values (per 100g of food). Each row
  links to one `nutrient` (join on `nutrient_id = id`) and one `food`
  (join on `fdc_id`).
- `nutrient`: 477 nutrient definitions with names and units.
- `food_portion`: 187 serving size measures with gram weights. Each row
  links to one `measure_unit` (join on `measure_unit_id = id`).
- `measure_unit`: 123 units used in portion measures.
- `food_category`: 28 food groups.

## Example

``` r
library(foodbank)
library(dplyr)
```

Look up the nutrients in hummus:

``` r
food |>
  filter(description == "Hummus, commercial") |>
  left_join(food_nutrient, join_by(fdc_id)) |>
  left_join(nutrient, join_by(nutrient_id == id)) |>
  select(description, name, amount, unit_name) |>
  head(10)
#> # A tibble: 10 × 4
#>    description        name                                amount unit_name
#>    <chr>              <chr>                                <dbl> <chr>    
#>  1 Hummus, commercial SFA 10:0                             0     G        
#>  2 Hummus, commercial SFA 16:0                             1.41  G        
#>  3 Hummus, commercial PUFA 20:5 n-3 (EPA)                  0     G        
#>  4 Hummus, commercial Tocopherol, delta                    1.3   MG       
#>  5 Hummus, commercial Magnesium, Mg                       71.1   MG       
#>  6 Hummus, commercial Galactose                            0     G        
#>  7 Hummus, commercial PUFA 20:2 n-6 c,c                    0.005 G        
#>  8 Hummus, commercial Fatty acids, total trans-dienoic     0.012 G        
#>  9 Hummus, commercial PUFA 18:3 n-3 c,c,c (ALA)            0.637 G        
#> 10 Hummus, commercial Choline, from glycerophosphocholine  1.1   MG
```

Find the foods highest in protein:

``` r
nutrient |>
  filter(name == "Protein") |>
  left_join(food_nutrient, join_by(id == nutrient_id)) |>
  left_join(food, join_by(fdc_id)) |>
  select(description, amount, unit_name) |>
  arrange(desc(amount)) |>
  head(10)
#> # A tibble: 10 × 3
#>    description                                                  amount unit_name
#>    <chr>                                                         <dbl> <chr>    
#>  1 Egg, white, dried                                              79.9 G        
#>  2 Flour, soy, defatted                                           51.1 G        
#>  3 Egg, whole, dried                                              48.1 G        
#>  4 Pork, cured, bacon, cooked, restaurant                         40.9 G        
#>  5 Flour, soy, full-fat                                           38.6 G        
#>  6 Egg, yolk, dried                                               34.2 G        
#>  7 Chicken, broiler or fryers, breast, skinless, boneless, mea…   32.1 G        
#>  8 Cheese, parmesan, grated, refrigerated                         30.1 G        
#>  9 Seeds, pumpkin seeds (pepitas), raw                            29.9 G        
#> 10 Cheese, parmesan, grated                                       29.6 G
```

## DuckDB

You can also create a DuckDB database backed by the parquet files, which
is useful for SQL queries or working with the data via dbplyr:

``` r
con <- DBI::dbConnect(duckdb::duckdb())
for (sql in foodbank_sql()) DBI::dbExecute(con, sql)

DBI::dbGetQuery(con, "
  SELECT f.description, n.name, fn.amount, n.unit_name
  FROM food f
  JOIN food_nutrient fn ON f.fdc_id = fn.fdc_id
  JOIN nutrient n ON fn.nutrient_id = n.id
  WHERE f.description = 'Hummus, commercial'
  ORDER BY fn.amount DESC
  LIMIT 8
")
#>          description                              name amount unit_name
#> 1 Hummus, commercial                            Energy    960        kJ
#> 2 Hummus, commercial                        Sodium, Na    438        MG
#> 3 Hummus, commercial                      Potassium, K    289        MG
#> 4 Hummus, commercial               Lutein + zeaxanthin    258        UG
#> 5 Hummus, commercial  Energy (Atwater General Factors)    243      KCAL
#> 6 Hummus, commercial Energy (Atwater Specific Factors)    229      KCAL
#> 7 Hummus, commercial                            Energy    229      KCAL
#> 8 Hummus, commercial                     Phosphorus, P    166        MG

DBI::dbDisconnect(con)
```

## Data source

The data comes from the [USDA FoodData
Central](https://fdc.nal.usda.gov/) Foundation Foods dataset (December
2025 release). Foundation foods have nutrient values derived primarily
by chemical analysis, with extensive underlying metadata.
