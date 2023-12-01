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
