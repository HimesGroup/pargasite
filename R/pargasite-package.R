##' @importFrom raqs get_aqs_email get_aqs_key aqs_dailydata aqs_annualdata
##' @importFrom sf st_as_sf st_as_sfc st_as_text st_crs st_read st_transform
##'   st_bbox st_crop st_sfc st_point st_within st_coordinates st_join st_equals
##'   st_interpolate_aw
##' @importFrom stars st_as_stars st_get_dimension_values st_extract
##' @importFrom gstat idw
##' @importFrom shiny fluidPage titlePanel sidebarLayout sidebarPanel mainPanel
##'   fluidRow uiOutput selectizeInput updateSelectizeInput renderUI
##'   radioButtons wellPanel observeEvent renderText p h2 h3 h4 shinyApp
##'   reactive reactiveValues hr span checkboxInput br HTML textOutput
##'   htmlOutput numericInput updateNumericInput tabsetPanel tabPanel
##'   conditionalPanel column a helpText icon req tagList
##' @importFrom leaflet leafletOutput renderLeaflet leaflet leafletOptions
##'   colorNumeric addTiles setView addRasterImage addPolygons addLegend
##'   labelFormat highlightOptions addMarkers addLayersControl
##'   layersControlOptions hideGroup JS addEasyButton easyButton addMeasure
##'   addPolylines
##' @importFrom shinycssloaders withSpinner
##' @importFrom leafsync sync
##' @importFrom methods as
##' @importFrom stats aggregate as.formula setNames
##' @importFrom utils capture.output download.file unzip
##' @importFrom cli cli_progress_bar cli_progress_update cli_progress_done
"_PACKAGE"
