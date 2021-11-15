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

    btn <- actionBttn(id_btn, "Show All", color = "primary", size = "sm",
                      style = "minimal", icon = icon("collapse-down", lib = "glyphicon"))

    collapsible <- div(id = id_div, class = "collapse")

    collapsible$children <- checkboxes[(i+1):length(checkboxes)]

    children <- c(checkboxes[1:i], list(collapsible), list(btn))

    input[[3]][[2]][[3]][[1]] <- children


    # Attach ID of that widget to the script, e.g. "#InputID_btn"
    # Adjust css and text shown in shiny in the script below
    # TODO: Move this to standalone JS script?
    script <- sprintf('$(document).ready(function(){
      $("#%s_btn").attr("data-target", "#%s_collapsible").attr("data-toggle", "collapse").css("margin-bottom", "11px").css("font-size", "12px");
      $("#%s_collapsible").on("hide.bs.collapse", function(){
        $("#%s_btn").html("<span class=\\\"glyphicon glyphicon-collapse-down\\\"></span> Show All");
      });
      $("#%s_collapsible").on("show.bs.collapse", function(){
        $("#%s_btn").html("<span class=\\\"glyphicon glyphicon-collapse-up\\\"></span> Hide");
      });
    });', inputId, inputId, inputId, inputId, inputId, inputId)

    tagList(input, tags$script(HTML(script)))
  }
