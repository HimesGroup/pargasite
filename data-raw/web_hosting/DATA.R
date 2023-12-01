library(raqs)
library(pargasite)
library(gstat)
library(sf)
library(stars)

## Annual pollutant grid
co <- create_pargasite_data(
  "CO", year = 1997:2022,
  event_filter = c("Events Included", "Events Excluded"), cell_size = 10000
)
so2 <- create_pargasite_data(
  "SO2", year = 1997:2022,
  event_filter = c("Events Included", "Events Excluded"), cell_size = 10000
)
no2 <- create_pargasite_data(
  "NO2", year = 1997:2022,
  event_filter = c("Events Included", "Events Excluded"), cell_size = 10000
)
ozone <- create_pargasite_data(
  "Ozone", year = 1997:2022,
  event_filter = c("Events Included", "Events Excluded"), cell_size = 10000
)
pm2.5 <- create_pargasite_data(
  "PM2.5", year = 1997:2022,
  event_filter = c("Events Included", "Events Excluded"), cell_size = 10000
)
pm10 <- create_pargasite_data(
  "PM10", year = 1997:2022,
  event_filter = c("Events Included", "Events Excluded"), cell_size = 10000
)
pargasite.dat <- c(co, so2, no2, ozone, pm2.5, pm10)

## supplementary data
x_bbox <- st_bbox(st_transform(pargasite.dat, 4269))
x_wkt_filter <- st_as_text(st_as_sfc(x_bbox))
x_crs <- st_crs(pargasite.dat)

pargasite.map_state <- st_read(
  "./shape/cb_2022_us_state_20m/cb_2022_us_state_20m.shp",
  wkt_filter = x_wkt_filter, quiet = TRUE) |>
  st_transform(x_crs)

pargasite.map_county <- st_read(
  "./shape/cb_2022_us_county_20m/cb_2022_us_county_20m.shp",
  wkt_filter = x_wkt_filter, quiet = TRUE) |>
  st_transform(x_crs)

pargasite.map_cbsa <-  st_read(
  "./shape/cb_2021_us_cbsa_20m/cb_2021_us_cbsa_20m.shp",
  wkt_filter = x_wkt_filter, quiet = TRUE) |>
  st_transform(x_crs)

pargasite.summary_state <- aggregate(
  pargasite.dat, by = pargasite.map_state,
  FUN = function(x) mean(x, na.rm = TRUE)
)

pargasite.summary_county <- aggregate(
  pargasite.dat, by = pargasite.map_county,
  FUN = function(x) mean(x, na.rm = TRUE)
)

pargasite.summary_cbsa <- aggregate(
  pargasite.dat, by = pargasite.map_cbsa,
  FUN = function(x) mean(x, na.rm = TRUE)
)

## Save
dir.create("app_data", showWarnings = FALSE)
saveRDS(pargasite.dat, "./app_data/pargasite.dat.RDS")
saveRDS(pargasite.map_state, "./app_data/pargasite.map_state.RDS")
saveRDS(pargasite.map_county, "./app_data/pargasite.map_county.RDS")
saveRDS(pargasite.map_cbsa, "./app_data/pargasite.map_cbsa.RDS")
saveRDS(pargasite.summary_state, "./app_data/pargasite.summary_state.RDS")
saveRDS(pargasite.summary_county, "./app_data/pargasite.summary_county.RDS")
saveRDS(pargasite.summary_cbsa, "./app_data/pargasite.summary_cbsa.RDS")
