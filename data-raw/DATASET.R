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
## Keep only current standards
ids_to_keep <- c(
  ## Lead 3-month 2009; too few sites for interpolation
  ## 2,
  ## CO 1-hour 1971, CO 8-hour 1971
  3, 4,
  ## NO2 1-hour 2010, NO2 Annual 1971
  8, 20,
  ## PM10 24-hour 2006
  12,
  ## SO2 1-hour 2010
  19,
  ## PM2.5 24-hour 2012, PM2.5 Annual 2012,
  21, 22,
  ## Ozone 8-hour 2015
  23
)

.criteria_pollutants <- .criteria_pollutants[
  .criteria_pollutants$pollutant_standard_id %in% ids_to_keep,
  ]
.criteria_pollutants <- .criteria_pollutants[
  with(.criteria_pollutants, order(parameter_code, parameter, pollutant_standard)),
  ]


################################################################################
## Monitor list
################################################################################
get_monitors <- function(param, year = 1997:2022) {
  monitors <- list()
  for (i in year) {
    message("Processing year: ", i)
    bdate <- paste0(i, "0101")
    edate <- paste0(i, "1231")
    out <- raqs::monitors_bybox(
                   param = param, bdate = bdate, edate = edate,
                   minlat = 24, maxlat = 50, minlon = -124, maxlon = -66
                 )
    out$param <- param
    out$year <- i
    out <- out[, c("parameter_code", "year", "longitude", "latitude", "datum")]
    out <- .aqs_transform(out, target_crs = 4326)
    monitors[[as.character(i)]] <- out
  }
  .sys_sleep_pb(5)
  out <- do.call(rbind, monitors)
  rownames(out) <- NULL
  out
}

.co_monitors <- get_monitors(42101)
.so2_monitors <- get_monitors(42401)
.no2_monitors <- get_monitors(42602)
.ozone_monitors <- get_monitors(44201)
.pm10_monitors <- get_monitors(81102)
.pm25_monitors <- get_monitors(88101)
.monitors <- do.call(rbind, list(.co_monitors, .so2_monitors, .no2_monitors,
                                 .ozone_monitors, .pm10_monitors, .pm25_monitors))

################################################################################
## Simplified cartographic
################################################################################
.topo_state <- get_tl_shape("https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_state_20m.zip")
.topo_county <- get_tl_shape("https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_county_20m.zip")
.topo_cbsa <- get_tl_shape("https://www2.census.gov/geo/tiger/GENZ2021/shp/cb_2021_us_cbsa_20m.zip")
## .topo_state <- get_tl_shape(.get_tl_url("state"))
## .topo_county <- get_tl_shape(.get_tl_url("county"))
## .topo_cbsa <- get_tl_shape(.get_tl_url("cbsa"))
geojsonio::topojson_write(st_as_sfc(.topo_state), file = "./inst/extdata/state.json")
geojsonio::topojson_write(st_as_sfc(.topo_county), file = "./inst/extdata/county.json")
geojsonio::topojson_write(st_as_sfc(.topo_cbsa), file = "./inst/extdata/cbsa.json")


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
mozone <- create_pargasite_data("Ozone", year = 2020:2022)
mno2 <- create_pargasite_data("NO2", year = 2020:2022)
.yy <- c(mozone, mno2)

pm25 <- get_raster(88101, NULL, year = 2005:2006, by_month = TRUE, cell_size = 20000)
co <- get_raster(42101, NULL, year = 2005:2006, by_month = TRUE,
                 download_chunk_size = "2-week", cell_size = 20000)
.mm <- c(pm25, co)

## Save internal dataset
usethis::use_data(.criteria_pollutants, .yy, .monitors,
                  internal = TRUE, overwrite = TRUE)

