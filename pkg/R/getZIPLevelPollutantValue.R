#' Get zipcode level pollutant values for a year
#'
#' Given a year and type of pollutant, the function will return the corresponding mean pollutant values for each zipcode.
#'
#' @param year numeric represented as yyyy. Earliest available year: "1997".
#' @param pollutant string, can be one of "PM2.5", "Ozone", "NO2", "SO2" or "CO". Default set to "PM2.5"
#' @param tracts_shp dataframe extracted from tigris library that contains the tract names and geometry of all census tracts (tracts(state = NULL, county = NULL, cb = TRUE, year = NULL))
#' @export

#zipcode_master <- zctas(cb = FALSE, starts_with = NULL, year = NULL, state = NULL)
getZIPLevelPollutantValue <- function(year, pollutant = "PM2.5", zipcode_master) {
  Raster_PR_Full <- switch(pollutant,
                           "PM2.5" = download(pr_pm_annual_brick),
                           "Ozone" = download(pr_ozone_annual_brick),
                           "NO2" = download(pr_no2_annual_brick),
                           "SO2" = download(pr_so2_annual_brick),
                           "CO" = download(pr_co_annual_brick))
  Raster_US_Full <- switch(pollutant,
                           "PM2.5" = download(pm_yearly_brick_full),
                           "Ozone" = download(ozone_yearly_brick_full),
                           "NO2" = download(no2_yearly_brick_full),
                           "SO2" = download(so2_yearly_brick_full),
                           "CO" = download(co_yearly_brick_full))
  ind <- as.numeric(year)-1996
  Raster_PR_Year <- Raster_PR_Full[[ind]]
  Raster_US_Year <- Raster_US_Full[[ind]]

  spts_PR <- raster::rasterToPoints(Raster_PR_Year, spatial = TRUE)
  llprj <-  "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"
  llpts_PR <- sp::spTransform(spts_PR, sp::CRS(llprj))
  x_1 <- as.data.frame(llpts_PR)
  colnames(x_1) <- c("Pollutant_Value", "Longitude", "Latitude")
  spts_US <- raster::rasterToPoints(Raster_US_Year, spatial = TRUE)
  llpts_US <- sp::spTransform(spts_US, sp::CRS(llprj))
  x_2 <- as.data.frame(llpts_US)
  colnames(x_2) <- c("Pollutant_Value", "Longitude", "Latitude")
  Pollutant_df <- rbind(x_1,x_2)
  lat_long <- data.frame(Pollutant_df$Longitude, Pollutant_df$Latitude)
  pointsSP <- sp::SpatialPoints(lat_long,
                            proj4string=CRS("+proj=longlat +datum=WGS84"))

  shp_sp <- sf::as_Spatial(zipcode_master$geometry)
  CRS.new <- sp::CRS("+proj=longlat +datum=WGS84")
  sp::proj4string(pointsSP) <- CRS.new
  sp::proj4string(shp_sp) <- CRS.new
  indices2 <- sp::over(pointsSP, shp_sp)

  poly_zip <- sapply(shp_sp@polygons, function(x) x@labpt)
  poly_zip_df <- t(poly_zip)
  poly_zip_df <- as.data.frame(poly_zip_df)
  poly_zip_df$ZIP <- zipcode_master$ZCTA5CE20
  zipcode_final <- poly_zip_df$ZIP[indices2]

  final_df <- data.frame(ZIPCODE = zipcode_final, Value = Pollutant_df$Pollutant_Value)
  final_df <- na.omit(final_df)
  final_df <- dplyr::group_by(final_df, ZIPCODE)
  final_df <- dplyr::summarise(final_df, Mean = mean(Value), Median = median(Value), SD = sd(Value))

  return(final_df)

}
