## Label formatting
label_fmt <- labelFormat(transform = function(x) sort(x, decreasing = TRUE))

## Recenter map
button.js <- paste0("function(btn, map){ map.setView([39.33, -98.58], 4); }")

## Get color palette
.get_pal <- function(min_val, max_val, reverse = TRUE) {
  colorNumeric("Spectral", domain = c(min_val, max_val),
               na.color = "transparent", reverse = reverse)
}

## Display pollutant estimates summarized by grids
.draw_grid <- function(x, monitor_dat, year, month = NULL) {
  min_val <- min(x[[1]], na.rm = TRUE) * 0.99 # small offset due to boundary
  max_val <- max(x[[1]], na.rm = TRUE) * 1.01
  if (is.null(month)) {
    if (length(year) > 1) {
      plist <- lapply(year, function(k) {
        y <- .dimsub(x, dim = "year", value = k, drop = TRUE)
        .draw_leaflet(y, monitor_dat, min_val, max_val, label_fmt,
                      title = paste0("Year: ", k), grid = TRUE)
      })
      do.call(sync, plist)
    } else {
      .draw_leaflet(x, monitor_dat, min_val, max_val, label_fmt, grid = TRUE)
    }
  } else {
    if (length(month) > 1) {
      plist <- lapply(month, function(k) {
        y <- .dimsub(x, dim = "month", value = k, drop = TRUE)
        .draw_leaflet(y, monitor_dat, min_val, max_val, label_fmt,
                      title = paste0(month.abb[as.integer(k)], " ", year),
                      grid = TRUE)
      })
      do.call(sync, plist)
    } else {
      .draw_leaflet(x, monitor_dat, min_val, max_val, label_fmt, grid = TRUE)
    }
  }
}

## Display pollutant estimates summarized by geographical boundaries
.draw_geoshape <- function(x, monitor_dat, year, month) {
  min_val <- min(x$value, na.rm = TRUE) * 0.99
  max_val <- max(x$value, na.rm = TRUE) * 1.01
  if (is.null(month)) {
    if (length(year) > 1) {
      plist <- lapply(year, function(k) {
        y <- x[x$year == k, ]
        .draw_leaflet(y, monitor_dat, min_val, max_val, label_fmt,
                      title = paste0("Year: ", k), grid = FALSE)
      })
      do.call(sync, plist)
    } else {
      .draw_leaflet(x, monitor_dat, min_val, max_val, label_fmt, grid = FALSE)
    }
  } else {
    if (length(month) > 1) {
      plist <- lapply(month, function(k) {
        y <- x[x$month == k, ]
        .draw_leaflet(y, monitor_dat, min_val, max_val, label_fmt,
                      title = paste0(month.abb[as.integer(k)], " ", year),
                      grid = FALSE)
      })
      do.call(sync, plist)
    } else {
      .draw_leaflet(x, monitor_dat, min_val, max_val, label_fmt,
                    grid = FALSE)
    }
  }
}

## Underlying function to create an interactive map
.draw_leaflet <- function(x, monitor_dat, min_val, max_val, label_fmt,
                          title = NULL, grid = TRUE) {
  p <- leaflet(options = leafletOptions(minZoom = 3)) |>
    addTiles() |>
    setView(lng = -98.58, lat = 39.33, zoom = 4) |>
    addMarkers(lng = monitor_dat$X, lat = monitor_dat$Y,
               group = "Monitor Locations") |>
    addLayersControl(overlayGroups = "Monitor Locations",
                     options = layersControlOptions(collapsed = FALSE)) |>
    hideGroup("Monitor Locations") |>
    addEasyButton(easyButton(
      icon = "fa-crosshairs", title = "Recenter",
      onClick = JS(button.js)
    )) |>
    ## Useful?
    addMeasure(
      position = "bottomleft",
      primaryLengthUnit = "meters",
      secondaryLengthUnit = "miles",
      primaryAreaUnit = "sqmeters",
      secondaryAreaUnit = "sqmiles"
    ) |>
    addLegend(position = "bottomright",
              pal = .get_pal(min_val, max_val, reverse = FALSE),
              values = c(min_val, max_val),
              labFormat = label_fmt, title = title)
  if (grid) {
    p |> addRasterImage(as(x, "Raster"), colors = .get_pal(min_val, max_val),
                        opacity = 0.6, project = TRUE) |>
      addPolylines(data = st_transform(getOption("pargasite.map")[["state"]], 4326),
                   weight = 1, color = "#444444")
  } else {
    p |> addPolygons(
      data = x, fillColor = ~.get_pal(min_val, max_val)(value),
      weight = 1, opacity = 1,
      color = "#444444",
      dashArray = NULL, fillOpacity = 0.6,
      highlightOptions = highlightOptions(
        weight = 3, color = "#444444", dashArray = NULL,
        fillOpacity = 0.9, bringToFront = FALSE
      ),
      label = paste0(x$NAME, ": ", sprintf("%.3f", x$value))
    )
  }
}
