# Variables used in Workshop 11

The source is the `Sheet2` tab of the PLOS ONE S1 Dataset.

| Workshop variable | Source column | Meaning and coding |
|:--|:--|:--|
| `mortality` | `mortaltiy` | 0 = survived, 1 = died |
| `age_years` | `age` | Age in years |
| `tbsa_percent` | `TBSA` | Percentage of total body surface area burned |
| `co_hemo` | `CoHemo` | Carboxyhemoglobin level (%) |
| `inhalation_injury` | `INHdiv` | 0 = Normal, 1 = Subjective, 2 = Upper, 3 = Lower |
| `pf_ratio_group` | `Pfdivide` | 0 = >300, 1 = 200–300, 2 = 100–200, 3 = <100, using the paper's labels |

## Reproducibility notes

- The workbook has 676 rows and reproduces the paper's univariable results for all variables above.
- Carboxyhemoglobin is missing for 93 patients, so a complete-case model containing it uses 583 patients.
- The workbook has no mechanical-ventilation variable. It must not be reconstructed from inhalation-injury categories. Upper and lower inhalation injury together identify 179 patients, while the paper reports 274 mechanically ventilated patients.
- One patient with PF ratio exactly 100 is coded in the lowest group, although the paper labels that group `<100`.

