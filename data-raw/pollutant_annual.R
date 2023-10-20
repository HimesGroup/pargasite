library(pargasite)

co <- create_pargasite_data("CO", year = 1997:2022)
so2 <- create_pargasite_data("SO2", year = 1997:2022)
no2 <- create_pargasite_data("NO2", year = 1997:2022)
ozone <- create_pargasite_data("Ozone", year = 1997:2022)
pm2.5 <- create_pargasite_data("PM2.5", year = 1997:2022)
pm10 <- create_pargasite_data("PM10", year = 1997:2022)

pollutant_annual <- c(co, so2, no2, ozone, pm2.5, pm10)
saveRDS(pollutant_annual, "data-raw/pollutant_annual.RDS")
