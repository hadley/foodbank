# env <- new.env(parent = emptyenv())
# env$

delayedAssign("food", foodbank:::read_table("food"))
delayedAssign("food_nutrient", foodbank:::read_table("food_nutrient"))
delayedAssign("nutrient", foodbank:::read_table("nutrient"))
delayedAssign("food_portion", foodbank:::read_table("food_portion"))
delayedAssign("measure_unit", foodbank:::read_table("measure_unit"))
delayedAssign("food_category", foodbank:::read_table("food_category"))
