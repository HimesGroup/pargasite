#' Get pollution estimates for dataset
#'
#' Given a dataset with Longitude and Latitude columns, will return dataset with columns for each pollutant corresponding to the average of monthly estimates spanning requested time period. Monthly estimates derived from daily EPA files.
#'
#' @param data dataframe with numeric Longitude and Latitude columns
#' @param monthyear_start string represented as "month-year". Earliest available month-year: "01-2005".
#' @param monthyear_end string represented as "month-year". Latest available month-year: "12-2017".
#' @examples
#' Longitude <- c(-75.133346, -96.27017, -80.448374)
#' Latitude <- c(40.009376, 29.891901, 26.649124)
#' dat <- data.frame(Longitude, Latitude)
#' getPollutionEstimates.df(dat, "01-2005", "12-2017")
#' @importFrom magrittr %>%
#' @export

getPollutionEstimates.df <- function(data, monthyear_start,
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
