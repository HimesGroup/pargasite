pollutant_ui <- function(pollutant_list, event_list, year_list, month_list = NULL,
                         summary_list) {
  ## Month full name
  if (!is.null(month_list)) {
    names(month_list) <- month.name[as.integer(month_list)]
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
      wellPanel(
        h4("Data Info", style = "font-weight: bold; color: #EEEEEE"),
        p(span("Source: ", style = "font-weight: bold; color: orange"),
          textOutput("dat_src", inline = TRUE)),
        p(span("Field used: ", style = "font-weight: bold; color: orange"),
          textOutput("dat_field", inline = TRUE)),
        helpText(
          icon("circle-info"),
          "Please check",
          a(href = "https://aqs.epa.gov/aqsweb/documents/AQS_Data_Dictionary.html",
            "AQS Data Dictionary", target = "_blank"), "for field descriptions.",
          style = "color: #3B71CA;"
        ),
        hr(),
        h4("Pollutant Standard Info", style = "font-weight: bold; color: #EEEEEE"),
        p(span("Pollutant standard: ", style = "font-weight: bold; color: orange"),
          textOutput("pollutant_std", inline = TRUE)),
        p(span("Primary Standard Level: ", style = "font-weight: bold; color: orange"),
          textOutput("primary_level", inline = TRUE)),
        p(span("Standard Unit: ", style = "font-weight: bold; color: orange"),
          textOutput("pollutant_unit", inline = TRUE)),
        p(span("Description: ", style = "font-weight: bold; color: orange"),
          textOutput("pollutant_desc", inline = TRUE)),
        p(span("NAAQS Basis: ", style = "font-weight: bold; color: orange"),
          shiny::textOutput("naaqs_basis", inline = TRUE)),
        p(span("NAAQS Statistic: ", style = "font-weight: bold; color: orange"),
          textOutput("naaqs_stat", inline = TRUE)),
        helpText(
          icon("circle-info"),
          "Please visit",
          a(href = "https://aqs.epa.gov/aqsweb/documents/codetables/pollutant_standards.html",
            "AQS Code List", target = "_blank"), "for details.",
          style = "color: #3B71CA; margin-bottom: -20px"
        ),
        style = "margin-top: -25px; margin-left: -18px; margin-right: 18px; border = none"
      ),
      hr(),
      selectizeInput(
        inputId = "event",
        label = "Exceptional event",
        choice = event_list,
        multiple = FALSE
      ),
      hr(),
      selectizeInput(
        inputId = "year",
        label = "Year",
        choice = year_list,
        multiple = FALSE
      ),
      if (!is.null(month_list)) {
        selectizeInput(
          inputId = "month",
          label = "Month",
          ## choice = month.name[as.integer(month_list)],
          choice = month_list,
          multiple = FALSE
        )
      },
      if (length(summary_list) > 1) {
        hr()
      },
      if (length(summary_list) > 1) {
        radioButtons(
          inputId = "summary",
          label = "Summarize by",
          ## choices = c("None", "State", "County", "CBSA"),
          choices = summary_list,
          inline = TRUE
        )
      },
      hr(),
      h4("Pollutant value", style = "font-weight: bold; color: #9CCC65"),
      ## h5(textOutput("pollutant_val"))
      h5(shiny::htmlOutput("pollutant_val"))
    )
  )
}

.recover_from_standard <- function(x, y = .criteria_pollutants) {
  d <- within(y, key <- .make_names(pollutant_standard))
  d <- merge(list(key = names(x)), d, sort = FALSE)
  d <- within(d, name <- paste0(parameter, " (", parameter_code, ")"))
  ## Preserve order
  d$name <- factor(d$name, levels = unique(d$name))
  lapply(split(d$pollutant_standard, d$name), as.list)
}
