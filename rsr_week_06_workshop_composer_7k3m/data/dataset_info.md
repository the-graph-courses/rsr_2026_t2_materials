# Week 6 workshop dataset

| File | Source | N × p | License |
|------|--------|-------|---------|
| `prevend.csv` | PREVEND cohort teaching sample (`oibiostat::prevend.samp`) | 500 × 31 | No explicit licence (oibiostat); educational use |

Original staging path: `rsr_resources/datasets_staging/cleaned/18_prevend.csv`.

**Demo:** `rfft` ~ `age_yrs`  
**Exercise:** `rfft` ~ `systolic_bp`

Also loadable in R:

```r
data(prevend.samp, package = "oibiostat")
```

Week 5 used the same cohort (via `openintro::prevend.samp`) for systolic BP **group comparisons**. Week 6 uses SLR for **cognitive function (RFFT)** vs continuous predictors.

---

| File | Source | N × p | License |
|------|--------|-------|---------|
| `fev_kahn.csv` | Kahn/Tager JSE 2005 — lung function in youths | 654 × 5 | Free, non-commercial (JSE) |

Original staging path: `rsr_resources/datasets_staging/cleaned/03_fev_kahn.csv`.

**FEV track** (`fev/rsr_week_06_exercise.Rmd`): walkthrough `fev_l ~ age_yrs`, then exercise `fev_l ~ height_in`.
