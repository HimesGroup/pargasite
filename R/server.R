server <- function(input, output, session) {

  ## Some pre-processing
  pollutant_list <- .recover_from_standard(getOption("pargasite.dat"))
  field_list <- st_get_dimension_values(getOption("pargasite.dat"), "data_field")
  event_list <- st_get_dimension_values(getOption("pargasite.dat"), "event")
  year_list <- sort(st_get_dimension_values(getOption("pargasite.dat"), "year"),
                    decreasing = TRUE)
  if ("month" %in% dimnames(getOption("pargasite.dat"))) {
    month_list <- sort(st_get_dimension_values(getOption("pargasite.dat"), "month"),
                       decreasing = TRUE)
  } else {
    month_list <- NULL
  }

  ## Render UI
  output$pollutant_ui <- renderUI(
    tagList(pollutant_ui(pollutant_list, field_list, event_list, year_list,
                         month_list))
  )

  ## Pollutant information
  observeEvent(input$pollutant, {
    output$dat_src <- renderText(
      if ("month" %ni% dimnames(getOption("pargasite.dat"))) {
        "EPA's AQS API annualData service"
      } else {
        "EPA's AQS API dailyData service"
      }
    )
    ## Select an appropriate field when NAAQS_statistic is given and update the
    ## dropdown menu
    if ("NAAQS_statistic" %in% field_list) {
      idx <- match("NAAQS_statistic", field_list)
      field_list[idx] <- .map_standard_to_field(input$pollutant)
      ## If NAAQS statistic = arithmetic mean, drop duplicate
      field_list <- unique(field_list)
    }
    updateSelectizeInput(session, inputId = "data_field", choices = field_list)
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

  r <- reactiveValues(dat_grid = NULL, dat_geo = NULL)

  observeEvent({
    ## Ensure that it is triggered when non-NULL values are given.
    req(input$summary)
    req(input$pollutant)
    req(input$data_field)
    req(input$event)
    req(input$year)
    input$month # exception; it can be NULL
  }, {
    ## Get monitor location data
    monitor_dat <- .subset_monitor_data(input$pollutant, input$year)
    ## Subset pargasite data
    r$dat_grid <- .subset_pargasite_data(
      getOption("pargasite.dat"), input$pollutant, input$data_field,
      input$event, input$year, input$month
    )
    if (input$summary == "Grid") {
      p <- .draw_grid(r$dat_grid, monitor_dat, input$year, input$month)
    } else {
      r$dat_geo <- .summarize_pargasite_data(
        r$dat_grid, us_map = getOption("pargasite.map")[[tolower(input$summary)]],
        input$year, input$month
      )
      p <- .draw_geoshape(r$dat_geo, monitor_dat, input$year, input$month)
    }
    if ((is.null(input$month) && length(input$year) == 1) ||
        (!is.null(input$month) && length(input$month) == 1)) {
      ## May do this on UI side using conditionalPanel
      ## output$us_map <- renderUI(leafletOutput("mymap", height = "67vh"))
      output$smap <- renderLeaflet(p)
    } else {
      output$mmap <- renderUI(p)
    }
  },
  ignoreNULL = FALSE # set FALSE as input$month can be NULL
  )

  ## Display pollutant value for a single-panel grid map
  observeEvent(input$smap_click, {
    if (!is.null(input$smap_click)) {
      if (input$summary == "Grid") {
        output$grid_val_ui <- renderUI(shiny::tableOutput("grid_val"))
        click_pos <- .get_click_pos(input$smap_click$lng, input$smap_click$lat)
        tbl <- .extract_grid_value(r$dat_grid, click_pos)
        output$grid_val <- shiny::renderTable(tbl)
      }
      ## is it necessary to display values for other summary types?
    } else {
      output$grid_val_ui <- renderUI(shiny::htmlOutput("grid_val_na"))
      output$grid_val_na <- renderText(
        "<h5 style='color:#E74C3C'><b>Click the map to retrieve a pollutant value.</b></h5>"
      )
    }
  }, ignoreNULL = FALSE)

  ## don't know synced map can observe click event; check later
  ## observeEvent(input$mmap_click, {
  ##   if (!is.null(input$mmap_click)) {
  ##   } else {
  ##   }
  ## })

}
