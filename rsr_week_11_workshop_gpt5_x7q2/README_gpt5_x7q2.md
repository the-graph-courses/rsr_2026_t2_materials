# Workshop 11 materials

This folder contains the `gpt5_x7q2` Workshop 11 draft.

## Main files

- `rsr_week_11_exercise_gpt5_x7q2.Rmd`: student exercise
- `rsr_week_11_solutions_gpt5_x7q2.Rmd`: solution, generated as a strict superset of the exercise
- `rsr_week_11_solutions_gpt5_x7q2.html`: rendered solution
- `scripts/birthwt_univariable_forest_table_gpt5_x7q2.R`: worked forest-table example
- `rsr_week_11_exercise_gpt5_x7q2.zip`: tested student archive
- `rsr_week_11_solutions_gpt5_x7q2.zip`: tested solution archive

## Rebuild and check

Run these commands from this folder:

```r
source("scripts/build_solutions_gpt5_x7q2.R")
rmarkdown::render("rsr_week_11_solutions_gpt5_x7q2.Rmd")
source("scripts/validate_workshop_gpt5_x7q2.R")
```

The build script preserves every exercise line and inserts each answer directly after its matching marker. Blank student chunks remain present with `eval=FALSE`.

## Replication boundary

The released burns workbook has no mechanical-ventilation variable. Upper or lower inhalation injury is not an equivalent: those categories contain 179 patients, while the paper reports 274 ventilated patients. The workshop therefore fits the fullest model supported by the released data and compares it transparently with the published model.
