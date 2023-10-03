server <- function(input, output, session) {

  ## Get data from global scope and reset pargasite options
  pargasite.dat <- getOption("pargasite.dat")
  pargasite.summary_state <- getOption("pargasite.summary_state")
  pargasite.summary_county <- getOption("pargasite.summary_county")
  pargasite.summary_cbsa <- getOption("pargasite.summary_cbsa")
  options(pargasite.dat = NULL, pargasite.summary_state = NULL,
          pargasite.summary_county = NULL, pargasite.summary_cbsa = NULL)

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

  output$pollutant_ui <- renderUI(
    tagList(
      pollutant_ui(pollutant_list, year_list, month_list, summary_list)
    )
  )
  observeEvent(input$pollutant, {
    ## List a selected pollutant information
    pollutant_idx <- which(
      .criteria_pollutants$pollutant_standard == input$pollutant
    )
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
  pargasite_dat <- reactive({
    ## Shiny renderUI may initiate input as NULL
    ## if (is.null(input$summary)) {
    ##   toget <- "pargasite.dat"
    ## } else {
    ##   toget <- switch(input$summary,
    ##               "None" = "pargasite.dat",
    ##               "State" = "pargasite.summary_state",
    ##               "County" = "pargasite.summary_county",
    ##               "CBSA" = "pargasite.summary_cbsa"
    ##               )
    ## }
    ## d <- getOption(toget)
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
        d <- dimsub(d, dim = "month", value = input$month)
      } else {
        d <- dimsub(d, dim = "month", value = st_get_dimension_values(d, "month")[1], drop = TRUE)
      }
    }
    d
  })

  observeEvent({
    pargasite_dat()
  }, {
    min_val <- min(pargasite_dat()[[1]], na.rm = TRUE)
    max_val <- max(pargasite_dat()[[1]], na.rm = TRUE)
    pal <- colorNumeric("Spectral", domain = c(min_val, max_val), na.color = "transparent", reverse = TRUE)
    ## For sorting add legend; clunky
    pal_rev <- colorNumeric("Spectral", domain = c(min_val, max_val), na.color = "transparent", reverse = FALSE)
    p <- leaflet::leaflet(options = leafletOptions(minZoom = 4)) |>
      addTiles() |>
      setView(lng = -98.58, lat = 39.33, zoom = 4)
    if (is.null(input$summary) || input$summary == "None") {
      p <- p |>
        ## addPolygons(data = st_transform(st_as_sf(pargasite_dat()), 4326),
        ##             stroke = FALSE, fillColor = ~pal(st_as_sf(pargasite_dat())[[1]]), fillOpacity = 0.5)
      addRasterImage(as(pargasite_dat(), "Raster"), color = pal, opacity = 0.5)
      ## addRasterImage(as(st_warp(pargasite_dat(), crs = 4326), "Raster"), color = pal, opacity = 0.5)
    } else {
      p <- p |>
        addPolygons(data = st_transform(st_as_sf(pargasite_dat()), 4326),
                    stroke = TRUE, color = "darkgray", opacity = 0.5, weight = 1,
                    fillColor = ~pal(st_as_sf(pargasite_dat())[[1]]), fillOpacity = 0.5)
    }
    p <- p |>
      ## leaflet::addLegend(position = "bottomright", pal = pal, values = c(min_val, max_val))
      addLegend(position = "bottomright", pal = pal_rev, values = c(min_val, max_val),
                labFormat = labelFormat(transform = function(x)  sort(x, decreasing = TRUE)))
    output$us_map <- renderLeaflet(p)
  })

}
