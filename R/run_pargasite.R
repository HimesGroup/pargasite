##' Run PARGASITE application
##'
##' Launch a Shiny application to visualize pollutant levels of the conterminous
##' US. The system's default web browser will be launched automatically after
##' the app is started.
##'
##' @param x A stars object created by [create_pargasite_data].
##' @param summarize_by A vector of strings specifying geographic boundaries to
##'   compute areal means.
##' @param summary_state A stars object created by [summarize_by_boundaries].
##'   Ignored if 'state' is not specified in `summarize_by`. While the function
##'   computes areal summary if the argument is `NULL`, it may be useful if the
##'   app is to be called multiple times to save processing time.
##' @param summary_county A stars object created by [summarize_by_boundaries].
##'   Ignored if 'county' is not specified in `summarize_by`.
##' @param summary_cbsa A stars object created by [summarize_by_boundaries].
##'   Ignored if 'cbsa' is not specified in `summarize_by`.
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
run_pargasite <- function(x, summarize_by = c("state", "county", "cbsa"),
                          summary_state = NULL, summary_county = NULL,
                          summary_cbsa = NULL) {
  ## Reset pargasite options first
  options(pargasite.dat = NULL, pargasite.summary_state = NULL,
          pargasite.summary_county = NULL, pargasite.summary_cbsa = NULL,
          pargasite.map_state = NULL, pargasite.map_county = NULL,
          pargasite.map_cbsa = NULL)
  ## Verify inputs
  if (!inherits(x, "stars")) {
    stop("'x' must be a stars object.")
  }
  if ("year" %ni% dimnames(x)) {
    stop("'x' must have 'year' dimension")
  }
  if (!is.null(summarize_by)) {
    summarize_by <- match.arg(summarize_by, several.ok = TRUE)
    x_bbox <- st_bbox(st_transform(x, 4269))
    x_wkt_filter <- st_as_text(st_as_sfc(x_bbox))
  }
  ## Not working
  ## op <- options()
  ## on.exit(options(op))
  options(pargasite.dat = x)
  if ("state" %in% summarize_by) {
    message("[Generating state-level summary...]")
    tl_state <- st_transform(
      get_tl_shape(.get_carto_url("state"), wkt_filter = x_wkt_filter),
      st_crs(x)
    )
    if (is.null(summary_state)) {
      summary_state <- aggregate(x, by = tl_state,
                                 FUN = function(x) mean(x, na.rm = TRUE))
    }
    options(pargasite.summary_state = summary_state,
            pargasite.map_state = tl_state)
  }
  if ("county" %in% summarize_by) {
    message("[Generating county-level summary...]")
    tl_county <- st_transform(
      get_tl_shape(url = .get_carto_url("county"), wkt_filter = x_wkt_filter),
      st_crs(x)
    )
    if (is.null(summary_county)) {
      summary_county <- aggregate(x, by = tl_county,
                                  FUN = function(x) mean(x, na.rm = TRUE))
    }
    options(pargasite.summary_county = summary_county,
            pargasite.map_county = tl_county)
  }
  if ("cbsa" %in% summarize_by) {
    message("[Generating CBSA-level summary...]")
    tl_cbsa <- st_transform(
      get_tl_shape(url = .get_carto_url("cbsa"), wkt_filter = x_wkt_filter),
      st_crs(x)
    )
    if (is.null(summary_cbsa)) {
      summary_cbsa <- aggregate(x, by = tl_cbsa,
                                FUN = function(x) mean(x, na.rm = TRUE))
    }
    options(pargasite.summary_cbsa = summary_cbsa,
            pargasite.map_cbsa = tl_cbsa)
  }
  shinyApp(ui = ui, server = server, options = list(launch.browser = TRUE))
}

