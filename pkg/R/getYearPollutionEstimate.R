#' Get pollution estimate for a given year
#'
#' Get estimate of a given pollutant for a given year (2005 to 2017). Derived from annual EPA files.
#'
#' @param long numeric longitude value
#' @param lat numeric latitude value
#' @param pollutant string, one of "PM2.5", "Ozone", "NO2", "SO2" or "CO". Default set to "PM2.5"
#' @param year string represented as "year." Example: "2015".
#' @examples
#' getYearPollutionEstimate(-75.162, 39.9526, "PM2.5", "2015")
#' @export

getYearPollutionEstimate <- function(long, lat, pollutant = "PM2.5", year){

  pollutant_number <- switch(pollutant,
                             "PM2.5" = 1,
                             "Ozone" = 2,
                             "NO2" = 3,
                             "SO2" = 4,
                             "CO" = 5)

  raster::extract(bricks.years[[year]][[pollutant_number]], cbind(long, lat))

}

