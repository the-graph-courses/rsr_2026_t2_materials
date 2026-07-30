exercise_path <- "rsr_week_11_exercise_gpt5_x7q2.Rmd"
solution_path <- "rsr_week_11_solutions_gpt5_x7q2.Rmd"

exercise <- readLines(exercise_path, warn = FALSE)
solution <- readLines(solution_path, warn = FALSE)

# Verify that every exercise line occurs in the solution in the same order.
solution_position <- 0L
for (line_number in seq_along(exercise)) {
  remaining <- solution[(solution_position + 1L):length(solution)]
  next_match <- match(exercise[line_number], remaining)
  if (is.na(next_match)) {
    stop("Exercise line ", line_number,
         " is missing from the solution after position ", solution_position, ".")
  }
  solution_position <- solution_position + next_match
}

markers <- grep("<!-- SOLUTION:", exercise, value = TRUE)
answers <- grep("\\*\\*Answer:\\*\\*", solution, value = TRUE)
student_chunks <- grep("student, eval=FALSE", exercise, value = TRUE)
solution_student_chunks <- grep("student, eval=FALSE", solution, value = TRUE)

if (length(markers) != 32L) stop("Expected 32 solution markers.")
if (length(answers) != 28L) stop("Expected 28 prose answer blocks.")
if (!identical(student_chunks, solution_student_chunks)) {
  stop("Blank student chunks were not preserved with eval=FALSE.")
}

required_files <- c(
  "data/S1Dataset_burns.xlsx",
  "data/codebook_gpt5_x7q2.md",
  "images/table2.png",
  "images/sunshine_logistic_gpt5_x7q2.svg",
  "outputs/birthwt_univariable_forest_table_gpt5_x7q2.png",
  "paper/kim_et_al_2017.pdf",
  "scripts/birthwt_univariable_forest_table_gpt5_x7q2.R"
)

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0) {
  stop("Missing required files: ", paste(missing_files, collapse = ", "))
}

message("PASS: solution is a strict superset of the exercise.")
message("PASS: all blank student chunks remain eval=FALSE in the solution.")
message("PASS: all required workshop assets are present.")
