
hk_accidents_valid <- dplyr::filter(hk_accidents, !is.na(latitude) & !is.na(longitude))

# Leaflet default expect WGS84 (crs 4326), need custom CRS for HK1980 Grid (crs 2326)
# https://rstudio.github.io/leaflet/projections.html
hk_accidents_valid_sf <- st_as_sf(x = hk_accidents_valid, coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)

# Need to convert to POSIXct again, otherwise reactive filtering does not work
# TODO: investigate why
hk_accidents_valid_sf$Date <- as.Date(hk_accidents_valid_sf$Date, format = "%Y-%m-%d")

CARTODB_POSITRON_TILE_URL <- "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png"

output$main_map <- renderLeaflet({
  leaflet() %>%
    addTiles(urlTemplate = CARTODB_POSITRON_TILE_URL) %>%
    setView(lng = 114.2, lat = 22.3, zoom = 12)
})

output$nrow_filtered <- reactive(nrow(filter_collision_data()))

# Filter the collision data according to users' input
filter_collision_data <- reactive({

  data_filtered = dplyr::filter(hk_accidents_valid_sf, Date >= input$date_filter[1] & Date <= input$date_filter[2])

  data_filtered = dplyr::filter(data_filtered,
                                No__of_Casualties_Injured >= input$n_causality_filter[1] & No__of_Casualties_Injured <= input$n_causality_filter[2])

  data_filtered = filter(data_filtered, Type_of_Collision %in% input$collision_type_filter)

  data_filtered = filter(data_filtered, Severity %in% input$severity_filter)

  data_filtered
})

# Fill color palette according to the severity of the accident
fill_palette <- colorFactor(palette = c("#230B4C", "#C03A51", "#F1701E"), domain = c("Fatal", "Serious", "Slight"))

observe({
  leafletProxy(mapId = "main_map", data = filter_collision_data()) %>%
    # proportional symbols
    clearMarkers() %>%
    addCircleMarkers(
      # sqrt for proportional **area** of circles
      radius = ~ sqrt(No__of_Casualties_Injured) * 2.5,
      color = "#FFFFFF", weight = 1, opacity = .75,
      # fillColor = "#f0a3a3", fillOpacity = .75,
      fillColor = ~ fill_palette(Severity), fillOpacity = .75,
      popup = ~ paste("Accident date: ", Date, "<br>", "Number of casualties: ", No__of_Casualties_Injured))
})