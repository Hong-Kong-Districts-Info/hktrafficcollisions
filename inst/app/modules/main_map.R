#############
## Filter UI
#############
output$district_filter_ui = renderUI({
  selectizeInput(
    inputId = "district_filter",
    label = i18n$t("District(s):"),
    choices = stats::setNames(
      DISTRICT_ABBR,
      lapply(DISTRICT_FULL_NAME, function(x) i18n$t(x))
    ),
    multiple = TRUE,
    selected = c("KC", "YTM", "SSP"),
    options = list(maxItems = 3, placeholder = 'Select districts (3 maximum)')
  ) %>%
    shinyhelper::helper(
      type = "markdown", colour = "#0d0d0d",
      content = "district_filter"
    )
})

output$start_month_ui = renderUI({
  airDatepickerInput("start_month",
                     label = i18n$t("From"),
                     value = "2016-01-01",
                     min = as.Date(min(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                     max = as.Date(max(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                     view = "months",
                     minView = "months",
                     dateFormat = "MM yyyy",
                     language = input$selected_language,
                     addon = "none"
  ) %>%
    shinyhelper::helper(
      type = "markdown", colour = "#0d0d0d",
      content = "date_filter"
    )
})

output$end_month_ui = renderUI({
  airDatepickerInput("end_month",
                     label = i18n$t("To"),
                     value = "2016-12-01",
                     min = as.Date(min(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                     max = as.Date(max(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                     view = "months",
                     minView = "months",
                     dateFormat = "MM yyyy",
                     language = input$selected_language,
                     addon = "none"
  )

})

collision_type_choices = sort(unique(hk_accidents$Type_of_Collision_with_cycle), decreasing = TRUE)

output$collision_type_filter_ui = renderUI({
  collapsibleAwesomeCheckboxGroupInput(
    inputId = "collision_type_filter", label = i18n$t("Collision type"),
    i = 3,
    # reverse alphabetical order
    choices = stats::setNames(
      collision_type_choices,
      lapply(collision_type_choices, function(x) {i18n$t(x)})
    ),
    selected = c("Vehicle collision with Pedestrian")
  ) %>%
    shinyhelper::helper(
      type = "markdown", colour = "#0d0d0d",
      content = "collision_type_filter"
    )
})

vehicle_class_choices = unique(hk_vehicles$Vehicle_Class)

output$vehicle_class_filter_ui = renderUI({
  collapsibleAwesomeCheckboxGroupInput(
    inputId = "vehicle_class_filter", label = i18n$t("Vehicle classes involved"),
    i = 2,
    choices = stats::setNames(
      vehicle_class_choices,
      lapply(vehicle_class_choices, function(x) {i18n$t(x)})
    )
    ,
    selected = unique(hk_vehicles$Vehicle_Class)
  ) %>%
    shinyhelper::helper(
      type = "markdown", colour = "#0d0d0d",
      content = "vehicle_class_filter"
    )
})




#############
## Main Map
#############

output$main_map <- renderLeaflet({
  overview_map <- leaflet(options = leafletOptions(minZoom = 11, preferCanvas = TRUE)) %>%
    # Set default location to Mong Kok
    setView(lng = 114.17, lat = 22.31, zoom = 16) %>%
    # Add geocoder map widget
    addSearchOSM(options = searchOptions(hideMarkerOnCollapse = TRUE))

  # addLayersControl and addProviderTiles needs to refer to the leaflet::providers list instead of vector
  SELECTED_BASEMAPS_LIST <- leaflet::providers[SELECTED_BASEMAPS]

  # Add the basemap tiles in background
  # http://rstudio.github.io/leaflet/morefeatures.html
  for (provider in SELECTED_BASEMAPS_LIST) {
    overview_map <- addProviderTiles(overview_map, provider, group = provider)
  }

  # Add change basemap widget
  addLayersControl(
    overview_map,
    baseGroups = names(SELECTED_BASEMAPS_LIST),
    options = layersControlOptions(collapsed = TRUE),
    position = "topleft"
    )
})

output$nrow_filtered <- reactive(format(nrow(filter_collision_data()), big.mark = ","))

# Filter the collision data according to users' input
filter_collision_data <- reactive({

  # Test for checking initialise value of date, will return TRUE when render airDatepickerInput in server side
  # message("is.null(input$end_month): ", is.null(input$end_month))

  # HACK: Temp workaround to fix non-initialised month value when airDatepickerInput renders in server side
  if (is.null(input$end_month)) {
    data_filtered = filter(hk_accidents_valid_sf,
                           year_month >= floor_date_to_month(as.Date("2016-01-01")) & year_month <= floor_date_to_month(as.Date("2016-12-01")))
  } else {
    data_filtered = filter(hk_accidents_valid_sf,
                           year_month >= floor_date_to_month(input$start_month) & year_month <= floor_date_to_month(input$end_month))
  }


  message("Min date in filtered data: ", min(data_filtered$Date_Time))
  message("Max date in filtered data: ", max(data_filtered$Date_Time))

  data_filtered = filter(data_filtered, Type_of_Collision_with_cycle %in% input$collision_type_filter)

  data_filtered = filter(data_filtered, Severity %in% input$severity_filter)

  data_filtered = filter(data_filtered, District_Council_District %in% input$district_filter)

  # Get the serial numbers (in vector form) where vehicles involved includes users' selected vehicle class
  accient_w_selected_veh <- filter(hk_vehicles, Vehicle_Class %in% input$vehicle_class_filter)

  # convert column to vector
  # remove duplicated serial number if there are more than 1 vehicle class
  accient_w_selected_veh_vct <- unique(accient_w_selected_veh[["Serial_No_"]])

  data_filtered <- filter(data_filtered, Serial_No_ %in% accient_w_selected_veh_vct)

  data_filtered
})

observe({
  # Template for popup, with summary of incidents
  popup_template = paste(

    # Control size of popups
    # https://stackoverflow.com/questions/29365749/how-to-control-popups-width-for-leaflet-features-popup-in-r
    "<style> div.leaflet-popup-content {width:200px !important;}</style>",

    # Square symbol indicating severity level
    # Use raw htmls since adding reactive expressions into tags$ will result in error
    "<div style=\"height:20px; width:20px; float:left; margin-right:10px; background-color:", fill_palette(filter_collision_data()$Severity) ,"\";>", "</div>",

    # Collision severity as title
    "<h3>", filter_collision_data()$Severity, " Collision</h3>",

    # Accident serial number
    tags$b("Serial number: "), filter_collision_data()$Serial_No_, tags$br(),

    # Accident date and time
    tags$b("Accident date: "), strftime(filter_collision_data()$Date_Time, "%d %b %Y %H:%M"), tags$br(),

    tags$br(),

    # District
    tags$b("District: "), filter_collision_data()$DC_full_name, tags$br(),
    # Street Name
    tags$b("Road name: "), filter_collision_data()$Street_Name, tags$br(),
    # Full address of collision location
    tags$b("Precise location: "), tags$br(), filter_collision_data()$Precise_Location, tags$br(),

    tags$br(),

    # Collision type
    tags$b("Collision type: "), tags$br(), filter_collision_data()$Type_of_Collision_with_cycle, tags$br(),

    tags$br(),

    # Number of vehicles involved
    tags$b("Number of vehicles: "), filter_collision_data()$No_of_Vehicles_Involved, tags$br(),
    # Involved vehicle class
    tags$b("Involved vehicle classes: "), filter_collision_data()$vehicle_class_involved, tags$br(),

    tags$br(),

    # Number of injuries
    tags$b("Number of casualties: "), filter_collision_data()$No_of_Casualties_Injured, tags$br(),
    # Involved casualty breakdown
    "(",
    filter_collision_data()$cas_dvr_n, " driver(s), ",
    filter_collision_data()$cas_pax_n, " passenger(s), ",
    filter_collision_data()$cas_ped_n, " pedestrian(s))",

    tags$br(),
    tags$br(),

    tags$b("Within 70 m of junctions? "), ifelse(filter_collision_data()$Within_70m, "Yes", "No"), tags$br(),
    tags$b("Road structure: "), filter_collision_data()$Structure_Type, tags$br(),
    tags$b("Road hierarchy: "), filter_collision_data()$Road_Hierarchy

  )

  leafletProxy(mapId = "main_map", data = filter_collision_data()) %>%
    clearMarkers() %>%
    clearMarkerClusters() %>%
    addCircleMarkers(
      # fixed point size symbol
      radius = 6,
      color = "#0d0d0d", weight = 2, opacity = .9,
      fillColor = ~ fill_palette(Severity), fillOpacity = .9,
      popup = popup_template,
      clusterOptions = markerClusterOptions(
        disableClusteringAtZoom = 16
      )
    )
})
