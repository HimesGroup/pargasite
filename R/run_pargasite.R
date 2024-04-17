##' Run pargasite application
##'
##' Launch a Shiny application to visualize pollutant levels of the conterminous
##' US. The system's default web browser will be launched automatically after
##' the app is started.
##'
##' @param x A stars object returned by [create_pargasite_data].
##'
##' @return This function normally does not return; interrupt R to stop the
##'   application (usually by pressing Ctrl + C or ESC).
##'
##' @examples
##'
##' if (interactive()) {
##'   run_pargasite(ozone20km)
##' }
##'
##' @export
run_pargasite <- function(x) {
  ## Reset pargasite options first
  options(pargasite.dat = NULL, pargasite.map = NULL)
  ## Verify inputs
  if (!inherits(x, "stars")) {
    stop("'x' must be a stars object.")
  }
  if ("data_field" %ni% dimnames(x)) {
    stop("'x' must have 'data_field' dimension")
  }
  if ("event" %ni% dimnames(x)) {
    stop("'x' must have 'event' dimension")
  }
  if ("year" %ni% dimnames(x)) {
    stop("'x' must have 'year' dimension")
  }
  map_state <- .get_pargasite_map(x, "state")
  map_county <- .get_pargasite_map(x, "county")
  map_cbsa <- .get_pargasite_map(x, "cbsa")
  options(pargasite.dat = x,
          pargasite.map = list(state = map_state, county = map_county,
                               cbsa = map_cbsa))
  ## Not working
  ## op <- options()
  ## on.exit(options(op))
  shinyApp(ui = ui, server = server, options = list(launch.browser = TRUE))
}

