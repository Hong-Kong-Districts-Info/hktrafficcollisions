
# Add tile from mapbox style
# https://docs.mapbox.com/studio-manual/guides/publish-your-style/
COLLISION_PTS_TILE_URL = paste0(
  "https://api.mapbox.com/styles/v1/khwong12/ckz18sv3a004415qrmcs9geal/tiles/256/{z}/{x}/{y}?access_token=",
  Sys.getenv("MAPBOX_PUBLIC_TOKEN")
  )

# Cannot directly use i18n$t() inside names of the value, thus need to create two separate vectors to store the names
# Order of vector is also used to decide the order of columns to be shown in the hotzone interactive table
TABLE_COLUMN_NAMES_EN = c(
  "Rank" = "Area_RK",
  "Zoom to the Zone" = "zoom_in_map_link",
  "Section Length (m)" = "Road_Length",
  "No. of collisions between 2015 - 2019" = "N_Colli",
  "Collision Density (No. of collisions per km of road)" = "Colli_Density",
  "Hot Zone Name" = "Name",
  "District" = "District"
)

TABLE_COLUMN_NAMES_ZH = c(
  "排名" = "Area_RK",
  "於互動地圖顯示此路段" = "zoom_in_map_link",
  "重災區路段長度（米）" = "Road_Length",
  "2015 至 2019 年期間該路段發生之行人相關車禍總數" = "N_Colli",
  "推算每公里車禍總數" = "Colli_Density",
  "車禍熱區路段" = "Name_zh",
  "地區" = "District_zh"
)

POPUP_COLUMN_NAMES_EN = c(
  "Rank: " = "Area_RK",
  "Collision Density (collisions/km): " = "Colli_Density",
  "Collisions between 2015 to 2019: " = "N_Colli",
  "Segement Length (m): " = "Road_Length"
)

POP_COLUMN_NAMES_ZH = c(
  "排名：" = "Area_RK",
  "推算每公里車禍總數：" = "Colli_Density",
  "2015 至 2019 年期間該路段發生之行人相關車禍總數：" = "N_Colli",
  "重災區路段長度（米）：" = "Road_Length"
)


# Interactive heatmap
output$hotzones_map = renderTmap({

  tm_shape(hotzone_streets) +
    tm_lines(
      group = i18n$t("Hotzone streets"),
      title.col = i18n$t("Hotzone Rank"),
      id = if(input$selected_language == "en") {"Name"} else {"Name_zh"},
      col = "Area_RK",
      lwd = 7.5,
      palette = "inferno",
      # Use only first half of inferno palette as the light color part does not show well on grey basemap
      contrast = c(0, .5),
      n = max(hotzone_streets[["Area_RK"]]),
      style = "cont",
      alpha = 1,
      popup.vars = if(input$selected_language == "en") {POPUP_COLUMN_NAMES_EN} else {POP_COLUMN_NAMES_ZH}
    ) +
    tm_tiles(COLLISION_PTS_TILE_URL, group = i18n$t("Collisions with pedestrian injuries"))

})

observe({
  # escape initialise state
  if (is.null(input$goto)) return()

  isolate({
    map = leafletProxy("hotzones_map")

    lat = input$goto$lat
    lng = input$goto$lng

    setView(map, lng, lat, zoom = 17)
  })
})

output$hotzones_table = renderDataTable({

  # Get the columns to show according to users' selected language
  if(input$selected_language == "en") {
    hotzone_dt_table = hotzone_out_df[,TABLE_COLUMN_NAMES_EN]
  } else {
    hotzone_dt_table = hotzone_out_df[,TABLE_COLUMN_NAMES_ZH]
  }

  # `rownames` needs to be consistent with `DT::datatable` option
  action = DT::dataTableAjax(session, hotzone_dt_table, rownames = FALSE)

  datatable(
    hotzone_dt_table,
    colnames = if(input$selected_language == "en") {TABLE_COLUMN_NAMES_EN} else {TABLE_COLUMN_NAMES_ZH},
    rownames = FALSE,
    options = list(
      # Change interface language according to user selected language
      # See https://rstudio.github.io/DT/004-i18n.html & https://datatables.net/plug-ins/i18n/
      language = list(
        url =
          if(input$selected_language == "en") {
            "https://cdn.datatables.net/plug-ins/1.12.1/i18n/en-GB.json"
          } else {
            "https://cdn.datatables.net/plug-ins/1.12.1/i18n/zh-HANT.json"
          }),
      # Set up AJAX
      ajax = list(url = action)
    ),
    # Render HTML tags inside table (e.g. fontawesome icons in <i> tags)
    escape = FALSE
    ) %>%
    # Add in-cell bar chart for collision density
    formatStyle(
      columns =
        if(input$selected_language == "en") {
          names(TABLE_COLUMN_NAMES_EN)[TABLE_COLUMN_NAMES_EN == "Colli_Density"]
          } else {
          names(TABLE_COLUMN_NAMES_ZH)[TABLE_COLUMN_NAMES_ZH == "Colli_Density"]
          },
      # start the bar from left
      background = styleColorBar(c(0, max(hotzone_streets[["Colli_Density"]])), 'steelblue', angle = -90),
      # fix vertical length to avoid differences in the height of the bar when row height varies
      backgroundSize = '100% 2rem',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'right'
    )
})
