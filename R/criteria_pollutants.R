list_criteria_pollutants <- function() {
  unique(.criteria_pollutants[, c("parameter_code", "parameter")])
}

list_pollutant_standards <- function(parameter_code = NULL) {
  if (is.null(parameter_code)) {
    return(.criteria_pollutants)
  }
  .criteria_pollutants[.criteria_pollutants$parameter_code %in% parameter_code, ]
}
