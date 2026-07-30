# Variables used in the Week 11 burns workshop

The source is the `Sheet2` tab of the PLOS ONE S1 Dataset.

| Workshop variable | Source column | Meaning and coding |
|:--|:--|:--|
| `mortality` | `mortaltiy` | 0 = survived, 1 = died |
| `age_years` | `age` | Age in years |
| `tbsa_percent` | `tbsa` | Percentage of total body surface area burned |
| `inhalation_injury` | `in_hdiv` | 0 = Normal, 1 = Subjective, 2 = Upper, 3 = Lower |
| `pf_ratio_group` | `pfdivide` | 0 = >300, 1 = 200-300, 2 = 100-200, 3 = <100 |

## Reproducibility notes

- The S1 workbook has 676 rows. This workshop uses the same four predictors as Week 10.
- The paper's Table 2 also lists mechanical ventilation and carboxyhemoglobin, but those are not included here.
- The workbook also contains a patient with PF ratio exactly 100 coded in the lowest group, even though the paper displays that group as `<100`.
