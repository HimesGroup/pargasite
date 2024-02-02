server <- function(input, output, session) {

  ## Get data from global scope
  pargasite.dat <- getOption("pargasite.dat")
  pargasite.summary_state <- getOption("pargasite.summary_state")
  pargasite.summary_county <- getOption("pargasite.summary_county")
  pargasite.summary_cbsa <- getOption("pargasite.summary_cbsa")
  pargasite.map_state <- getOption("pargasite.map_state")
  pargasite.map_county <- getOption("pargasite.map_county")
  pargasite.map_cbsa <- getOption("pargasite.map_cbsa")
  ## Reset pargasite options
  ## Whenever the web page is refreshed it throws an error as data are set to NULL
  ## options(pargasite.dat = NULL, pargasite.summary_state = NULL,
  ##         pargasite.summary_county = NULL, pargasite.summary_cbsa = NULL,
  ##         pargasite.map_state = NULL, pargasite.map_county = NULL,
  ##         pargasite.map_cbsa = NULL)

  ## Some pre-processing
  pollutant_list <- .recover_from_standard(pargasite.dat)
  field_list <- st_get_dimension_values(pargasite.dat, "data_field")
  event_list <- st_get_dimension_values(pargasite.dat, "event")
  year_list <- st_get_dimension_values(pargasite.dat, "year")
  if ("month" %in% dimnames(pargasite.dat)) {
    month_list <- st_get_dimension_values(pargasite.dat, "month")
  } else {
    month_list <- NULL
  }
  summary_list <- "None"
  if (!is.null(pargasite.summary_state)) {
    summary_list <- c(summary_list, "State")
  }
  if (!is.null(pargasite.summary_county)) {
    summary_list <- c(summary_list, "County")
  }
  if (!is.null(pargasite.summary_cbsa)) {
    summary_list <- c(summary_list, "CBSA")
  }

  ## Render UI
  output$pollutant_ui <- renderUI(
    tagList(pollutant_ui(pollutant_list, field_list, event_list, year_list,
                         month_list, summary_list))
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
    ## output$data_field <- renderText(
    ##   if ("month" %ni% dimnames(pargasite.dat)) {
    ##     .map_standard_to_field(input$pollutant)
    ##   } else {
    ##     "arithmetic_mean"
    ##   }
    ## )
    if ("NAAQS_statistic" %in% st_get_dimension_values(pargasite.dat, "data_field")) {
      idx <- match("NAAQS_statistic", field_list)
      field_list[idx] <- .map_standard_to_field(input$pollutant)
    }
    updateSelectizeInput(session, inputId = "dat_field", choices = field_list)
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

  ## Consistent color scale across different times and event filters
  v <- reactiveValues(min_val = NULL, max_val = NULL, ulim_val = NULL)

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
    if (!is.null(input$dat_field)) {
      if (input$dat_field != "arithmetic_mean") {
        d <- dimsub(
          d, dim = "data_field",
          value = setdiff(st_get_dimension_values(d, "data_field"), "arithmetic_mean"),
          drop = FALSE
        )
      } else{
        d <- dimsub(d, dim = "data_field", value = input$dat_field, drop = FALSE)
      }
    } else {
      d <- dimsub(d, dim = "data_field",
                  value = st_get_dimension_values(d, "data_field")[1],
                  drop = FALSE)
    }
    ## For color scale; still allow different scale between data fields as they
    ## are a lot different
    v$max_val <- max(d[[i = TRUE]], na.rm = TRUE)
    v$min_val <- min(d[[i = TRUE]], na.rm = TRUE)
    if (!is.null(input$event)) {
      ## Drop=TRUE will drop singular dimension of year; it throw an error next year eval.
      d <- dimsub(d, dim = "event", value = input$event, drop = FALSE)
    } else {
      d <- dimsub(d, dim = "event", value = st_get_dimension_values(d, "event")[1],
                  drop = FALSE)
    }
    if (!is.null(input$year)) {
      d <- dimsub(d, dim = "year", value = input$year, drop = TRUE)
    } else {
      d <- dimsub(d, dim = "year", value = st_get_dimension_values(d, "year")[1],
                  drop = TRUE)
    }
    if ("month" %in% dimnames(d)) {
      if (!is.null(input$month)) {
        d <- dimsub(d, dim = "month", value = input$month, drop = TRUE)
      } else {
        d <- dimsub(d, dim = "month",
                    value = st_get_dimension_values(d, "month")[1], drop = TRUE)
      }
    }
    d
  })

  monitor_dat <- reactive({
    if (is.null(input$year)) {
      year <- st_get_dimension_values(pargasite.dat, "year")[1]
    } else {
      year <- input$year
    }
    if (is.null(input$pollutant)) {
      idx <- which(.criteria_pollutants$pollutant_standard ==
                   .recover_from_standard(pargasite.dat)[[1]][[1]])
    } else {
      idx <- which(.criteria_pollutants$pollutant_standard == input$pollutant)
    }
    parameter_code <- .criteria_pollutants$parameter_code[idx]
    d <- .monitors[.monitors$year == year &
                   .monitors$parameter_code == parameter_code, ]
    as.data.frame(st_coordinates(d))
  })

  observeEvent({
    input$pollutant
  }, {
    v$ulim_val <- .map_standard_to_ulim(.make_names(input$pollutant))
    updateNumericInput(inputId = "outlier_cutoff", value = v$ulim_val)
  })

  observeEvent({
    input$outlier_cutoff
  }, {
    v$ulim_val <- input$outlier_cutoff
  })

  ## Draw map
  observeEvent({
    pargasite_dat()
    monitor_dat()
    input$color
    input$color_bounded
    v$ulim_val
  }, {
    map_dat <- pargasite_dat()
    label_fmt <- labelFormat(transform = function(x) sort(x, decreasing = TRUE))
    ## prevent color distortion due to too high values
    if (input$color == "Free") {
      min_val <- min(map_dat[[1]], na.rm = TRUE) * 0.99
      max_val <- max(map_dat[[1]], na.rm = TRUE) * 1.01 # small offset due to boundary
    } else {
      min_val <- v$min_val * 0.99 # small offset due to boundary
      max_val <- v$max_val * 1.01
    }
    if (input$color_bounded) {
      ## ulim_val <- .map_standard_to_ulim(names(pargasite_dat()))
      ulim_val <- v$ulim_val
      map_dat[[1]] <- pmin(map_dat[[1]], ulim_val)
      max_val <- min(max_val, ulim_val * 1.01)
      label_fmt <- labelFormat(transform = function(x) sort(x, decreasing = TRUE),
                               suffix = "+")
    }
    ## min_val <- min(map_dat[[1]], na.rm = TRUE) * 0.99
    ## max_val <- max(map_dat[[1]], na.rm = TRUE) * 1.01 # small offset due to boundary
    pal <- colorNumeric("Spectral", domain = c(min_val, max_val),
                        na.color = "transparent", reverse = TRUE)
    ## For sorting add legend; clunky
    pal_rev <- colorNumeric("Spectral", domain = c(min_val, max_val),
                            na.color = "transparent", reverse = FALSE)
    ## map_dat <- st_transform(st_as_sf(pargasite_dat()), 4326)
    p <- leaflet(options = leafletOptions(minZoom = 3)) |>
      addTiles() |>
      setView(lng = -98.58, lat = 39.33, zoom = 4) |>
      addMarkers(lng = monitor_dat()$X, lat = monitor_dat()$Y,
                 group = "Show Monitor Locations") |>
      addLayersControl(overlayGroups = "Show Monitor Locations",
                       options = layersControlOptions(collapsed = FALSE)) |>
      hideGroup("Show Monitor Locations")
    if (is.null(input$summary) || input$summary == "None") {
      p <- p |>
        ## addRasterImage with project = TRUE will project data to the leaflet map CRS
        addRasterImage(as(map_dat, "Raster"), color = pal, opacity = 0.7)
    } else {
      m <- switch(
        input$summary,
        "State" = pargasite.map_state,
        "County" = pargasite.map_county,
        "CBSA" = pargasite.map_cbsa
      )
      r <- st_join(st_as_sf(map_dat), m, join = sf::st_equals) |>
        st_transform(4326)
      names(r)[1] <- "value"
      p <- p |>
        addPolygons(
          data = r, fillColor = ~pal(value), weight = 1, opacity = 1,
          color = "#444444",
          dashArray = NULL, fillOpacity = 0.7,
          highlightOptions = highlightOptions(
            weight = 3, color = "#444444", dashArray = NULL,
            fillOpacity = 0.9, bringToFront = FALSE
          ),
          label = paste0(r$NAME, ": ", sprintf("%.3f", r$value))
        )
    }
    p <- p |>
      addLegend(position = "bottomright", pal = pal_rev, values = c(min_val, max_val),
                labFormat = label_fmt)
    output$us_map <- renderLeaflet(p)
  })

  ## Display pollutant level based upon mouse click event
  ## Can use mouseover events with map_shape_mouseover but would not work with
  ## addRasterImage; (limitation can be bypassed with leafem addImageQuery/addMouseCoordinates ?)
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
      "<b>Click the map to retrieve a pollutant value.</b>"
    }
  })

}
