#Cropped
library(raster)
library(rgdal)

us <- readOGR("tl_2017_us_state/tl_2017_us_state.shp")
us <- spTransform(x = us, CRSobj = '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
pr <- readOGR("../PR_shapefile/PRI_adm0.shp")
pr <- spTransform(x = pr, CRSobj = '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')

#for US+PR (1X1 rasters)
full_shp <- union(us, pr) #use for us+pr only (1x1 km rasters)
#for US (10X10 rasters)
full_shp <- us #use for us only (10x10km)

dirs = paste0("folder location",list.files("folder location")) #change the folder location

for (i in dirs){
  file = gsub(".tif","cropped.tif",i)
  ras <- brick(i)
  c <- crop(ras, extent(full_shp))
  m <- mask(c, full_shp) 
  plot(m)
  writeRaster(m,file)
}


