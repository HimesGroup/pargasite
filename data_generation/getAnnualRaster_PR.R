#Annual rasters for USA + Puerto Rico at resolution 1x1km

# data from https://aqs.epa.gov/aqsweb/airdata/download_files.html (annual summary files)

pm_params <- c("PM2.5 - Local Conditions", "PM25 24-hour 2012")
ozone_params <- c("Ozone", "Ozone 8-hour 2015")
no2_params <- c("Nitrogen dioxide (NO2)", "NO2 1-hour 2010") #modifying the second parameter to "NO2 1-hour 2010" for 2020 and 2021 data. For previous years, it is "NO2 1-hour"
so2_params <- c("Sulfur dioxide", "SO2 1-hour 2010")
co_params <- c("Carbon monoxide", "CO 1-hour 1971")

#dat_2020 <- read.csv("/Users/nishanarayanan/Documents/PARGASITE/annual_conc_by_monitor_2020.csv", header=T, sep=",")
#dat_2021 <- read.csv("/Users/nishanarayanan/Documents/PARGASITE/annual_conc_by_monitor_2021.csv", header=T, sep=",")

getRaster <- function(data, par_name, poll_standard){
  
  ## filter data to contiguous US 
  ## get one row per location by averaging all entries
  pollutant <- filter(data, 
                      Parameter.Name == par_name,  
                      Pollutant.Standard == poll_standard,
                      #Longitude > -124, Longitude < -66,
                      #Latitude > 24, Latitude < 50) %>%
                      Longitude > -124, Longitude <= -65,
                      Latitude > 17.9, Latitude < 50) %>%
    filter(!is.na(Arithmetic.Mean), Arithmetic.Mean > 0) %>%
    group_by(Latitude, Longitude, Datum) %>%
    summarise(avg = mean(Arithmetic.Mean, na.rm = TRUE)) 
  
  ## get all in same Datum
  nad83 <- filter(pollutant, Datum == "NAD83")
  wgs <- filter(pollutant, Datum == "WGS84")
  xy.nad83 <- nad83[,c(1,2)]
  xy.wgs <- wgs[,c(1,2)]
  spdf.nad83 <- SpatialPointsDataFrame(coords = xy.nad83,
                                       data = nad83,
                                       proj4string = CRS("+proj=longlat +datum=NAD83"))
  spdf.nadtoWGS <- spTransform(spdf.nad83, CRS("+proj=longlat +datum=WGS84"))
  spdf.wgs <- SpatialPointsDataFrame(coords = xy.wgs,
                                     data = wgs,
                                     proj4string = CRS("+proj=longlat +datum=WGS84"))
  all.fixed <- spRbind(spdf.wgs, spdf.nadtoWGS)
  dat <- all.fixed@data
  coordinates(dat) = ~Longitude+Latitude
  crs(dat) <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  
  ## make base raster
  #find distance between the latitude and longitudes and convert to km (*111)
  #r <- raster(nrow = 269, ncol = 640, extent(-124.6813, -67.00742,25.12993,49.38323))
  r <- raster(nrow = 74, ncol = 192, extent(-67.32771, -65.57436, 17.8965,18.57787)) 
  crs(r) <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  
  ## generate raster (idw with 5 nearest sites)
  gs <- gstat(formula=avg~1, data=dat, nmax = 5)
  nn <- interpolate(r, gs)
  
  return(nn)
  
}
