run_pargasite <- function(x, summarize_by = c("state", "county", "cbsa")) {
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
    summary_state <- aggregate(x, by = tl_state, FUN = function(x) mean(x, na.rm = TRUE))
    options(pargasite.summary_state = summary_state,
            pargasite.map_state = tl_state)
  }
  if ("county" %in% summarize_by) {
    message("[Generating county-level summary...]")
    tl_county <- st_transform(
      get_tl_shape(url = .get_carto_url("county"), wkt_filter = x_wkt_filter),
      st_crs(x)
    )
    summary_county <- aggregate(x, by = tl_county, FUN = function(x) mean(x, na.rm = TRUE))
    options(pargasite.summary_county = summary_county,
            pargasite.map_county = tl_county)
  }
  if ("cbsa" %in% summarize_by) {
    message("[Generating CBSA-level summary...]")
    tl_cbsa <- st_transform(
      get_tl_shape(url = .get_carto_url("cbsa"), wkt_filter = x_wkt_filter),
      st_crs(x)
    )
    summary_cbsa <- aggregate(x, by = tl_cbsa, FUN = function(x) mean(x, na.rm = TRUE))
    options(pargasite.summary_cbsa = summary_cbsa,
            pargasite.map_cbsa = tl_cbsa)
  }
  shinyApp(ui = ui, server = server, options = list(launch.browser = TRUE))
}

