## This script is simply to run app on POSIT cloud
library(shiny)
library(raqs)
library(pargasite)
library(sf)
library(shinycssloaders)
library(gstat)
library(leaflet)
library(leafsync)
library(stars)
pargasite_scripts <- list.files("../../R", pattern = "\\.R$", full.names = TRUE)
to_source <- !grepl("ui.R|server.R|run_pargasite.R", pargasite_scripts)
lapply(pargasite_scripts[to_source], source)
source("helpers.R")

## file source DIR as working DIR
.criteria_pollutants <- pargasite:::.criteria_pollutants
.monitors <- pargasite:::.monitors

pargasite.dat <- readRDS("./app_data/pargasite.dat.RDS")
map_state <- .get_pargasite_map(pargasite.dat, "state")
map_county <- .get_pargasite_map(pargasite.dat, "county")
map_cbsa <- .get_pargasite_map(pargasite.dat, "cbsa")
options(pargasite.dat = pargasite.dat,
        pargasite.map = list(state = map_state, county = map_county,
                             cbsa = map_cbsa))
rm(pargasite.dat, map_state, map_county, map_cbsa)

pargasite.aqi_county <- readRDS("AQI_county.RDS")
pargasite.aqi_cbsa <- readRDS("AQI_cbsa.RDS")

