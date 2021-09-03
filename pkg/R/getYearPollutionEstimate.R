#' Get pollution estimate for a given year
#'
#' Get estimate of a given pollutant for a given year (1997 to 2019). Derived from annual EPA files.
#'
#' @param long numeric longitude value
#' @param lat numeric latitude value
#' @param pollutant string, one of "PM2.5", "Ozone", "NO2", "SO2" or "CO". Default set to "PM2.5"
#' @param year string represented as "yyyy." Example: "2015".
#' @examples
#' getYearPollutionEstimate(-75.162, 39.9526, "PM2.5", "2015")
#' @export

getYearPollutionEstimate <- function(long, lat, pollutant = "PM2.5", year){

  if(lat < 20){
    pollutant_brick <- switch(pollutant,
                              "PM2.5" = download(pr_pm_annual_brick),
                              "Ozone" = download(pr_ozone_annual_brick),
                              "NO2" = download(pr_no2_annual_brick),
                              "SO2" = download(pr_so2_annual_brick),
                              "CO" = download(pr_co_annual_brick))
  } else {
  pollutant_brick <- switch(pollutant,
                            "PM2.5" = download(pm_yearly_brick_full),
                            "Ozone" = download(ozone_yearly_brick_full),
                            "NO2" = download(no2_yearly_brick_full),
                            "SO2" = download(so2_yearly_brick_full),
                            "CO" = download(co_yearly_brick_full))
  }

  raster::extract(pollutant_brick[[(as.numeric(year)-1996)]], cbind(long, lat))

}

