output$plotly_testvisual = renderPlotly(
  {
    hk_accidents %>%
      ggplot(aes(x = Type_of_Collision)) +
      geom_histogram(stat = "count")
  }
)
