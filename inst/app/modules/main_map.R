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
    selected = c("CW", "WCH", "E", "S", "YTM", "SSP", "KC", "WTS", "KT"),
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
                     value = c("2023-01-01", "2023-12-01"),
                     min = as.Date(min(hk_collisions$date_time), tz = "Asia/Hong_Kong"),
                     max = as.Date(max(hk_collisions$date_time), tz = "Asia/Hong_Kong"),
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
    selected = unique(hk_collisions$severity),
    direction = "vertical",
    justified = TRUE
  ) %>%
    shinyhelper::helper(
      type = "markdown", colour = "#0d0d0d",
      content = "filter_severity"
    )
})


collision_type_choices =
  c(
    "Vehicle collision with Vehicle", "Vehicle collision with Pedestrian", "Vehicle collision with Pedal Cycle",
    "Vehicle collision with Object", "Vehicle collision with Nothing", "Pedal Cycle collision with Pedestrian",
    "Pedal Cycle collision with Pedal Cycle", "Pedal Cycle collision with Object", "Pedal Cycle collision with Nothing",
    "Unknown vehicle collision type"
  )

output$collision_type_filter_ui = renderUI({
  checkboxGroupInput(
    inputId = "collision_type_filter", label = i18n$t("Collision type"),
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

vehicle_class_choices = unique(hk_vehicles$vehicle_class)

output$vehicle_class_filter_ui = renderUI({
  checkboxGroupInput(
    inputId = "vehicle_class_filter", label = i18n$t("Vehicle classes involved"),
    choices = stats::setNames(
      vehicle_class_choices,
      lapply(vehicle_class_choices, function(x) {i18n$t(x)})
    )
    ,
    selected = unique(hk_vehicles$vehicle_class)
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
  overview_map <- leaflet(
    options = leafletOptions(
      minZoom = 11, 
      preferCanvas = TRUE,
      zoomControl = TRUE,
      attributionControl = TRUE
    )
  ) %>%
    # Set default location to Mong Kok
    setView(lng = 114.17, lat = 22.31, zoom = 16) %>%
    # Add geocoder map widget
    addSearchOSM(
      options = searchOptions(
        hideMarkerOnCollapse = TRUE,
        position = "topleft"
      )
    )

  # addLayersControl and addProviderTiles needs to refer to the leaflet::providers list instead of vector
  SELECTED_BASEMAPS_LIST <- leaflet::providers[SELECTED_BASEMAPS]

  # Add the basemap tiles in background
  # http://rstudio.github.io/leaflet/morefeatures.html
  for (provider in SELECTED_BASEMAPS_LIST) {
    overview_map <- addProviderTiles(overview_map, provider, group = provider)
  }

  # Add change basemap widget
  overview_map %>%
    addLayersControl(
      baseGroups = names(SELECTED_BASEMAPS_LIST),
      options = layersControlOptions(collapsed = TRUE),
      position = "topleft"
    ) %>%
    # Add fullscreen control
    addFullscreenControl(position = "topleft") %>%
    # Add zoom control
    addScaleBar(position = "bottomleft")
})

output$nrow_filtered <- reactive({

  n_filtered = format(nrow(filter_collision_data()), big.mark = ",")

  if(input$selected_language == "en"){
    glue::glue("{n_filtered} collisions filtered")
  } else {
    glue::glue("已篩選 {n_filtered} 宗車禍")
  }
})

# Filter the collision data according to users' input
filter_collision_data <-
  debounce(
    # Run the query 0.75 s after user stops changing filter inputs
    millis = 750,
    r = reactive({

      # Ensure month filter values are initialised when airDatepickerInput renders in server side
      req(
        input$month_range
      )

      data_filtered = filter(hk_collisions_valid_sf,
                             year_month >= floor_date_to_month(input$month_range[1]) & year_month <= floor_date_to_month(input$month_range[2]))

      data_filtered = filter(data_filtered, collision_type_with_cycle %in% input$collision_type_filter)

      data_filtered = filter(data_filtered, severity %in% input$severity_filter)

      data_filtered = filter(data_filtered, district %in% input$district_filter)

      # Get the serial numbers (in vector form) where vehicles involved includes users' selected vehicle class
      accient_w_selected_veh <- filter(hk_vehicles, vehicle_class %in% input$vehicle_class_filter)

      # convert column to vector
      # remove duplicated serial number if there are more than 1 vehicle class
      accient_w_selected_veh_vct <- unique(accient_w_selected_veh[["serial_no"]])

      data_filtered <- filter(data_filtered, serial_no %in% accient_w_selected_veh_vct)

      # Show at most 5,000 points on the map to ensure performance
      if (nrow(data_filtered) > 5000) {

        showModal(modalDialog(
          title = "⚠️ 地圖無法顯示所有符合篩選條件的車禍 | The map cannot display all collisions matching your filter criteria",
          tags$ul(
            tags$li("此地圖只可以同時顯示最多 5,000 宗車禍，而符合您目前篩選條件的車禍已超過此數量。"),
            tags$li("請調整篩選條件（如縮小地區範圍／縮短日期範圍）以顯示所有符合篩選條件之車禍。"),
            br(),
            tags$li("The map can only display up to 5,000 collisions at once, and your current filters exceed this limit."),
            tags$li("Adjust your filters (e.g., narrow the districts/shorten the date range) to view all qualifying collisions.")
          ),
          easyClose = TRUE
        ))

        return(data_filtered[1:5000,])
      }

      data_filtered
    })
  )

# Update map markers when data is filtered
observe({

  # Template for popup, with summary of incidents
  popup_template = paste(

    # Control size of popups
    # https://stackoverflow.com/questions/29365749/how-to-control-popups-width-for-leaflet-features-popup-in-r
    "<style> div.leaflet-popup-content {width:200px !important;}</style>",

    # Square symbol indicating severity level
    # Use raw htmls since adding reactive expressions into tags$ will result in error
    "<div style=\"height:20px; width:20px; float:left; margin-right:10px; background-color:", fill_palette(filter_collision_data()$severity) ,"\";>", "</div>",

    # Collision severity as title
    "<h3>", i18n$t(paste0(filter_collision_data()$severity, " Collision")), "</h3>",

    # Accident serial number
    tags$b(i18n$t("Serial number"), ": "), filter_collision_data()$serial_no, tags$br(),

    # Accident date and time
    tags$b(i18n$t("Collision date"), ": "), strftime(filter_collision_data()$date_time, "%d %b %Y %H:%M"), tags$br(),

    tags$br(),

    # District
    tags$b(i18n$t("District"), ": "), i18n$t(filter_collision_data()$DC_full_name), tags$br(),
    # Street Name
    tags$b(i18n$t("Road name"), ": "), filter_collision_data()$street_name, tags$br(),
    # Full address of collision location
    tags$b(i18n$t("Precise location"), ": "), tags$br(), filter_collision_data()$precise_location, tags$br(),

    tags$br(),

    # Collision type
    tags$b(i18n$t("Collision type"), ": "), tags$br(), i18n$t(filter_collision_data()$collision_type_with_cycle), tags$br(),

    tags$br(),

    # Number of vehicles involved
    tags$b(i18n$t("Number of vehicles"), ": "), filter_collision_data()$n_vehicles, tags$br(),
    # Involved vehicle class
    # FIXME: Can't translate when collision includes >1 vehicle type
    tags$b(i18n$t("Involved vehicle classes"), ": "), suppressWarnings(i18n$t(filter_collision_data()$vehicle_class_involved)), tags$br(),

    tags$br(),

    # Number of injuries
    tags$b(i18n$t("Number of casualties")), filter_collision_data()$n_casualties, tags$br(),
    # Involved casualty breakdown
    "(",
    filter_collision_data()$cas_dvr_n, i18n$t(" driver(s)"), ", ",
    filter_collision_data()$cas_pax_n, i18n$t(" passenger(s)"), ", ",
    filter_collision_data()$cas_ped_n, i18n$t(" pedestrian(s)"), ")",

    tags$br(),
    tags$br(),

    tags$b(i18n$t("Within 70 m of junctions? ")), ifelse(filter_collision_data()$in_70m_junction, i18n$t("Yes"), i18n$t("No")), tags$br(),
    tags$b(i18n$t("Road structure"), ": "), suppressWarnings(i18n$t(filter_collision_data()$structure_type)), tags$br(),
    # Suppress warning message from i18n when `Road_Hierarchy` is NA
    # TODO: Transform NA to ''?
    tags$b(i18n$t("Road hierarchy"), ": "), suppressWarnings(i18n$t(filter_collision_data()$road_hierarchy)),

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
      fillColor = ~ fill_palette(severity), fillOpacity = .9,
      popup = popup_template,
      clusterOptions = markerClusterOptions(
        disableClusteringAtZoom = 15
      )
    )
})
