## This script is simply to run app on POSIT cloud
library(shiny)
library(raqs)
library(pargasite)
library(sf)
library(shinycssloaders)
library(gstat)
library(leaflet)
library(stars)
source("functions.R")

## file source DIR as working DIR
.criteria_pollutants <- pargasite:::.criteria_pollutants
.monitors <- pargasite:::.monitors

options(pargasite.dat = readRDS("pollutant_annual_10km_no_concurred_filter.RDS"))
x_bbox <- st_bbox(st_transform(getOption("pargasite.dat"), 4269))
x_wkt_filter <- st_as_text(st_as_sfc(x_bbox))
x_crs <- st_crs(getOption("pargasite.dat"))

options(
  pargasite.map_state = st_read(
    "./shape/cb_2022_us_state_20m/cb_2022_us_state_20m.shp",
    wkt_filter = x_wkt_filter, quiet = TRUE) |>
    st_transform(x_crs),
  pargasite.map_county = st_read(
    "./shape/cb_2022_us_county_20m/cb_2022_us_county_20m.shp",
    wkt_filter = x_wkt_filter, quiet = TRUE) |>
    st_transform(x_crs),
  pargasite.map_cbsa = st_read(
    "./shape/cb_2021_us_cbsa_20m/cb_2021_us_cbsa_20m.shp",
    wkt_filter = x_wkt_filter, quiet = TRUE) |>
    st_transform(x_crs)
)

options(
  pargasite.summary_state = aggregate(
    getOption("pargasite.dat"), by = getOption("pargasite.map_state"),
    FUN = function(x) mean(x, na.rm = TRUE)
  ),
  pargasite.summary_county = aggregate(
    getOption("pargasite.dat"), by = getOption("pargasite.map_county"),
    FUN = function(x) mean(x, na.rm = TRUE)
  ),
  pargasite.summary_cbsa = aggregate(
    getOption("pargasite.dat"), by = getOption("pargasite.map_cbsa"),
    FUN = function(x) mean(x, na.rm = TRUE)
  )
)
