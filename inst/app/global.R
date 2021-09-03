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

## Thematic map
library(tmap)


# Data import -------------------------------------------------------------

## Take data from {hkdatasets}
hk_accidents <- hkdatasets:::hk_accidents
hk_vehicles <- hkdatasets::hk_vehicles
hk_casualties <- hkdatasets::hk_casualties

# interactive thematic map mode option ------------------------------------

tmap_mode("view")
tmap_options(basemaps = c("CartoDB.Positron", "Stamen.TonerLite", "OpenStreetMap"))

# Color scheme ------------------------------------------------------------

SEVERITY_COLOR = c(Fatal = "#230B4C", Serious = "#C03A51", Slight = "#F1701E")
