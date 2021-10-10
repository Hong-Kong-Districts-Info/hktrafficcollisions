# -------- #
# global.R #
# -------- #

# DESC: global.R script used to create static objects that app needs to run.
#       Includes importing packages, loading and manipulating data.


# Packages ----------------------------------------------------------------

## data wrangling
library(dplyr)
library(tidyr)
library(hkdatasets)

## shiny-related
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(ggplot2)
library(plotly)

## interactive map
library(sf)
library(leaflet)
library(leaflet.extras)


# Data import -------------------------------------------------------------

## Take data from {hkdatasets}
hk_accidents <- fst::read_fst("./data/hk_accidents.fst")
hk_vehicles <- fst::read_fst("./data/hk_vehicles.fst")
hk_casualties <- fst::read_fst("./data/hk_casualties.fst")


# Custom functions --------------------------------------------------------

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

    children <- c(checkboxes[1:i], list(btn), list(collapsible))

    input[[3]][[2]][[3]][[1]] <- children

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
