
# Add tile from mapbox style
# https://docs.mapbox.com/studio-manual/guides/publish-your-style/
COLLISION_PTS_TILE_URL = "https://api.mapbox.com/styles/v1/khwong12/ckyxixwuc006b14t8gyghov8v/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia2h3b25nMTIiLCJhIjoiY2ptMGJqMHh2MGFzZjNsbXl2MjVuMGl1biJ9.N5P5k0byVnsWeBg6iLObww"

# Interactive heatmap
output$hotspots_map = renderTmap({

  tm_tiles(COLLISION_PTS_TILE_URL, group = "Collisions with pedestrian injuries") +
    tm_shape(hotzone_streets) +
    tm_lines(
      group = "Hotzone streets",
      title.col = "Hotzone Street Rank",
      col = "Area_RK",
      lwd = 2.5,
      palette = "inferno",
      # n = max(hotzone_streets[["Area_RK"]]),
      style = "cont",
      alpha = 0.8,
      # disable popups
      popup.vars = NA,
      # remove legend
      legend.show = FALSE
    )

})

output$hotspots_table = renderDataTable({
  datatable(st_drop_geometry(hotzone_streets))
})
