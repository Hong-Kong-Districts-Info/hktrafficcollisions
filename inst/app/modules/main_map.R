
CARTODB_POSITRON_TILE_URL <- "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png"

output$main_map <- renderLeaflet({
  leaflet() %>%
    addTiles(urlTemplate = CARTODB_POSITRON_TILE_URL) %>%
    setView(114.2, 22.3, zoom = 12)
})


