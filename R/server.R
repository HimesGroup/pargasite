server <- function(input, output, session) {

  ## Get data from global scope and reset pargasite options
  pargasite.dat <- getOption("pargasite.dat")
  pargasite.summary_state <- getOption("pargasite.summary_state")
  pargasite.summary_county <- getOption("pargasite.summary_county")
  pargasite.summary_cbsa <- getOption("pargasite.summary_cbsa")
  pargasite.map_state <- getOption("pargasite.map_state")
  pargasite.map_county <- getOption("pargasite.map_county")
  pargasite.map_cbsa <- getOption("pargasite.map_cbsa")
  options(pargasite.dat = NULL, pargasite.summary_state = NULL,
          pargasite.summary_county = NULL, pargasite.summary_cbsa = NULL,
          pargasite.map_state = NULL, pargasite.map_county = NULL,
          pargasite.map_cbsa = NULL)

  ## Some preprocessing
  pollutant_list <- .recover_from_standard(pargasite.dat)
  year_list <- st_get_dimension_values(pargasite.dat, "year")
  if ("month" %in% dimnames(pargasite.dat)) {
    month_list <- st_get_dimension_values(pargasite.dat, "month")
  } else {
    month_list <- NULL
  }
  summary_list <- "None"
  if (!is.null(pargasite.summary_state)) summary_list <- c(summary_list, "State")
  if (!is.null(pargasite.summary_county)) summary_list <- c(summary_list, "County")
  if (!is.null(pargasite.summary_cbsa)) summary_list <- c(summary_list, "CBSA")

  ## Render UI
  output$pollutant_ui <- renderUI(
    tagList(
      pollutant_ui(pollutant_list, year_list, month_list, summary_list)
    )
  )

  ## Pollutant information
  observeEvent(input$pollutant, {
    output$dat_src <- renderText(
      if ("month" %ni% dimnames(pargasite.dat)) {
        "EPA's AQS API annualData service"
      } else {
        "EPA's AQS API dailyData service"
      }
    )
    output$dat_field <- renderText(
      .map_standard_to_field(input$pollutant)
    )
    ## List a selected pollutant information
    pollutant_idx <- which(
      .criteria_pollutants$pollutant_standard == input$pollutant
    )
    output$pollutant_std <- renderText(input$pollutant)
    output$pollutant_desc <- renderText(
      .criteria_pollutants$pollutant_standard_description[pollutant_idx]
    )
    output$pollutant_unit <- renderText(
      .criteria_pollutants$standard_units[pollutant_idx]
    )
    output$naaqs_basis <- renderText(
      .criteria_pollutants$naaqs_basis[pollutant_idx]
    )
    output$naaqs_stat <- renderText(
      .criteria_pollutants$naaqs_statistic[pollutant_idx]
    )
    output$primary_level <- renderText(
      .criteria_pollutants$primary_standard_level[pollutant_idx]
    )
  })

  ## Choose data by user's selections
  ## To do: uniform legend scale for the same pollutant
  pargasite_dat <- reactive({
    if (is.null(input$summary)) {
      d <- pargasite.dat
    } else {
      d <- switch(
        input$summary,
        "None" = pargasite.dat,
        "State" = pargasite.summary_state,
        "County" = pargasite.summary_county,
        "CBSA" = pargasite.summary_cbsa
      )
    }
    if (is.null(input$pollutant)) {
      ## Clumsy; need a better way to set a default value
      d <- d[.make_names(.recover_from_standard(d)[[1]][[1]])]
    } else {
      d <- d[.make_names(input$pollutant)]
    }
    if (!is.null(input$year)) {
      d <- dimsub(d, dim = "year", value = input$year, drop = TRUE)
    } else {
      d <- dimsub(d, dim = "year", value = st_get_dimension_values(d, "year")[1], drop = TRUE)
    }
    if ("month" %in% dimnames(d)) {
      if (!is.null(input$month)) {
        d <- dimsub(d, dim = "month", value = input$month, drop = TRUE)
      } else {
        d <- dimsub(d, dim = "month", value = st_get_dimension_values(d, "month")[1], drop = TRUE)
      }
    }
    d
  })

  ## Draw map
  observeEvent({
    pargasite_dat()
    input$color
  }, {
    map_dat <- pargasite_dat()
    label_fmt <- labelFormat(transform = function(x) sort(x, decreasing = TRUE))
    ## prevent color distortion due to too high values
    if (input$color != "As is") {
      ulim_val <- .map_standard_to_ulim(names(pargasite_dat()))
      map_dat[[1]] <- pmin(map_dat[[1]], ulim_val)
      label_fmt <- labelFormat(transform = function(x) sort(x, decreasing = TRUE),
                               suffix = "+")
    }
    min_val <- min(map_dat[[1]], na.rm = TRUE) * 0.99
    max_val <- max(map_dat[[1]], na.rm = TRUE) * 1.01 # small offset due to boundary
    pal <- colorNumeric("Spectral", domain = c(min_val, max_val),
                        na.color = "transparent", reverse = TRUE)
    ## For sorting add legend; clunky
    pal_rev <- colorNumeric("Spectral", domain = c(min_val, max_val),
                            na.color = "transparent", reverse = FALSE)
    ## map_dat <- st_transform(st_as_sf(pargasite_dat()), 4326)
    p <- leaflet(options = leafletOptions(minZoom = 3)) |>
      addTiles() |>
      setView(lng = -98.58, lat = 39.33, zoom = 4)
    if (is.null(input$summary) || input$summary == "None") {
      p <- p |>
        ## addRasterImage with project = TRUE will project data to the leaflet map CRS
        addRasterImage(as(map_dat, "Raster"), color = pal, opacity = 0.5)
    } else {
      ## Avoid addPolygons due to performance issue
      r <- st_as_sf(map_dat) |>
        stars::st_rasterize(dx = 10000)
      p <- p |>
        addRasterImage(as(r, "Raster"), color = pal, opacity = 0.5)
    }
    p <- p |>
      addLegend(position = "bottomright", pal = pal_rev, values = c(min_val, max_val),
                labFormat = label_fmt)
    output$us_map <- renderLeaflet(p)
  })

  ## Display pollutant level based upon mouse click event
  output$pollutant_val <- renderText({
    if (!is.null(input$us_map_click)) {
      click_pos <- st_point(c(input$us_map_click$lng, input$us_map_click$lat)) |>
        st_sfc(crs = 4326) |>
        st_transform(st_crs(pargasite_dat()))
      if (is.null(input$summary) || input$summary == "None") {
        pollutant_val <- round(st_extract(pargasite_dat(), st_coordinates(click_pos)), 3)
        if (is.na(pollutant_val)) pollutant_val <- "out of bounds"
        paste0("(", round(input$us_map_click$lng,2), ", ",
               round(input$us_map_click$lat, 2), "):  ",
               pollutant_val)
      } else {
        m <- switch(
          input$summary,
          "State" = pargasite.map_state,
          "County" = pargasite.map_county,
          "CBSA" = pargasite.map_cbsa
        )
        ## st_extract not work? perhaps data is multipolygon?
        ## pollutant_val <- round(st_extract(pargasite_dat(), sf::st_coordinates(click_pos)), 2)
        val_idx <- sf::st_within(click_pos, st_as_sf(pargasite_dat()))[[1]]
        pollutant_val <- round(st_as_sf(pargasite_dat())[[1]][val_idx], 3)
        name_idx <- sf::st_within(click_pos, m)[[1]]
        if (length(pollutant_val) == 0) {
          paste0("(", round(input$us_map_click$lng,2), ", ",
                 round(input$us_map_click$lat, 2), "):  ",
                 "out of bounds")
        } else {
          if (input$summary == "State") {
            paste0(m$NAME[name_idx], ":  ", pollutant_val)
          } else {
            paste0(m$NAMELSAD[name_idx], ":  ", pollutant_val)
          }
        }
      }
    } else {
      ## "<font color='#DC4C64'><b>Click the map to retrieve a pollutant value.</b></font>"
      "<b>Click the map to retrieve a pollutant value.</b>"
    }
  })

}
