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

pargasite.dat <- readRDS("./app_data/pargasite.dat.RDS")
pargasite.map_state <- readRDS("./app_data/pargasite.map_state.RDS")
pargasite.map_county <- readRDS("./app_data/pargasite.map_county.RDS")
pargasite.map_cbsa <- readRDS("./app_data/pargasite.map_cbsa.RDS")
pargasite.summary_state <- readRDS("./app_data/pargasite.summary_state.RDS")
pargasite.summary_county <- readRDS("./app_data/pargasite.summary_county.RDS")
pargasite.summary_cbsa <- readRDS("./app_data/pargasite.summary_cbsa.RDS")

pargasite.aqi_county <- readRDS("AQI_county.RDS")
pargasite.aqi_cbsa <- readRDS("AQI_cbsa.RDS")

aqi_colors <- function(x) {
  ifelse(x >= 0 & x <= 50, "#00e400",
  ifelse(x > 50 & x <= 100, "#ffff00",
  ifelse(x > 100 & x <= 150, "#ff7e00",
  ifelse(x > 150 & x <= 200, "#ff0000",
  ifelse(x > 200 & x <= 300, "#8f3f97",
  ifelse(x > 300, "#7e0023", NA)))
  )))
}

