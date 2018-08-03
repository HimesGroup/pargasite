#' Get pollution estimate over time period
#'
#' Get estimate of a given pollutant for a given time period as defined by
#' month-year to month-year. The result can be an average over the time period or an array with
#' values corresponding to each month. Derived from daily EPA files.
#'
#' @param long numeric longitude value
#' @param lat numeric latitude value
#' @param pollutant string, one of "PM2.5", "Ozone", "NO2", "SO2" or "CO". Default set to "PM2.5"
#' @param monthyear_start string represented as "month-year." Earliest available month-year: "01-2005".
#' @param monthyear_end string represented as "month-year." Latest available month-year: "12-2017".
#' @param result string, one of "mean" or "array." Mean will return the average of the monthly estimates over the time
#' period, array will return a vector where each value corresponds to each month over the time period
#' @examples
#' getRangePollutionEstimate(-75.162, 39.9526, "PM2.5", "01-2005", "12-2017")
#' @export

getRangePollutionEstimate <- function(long, lat, pollutant = "PM2.5", monthyear_start,
                                      monthyear_end, result = "mean") {

  pollutant_brick <- switch(pollutant,
                            "PM2.5" = download(pm_monthly_brick),
                            "Ozone" = download(ozone_monthly_brick),
                            "NO2" = download(no2_monthly_brick),
                            "SO2" = download(so2_monthly_brick),
                            "CO" = download(co_monthly_brick))

  month_year_start <- as.numeric(strsplit(monthyear_start, "-")[[1]])
  ind_start <- 12*(month_year_start[2]-2005) + month_year_start[1]

  month_year_end <- as.numeric(strsplit(monthyear_end, "-")[[1]])
  ind_end <- 12*(month_year_end[2]-2005) + month_year_end[1]

  brick_sub <- raster::subset(pollutant_brick, c(ind_start:ind_end))
  ests <- raster::extract(brick_sub, cbind(long,lat))
  if(result == "mean"){
    return(mean(ests))
  }
  else if(result == "array"){
    return(ests)
  }

}




