#' Get census MMSA level pollutant values for a year
#'
#' Given a year and type of pollutant, the function will return the corresponding mean pollutant values for each MMSA.
#'
#' @param year numeric represented as yyyy. Earliest available year: "1997".
#' @param pollutant string, can be one of "PM2.5", "Ozone", "NO2", "SO2" or "CO". Default set to "PM2.5"
#' @param mmsa_shp dataframe extracted from tigris library that contains the tract names and geometry of all census tracts (tracts(state = NULL, county = NULL, cb = TRUE, year = NULL))
#' @export

#mmsa_shp <- core_based_statistical_areas(cb = FALSE, resolution = "500k", year = NULL)
getMMSALevelPollutantValue <- function(year, pollutant = "PM2.5", mmsa_shp) {
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
                                proj4string=sp::CRS("+proj=longlat +datum=WGS84"))

  mmsa_shp_sp <- sf::as_Spatial(mmsa_shp$geometry)
  CRS.new <- sp::CRS("+proj=longlat +datum=WGS84")
  sp::proj4string(pointsSP) <- CRS.new
  sp::proj4string(mmsa_shp_sp) <- CRS.new
  indices2 <- sp::over(pointsSP, mmsa_shp_sp)

  poly_mmsa <- sapply(mmsa_shp_sp@polygons, function(x) x@labpt)
  poly_mmsa_df <- t(poly_mmsa)
  poly_mmsa_df <- as.data.frame(poly_mmsa_df)
  poly_mmsa_df$GEOID <- mmsa_shp$GEOID
  mmsa_final <- poly_mmsa_df$GEOID[indices2]

  final_df_mmsa <- data.frame(GEOID = mmsa_final, Value = Pollutant_df$Pollutant_Value)
  final_df_mmsa <- na.omit(final_df_mmsa)
  final_df_mmsa <- dplyr::group_by(final_df_mmsa, GEOID)
  final_df_mmsa <- dplyr::summarise(final_df_mmsa, Mean = mean(Value), Median = median(Value), SD = sd(Value))
  mmsa_df <- data.frame(GEOID = mmsa_shp$GEOID, MMSA = mmsa_shp$NAME)
  final_df_mmsa <- merge(final_df_mmsa, mmsa_df, by = "GEOID")

  return(final_df_mmsa)

}
