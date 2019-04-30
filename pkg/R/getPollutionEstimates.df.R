#' Get pollution estimates for dataset
#'
#' Given a dataset with Longitude and Latitude columns (case sensitive), will return dataset with columns for each pollutant corresponding to the average of monthly estimates spanning requested time period. Monthly estimates derived from daily EPA files.
#'
#' @param data dataframe with numeric Longitude and Latitude columns
#' @param monthyear_start string represented as "mm-yyyy". Earliest available month-year: "01-2005".
#' @param monthyear_end string represented as "mm-yyyy". Latest available month-year: "12-2017".
#' @examples
#' Longitude <- c(-75.133346, -96.27017, -80.448374)
#' Latitude <- c(40.009376, 29.891901, 26.649124)
#' dat <- data.frame(Longitude, Latitude)
#' getPollutionEstimates.df(dat, "01-2005", "12-2006")
#' @export

getPollutionEstimates.df <- function(data, monthyear_start,
                                      monthyear_end) {

  month_year_start <- as.numeric(strsplit(monthyear_start, "-")[[1]])
  ind_start <- 12*(month_year_start[2]-2005) + month_year_start[1]

  month_year_end <- as.numeric(strsplit(monthyear_end, "-")[[1]])
  ind_end <- 12*(month_year_end[2]-2005) + month_year_end[1]

  pollutant_bricks <- list(download(pm_monthly_brick), download(ozone_monthly_brick),
                           download(no2_monthly_brick), download(so2_monthly_brick), download(co_monthly_brick))

  pollutant_bricks_pr <- list(download(pr_pm_monthly_brick), download(pr_ozone_monthly_brick),
                           download(pr_no2_monthly_brick), download(pr_so2_monthly_brick), download(pr_co_monthly_brick))

  dat <- filter(data, Latitude > 20)
  dat_pr <- filter(data, Latitude < 20)

  subset_bricks <- lapply(pollutant_bricks, function(pollutant_brick){
    return(raster::subset(pollutant_brick, c(ind_start:ind_end))) })

  subset_bricks_pr <- lapply(pollutant_bricks_pr, function(pollutant_brick_pr){
    return(raster::subset(pollutant_brick_pr, c(ind_start:ind_end))) })

  dat$pm_estimate <- rowMeans(raster::extract(subset_bricks[[1]], cbind(dat$Longitude, dat$Latitude)))
  dat$ozone_estimate <- rowMeans(raster::extract(subset_bricks[[2]], cbind(dat$Longitude, dat$Latitude)))
  dat$no2_estimate <- rowMeans(raster::extract(subset_bricks[[3]], cbind(dat$Longitude, dat$Latitude)))
  dat$so2_estimate <- rowMeans(raster::extract(subset_bricks[[4]], cbind(dat$Longitude, dat$Latitude)))
  dat$co_estimate <- rowMeans(raster::extract(subset_bricks[[5]], cbind(dat$Longitude, dat$Latitude)))

  dat_pr$pm_estimate <- rowMeans(raster::extract(subset_bricks_pr[[1]], cbind(dat_pr$Longitude, dat_pr$Latitude)), na.rm = TRUE)
  dat_pr$ozone_estimate <- rowMeans(raster::extract(subset_bricks_pr[[2]], cbind(dat_pr$Longitude, dat_pr$Latitude)), na.rm = TRUE)
  dat_pr$no2_estimate <- rowMeans(raster::extract(subset_bricks_pr[[3]], cbind(dat_pr$Longitude, dat_pr$Latitude)), na.rm = TRUE)
  dat_pr$so2_estimate <- rowMeans(raster::extract(subset_bricks_pr[[4]], cbind(dat_pr$Longitude, dat_pr$Latitude)), na.rm = TRUE)
  dat_pr$co_estimate <- rowMeans(raster::extract(subset_bricks_pr[[5]], cbind(dat_pr$Longitude, dat_pr$Latitude)), na.rm = TRUE)

  toReturn <- rbind(dat, dat_pr)
  return(toReturn)
}
