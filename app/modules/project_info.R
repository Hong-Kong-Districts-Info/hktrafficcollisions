# Terminology table
output$terminology_table = renderDataTable({
  datatable(
    terminology,
    rownames = FALSE,
    # Show all rows in one single page
    options = list(
      # only show the filtering box (f) and the table (t)
      dom = 'ft',
      # Show all rows in one single page
      pageLength = 100
      )
    )
})
