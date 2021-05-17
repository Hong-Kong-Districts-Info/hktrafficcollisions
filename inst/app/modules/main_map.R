
hk_accidents_valid <- filter(hk_accidents, !is.na(latitude) & !is.na(longitude))

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

CARTODB_POSITRON_TILE_URL <- "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png"

output$main_map <- renderLeaflet({
  leaflet() %>%
    addTiles(urlTemplate = CARTODB_POSITRON_TILE_URL) %>%
    setView(lng = 114.2, lat = 22.3, zoom = 12)
})

output$nrow_filtered <- reactive(nrow(filter_collision_data()))

# Filter the collision data according to users' input
filter_collision_data <- reactive({

  data_filtered = filter(hk_accidents_valid_sf, Date >= input$date_filter[1] & Date <= input$date_filter[2])

  data_filtered = filter(data_filtered,
                                No__of_Casualties_Injured >= input$n_causality_filter[1] & No__of_Casualties_Injured <= input$n_causality_filter[2])

  data_filtered = filter(data_filtered, Type_of_Collision %in% input$collision_type_filter)

  data_filtered = filter(data_filtered, Severity %in% input$severity_filter)

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

    # Accident date and time
    tags$b("Accident date: "), tags$br(), strftime(filter_collision_data()$Date_Time, "%d %b %Y %H:%M"), tags$br(),
    # Full address of collision location
    tags$b("Precise location: "), tags$br(), "TODO", tags$br(),
    # District
    tags$b("District: "), tags$br(), filter_collision_data()$District_Council_District, tags$br(),
    # Number of injuries
    tags$b("Number of casualties: "), tags$br(), filter_collision_data()$No__of_Casualties_Injured, tags$br(),
    # Involved parties
    tags$b("Involved parties: "), tags$br(), "TODO", tags$br()
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
