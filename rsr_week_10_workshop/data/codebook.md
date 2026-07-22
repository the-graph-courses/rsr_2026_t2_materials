# Variables used in the Week 10 burns workshop

The source is the `Sheet2` tab of the PLOS ONE S1 Dataset.

| Workshop variable | Source column | Meaning and coding |
|:--|:--|:--|
| `mortality` | `mortaltiy` | 0 = survived, 1 = died |
| `age_years` | `age` | Age in years |
| `tbsa_percent` | `TBSA` | Percentage of total body surface area burned |
| `co_hemo` | `CoHemo` | Carboxyhemoglobin level |
| `inhalation_injury` | `INHdiv` | 0 = Normal, 1 = Subjective, 2 = Upper, 3 = Lower |
| `pf_ratio` | `PF ratio` | Arterial oxygen pressure divided by fraction of inspired oxygen |
| `pf_ratio_group` | `Pfdivide` | 0 = >300, 1 = 200-300, 2 = 100-200, 3 = <100, using the paper's displayed labels |

## Reproducibility note

The S1 workbook has 676 rows and reproduces the paper's age, TBSA, inhalation-injury, PF-ratio, and carboxyhemoglobin univariable models. It does not contain a mechanical-ventilation column, so that Table 2 row cannot be replicated from the shared patient-level data.

The workbook also contains a patient with PF ratio exactly 100 coded in the lowest group, even though the paper displays that group as `<100`. The workshop retains the supplied category coding and the paper's displayed label so the published regression is reproduced.
