library(sp)
library(rgdal)
library(maptools)
library(maps)
library(dplyr)
library(raster)
library(gstat)

# data from https://aqs.epa.gov/aqsweb/airdata/download_files.html (daily summary files)

# poll_standard <-
## PM2.5: c("PM25 24-hour 2006", "PM25 24-hour 2012")
## Ozone: c("Ozone 8-Hour 2008", "Ozone 8-hour 2015")
## NO2: c("NO2 1-hour")
## SO2: c("SO2 1-hour 2010")
## CO: c("CO 1-hour 1971")

fixData <- function(data, poll_standard){
  
  ## filter data to contiguous US 
  ## get one row per location by averaging all entries
  data$date <- as.Date(as.character(data$Date.Local))
  data$month <- as.numeric(format(data$date, "%m"))
  pollutant <- filter(data,
                      Longitude > -124, Longitude < -66,
                      Latitude > 24, Latitude < 50,
                      Pollutant.Standard %in% poll_standard) %>%
    filter(!is.na(Arithmetic.Mean), Arithmetic.Mean > 0) %>%
    group_by(Latitude, Longitude, month, Datum) %>%
    summarise(avg = mean(Arithmetic.Mean, na.rm = TRUE))
  
  # get all data into same Datum
  nad83 <- filter(pollutant, Datum == "NAD83")
  nad27 <- filter(pollutant, Datum == "NAD27")
  wgs <- filter(pollutant, Datum == "WGS84")
  xy.nad83 <- nad83[,c(1,2)]
  xy.nad27 <- nad27[,c(1,2)]
  xy.wgs <- wgs[,c(1,2)]
  spdf.nad83 <- SpatialPointsDataFrame(coords = xy.nad83,
                                       data = nad83,
                                       proj4string = CRS("+proj=longlat +datum=NAD83"))
  spdf.nad83toWGS <- spTransform(spdf.nad83, CRS("+proj=longlat +datum=WGS84"))
  if(dim(xy.nad27)[1] > 1){
    spdf.nad27 <- SpatialPointsDataFrame(coords = xy.nad27,
                                         data = nad27,
                                         proj4string = CRS("+proj=longlat +datum=NAD27"))
    spdf.nad27toWGS <- spTransform(spdf.nad27, CRS("+proj=longlat +datum=WGS84"))
  }
  spdf.wgs <- SpatialPointsDataFrame(coords = xy.wgs,
                                     data = wgs,
                                     proj4string = CRS("+proj=longlat +datum=WGS84"))
  all.fixed <- spRbind(spdf.wgs, spdf.nad83toWGS)
  if(dim(xy.nad27)[1] > 1){
    all.fixed <- spRbind(all.fixed, spdf.nad27toWGS)
  }
  dat <- all.fixed@data
  
  return(dat)
}

# feed fixed data into getMonthRaster >>

getMonthRaster <- function(data, m){
  
  dat <- filter(data, month == m)
  coordinates(dat) = ~Longitude+Latitude
  crs(dat) <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  
  ## make base raster
  r <- raster(nrow = 269, ncol = 640, extent(-124.6813, -67.00742, 25.12993, 49.38323))
  crs(r) <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  
  ## generate raster (idw with 5 nearest sites)
  gs <- gstat(formula=avg~1, data=dat, nmax = 5)
  nn <- interpolate(r, gs)
  
  return(nn)
  
}