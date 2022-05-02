
# Interactive heatmap
output$hotspots_map = renderTmap({

  tm_shape(hotzone_streets) +
    tm_lines(
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
