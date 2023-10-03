## code to prepare `DATASET` dataset goes here
## Last update: 09.14.23

## Criteria Pollutants
.criteria_pollutants <- read.csv(
  "https://aqs.epa.gov/aqsweb/documents/codetables/parameter_classes.csv"
)
.criteria_pollutants <- .criteria_pollutants[
  .criteria_pollutants$Class.Code == "CRITERIA", c("Parameter.Code", "Parameter")
]

.criteria_pollutants <- setNames(
  .criteria_pollutants, .make_names(names(.criteria_pollutants))
)

## Pollutant Standards
.pollutant_standards <- read.csv(
  "https://aqs.epa.gov/aqsweb/documents/codetables/pollutant_standards.csv"
)
.pollutant_standards <- setNames(
  .pollutant_standards, .make_names(names(.pollutant_standards))
  ## .pollutant_standards[, c("Parameter.Code", "Parameter",
  ##                          "Pollutant.Standard.Short.Name")],
  ## c("parameter_code", "parameter", "pollutant_standard")
)
idx <- names(.pollutant_standards) == "pollutant_standard_short_name"
names(.pollutant_standards)[idx] <- "pollutant_standard"

## Merge info
.criteria_pollutants <- merge(.criteria_pollutants, .pollutant_standards)
.criteria_pollutants <- .criteria_pollutants[
  with(.criteria_pollutants, order(parameter_code, parameter, pollutant_standard)),
]

## USA CONUS and Puerto Rico shape files using Natural Earth data:
## Downloads Admin 0 without boundary lakes:
## https://www.naturalearthdata.com/downloads/10m-cultural-vectors/
## Natural Earth is license-free in any manner.
## https://www.naturalearthdata.com/about/terms-of-use/
##
## Alternatively, GADM (level2 and ENGTYPE_2 != "Water body" filters Great
## Lakes). Non-commercial use is free, but redistribution is not allowed.
## https://gadm.org/license.html
library(sf)
library(stars)
ne <- st_read("~/Downloads/ne_10m_admin_0_countries_lakes/ne_10m_admin_0_countries_lakes.shp")
ne_us <- ne[grep("United States of America", ne$ADMIN), ]

conus_filter <- st_bbox(
  c(xmin = -125, xmax = -65, ymin = 20, ymax = 50),
  crs = 4326
)

.us_conus <- st_as_sfc(ne_us) |>
  st_cast("POLYGON")|> # split for cropping
  st_crop(conus_filter)

.us_pr <- ne[ne$ADMIN == "Puerto Rico", ] |>
  st_as_sfc()

## Temporary for package develop
## Eventually data will be provided by users
mozone <- get_raster(44201, NULL, year = 2005:2007, nmax = 10, cell_size = 20000)
mno2 <- get_raster(42602, NULL, year = 2005:2007, nmax = 10, cell_size = 20000)
.yy <- c(mozone, mno2)

pm25 <- get_raster(88101, NULL, year = 2005:2006, by_month = TRUE, cell_size = 20000)
co <- get_raster(42101, NULL, year = 2005:2006, by_month = TRUE,
                 download_chunk_size = "2-week", cell_size = 20000)
.mm <- c(pm25, co)

## Save internal dataset
format(object.size(list(.criteria_pollutants, .us_conus, .us_pr)), "Mb")
usethis::use_data(.criteria_pollutants, .us_conus, .us_pr, .yy, .mm,
                  internal = TRUE, overwrite = TRUE)


