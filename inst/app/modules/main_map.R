
output$main_map <- renderLeaflet({
  leaflet() %>%
    addTiles() %>%
    setView(114.2, 22.3, zoom = 12)
})


