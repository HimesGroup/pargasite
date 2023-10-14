summarize_by_boundaries <- function(x , level = c("state", "county", "cbsa")) {
  if (!inherits(x, "stars")) {
    stop("'x' must be a stars object.")
  }
  level <- match.arg(level)
  x_bbox <- st_bbox(st_transform(x, 4269))
  x_wkt_filter <- st_as_text(st_as_sfc(x_bbox))
  us_map <- st_transform(
    get_tl_shape(.get_carto_url(level), wkt_filter = x_wkt_filter),
    st_crs(x)
  )
  aggregate(x, by = us_map, FUN = function(x) mean(x, na.rm = TRUE))
}
