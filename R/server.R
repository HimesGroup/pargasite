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
    tagList(pollutant_ui(pollutant_list, event_list, year_list,
                         month_list))
  )

  rv <- reactiveValues(pollutant = NULL, field_list = NULL, data_field = NULL,
                       unit = NULL, dat_grid = NULL, dat_geo = NULL)

  output$dat_src <- renderText(
    if ("month" %ni% dimnames(getOption("pargasite.dat"))) {
      "EPA's AQS API annualData service"
    } else {
      "EPA's AQS API dailyData service"
    }
  )

  observeEvent({
    input$pollutant # initialized as NULL
  }, {
    if (!is.null(input$pollutant)) {
      rv$pollutant <- input$pollutant
    } else {
      ## Get the first entry from a nested list
      rv$pollutant <- unlist(pollutant_list)[1]
    }
    rv$unit <- .get_pollutant_unit(rv$pollutant)
    if ("NAAQS_statistic" %in% field_list) {
      idx <- match("NAAQS_statistic", field_list)
      field_list[idx] <- .map_standard_to_field(rv$pollutant)
      ## If NAAQS statistic = arithmetic mean, drop duplicate
      rv$field_list <- unique(field_list)
    }
    pollutant_idx <- which(
      .criteria_pollutants$pollutant_standard == rv$pollutant
    )
    output$pollutant_std <- renderText(rv$pollutant)
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
  }, ignoreNULL = FALSE)

  observeEvent({
    req(rv$pollutant)
    input$data_field
  }, {
    if (is.null(input$data_field) || input$data_field %ni% rv$field_list) {
      rv$data_field <- rv$field_list[1]
      updateSelectizeInput(session, inputId = "data_field", choices = rv$field_list,
                           selected = rv$data_field)
    } else {
      rv$data_field <- input$data_field
      updateSelectizeInput(session, inputId = "data_field", choices = rv$field_list,
                           selected = rv$data_field)
    }
  }, ignoreNULL = FALSE)

  observeEvent({
    req(rv$pollutant)
    req(rv$data_field)
    req(input$event)
    req(input$year)
    req(input$summary)
    input$month
  }, {
    ## Get monitor location data
    monitor_dat <- .subset_monitor_data(rv$pollutant, input$year)
    ## Subset pargasite data
    rv$dat_grid <- .subset_pargasite_data(
      getOption("pargasite.dat"), rv$pollutant, rv$data_field,
      input$event, input$year, input$month
    )
    if (input$summary == "Grid") {
      p <- .draw_grid(rv$dat_grid, monitor_dat, input$year, input$month,
                      unit = rv$unit)
    } else {
      rv$dat_geo <- .summarize_pargasite_data(
        rv$dat_grid, us_map = getOption("pargasite.map")[[tolower(input$summary)]],
        input$year, input$month
      )
      p <- .draw_geoshape(rv$dat_geo, monitor_dat, input$year, input$month,
                          unit = rv$unit)
    }
    if ((is.null(input$month) && length(input$year) == 1) ||
        (!is.null(input$month) && length(input$month) == 1)) {
      ## May do this on UI side using conditionalPanel
      ## output$us_map <- renderUI(leafletOutput("mymap", height = "67vh"))
      output$smap <- renderLeaflet(p)
    } else {
      output$mmap <- renderUI(p)
    }
  }, ignoreNULL = FALSE)

  ## Display pollutant value for a single-panel grid map
  observeEvent(input$smap_click, {
    if (!is.null(input$smap_click)) {
      if (input$summary == "Grid") {
        output$grid_val_ui <- renderUI(shiny::tableOutput("grid_val"))
        click_pos <- .get_click_pos(input$smap_click$lng, input$smap_click$lat)
        tbl <- .extract_grid_value(rv$dat_grid, click_pos)
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

.get_pollutant_unit <- function(x) {
  switch(
    sub("^(.*?) (.*)", "\\1", x),
    "CO" = "(ppm)",
    "SO2" = "(ppb)",
    "NO2" = "(ppb)",
    "Ozone" = "(ppm)",
    "PM25" = "(μg/m<sup>3</sup>)",
    "PM10" = "(μg/m<sup>3</sup>)"
  )
}
