#' Get census tract level pollutant values for a year
#'
#' Given a year and type of pollutant, the function will return the corresponding mean pollutant values for each census tract.
#'
#' @param year numeric represented as yyyy. Earliest available year: "1997".
#' @param pollutant string, can be one of "PM2.5", "Ozone", "NO2", "SO2" or "CO". Default set to "PM2.5"
#' @param tracts_shp dataframe extracted from tigris library that contains the tract names and geometry of all census tracts (tracts(state = NULL, county = NULL, cb = TRUE, year = NULL))
#' @export

#tracts_shp <- tracts(state = NULL, county = NULL, cb = TRUE, year = NULL)
getTractLevelPollutantValue <- function(year, pollutant = "PM2.5", tracts_shp) {
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

  tracts_shp_sp <- sf::as_Spatial(tracts_shp$geometry)
  CRS.new <- sp::CRS("+proj=longlat +datum=WGS84")
  pointsSP <- sp::spTransform(pointsSP, CRS.new)
  tracts_shp_sp <- sp::spTransform(tracts_shp_sp, CRS.new)
  indices2 <- sp::over(pointsSP, tracts_shp_sp)

  poly_tract <- sapply(tracts_shp_sp@polygons, function(x) x@labpt)
  poly_tract_df <- t(poly_tract)
  poly_tract_df <- as.data.frame(poly_tract_df)
  poly_tract_df$GEOID<- tracts_shp$GEOID
  tracts_final <- poly_tract_df$GEOID[indices2]

  final_df_tract <- data.frame(GEOID = tracts_final, Value = Pollutant_df$Pollutant_Value)
  final_df_tract <- na.omit(final_df_tract)
  final_df_tract <- dplyr::group_by(final_df_tract, GEOID)
  final_df_tract <- dplyr::summarise(final_df_tract, Mean = mean(Value), Median = median(Value), SD = sd(Value))
  tracts_df <- data.frame(GEOID = tracts_shp$GEOID, Tracts = tracts_shp$NAMELSAD)
  final_df_tract <- merge(tracts_df, final_df_tract, by = "GEOID")

  return(final_df_tract)

}
