.dimsub <- function(x, i = TRUE, dim = dimnames(x),
                          value = stars::st_get_dimension_values(x, dim),
                          drop = FALSE) {
  if (!inherits(x, "stars")) {
    stop("'x' must be a stars object.")
  }
  ## Would not allow to select a dimension by numeric index
  dim <- match.arg(dim)
  ## Would not allow to subset by numeric indices
  value <- match.arg(value, several.ok = TRUE)
  ## Create missing arguments to generate a function call
  ## Check rlang::missing_arg example
  nms <- dimnames(x)
  args <- rep(list(rlang::missing_arg()), length(nms))
  args[[which(dim == nms)]] <- value
  ## !!! to unquote many arguments
  rlang::eval_tidy(rlang::call2(`[`, rlang::expr(x), i = i, !!!args, drop = drop))
}

.subset_pargasite_data <- function(x, pollutant, data_field, event, year, month) {
  ## translate pollutant name
  pollutant <- .make_names(pollutant)
  x <- x[pollutant]
  ## Drop = TRUE will drop any singular dimension so set drop = FALSE for the next eval
  if (data_field == "arithmetic_mean") {
    x <- .dimsub(x, dim = "data_field", value = "arithmetic_mean", drop = FALSE)
  } else {
    x <- .dimsub(
      x, dim = "data_field",
      ## use setdiff as NAAQS_statistic is updated (e.g. second_max_value)
      value = setdiff(st_get_dimension_values(x, "data_field"), "arithmetic_mean"),
      drop = FALSE
    )
  }
  ## x <- .dimsub(x, dim = "data_field", value = data_field, drop = FALSE)
  x <- .dimsub(x, dim = "event", value = event, drop = FALSE)
  if ("month" %ni% dimnames(x)) {
    x <- .dimsub(x, dim = "year", value = as.character(year), drop = TRUE)
  } else {
    ## let year must be an integer of length 1
    x <- .dimsub(x, dim = "year", value = as.character(year), drop = FALSE)
    if (is.null(month)) {
      x <- .dimsub(x, dim = "month",
                   value = st_get_dimension_values(x, "month")[1],
                   drop = TRUE)
    } else {
      x <- .dimsub(x, dim = "month", value = as.character(month), drop = TRUE)
    }
  }
  x
}

.subset_monitor_data <- function(pollutant, year) {
  idx <- which(.criteria_pollutants$pollutant_standard == pollutant)
  parameter_code <- .criteria_pollutants$parameter_code[idx]
  d <- .monitors[.monitors$year %in% year &
                 .monitors$parameter_code == parameter_code, ]
  d <- lapply(year, function(k) {
    x <- d[d$year == k, ]
    x <- as.data.frame(st_coordinates(x))
    x$year <- k
    x
  })
  do.call(rbind, d)
}
