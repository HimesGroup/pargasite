aqi_colors <- function(x) {
  ifelse(x >= 0 & x <= 50, "#00e400",
  ifelse(x > 50 & x <= 100, "#ffff00",
  ifelse(x > 100 & x <= 150, "#ff7e00",
  ifelse(x > 150 & x <= 200, "#ff0000",
  ifelse(x > 200 & x <= 300, "#8f3f97",
  ifelse(x > 300, "#7e0023", NA)))
  )))
}

aqi_ui <- function() {
  fluidRow(
    column(
      12,
      h3("Choose AQI statistic to visualize",
         style = "font-weight: bold; color: #DC4C64; margin-top:10px; margin-bottom: 15px"),
      selectizeInput(
        inputId = "aqi_stat",
        label = NULL,
        choice = c("Median", "Max", "90th Percentile"),
        selected = "Median",
        multiple = FALSE
      ),
      h4("Data Info", style = "font-weight: bold; color: #332D2D"),
      p("Source: AQS Annual Summary Data",
        style = "font-weight: bold; color: orange"),
      hr(),
      selectizeInput(
        inputId = "aqi_year",
        label = "Year",
        choice = 2022:1996,
        selected = 2022,
        multiple = TRUE
      ),
      hr(),
      radioButtons(
        inputId = "aqi_summary",
        label = "Summarized by",
        choices = c("County", "CBSA"),
        inline = TRUE
      ),
      hr(),
      h4("AQI value", style = "font-weight: bold; color: #9CCC65"),
      h5(htmlOutput("aqi_val")),
      hr(),
      p(span("Good (0-50)", style = "font-weight: bold; background-color: #00e400"),
        " Air quality is satisfactory, and air pollution poses little or no risk."),
      p(span("Moderate (51-100)", style = "font-weight: bold; background-color: #ffff00"),
        paste0(" Air quality is acceptable. However, there may be a risk for some people, ",
               "particularly those who are unusually sensitive to air pollution.")),
      p(span("Unhealthy for Sensitive Groups (101-150)",
             style = "font-weight: bold; background-color: #ff7e00"),
        paste0(" Members of sensitive groups may experience health effects. ",
               "The general public is less likely to be affected.")),
      p(span("Unhealthy (151-200)",
             style = "font-weight: bold; background-color: #ff0000"),
        paste0(" Some members of the general public may experience health effects; ",
               "members of sensitive groups may experience more serious health effects.")),
      p(span("Very Unhealthy (201-300)",
             style = "font-weight: bold; background-color: #8f3f97"),
        " Health alert: The risk of health effects is increased for everyone. "),
      p(span("Hazardous (> 301)",
             style = "font-weight: bold; background-color: #7e0023"),
        paste0(" Health warning of emergency condition: ",
               "every is more likely to be affected."))
    )
  )
}

aqi_draw <- function(x, stat, year) {
  d <- x[x$year == as.integer(year), ]
  if (stat == "Median") {
    idx <- match("median_aqi", names(d))
    names(d)[idx] <- "value"
  } else if (stat == "Max") {
    idx <- match("max_aqi", names(d))
    names(d)[idx] <- "value"
  } else {
    idx <- match("x90th_percentile_aqi", names(d))
    names(d)[idx] <- "value"
  }
  d$fill_cols <- aqi_colors(d$value)
  d <- st_transform(d, 4326)
  leaflet(options = leafletOptions(minZoom = 3)) |>
    addTiles() |>
    setView(lng = -98.58, lat = 39.33, zoom = 4) |>
    addEasyButton(easyButton(
      icon = "fa-crosshairs", title = "Recenter",
      onClick = JS("function(btn, map){ map.setView([39.33, -98.58], 4); }")
    )) |>
    addMeasure(
      position = "bottomleft",
      primaryLengthUnit = "meters",
      secondaryLengthUnit = "miles",
      primaryAreaUnit = "sqmeters",
      secondaryAreaUnit = "sqmiles"
    ) |>
    addPolygons(
      data = d,
      fillColor = d$fill_cols, weight = 1, opacity = 1,
      color = "#444444", dashArray = NULL, fillOpacity = 0.6,
      highlightOptions = highlightOptions(
        weight = 3, color = "#444444", dashArray = NULL,
        fillOpacity = 0.9, bringToFront = FALSE
      ),
      label = paste0(d$name, ": ", sprintf("%.1f", d$value))
    ) |>
    addLegend(position = "bottomright",
              color = c("#7e0023", "#8f3f97", "#ff0000", "#ff7e00", "#ffff00", "#00e400"),
              labels = c("Hazardous", "Very Unhealthy", "Unhealthy",
                         "Unhealthy for Sensitive Groups",
                         "Moderate", "Good"))
}

aqi_draw_multi <- function(x, stat, year) {
  plist <- lapply(year, function(k) aqi_draw(x, stat, k))
  do.call(sync, plist)
}
