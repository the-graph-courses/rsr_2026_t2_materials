# Variables used in the Week 11 burns workshop

The source is the `Sheet2` tab of the PLOS ONE S1 Dataset.

| Workshop variable | Source column | Meaning and coding |
|:--|:--|:--|
| `mortality` | `mortaltiy` | 0 = survived, 1 = died |
| `age_years` | `age` | Age in years |
| `tbsa_percent` | `TBSA` | Percentage of total body surface area burned |
| `carboxyhemoglobin` | `CoHemo` | Carboxyhemoglobin level (%) |
| `inhalation_injury` | `INHdiv` | 0 = Normal, 1 = Subjective, 2 = Upper, 3 = Lower |
| `pf_ratio_group` | `Pfdivide` | 0 = >300, 1 = 200-300, 2 = 100-200, 3 = <100, using the paper's displayed labels |

## Reproducibility notes

The S1 workbook has 676 rows and reproduces the paper's age, TBSA, inhalation-injury, PF-ratio and carboxyhemoglobin **univariable** models exactly.

`CoHemo` is missing for 93 patients, so any model containing it is fitted on 583 rows.

The workbook does **not** contain a mechanical-ventilation column, so that row of Table 2 cannot be replicated. Deriving a proxy from inhalation injury does not work: a variable defined as "Upper or Lower inhalation injury" is a deterministic function of `inhalation_injury`, so the two cannot appear in the same model, and its univariable odds ratio (3.51) does not match the paper's mechanical-ventilation odds ratio (5.494) anyway. Our multivariable model therefore omits mechanical ventilation, which is why our adjusted inhalation-injury odds ratios are larger than the paper's.

The workbook also contains a patient with PF ratio exactly 100 coded in the lowest group, even though the paper displays that group as `<100`.
