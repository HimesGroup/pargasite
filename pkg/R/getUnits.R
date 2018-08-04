#' Get standard and units of measurement for pollution variables
#' @export

getUnits <- function(){
  
  units <- list("Mean PM2.5 24-hour average (2012 standard); Units = Micrograms/cubic meter",
                "Mean Ozone 8-hour average (2015 standard); Units = Parts per million",
                "Mean nitrogen dioxide (NO2) 1-hour average; Units = Parts per billion",
                "Mean sulfur dioxide (SO2) 1-hour average (2010 standard); Units = Parts per billion",
                "Mean carbon monoxide (CO) 1-hour average (1971 standard); Units = Parts per million")

  names(units) <- c("PM2.5", "Ozone", "NO2", "SO2", "CO")
  
  return(units)
  
}

