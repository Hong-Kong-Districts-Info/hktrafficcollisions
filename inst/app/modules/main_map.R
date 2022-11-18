#############
## Filter UI
#############

observeEvent(input$zoom_to_pts, {
  data_bbox = st_bbox(filter_collision_data())

  fitBounds(
    leafletProxy("main_map"),
    data_bbox[["xmin"]], data_bbox[["ymin"]], data_bbox[["xmax"]], data_bbox[["ymax"]]
    )
})

output$district_filter_ui = renderUI({
  selectizeInput(
    inputId = "district_filter",
    label = i18n$t("District(s)"),
    choices = stats::setNames(
      DISTRICT_ABBR,
      lapply(DISTRICT_FULL_NAME, function(x) i18n$t(x))
    ),
    multiple = TRUE,
    selected = DISTRICT_ABBR,
    options = list(placeholder = 'Select districts')
  ) %>%
    shinyhelper::helper(
      type = "markdown", colour = "#0d0d0d",
      content = "filter_district"
    )
})

output$month_range_ui = renderUI({
  airDatepickerInput("month_range",
                     label = i18n$t("Date range"),
                     range = TRUE,
                     value = c("2016-01-01", "2016-12-01"),
                     min = as.Date(min(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                     max = as.Date(max(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                     view = "months",
                     minView = "months",
                     monthsField = "monthsShort",
                     dateFormat = "MMM yyyy",
                     language = input$selected_language,
                     addon = "none"
  ) %>%
    shinyhelper::helper(
      type = "markdown", colour = "#0d0d0d",
      content = "filter_date"
    )
})

output$severity_filter_ui = renderUI({
  checkboxGroupButtons(
    inputId = "severity_filter", label = i18n$t("Collision severity"),
    # TODO: use sprintf and global SEVERITY_COLOR constant for mapping icon color
    choiceNames = c(
      paste0('<div style="display: flex;justify-content: center;align-items: center;"><span class="filter__circle-marker" style="background-color: #FF4039;"></span><span class="filter__text">', i18n$t("Fatal"), '</span></div>'),
      paste0('<div style="display: flex;justify-content: center;align-items: center;"><span class="filter__circle-marker" style="background-color: #FFB43F;"></span><span class="filter__text">', i18n$t("Serious"), '</span></div>'),
      paste0('<div style="display: flex;justify-content: center;align-items: center;"><span class="filter__circle-marker" style="background-color: #FFE91D"></span><span class="filter__text">', i18n$t("Slight"), '</span></div>')
    ),
    choiceValues = c(
      "Fatal",
      "Serious",
      "Slight"
    ),
    selected = unique(hk_accidents$Severity),
    direction = "vertical",
    justified = TRUE
  ) %>%
    shinyhelper::helper(
      type = "markdown", colour = "#0d0d0d",
      content = "filter_severity"
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
      content = "filter_collision_type"
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
      content = "filter_vehicle_class"
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
filter_collision_data <-
  debounce(
    # Run the query 0.75 s after user stops changing filter inputs
    millis = 750,
    r = reactive({

      # Test for checking initialise value of date, will return TRUE when render airDatepickerInput in server side
      # message("is.null(input$end_month): ", is.null(input$end_month))

      # HACK: Temp workaround to fix non-initialised month value when airDatepickerInput renders in server side
      if (is.null(input$month_range)) {
        data_filtered = filter(hk_accidents_valid_sf,
                               year_month >= floor_date_to_month(as.Date("2016-01-01")) & year_month <= floor_date_to_month(as.Date("2016-12-01")))
      } else {
        data_filtered = filter(hk_accidents_valid_sf,
                               year_month >= floor_date_to_month(input$month_range[1]) & year_month <= floor_date_to_month(input$month_range[2]))
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

      # Show at most 20,000 points on the map to ensure performance
      if (nrow(data_filtered) > 20000) {

        showNotification(
          paste(
            "
            地圖不能顯示所有符合篩選條件的車禍。
            此地圖只可以同時顯示最多 20,000 宗車禍，而現有篩選條件包含超過 20,000 宗車禍。
            地圖只會顯示首 20,000 宗符合條件的車禍。
            請更改篩選條件（如刪除地區，縮短日期範圍）以顯示所有符合篩選條件之車禍。
            ",
            "
            The map cannot show all collisions matching the requirements.
            The total number of collisions included in current filter settings exceeds the rendering capacity (20,000 points) of the map.
            Only the first 20,000 records are shown on the map.
            Change the filters (e.g. remove districts outside your area of interest, shortern the time frame) to show all filtered records.
            "
            , collapse = "<br/>"),
          type = "error",
          duration = NULL,
        )

        return(data_filtered[1:20000,])
      }

      data_filtered
    })
  )



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
    "<h3>", i18n$t(paste0(filter_collision_data()$Severity, " Collision")), "</h3>",

    # Accident serial number
    tags$b(i18n$t("Serial number: ")), filter_collision_data()$Serial_No_, tags$br(),

    # Accident date and time
    tags$b(i18n$t("Collision date: ")), strftime(filter_collision_data()$Date_Time, "%d %b %Y %H:%M"), tags$br(),

    tags$br(),

    # District
    tags$b(i18n$t("District: ")), i18n$t(filter_collision_data()$DC_full_name), tags$br(),
    # Street Name
    tags$b(i18n$t("Road name: ")), filter_collision_data()$Street_Name, tags$br(),
    # Full address of collision location
    tags$b(i18n$t("Precise location: ")), tags$br(), filter_collision_data()$Precise_Location, tags$br(),

    tags$br(),

    # Collision type
    tags$b(i18n$t("Collision type: ")), tags$br(), i18n$t(filter_collision_data()$Type_of_Collision_with_cycle), tags$br(),

    tags$br(),

    # Number of vehicles involved
    tags$b(i18n$t("Number of vehicles: ")), filter_collision_data()$No_of_Vehicles_Involved, tags$br(),
    # Involved vehicle class
    # FIXME: Can't translate when collision includes >1 vehicle type
    tags$b(i18n$t("Involved vehicle classes: ")), suppressWarnings(i18n$t(filter_collision_data()$vehicle_class_involved)), tags$br(),

    tags$br(),

    # Number of injuries
    tags$b(i18n$t("Number of casualties: ")), filter_collision_data()$No_of_Casualties_Injured, tags$br(),
    # Involved casualty breakdown
    "(",
    filter_collision_data()$cas_dvr_n, i18n$t(" driver(s)"), ", ",
    filter_collision_data()$cas_pax_n, i18n$t(" passenger(s)"), ", ",
    filter_collision_data()$cas_ped_n, i18n$t(" pedestrian(s)"), ")",

    tags$br(),
    tags$br(),

    tags$b(i18n$t("Within 70 m of junctions? ")), ifelse(filter_collision_data()$Within_70m, i18n$t("Yes"), i18n$t("No")), tags$br(),
    tags$b(i18n$t("Road structure: ")), i18n$t(filter_collision_data()$Structure_Type), tags$br(),
    # Suppress warning message from i18n when `Road_Hierarchy` is NA
    # TODO: Transform NA to ''?
    tags$b(i18n$t("Road hierarchy: ")), suppressWarnings(i18n$t(filter_collision_data()$Road_Hierarchy)),

    tags$br(),
    tags$br(),

    # Use raw HTML since using tags$a() will result in error which link of all rows are included
    # Because tags$a() vectorise and include all rows in one popup?
    "<a href='",
    # URL link of the street view, with bearing/zoom/tilt all set to 0
    # https://developers.google.com/maps/documentation/urls/android-intents#display-a-street-view-panorama
    "https://maps.google.com/?cbll=", filter_collision_data()$latitude, ",", filter_collision_data()$longitude, "&cbp=0,0,0,0,0&layer=c",
    # open page in new tab
    "' target='_blank' rel='noopener noreferrer'>",
    i18n$t("View this location in Google Street View"),
    "</a>"

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
