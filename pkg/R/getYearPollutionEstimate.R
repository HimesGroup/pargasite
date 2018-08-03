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

  pollutant_brick <- switch(pollutant,
                            "PM2.5" = download(pm_yearly_brick_full),
                            "Ozone" = download(ozone_yearly_brick_full),
                            "NO2" = download(no2_yearly_brick_full),
                            "SO2" = download(so2_yearly_brick_full),
                            "CO" = download(co_yearly_brick_full))

  raster::extract(pollutant_brick[[(as.numeric(year)-2004)]], cbind(long, lat))

}

