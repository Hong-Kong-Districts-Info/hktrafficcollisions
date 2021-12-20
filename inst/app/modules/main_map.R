# Get information of all types of vehicles involved in the accidents to show in popup
# TODO: prepare following mutated dataset before running shiny to save loading time?
hk_vehicles_involved <- hk_vehicles %>%
  group_by(Serial_No_) %>%
  summarize(vehicle_class_involved = paste(sort(unique(Vehicle_Class)), collapse = ", "))

# Get casualty role involved in each accident to show in popup
casualty_role_n = hk_casualties %>% count(Serial_No_, Role_of_Casualty)

accidents_cas_type <- casualty_role_n %>%
  pivot_wider(
    id_cols = Serial_No_,
    names_from = Role_of_Casualty,
    values_from = n, values_fill = 0
  ) %>%
  rename(cas_ped_n = Pedestrian, cas_pax_n = Passenger, cas_dvr_n = Driver)


# Add date floored to first day of the month for easier month filter handling
hk_accidents <- mutate(hk_accidents, year_month = floor_date_to_month(Date_Time))

hk_accidents_join <- hk_accidents %>%
  left_join(accidents_cas_type, by = "Serial_No_") %>%
  left_join(hk_vehicles_involved, by = "Serial_No_") %>%
  # Show full name of district in popup of maps
  left_join(data.frame(DC_Abbr = DISTRICT_ABBR, DC_full_name = DISTRICT_FULL_NAME),
            by = c("District_Council_District" = "DC_Abbr"))

hk_accidents_valid <- filter(hk_accidents_join, !is.na(latitude) & !is.na(longitude))

# Leaflet default expect WGS84 (crs 4326), need custom CRS for HK1980 Grid (crs 2326)
# https://rstudio.github.io/leaflet/projections.html
hk_accidents_valid_sf <- st_as_sf(x = hk_accidents_valid, coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)

output$main_map <- renderLeaflet({
  overview_map <- leaflet() %>%
    setView(lng = 114.2, lat = 22.3, zoom = 12) %>%
    # Add geocoder map widget
    addSearchOSM(options = searchOptions(hideMarkerOnCollapse = TRUE))

  # Subset basemap providers to be used for the map
  SELECTED_BASEMAPS <- leaflet::providers[c("Stamen.TonerLite", "CartoDB.Positron", "OpenStreetMap")]

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

output$nrow_filtered <- reactive(format(nrow(filter_collision_data()), big.mark = ","))

# Filter the collision data according to users' input
filter_collision_data <- reactive({

  data_filtered = filter(hk_accidents_valid_sf,
                         year_month >= floor_date_to_month(input$start_month) & year_month <= floor_date_to_month(input$end_month))

  message("Min date in filtered data: ", min(data_filtered$Date_Time))
  message("Max date in filtered data: ", max(data_filtered$Date_Time))

  data_filtered = filter(data_filtered, Type_of_Collision_with_cycle %in% input$collision_type_filter)

  data_filtered = filter(data_filtered, Severity %in% input$severity_filter)

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
      radius = 7.5,
      color = "#FFFFFF", weight = 1, opacity = .75,
      fillColor = ~ fill_palette(Severity), fillOpacity = .75,
      popup = popup_template,
      clusterOptions = markerClusterOptions(
        disableClusteringAtZoom = 16
      )
    )
})
