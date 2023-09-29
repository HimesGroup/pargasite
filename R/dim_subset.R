.subset_stars <- function(x, i = TRUE, dim = dimnames(x),
                          value = stars::st_get_dimension_values(x, dim),
                          drop = FALSE) {
  if (!inherits(x, "stars")) {
    stop("'x' must be a stars object.")
  }
  ## Would not allow to select a dimension by numeric index
  dim <- match.arg(dim)
  ## Would not allow to subset by numeric indices
  value <- match.arg(value)
  ## Create missing arguments to generate a function call
  ## Check rlang::missing_arg example
  nms <- dimnames(x)
  args <- rep(list(rlang::missing_arg()), length(nms))
  args[[which(dim == nms)]] <- value
  ## !!! to unquote many arguments
  rlang::eval_tidy(rlang::call2(`[`, rlang::expr(x), i = i, !!!args, drop = drop))
}

dimsub <- function(x, dim, value, drop = FALSE) {
  .subset_stars(x = x, i = TRUE, dim = dim, value = value, drop = drop)
}
