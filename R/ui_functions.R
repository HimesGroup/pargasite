pollutant_ui <- function(pollutant_list, field_list, event_list, year_list,
                         month_list = NULL) {
  ## Month full name
  if (!is.null(month_list)) {
    names(month_list) <- month.abb[as.integer(month_list)]
  }
  fluidRow(
    column(
      12,
      ## h3("Map View", style = "font-weight: bold; color: #54B4D3; margin-top: 10px; margin-bottom: 20px"),
      ## hr(),
      h3("Choose a raster attribute to visualize",
         style = "font-weight: bold; color: #DC4C64; margin-top:10px; margin-bottom: 15px"),
      selectizeInput(
        inputId = "pollutant",
        label = NULL,
        choice = pollutant_list,
        selected = NULL,
        multiple = FALSE
      ),
      ## h4("Data Info", style = "font-weight: bold; color: #EEEEEE"),
      h4("Data Info", style = "font-weight: bold; color: #332D2D"),
      p(span("Source: ", style = "font-weight: bold; color: orange"),
        textOutput("dat_src", inline = TRUE)),
      p("Field used:",
        style = "font-weight: bold; color: orange; margin-bottom: -15px"),
      selectizeInput(
        inputId = "data_field",
        label = "",
        choice = field_list,
        multiple = FALSE
      ),
      helpText(
        icon("circle-info"),
        "Please check",
        a(href = "https://aqs.epa.gov/aqsweb/documents/AQS_Data_Dictionary.html",
          "AQS Data Dictionary", target = "_blank"), "for field descriptions.",
        style = "color: #3B71CA;"
      ),
      hr(),
      ## h4("Pollutant Standard Info", style = "font-weight: bold; color: #EEEEEE"),
      h4("Pollutant Standard Info", style = "font-weight: bold; color: #332D2D"),
      p(span("Pollutant standard: ", style = "font-weight: bold; color: orange"),
        textOutput("pollutant_std", inline = TRUE)),
      p(span("Primary Standard Level: ", style = "font-weight: bold; color: orange"),
        textOutput("primary_level", inline = TRUE)),
      p(span("Standard Unit: ", style = "font-weight: bold; color: orange"),
        textOutput("pollutant_unit", inline = TRUE)),
      p(span("Description: ", style = "font-weight: bold; color: orange"),
        textOutput("pollutant_desc", inline = TRUE)),
      p(span("NAAQS Basis: ", style = "font-weight: bold; color: orange"),
        textOutput("naaqs_basis", inline = TRUE)),
      p(span("NAAQS Statistic: ", style = "font-weight: bold; color: orange"),
        textOutput("naaqs_stat", inline = TRUE)),
      helpText(
        icon("circle-info"),
        "Please visit",
        a(href = "https://aqs.epa.gov/aqsweb/documents/codetables/pollutant_standards.html",
          "AQS Code List", target = "_blank"), "for details.",
        style = "color: #3B71CA"
      ),
      hr(),
      selectizeInput(
        inputId = "event",
        label = "Exceptional event",
        choice = event_list,
        multiple = FALSE
      ),
      hr(),
      if (is.null(month_list)) {
        selectizeInput(
          inputId = "year",
          label = "Year",
          choice = year_list,
          ## selected = if (length(year_list) > 1) year_list[1:2] else year_list[1],
          selected = year_list[1],
          multiple = TRUE
        )
      } else {
        selectizeInput(
          inputId = "year",
          label = "Year",
          choice = year_list,
          multiple = FALSE
        )
      },
      if (!is.null(month_list)) {
        ## had to put on separate if else block; cannot accommodate multiple
        ## selectizeInput
        selectizeInput(
          inputId = "month",
          label = "Month",
          choice = month_list,
          selected = month_list[1],
          multiple = TRUE
        )
      },
      hr(),
      radioButtons(
        inputId = "summary",
        label = "Summarized by",
        choices = c("Grid", "State", "County", "CBSA"),
        inline = TRUE
      )
      ## h4("Pollutant value", style = "font-weight: bold; color: #9CCC65"),
      ## h5(htmlOutput("pollutant_val"))
    )
  )
}

.recover_from_standard <- function(x, y = .criteria_pollutants) {
  y$key <- .make_names(y$pollutant_standard)
  y <- merge(list(key = names(x)), y, sort = FALSE)
  y$name <- paste0(y$parameter, " (", y$parameter_code, ")")
  ## Preserve order
  y$name <- factor(y$name, levels = unique(y$name))
  lapply(split(y$pollutant_standard, y$name), as.list)
}
