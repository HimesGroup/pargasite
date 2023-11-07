library(pargasite)

## Too large for posit cloud
## co <- create_pargasite_data("CO", year = 1997:2022)
## so2 <- create_pargasite_data("SO2", year = 1997:2022)
## no2 <- create_pargasite_data("NO2", year = 1997:2022)
## ozone <- create_pargasite_data("Ozone", year = 1997:2022)
## pm2.5 <- create_pargasite_data("PM2.5", year = 1997:2022)
## pm10 <- create_pargasite_data("PM10", year = 1997:2022)
## pollutant_annual <- c(co, so2, no2, ozone, pm2.5, pm10)
## saveRDS(pollutant_annual, "data-raw/pollutant_annual.RDS")

## Smaller
co <- create_pargasite_data("CO", event_filter = "Events Included",
                            year = 1997:2022, cell_size = 10000)
so2 <- create_pargasite_data("SO2", event_filter = "Events Included",
                             year = 1997:2022, cell_size = 10000)
no2 <- create_pargasite_data("NO2", event_filter = "Events Included",
                             year = 1997:2022, cell_size = 10000)
ozone <- create_pargasite_data("Ozone", event_filter = "Events Included",
                               year = 1997:2022, cell_size = 10000)
pm2.5 <- create_pargasite_data("PM2.5", event_filter = "Events Included",
                               year = 1997:2022, cell_size = 10000)
pm10 <- create_pargasite_data("PM10", event_filter = "Events Included",
                              year = 1997:2022, cell_size = 10000)
pollutant_annual <- c(co, so2, no2, ozone, pm2.5, pm10)
saveRDS(pollutant_annual, "data-raw/pollutant_annual_10km_events_included.RDS")

## 10km with all event filters
co <- create_pargasite_data("CO", year = 1997:2022, cell_size = 10000)
so2 <- create_pargasite_data("SO2", year = 1997:2022, cell_size = 10000)
no2 <- create_pargasite_data("NO2", year = 1997:2022, cell_size = 10000)
ozone <- create_pargasite_data("Ozone", year = 1997:2022, cell_size = 10000)
pm2.5 <- create_pargasite_data("PM2.5", year = 1997:2022, cell_size = 10000)
pm10 <- create_pargasite_data("PM10", year = 1997:2022, cell_size = 10000)
pollutant_annual <- c(co, so2, no2, ozone, pm2.5, pm10)
saveRDS(pollutant_annual, "data-raw/pollutant_annual_10km.RDS")
