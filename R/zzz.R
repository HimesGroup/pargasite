.onLoad <- function(libname, pkgname) {
  op <- options()
  tmp <- tempdir()
  op.pargasite <- list(
    pargasite.dat = NULL,
    pargasite.summary_state = NULL,
    pargasite_summary_county = NULL,
    pargasite.summary_cbsa = NULL,
    pargasite.map_state = NULL,
    pargasite_map_county = NULL,
    pargasite.map_cbsa = NULL,
    pargasite.shape_dir = file.path(tmp, "pargasite_shape_dir")
  )
  toset <- names(op.pargasite) %ni% names(op)
  if (any(toset)) options(op.pargasite[toset])
  invisible()
}
