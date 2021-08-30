
# Get information of all types of vehicles involved in the accidents to show in popup
# TODO: prepare following mutated dataset before running shiny to save loading time?
hk_vehicles_involved <- hk_vehicles %>%
  group_by(Serial_No_) %>%
  summarize(vehicle_class_involved = paste(sort(unique(Vehicle_Class)), collapse = ", "))

# Get casualty role involved in each accident to show in popup
accidents_cas_type <- hk_casualties %>%
  group_by(Serial_No_) %>%
  summarise(
    include_ped = any(Role_of_Casualty == "Pedestrian"),
    include_pax = any(Role_of_Casualty == "Passenger"),
    include_dvr = any(Role_of_Casualty == "Driver")
  )

hk_accidents_join <- hk_accidents %>%
  left_join(accidents_cas_type, by = "Serial_No_") %>%
  left_join(hk_vehicles_involved, by = "Serial_No_")

hk_accidents_valid <- filter(hk_accidents_join, !is.na(latitude) & !is.na(longitude))

# Leaflet default expect WGS84 (crs 4326), need custom CRS for HK1980 Grid (crs 2326)
# https://rstudio.github.io/leaflet/projections.html
hk_accidents_valid_sf <- st_as_sf(x = hk_accidents_valid, coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)

# Need to convert to POSIXct again, otherwise reactive filtering does not work
# TODO: investigate why
hk_accidents_valid_sf$Date <- as.Date(hk_accidents_valid_sf$Date, format = "%Y-%m-%d")

# Combine date and time together as a complete POSIXct class time column
# Easier for formatting
hk_accidents_valid_sf$Date_Time <- as.POSIXct(
  strptime(
    paste0(hk_accidents_valid_sf$Date, " ", hk_accidents_valid_sf$Time),
    format = "%Y-%m-%d %H%M",
    tz = "Asia/Hong_Kong"
    )
  )


output$main_map <- renderLeaflet({
  overview_map <- leaflet() %>%
    setView(lng = 114.2, lat = 22.3, zoom = 12) %>%
    # Add geocoder map widget
    addSearchOSM(options = searchOptions(hideMarkerOnCollapse = TRUE))

  # Subset basemap providers to be used for the map
  SELECTED_BASEMAPS <- leaflet::providers[c("CartoDB.Positron", "Stamen.TonerLite", "OpenStreetMap")]

  # Add the basemap tiles in background
  # http://rstudio.github.io/leaflet/morefeatures.html
  for (provider in SELECTED_BASEMAPS) {
    overview_map <- addProviderTiles(overview_map, provider, group = provider)
  }

  # Add change basemap widget
  addLayersControl(
    overview_map,
    baseGroups = names(SELECTED_BASEMAPS),
    options = layersControlOptions(collapsed = TRUE),
    position = "topleft"
    )
})

output$nrow_filtered <- reactive(nrow(filter_collision_data()))

# Filter the collision data according to users' input
filter_collision_data <- reactive({

  data_filtered = filter(hk_accidents_valid_sf, Date >= input$date_filter[1] & Date <= input$date_filter[2])

  data_filtered = filter(data_filtered,
                                No_of_Casualties_Injured >= input$n_causality_filter[1] & No_of_Casualties_Injured <= input$n_causality_filter[2])

  data_filtered = filter(data_filtered, Type_of_Collision %in% input$collision_type_filter)

  data_filtered = filter(data_filtered, Severity %in% input$severity_filter)

  # Get the serial numbers (in vector form) where vehicles involved includes users' selected vehicle class
  accient_w_selected_veh <- filter(hk_vehicles, Vehicle_Class %in% input$vehicle_class_filter)

  # convert column to vector
  # remove duplicated serial number if there are more than 1 vehicle class
  accient_w_selected_veh_vct <- unique(accient_w_selected_veh[["Serial_No_"]])

  data_filtered <- filter(data_filtered, Serial_No_ %in% accient_w_selected_veh_vct)

  # --- Casualty filter ---
  accident_w_selected_cas <- filter(hk_casualties, Role_of_Casualty %in% input$casualty_filter)
  accident_w_selected_cas_vct <- unique(accident_w_selected_cas[["Serial_No_"]])

  data_filtered <- filter(data_filtered, Serial_No_ %in% accident_w_selected_cas_vct)

  data_filtered
})

# Fill color palette according to the severity of the accident
fill_palette <- colorFactor(palette = c("#230B4C", "#C03A51", "#F1701E"), domain = c("Fatal", "Serious", "Slight"))


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
    tags$b("Serial number: "), tags$br(), filter_collision_data()$Serial_No_, tags$br(),

    # Accident date and time
    tags$b("Accident date: "), tags$br(), strftime(filter_collision_data()$Date_Time, "%d %b %Y %H:%M"), tags$br(),
    # Full address of collision location
    tags$b("Precise location: "), tags$br(), "TODO", tags$br(),
    # District
    tags$b("District: "), tags$br(), filter_collision_data()$District_Council_District, tags$br(),
    # Number of injuries
    tags$b("Number of casualties: "), tags$br(), filter_collision_data()$No_of_Casualties_Injured, tags$br(),
    # Involved vehicle class
    tags$b("Involved vehicle classes: "), tags$br(), filter_collision_data()$vehicle_class_involved, tags$br(),
    # Involved casualty
    tags$b("Involved casualty role: "), tags$br(),
    tags$b("Pedestrian: "), filter_collision_data()$include_ped, tags$br(),
    tags$b("Passenger: "), filter_collision_data()$include_pax, tags$br(),
    tags$b("Driver: "), filter_collision_data()$include_dvr
    )

  leafletProxy(mapId = "main_map", data = filter_collision_data()) %>%
    clearMarkers() %>%
    addCircleMarkers(
      # fixed point size symbol
      radius = 2.5,
      color = "#FFFFFF", weight = 1, opacity = .75,
      fillColor = ~ fill_palette(Severity), fillOpacity = .75,
      popup = popup_template
      )
})
