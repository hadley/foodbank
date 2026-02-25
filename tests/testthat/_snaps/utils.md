# foodbank_sql() generates correct SQL

    Code
      writeLines(foodbank_sql())
    Output
      CREATE VIEW food AS SELECT * FROM '<package>/parquet/food.parquet'
      CREATE VIEW food_category AS SELECT * FROM '<package>/parquet/food_category.parquet'
      CREATE VIEW food_nutrient AS SELECT * FROM '<package>/parquet/food_nutrient.parquet'
      CREATE VIEW food_portion AS SELECT * FROM '<package>/parquet/food_portion.parquet'
      CREATE VIEW measure_unit AS SELECT * FROM '<package>/parquet/measure_unit.parquet'
      CREATE VIEW nutrient AS SELECT * FROM '<package>/parquet/nutrient.parquet'

