# Week 6 workshop draft: simple linear regression

This folder contains two focused Week 6 workshop versions.

## Version 1: `prevend_regression`

- Dataset: PREVEND cognitive function and aging teaching sample (`prevend.csv`), 500 adults from a Dutch cohort
- Demo question: Is age associated with systolic blood pressure?
- Exercise question: Is age associated with Ruff Figural Fluency Test score?
- Main concepts: correlation, scatterplots, simple linear regression, slope, p-value, confidence interval for the slope, R-squared, residual standard error, residuals, and prediction

This version uses individual-level health data and concrete measured variables. The exercise follows the dataset's intended simple regression example, `rfft ~ age_yrs`.

## Version 2: `fev_single_file`

- Dataset: FEV lung function in youths (`fev_kahn.csv`)
- Format: one main workshop file, with the worked demo embedded directly in the exercise file
- Worked section: `fev_l ~ age_yrs`
- Student exercise: `fev_l ~ height_in`, comparing R-squared with the age model
- End section: smoking status, raw comparison, and a short multiple-regression preview showing why controlling for height changes the smoking story
- Main concepts: using regression to describe, predict, and preview controlling for another variable
