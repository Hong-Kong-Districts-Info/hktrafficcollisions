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
hk_accidents <- fst::read_fst("./data/hk_accidents.fst")
hk_vehicles <- fst::read_fst("./data/hk_vehicles.fst")
hk_casualties <- fst::read_fst("./data/hk_casualties.fst")

# interactive thematic map mode option ------------------------------------

tmap_mode("view")
tmap_options(basemaps = c("CartoDB.Positron", "Stamen.TonerLite", "OpenStreetMap"))

# Constants ---------------------------------------------------------------

DISTRICT_ABBR = c("CW", "WCH", "E", "S", "YTM", "SSP", "KC", "WTS", "KT", "TW", "TM", "YL", "N", "TP", "SK", "ST", "KTS", "I")
DISTRICT_FULL_NAME = hkdatasets::hkdistrict_summary[["District_EN"]]

# Color scheme ------------------------------------------------------------

SEVERITY_COLOR = c(Fatal = "#230B4C", Serious = "#C03A51", Slight = "#F1701E")
SEVERITY_COLOR_DESAT = c(Fatal = "#251541", Serious = "#bb3e53", Slight = "#ffa500")
CATEGORY_COLOR = setNames(as.list(c("#67B7DC", "#A367DC", "#FFAE12")), c("accidents", "casualties", "vehicles"))

# Custom misc functions ---------------------------------------------------

source(file = "modules/utils.R", local = TRUE)
