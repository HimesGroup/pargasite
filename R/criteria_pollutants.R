list_criteria_pollutants <- function() {
  unique(.criteria_pollutants[, c("parameter_code", "parameter")])
}

list_pollutant_standards <- function(parameter_code = NULL, full_info = FALSE) {
  if (full_info) {
    cols_to_show <- names(.criteria_pollutants)
  } else {
    cols_to_show <- c("parameter_code", "parameter", "pollutant_standard")
  }
  if (is.null(parameter_code)) {
    return(.criteria_pollutants[, cols_to_show])
  }
  idx <- .criteria_pollutants$parameter_code %in% parameter_code
  if (sum(idx) == 0) {
    stop("Not a criteria pollutant. Please check the parameter code.")
  }
  .criteria_pollutants[idx, cols_to_show, drop = FALSE]
}
