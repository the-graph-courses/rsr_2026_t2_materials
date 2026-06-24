# RSR Week 6 Workshop, Simple Linear Regression

Built by Opus 4.8 (folder ID `opus48_k9d2`).

The lesson is organized around the **three purposes of regression**: describe, predict, and control. It uses a classic dataset of 654 children and teenagers (Kahn, *JSE* 2005); the outcome is forced expiratory volume (FEV, lung function in litres), a concrete physical measure.

## Files (in `fev_version/`)

- `rsr_week_06_exercise.Rmd`: the worked-example code (correlation, fit, predict, the multiple-regression peek) is shown filled in; students fill a few blanks and, mainly, interpret.
- `rsr_week_06_solutions.Rmd` / `.html`: a full **superset** of the exercise. It reproduces every instruction and every blanked code block from the exercise, and adds a worked Solution chunk (with output) and a written Answer for each step. The HTML is the easy-to-view render.
- `rsr_week_06_workshop.Rproj`, `data/fev_lung_function.csv`.

## The three purposes

1. **Describe.** Plot, correlation, fit a line, and R-squared. Worked for **age** (r = 0.76, R-squared = 0.57); students then describe FEV with **height** (r = 0.87, R-squared = 0.75) and compare, finding height describes FEV better. Includes why R-squared is more useful than a bare correlation (0 to 1 "proportion explained" scale, always positive, and it generalizes to models with more than one predictor).
2. **Predict.** Use `predict()` for a new child's FEV, with a caution about extrapolating outside the data range.
3. **Control.** The smoking puzzle. A naive comparison shows smokers have *higher* FEV (+0.71 L), because the smokers are older teenagers with bigger lungs. A quick peek at multiple regression (`fev_l ~ smoke + age_yrs`) flips the smoking coefficient to *negative* (-0.21 L) once age is held constant. Shown as a teaser, since multiple regression comes later, to illustrate what "controlling" buys you. Note: `smoke` is the child's own smoking status.

## Notes

- Data shipped as a CSV in `data/` so the files knit without installing dataset packages.
- Packages: `tidyverse`, `here`, `janitor`, `broom`, loaded via `pacman`.
- Every code chunk was executed; the numbers in the solutions match the real output. The solutions render with no errors.
- No em dashes are used in the materials.
