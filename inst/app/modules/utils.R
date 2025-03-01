# -------- #
# utils.R #
# -------- #

# DESC: miscellaneous functions used to create the UI of the dashboard

# Floor date to first day of the month
floor_date_to_month <- function(x) {
  x <- as.POSIXlt(x)
  x$mday <- 1
  as.Date(x)
}

get_last_modified_date = function(directory) {
  paths = dir(directory, full.names=TRUE, recursive = TRUE)

  # column of last status change time
  last_modified_time = max(file.info(paths)[["ctime"]])

  # return in YYYY.MM.DD
  format(last_modified_time, "%Y.%m.%d")

}


# Generate a spatial grid from the bounding box of points (i.e. collisions),
# then count the number of points within each grid
#
# returns a sf class spatial grid with a count column named "n_colli"
count_collisions_in_grid = function(point_data, grid_size = c(150, 150)) {
  area_grid <- st_make_grid(point_data, grid_size, what = "polygons", square = TRUE)

  # To sf and add grid ID
  area_grid_count <- st_sf(area_grid) %>%
    mutate(grid_id = 1:length(lengths(area_grid)))

  # count number of points in each grid
  # https://gis.stackexchange.com/questions/323698/counting-points-in-polygons-with-sf-package-of-r
  area_grid_count$n_colli = lengths(st_intersects(area_grid_count, point_data))

  # remove grid without accidents
  area_grid_count = filter(area_grid_count, n_colli > 0)

  # return the grid in sf format
  area_grid_count
}

# Custom dateRangeInput with custom min and max view modes,
# by default only show 12 months view in the and hide date view
# https://stackoverflow.com/a/54922170/14131305
dateRangeInput2 <- function(inputId, label, minview = "months", maxview = "decades", ...) {
  d <- shiny::dateRangeInput(inputId, label, ...)
  d$children[[2L]]$children[[1]]$attribs[["data-date-min-view-mode"]] <- minview
  d$children[[2L]]$children[[3]]$attribs[["data-date-min-view-mode"]] <- minview
  d$children[[2L]]$children[[1]]$attribs[["data-date-max-view-mode"]] <- maxview
  d$children[[2L]]$children[[3]]$attribs[["data-date-max-view-mode"]] <- maxview
  d
}


# Custom checkbox group with collapsible tick options
# https://stackoverflow.com/questions/56738392/collapsible-checkboxgroupinput-in-shiny
collapsibleAwesomeCheckboxGroupInput <-
  function(inputId, label, i, choices = NULL, selected = NULL,
           status = "primary", width = NULL) {

    input <- awesomeCheckboxGroup(inputId, label, choices = choices,
                                  selected = selected, width = width,
                                  status = status)

    checkboxes <- input[[3]][[2]][[3]][[1]]

    id_btn <- paste0(inputId, "_btn")
    id_div <- paste0(inputId, "_collapsible")

    # Use consistent styling for the button, with primary color
    btn <- actionBttn(id_btn, "Show All", color = "primary", size = "sm",
                      style = "minimal", icon = icon("chevron-down"))

    # Add explicit collapse class with transition styling
    collapsible <- div(
      id = id_div, 
      class = "collapse", 
      style = "width: 100%; transition: height 0.25s ease;"
    )

    collapsible$children <- checkboxes[(i+1):length(checkboxes)]

    children <- c(checkboxes[1:i], list(collapsible), list(btn))

    input[[3]][[2]][[3]][[1]] <- children

    # Call JavaScript initialization function
    initScript <- sprintf('initCollapsibleCheckboxGroup("%s");', inputId)
    input <- tagAppendChild(input, tags$script(HTML(initScript)))

    input
  }
