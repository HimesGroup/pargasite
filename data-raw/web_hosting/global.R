## This script is simply to run app on POSIT cloud
## library(pargasite)
library(shiny)
library(raqs)
library(sf)
library(cli)
library(shinycssloaders)
library(gstat)
library(leaflet)
library(leafsync)
library(stars)
library(rlang)
## pargasite_scripts <- list.files("../../R", pattern = "\\.R$", full.names = TRUE)
## to_source <- !grepl("ui.R|server.R|run_pargasite.R", pargasite_scripts)
## lapply(pargasite_scripts[to_source], source)
source("helpers.R")
source("draw_map.R")
source("extract_grid_value.R")
source("subset_data.R")
source("summarize_by.R")
source("ui_functions.R")
source("utils.R")

## file source DIR as working DIR
load("sysdata.rda")

pargasite.dat <- readRDS("./app_data/pargasite.dat.RDS")
pargasite.map_state <- readRDS("./app_data/pargasite.map_state.RDS")
pargasite.map_county <- readRDS("./app_data/pargasite.map_county.RDS")
pargasite.map_cbsa <- readRDS("./app_data/pargasite.map_cbsa.RDS")
options(
  pargasite.dat = pargasite.dat,
  pargasite.map = list(state = pargasite.map_state, county = pargasite.map_county,
                       cbsa = pargasite.map_cbsa)
)
## rm(pargasite.dat, map_state, map_county, map_cbsa)

pargasite.aqi_county <- readRDS("./app_data/AQI_county.RDS")
pargasite.aqi_cbsa <- readRDS("./app_data/AQI_cbsa.RDS")

