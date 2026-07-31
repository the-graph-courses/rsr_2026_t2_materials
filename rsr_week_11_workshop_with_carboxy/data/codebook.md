# Variables used in the Week 11 burns workshop

The source is the `Sheet2` tab of the PLOS ONE S1 Dataset.

| Workshop variable | Source column | Meaning and coding |
|:--|:--|:--|
| `mortality` | `mortaltiy` | 0 = survived, 1 = died |
| `age_years` | `age` | Age in years |
| `tbsa_percent` | `TBSA` | Percentage of total body surface area burned |
| `inhalation_injury` | `INHdiv` | 0 = Normal, 1 = Subjective, 2 = Upper, 3 = Lower |
| `pf_ratio_group` | `Pfdivide` | 0 = >300, 1 = 200-300, 2 = 100-200, 3 = <100, using the paper's displayed labels |

## Reproducibility notes

- The S1 workbook has 676 rows and reproduces the paper's age, TBSA, inhalation-injury, and PF-ratio univariable models.
- Table 2 in the paper also reports mechanical ventilation and carboxyhemoglobin. Mechanical ventilation is not in the shared file. Carboxyhemoglobin is present but has substantial missingness, so this workshop does not include either variable.
- The workbook also contains a patient with PF ratio exactly 100 coded in the lowest group, even though the paper displays that group as `<100`.
