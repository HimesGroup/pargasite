getPollutionEstimates.df.app <- function(data, monthyear_start,
                                     monthyear_end) {
  
  month_year_start <- as.numeric(strsplit(monthyear_start, "-")[[1]])
  ind_start <- 12*(month_year_start[2]-2005) + month_year_start[1]
  
  month_year_end <- as.numeric(strsplit(monthyear_end, "-")[[1]])
  ind_end <- 12*(month_year_end[2]-2005) + month_year_end[1]
  
  pollutant_bricks <- list(pm_monthly_brick, ozone_monthly_brick,
                           no2_monthly_brick, so2_monthly_brick, co_monthly_brick)
  
  subset_bricks <- lapply(pollutant_bricks, function(pollutant_brick){
    return(raster::subset(pollutant_brick, c(ind_start:ind_end))) })
  
  df <- data %>% dplyr::rowwise() %>% dplyr::mutate(
    pm_estimate = mean(raster::extract(subset_bricks[[1]], cbind(Longitude, Latitude))),
    ozone_estimate = mean(raster::extract(subset_bricks[[2]], cbind(Longitude, Latitude))),
    no2_estimate = mean(raster::extract(subset_bricks[[3]], cbind(Longitude, Latitude))),
    so2_estimate = mean(raster::extract(subset_bricks[[4]], cbind(Longitude, Latitude))),
    co_estimate = mean(raster::extract(subset_bricks[[5]], cbind(Longitude, Latitude))))
  
  return(df)
}
