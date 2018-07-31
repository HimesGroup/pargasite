#' Get pollution estimate for a given month
#'
#' Get estimate of a given pollutant for a given month ("01-2005" - "12-2017"). Derived from daily EPA files.
#'
#' @param long numeric longitude value
#' @param lat numeric latitude value
#' @param pollutant string, one of "PM2.5", "Ozone", "NO2", "SO2" or "CO". Default set to "PM2.5"
#' @param monthyear string represented as "month-year". Example: "12-2015".
#' @examples
#' getMonthPollutionEstimate(-75.162, 39.9526, "PM2.5", "12-2015")

getMonthPollutionEstimate <- function(long, lat, pollutant = "PM2.5", monthyear) {

  pollutant_brick <- switch(pollutant,
                             "PM2.5" = pm_monthly_brick,
                             "Ozone" = ozone_monthly_brick,
                             "NO2" = no2_monthly_brick,
                             "SO2" = so2_monthly_brick,
                             "CO" = co_monthly_brick)

  month_year <- as.numeric(strsplit(monthyear, "-")[[1]])
  ind <- 12*(month_year[2]-2005) + month_year[1]

  extract(pollutant_brick[[ind]], cbind(long,lat))

}
