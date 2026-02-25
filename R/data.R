#' Foods
#'
#' Any substance consumed by humans for nutrition, taste and/or aroma.
#' From the USDA FoodData Central Foundation Foods dataset
#' (December 2025).
#'
#' @format A data frame with 436 rows and 5 columns:
#' \describe{
#'   \item{fdc_id}{Unique permanent identifier of the food.}
#'   \item{data_type}{Type of food data.}
#'   \item{description}{Description of the food.}
#'   \item{food_category_id}{ID of the food category the food belongs
#'     to. Foreign key to [food_category].}
#'   \item{publication_date}{Date when the food was published to
#'     FoodData Central.}
#' }
#' @source <https://fdc.nal.usda.gov/download-datasets>
"food"

#' Food nutrients
#'
#' A nutrient value for a food. Amounts are per 100g of food, in the
#' unit defined in the [nutrient] table.
#'
#' @format A data frame with 19,828 rows and 11 columns:
#' \describe{
#'   \item{id}{Unique permanent identifier.}
#'   \item{fdc_id}{ID of the food this food nutrient pertains to.
#'     Foreign key to [food].}
#'   \item{nutrient_id}{ID of the nutrient to which the food nutrient
#'     pertains. Foreign key to [nutrient].}
#'   \item{amount}{Amount of the nutrient per 100g of food.}
#'   \item{data_points}{Number of observations on which the value is
#'     based.}
#'   \item{derivation_id}{ID of the food nutrient derivation technique
#'     used to derive the value.}
#'   \item{min}{The minimum amount.}
#'   \item{max}{The maximum amount.}
#'   \item{median}{The median amount.}
#'   \item{footnote}{Comments on any unusual aspects of the food
#'     nutrient.}
#'   \item{min_year_acquired}{Minimum purchase year of all acquisitions
#'     used to derive the nutrient value.}
#' }
#' @source <https://fdc.nal.usda.gov/download-datasets>
"food_nutrient"

#' Nutrients
#'
#' The chemical constituents of a food (e.g. calcium, vitamin E)
#' officially recognized as essential to human health.
#'
#' @format A data frame with 477 rows and 5 columns:
#' \describe{
#'   \item{id}{Unique permanent identifier.}
#'   \item{name}{Name of the nutrient.}
#'   \item{unit_name}{The standard unit of measure for the nutrient
#'     (per 100g of food).}
#'   \item{nutrient_nbr}{A unique code identifying a nutrient or food
#'     constituent.}
#'   \item{rank}{Display rank for ordering nutrients.}
#' }
#' @source <https://fdc.nal.usda.gov/download-datasets>
"nutrient"

#' Food portions
#'
#' Discrete amounts of food, used to convert from per-100g nutrient
#' values to common serving sizes.
#'
#' @format A data frame with 187 rows and 11 columns:
#' \describe{
#'   \item{id}{Unique permanent identifier.}
#'   \item{fdc_id}{ID of the food this food portion pertains to.
#'     Foreign key to [food].}
#'   \item{seq_num}{The order the measure will be displayed on the
#'     released food.}
#'   \item{amount}{The number of measure units that comprise the
#'     measure (e.g. if measure is 3 tsp, the amount is 3).}
#'   \item{measure_unit_id}{The unit used for the measure. Foreign key
#'     to [measure_unit].}
#'   \item{portion_description}{Comments that provide more specificity
#'     on the measure.}
#'   \item{modifier}{Qualifier of the measure (e.g. related to food
#'     shape or form).}
#'   \item{gram_weight}{The weight of the measure in grams.}
#'   \item{data_points}{The number of observations on which the
#'     measure is based.}
#'   \item{footnote}{Comments on any unusual aspects of the measure.}
#'   \item{min_year_acquired}{Minimum purchase year of all acquisitions
#'     used to derive the measure value.}
#' }
#' @source <https://fdc.nal.usda.gov/download-datasets>
"food_portion"

#' Measure units
#'
#' Units for measuring quantities of foods.
#'
#' @format A data frame with 123 rows and 2 columns:
#' \describe{
#'   \item{id}{Unique permanent identifier.}
#'   \item{name}{Name of the unit.}
#' }
#' @source <https://fdc.nal.usda.gov/download-datasets>
"measure_unit"

#' Food categories
#'
#' Foods of defined similarity.
#'
#' @format A data frame with 28 rows and 3 columns:
#' \describe{
#'   \item{id}{Unique permanent identifier.}
#'   \item{code}{Food group code.}
#'   \item{description}{Description of the food group.}
#' }
#' @source <https://fdc.nal.usda.gov/download-datasets>
"food_category"
