.onLoad <- function(libname, pkgname) {
  op <- options()
  tmp <- tempdir()
  op.pargasite <- list(
    pargasite.dat = NULL,
    pargasite.summary_state = NULL,
    pargasite_summary_county = NULL,
    pargasite.summary_cbsa = NULL,
    pargasite.shape_dir = file.path(tmp, "pargasite_shape_dir")
  )
  toset <- names(op.pargasite) %ni% names(op)
  if (any(toset)) options(op.pargasite[toset])
  shiny::addResourcePath(
           prefix = "www", # custom prefix that will be used to reference your directory
           directoryPath = system.file("www", package = "pargasite")
         )# path to resource in your package
  invisible()
}
