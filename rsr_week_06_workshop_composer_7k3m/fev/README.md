# Week 6: FEV version (embedded walkthrough)

Single **exercise-only** workbook. No separate demo file.

## Files

| File | Role |
|------|------|
| `rsr_week_06_exercise.Rmd` | Part 1: age walkthrough (filled in); Part 2: height (blanks); Part 3: compare |
| `rsr_week_06_solutions.Rmd` / `.html` | Full superset solutions |
| `data/fev_kahn.csv` | Kahn/Tager JSE lung function (654 youths) |

## Flow

1. **Walkthrough:** `fev_l ~ age_yrs`, complete code, chunks use `echo=TRUE`
2. **Exercise:** `fev_l ~ height_in`, same steps, fill-in blanks
3. **Compare:** height has stronger $r$ and $R^2$ (~0.87 / 0.75 vs ~0.76 / 0.57)

Open the parent `rsr_week_06_workshop.Rproj` and set working directory to `fev/`, or open the Rmd directly.

## Coexists with

`../rsr_week_06_exercise.Rmd`, the PREVEND version (separate demo + exercise files).
