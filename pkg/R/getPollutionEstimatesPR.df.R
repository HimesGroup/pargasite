#' Get pollution estimates for dataset
#'
#' Given a dataset with Longitude and Latitude columns, will return dataset with columns for each pollutant corresponding to the average of monthly estimates spanning requested time period. Monthly estimates derived from daily EPA files.
#' Only for data within Puerto Rico.
#'
#' @param data dataframe with numeric Longitude and Latitude columns
#' @param monthyear_start string represented as "mm-yyyy". Earliest available month-year: "01-2005".
#' @param monthyear_end string represented as "mm-yyyy". Latest available month-year: "12-2017".
#' @examples
#' Longitude <- c(-66.8, -66.5, -66.1)
#' Latitude <- c(18.4, 18.4, 18.3)
#' dat <- data.frame(Longitude, Latitude)
#' getPollutionEstimates.df(dat, "01-2005", "12-2006")
#' @export

getPollutionEstimatesPR.df <- function(data, monthyear_start,
                                     monthyear_end) {

  month_year_start <- as.numeric(strsplit(monthyear_start, "-")[[1]])
  ind_start <- 12*(month_year_start[2]-2005) + month_year_start[1]

  month_year_end <- as.numeric(strsplit(monthyear_end, "-")[[1]])
  ind_end <- 12*(month_year_end[2]-2005) + month_year_end[1]

  pollutant_bricks <- list(download(pr_pm_monthly_brick), download(pr_ozone_monthly_brick),
                           download(pr_no2_monthly_brick), download(pr_so2_monthly_brick), download(pr_co_monthly_brick))

  subset_bricks <- lapply(pollutant_bricks, function(pollutant_brick){
    return(raster::subset(pollutant_brick, c(ind_start:ind_end))) })

  data$pm_estimate <- rowMeans(raster::extract(subset_bricks[[1]], cbind(data$Longitude, data$Latitude)))
  data$ozone_estimate <- rowMeans(raster::extract(subset_bricks[[2]], cbind(data$Longitude, data$Latitude)))
  data$no2_estimate <- rowMeans(raster::extract(subset_bricks[[3]], cbind(data$Longitude, data$Latitude)))
  data$so2_estimate <- rowMeans(raster::extract(subset_bricks[[4]], cbind(data$Longitude, data$Latitude)))
  data$co_estimate <- rowMeans(raster::extract(subset_bricks[[5]], cbind(data$Longitude, data$Latitude)))

  return(data)
}
