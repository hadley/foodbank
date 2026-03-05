# Data dictionary specification

A data dictionary is a YAML file that describes a collection of related tables: their fields, constraints, relationships, and domain terminology. It is designed to be both human-readable and machine-processable.

Inspirations:

* [Frictionless Table Schema](https://datapackage.org/standard/table-schema/)
* [Hex semantic models](https://learn.hex.tech/docs/connect-to-data/semantic-models/semantic-authoring/modeling-specification)
* [QNCH](https://eagereyes.org/blog/2009/qnch-data-description-language-for-tabular-data).

A data dictionary has the following top-level keys:

| Property | Required | Description |
|--------------|----------|-------------|
| `name` | Yes | A short identifier for this data dictionary. |
| `description` | No | A human-readable description of the dataset. |
| `tables` | Yes | Table definitions (see [Tables](#tables)). |
| `relationships` | No | Join descriptors (see [Relationships](#relationships)). |
| `glossary` | No | Domain terminology (see [Glossary](#glossary)). |

## Tables

`tables` is a map from table name to table definition. Each table definition has the following properties:

| Property | Required | Description |
|-------------|----------|-------------|
| `description` | Yes | A human-readable description of the table. May contain markdown. |
| `source` | Yes | Ways to access the data (see [Source](#source)). |
| `fields` | Yes | An ordered list of field metadata (see [Fields](#fields)). |

### Source

`source` is a map whose keys name the access method and whose values give the location. For example:

```yaml
source:
  parquet: inst/parquet/food.parquet
  r: foodbank::food
  SQL: foodbank.food
```

Currently the set of keys is not fixed; any string key is valid. Consumers should use whichever key they understand.

### Fields

Each entry in the `fields` list is a field descriptor with the following properties:

| Property | Required | Description |
|-------------|----------|-------------|
| `name` | Yes | Column name. Must match the column name in the underlying data. |
| `type` | Yes | The field's data type. Must match (approximately) the underlying data type (see [Types](#types)). |
| `constraints` | No | A list of field-level constraints (see [Field constraints](#field-constraints)). |
| `description` | Yes | A human-readable description of the field. Can use markdown. Can include example values. Should include surprises. |

#### Types

Types capture data types at a level that makes sense for analysis, which is typically coarser than the logical types of the underlying data.

The supported types are:

| Type | Description |
|-----------|-------------|
| `number` | Numeric values (integers or floating-point). Can be qualified with a measure in parentheses: `number(id)`, `number(ordinal)`, or `number(quantity)`. See [Measures](#measures). |
| `string` | UTF-8 text strings. |
| `boolean` | True/false values. |
| `date` | Calendar dates (days since epoch). |
| `timestamp` | Date-times with timezone. |
| `enum` | A string with repeated values from a finite set. |
| `enum<l1, l2, ...>` | A string with a small, known set of values listed inside angle brackets. For example, `enum<Analytical, Summed, Calculated>`. Only enumerate values when the set is small and meaningful; use plain `enum` otherwise. |

#### Measures

The `number` type can be qualified with a measure in parentheses that classifies what operations are meaningful:

| Type | Can compare | Can average | Can sum | Examples |
|------------|-------------|-------------|---------|----------|
| `number(id)` | No | No | No | primary keys, foreign keys, codes |
| `number(ordinal)` | Yes | No | No | ranks, years, sequence numbers |
| `number(quantity)` | Yes | Yes | Yes | weights, counts, amounts |

If the measure is omitted (plain `number`), it is unknown.

#### Field constraints

The `constraints` property is a list of constraint names. The supported constraints are:

| Constraint | Description |
|---------------|-------------|
| `primary_key` | This field uniquely identifies each row. Implies `required` and `unique`. |
| `required` | The field must not contain null/missing values. |
| `unique` | The field's values must be distinct (no duplicates). |
| `foreign_key` | The field references a primary key in another table. The specific relationship is defined in [`relationships`](#relationships). |

For example: `constraints: [primary_key, required]`.

## Relationships

`relationships` is a list of join descriptors. Each entry describes how two tables are related.

| Property | Required | Description |
|--------------|----------|-------------|
| `description` | Yes | Human-readable description of the relationship. |
| `cardinality` | Yes | Either `one-to-one`, `one-to-many`, or `many-to-one`. Describes the relationship from the left table to the right table in the join expression. |
| `join` | Yes | An join expression of the form `table1.field = table2.field`, or `table1.date >= table2.start AND table1.date <= table2.end`. |
| `conflicts` | No | A list of field names that appear in both tables with different meanings. These fields would cause ambiguity in a join and may need to be renamed or dropped. |

## Glossary

`glossary` is a map from term to definition. Each entry provides a plain-language definition of a domain-specific term used in the table or field descriptions, or is likely to be used by a domain expert working with this data.

```yaml
glossary:
  foundation food: >
    A food whose nutrient and food component values are derived
    primarily by chemical analysis.
```

## Enrichment

A data dictionary can be programmatically enriched with summary statistics computed from the actual data. Enriched fields gain additional properties:

| Property | Description |
|-------------|-------------|
| `n_missing` | Count of `NA` values (omitted when zero). |
| `range` | For numeric fields: the `[min, max]` interval. |
| `mean` | For numeric fields: the mean (4 significant figures). |
| `n_unique` | For non-numeric fields: the number of distinct non-missing values. |

The enriched dictionary also gains a `nrow` property on each table, recording the number of rows.
