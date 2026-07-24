# Workshop-building guidelines

Use these guidelines when creating or revising workshop exercises and solutions in this repository.

## Teaching flow

- Introduce one new idea at a time and show intermediate objects before combining steps.
- Fit and interpret a model before producing formatted model tables or diagnostic plots.
- Call `summary()` and ask at least one interpretation question before introducing `broom::tidy()`.
- Introduce `predict()` with one specific predictor value before using it across a range of values.
- When creating predictions across a simple integer range, prefer a readable vector such as `18:92` or `0:100` over a more complex `seq()` call.
- Store and print the predictor-value vector. Then build and print the prediction table, explaining what each row represents.

## Code chunks

- When a whole code chunk is supplied, keep explanatory comments out of the chunk. Explain what the code does in the prose immediately before it.
- Comments may be used in partially completed chunks to guide students. If students must fill in variable names or factor levels, state the expected names or levels in comments above the relevant line.
- Keep syntax as simple as the learning objective permits.
- Treat vertical screen space as limited. Keep related code, output, and explanation close enough to remain in view together.
- Format R code compactly. Do not put every function argument or aesthetic on its own line when a short call is still readable.
- Break lines at conceptual steps, such as one `ggplot2` layer per line, rather than using JavaScript-style expanded formatting.
- Do not add `.groups = "drop"` when the default `summarise()` behavior is sufficient.
- Do not calculate grouped means or other intermediate values unless they are needed.
- Avoid unnecessary `ggplot2` themes, scales, and formatting.

## Questions and answer spaces

- Ask one question at a time. Split questions that request two separate answers.
- Use `______` to provide space for open answers.
- If a quoted fill-in sentence already contains blanks, do not add another line of underscores.
- Put the `Ans` label before a quoted fill-in sentence.
- In the first worked example of a pair, make interpretation blanks relatively easy, such as choosing higher versus lower.
- In the second example, ask students to write the full interpretation. Tell them which elements to include.

## Data preparation

- Inspect raw categorical and numeric variables before recoding so students can notice categorical variables stored as numbers.
- Use labelled factors when labels make output easier to read.
- Use `rename()` for renaming and `select()` for selecting. Do not rename variables inside `select()` when a rename step is already present.
- Fill in factor-level labels when recalling the labels is not part of the learning objective.
- Keep the exercise focused on the variables being taught.
- Write the current document as a self-contained workshop. Do not refer to removed material, omitted variables, or an older version.

## Continuous predictors

- Fit and interpret the model first.
- Calculate a fitted probability manually for a specific value when this helps explain the inverse-logit transformation.
- Compare the manual result with `predict(..., type = "response")`.
- Only then compare fitted probabilities with observed data.
- Build the observed summary and show it by itself before adding the fitted line in a second step.
- Use bars for regular, equal-width groups. For irregular or open-ended groups plotted on a continuous axis, use vertical segments and points instead of assigning arbitrary bar widths.
- Avoid interactive plots and hover behavior unless interactivity directly supports the learning objective.
- Emphasize that equal changes in a continuous predictor produce a constant multiplicative change in odds, not a constant percentage-point change in probability.

## Categorical predictors

- Start with a grouped table of observed outcome probabilities.
- A bar chart is optional and should only be included if it adds teaching value.
- Demonstrate a fitted group probability by adding the intercept and relevant coefficient, applying the inverse logit, and comparing it with the observed group probability.
- Explain that a categorical predictor estimates separate group probabilities. A continuous sigmoid curve is not meaningful across category names.

## Statistical reporting

- Explain odds ratios using the correct unit of change.
- Explain that an odds ratio of 1 represents no difference in odds.
- When teaching confidence intervals, note if the software and source paper use different methods. Name both methods and show how to reproduce the paper's method where practical.
- Keep explanations concise and focused on the immediate learning objective.

## Exercises, solutions, and deliverables

- Keep exercise and solution wording, numbering, code structure, and scope synchronized.
- In solutions, replace exercise blanks with runnable code and provide answers only for questions that remain in the exercise.
- Render the solutions after every substantive change.
- Check the rendered output, refresh the exercise and solutions archives, and test both archives before handoff.
