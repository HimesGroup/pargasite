## This script is simply to run app on POSIT cloud
library(shiny)
library(pargasite)
library(sf)
library(shinycssloaders)
library(gstat)
library(leaflet)
library(stars)
source("functions.R")

.criteria_pollutants <- pargasite:::.criteria_pollutants
.monitors <- pargasite:::.monitors

x <- ozone20km
x_bbox <- st_bbox(st_transform(ozone20km, 4269))
x_wkt_filter <- st_as_text(st_as_sfc(x_bbox))
tl_state <- st_transform(
  get_tl_shape(.get_carto_url("state"), wkt_filter = x_wkt_filter),
  st_crs(x)
)
tl_county <- st_transform(
  get_tl_shape(url = .get_carto_url("county"), wkt_filter = x_wkt_filter),
  st_crs(x)
)
tl_cbsa <- st_transform(
  get_tl_shape(url = .get_carto_url("cbsa"), wkt_filter = x_wkt_filter),
  st_crs(x)
)

summary_state <- summarize_by_boundaries(x, "state")
summary_county <- summarize_by_boundaries(x, "county")
summary_cbsa <- summarize_by_boundaries(x, "cbsa")

options(pargasite.dat = ozone20km,
        pargasite.summary_state = summary_state,
        pargasite.summary_county = summary_county,
        pargasite.summary_cbsa = summary_cbsa,
        pargasite.map_state = tl_state,
        pargasite.map_county = tl_county,
        pargasite.map_cbsa = tl_cbsa)

