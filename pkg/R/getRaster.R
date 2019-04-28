#' Get raster layer for a given year or month-year
#'
#' Get pre-generated raster layer for a given pollutant for a month or year in 2005 to 2017. 
#'
#' @param pollutant string, one of "PM2.5", "Ozone", "NO2", "SO2", "CO"
#' @param  month_or_year string represented as "mm-yyyy" or "yyyy". Ex: "02-2012" or "2012".
#' @examples
#' getYearPollutionEstimate("PM2.5", "02-2012")
#' @export

getRaster <- function(pollutant, month_or_year){
  
  if(nchar(month_or_year) == 4){
    
    poll_brick <- switch(pollutant,
                         "PM2.5" = download(pm_yearly_brick_full),
                         "Ozone" = download(ozone_yearly_brick_full),
                         "NO2" = download(no2_yearly_brick_full),
                         "SO2" = download(so2_yearly_brick_full),
                         "CO" = download(co_yearly_brick_full)
    )
    ind <- as.numeric(month_or_year)-2004
    
    r <- poll_brick[[ind]]
    return(r)
  }
  
  else if(nchar(month_or_year) %in% c(6,7)){
    
    poll_brick <- switch(pollutant,
                              "PM2.5" = download(pm_monthly_brick),
                              "Ozone" = download(ozone_monthly_brick),
                              "NO2" = download(no2_monthly_brick),
                              "SO2" = download(so2_monthly_brick),
                              "CO" = download(co_monthly_brick))
    
    month_year <- as.numeric(strsplit(month_or_year, "-")[[1]])
    ind <- 12*(month_year[2]-2005) + month_year[1]
    
    r <- poll_brick[[ind]]
    return(r)
    
  }
  
}