##' Look up National Ambient Air Quality Standards (NAAQS)
##'
##' A function to show pollutant standard information on criteria air
##' pollutants.
##'
##' @param parameter_code An AQS parameter code to retrieve specific standard
##'   information. If `NULL` (default), display all pollutant standards.
##' @param detail A logical value indicating whether detailed information is
##'   retrieved.
##'
##' @return A data.frame containing the pollutant standard information
##'
##' @examples
##' list_pollutant_standards()
##'
##' @references Data source:
##'   \url{https://aqs.epa.gov/aqsweb/documents/codetables/pollutant_standards.html}
##'
##' @export
list_pollutant_standards <- function(parameter_code = NULL, detail = FALSE) {
  if (detail) {
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
