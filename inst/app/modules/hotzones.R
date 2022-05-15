
# Add tile from mapbox style
# https://docs.mapbox.com/studio-manual/guides/publish-your-style/
COLLISION_PTS_TILE_URL = "https://api.mapbox.com/styles/v1/khwong12/ckz18sv3a004415qrmcs9geal/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia2h3b25nMTIiLCJhIjoiY2ptMGJqMHh2MGFzZjNsbXl2MjVuMGl1biJ9.N5P5k0byVnsWeBg6iLObww"

TABLE_COLUMN_NAMES = c(
  "Hot Zone Name" = "Name",
  "District" = "District",
  "Rank" = "Area_RK",
  "Section Length (m)" = "Road_Length",
  "No. of collisions between 2015 - 2019" = "N_Colli",
  "Collision Density (No. of collisions per km of road)" = "Colli_Density",
  "Zoom to the Zone" = "zoom_in_map_link"
)


# Interactive heatmap
output$hotspots_map = renderTmap({

  tm_tiles(COLLISION_PTS_TILE_URL, group = "Collisions with pedestrian injuries") +
    tm_shape(hotzone_streets) +
    tm_lines(
      group = "Hotzone streets",
      title.col = "Hotzone Rank",
      id = "Name",
      col = "Area_RK",
      lwd = 2.5,
      palette = "inferno",
      # Use only first half of inferno palette as the light color part does not show well on grey basemap
      contrast = c(0, .5),
      n = max(hotzone_streets[["Area_RK"]]),
      style = "cont",
      alpha = 1,
      popup.vars = c(
        "Rank: " = "Area_RK",
        "Collision Density (collisions/km): " = "Colli_Density",
        "Collisions between 2015 to 2019: " = "N_Colli",
        "Segement Length (m): " = "Road_Length"
        )
    )

})

observe({
  # escape initialise state
  if (is.null(input$goto)) return()

  isolate({
    map = leafletProxy("hotspots_map")

    lat = input$goto$lat
    lng = input$goto$lng

    setView(map, lng, lat, zoom = 17)
  })
})

output$hotspots_table = renderDataTable({

  # `rownames` needs to be consistent with `DT::datatable` option
  action = DT::dataTableAjax(session, hotzone_out_df, rownames = FALSE)

  datatable(
    hotzone_out_df,
    colnames = TABLE_COLUMN_NAMES,
    rownames = FALSE,
    options = list(ajax = list(url = action)),
    # Render HTML tags inside table (e.g. fontawesome icons in <i> tags)
    escape = FALSE
    ) %>%
    # Add in-cell bar chart for collision density
    formatStyle(
      "Collision Density (No. of collisions per km of road)",
      # start the bar from left
      background = styleColorBar(c(0, max(hotzone_streets[["Colli_Density"]])), 'steelblue', angle = -90),
      # fix vertical length to avoid differences in the height of the bar when row height varies
      backgroundSize = '100% 2rem',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'right'
    )
})
