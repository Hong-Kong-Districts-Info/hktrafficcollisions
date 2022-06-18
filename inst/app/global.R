# -------- #
# global.R #
# -------- #

# DESC: global.R script used to create static objects that app needs to run.
#       Includes importing packages, loading and manipulating data.


# Packages ----------------------------------------------------------------

## data wrangling
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(hkdatasets)

## shiny-related
library(shiny)
library(shinydashboard, warn.conflicts = FALSE)
library(shinyWidgets)
library(shinyhelper)
library(ggplot2)
library(plotly, warn.conflicts = FALSE)
library(shiny.i18n)

## interactive map
library(sf)
library(leaflet)
library(leaflet.extras)

## Thematic map
library(tmap)

## Interactive tables
library(DT, warn.conflicts = FALSE)


# Metadata -------------------------------------------------------------

# opengraph properties
OPENGRAPH_PROPS = list(
  title = "Hong Kong Traffic Injury Collision Database",
  url = "https://hkdistricts-info.shinyapps.io/trafficcollisions/",
  image = "https://user-images.githubusercontent.com/29334677/183444210-1b983c91-476c-4534-8425-10999051f132.jpg",
  description = "Visualise Hong Kong traffic collision data with interactive mapping"
)


# Data import -------------------------------------------------------------

## Take data from {hkdatasets}
hk_accidents <- fst::read_fst("./data/hk_accidents.fst")
hk_vehicles <- fst::read_fst("./data/hk_vehicles.fst")
hk_casualties <- fst::read_fst("./data/hk_casualties.fst")

hotzone_streets = read_sf("./data/hotzone_streets.gpkg")

## Project info data
terminology = read.csv("./data/terminology.csv")

## Manipulated data, generated from `modules/manipulate_data.R`
hk_accidents_valid_sf = read_sf("./data/data-manipulated/hk_accidents_valid_sf.gpkg")
hotzone_out_df = fst::read_fst("./data/data-manipulated/hotzone_out_df.fst")

# interactive thematic map mode option ------------------------------------

# Subset basemap providers to be used for interactive maps
SELECTED_BASEMAPS = c("CartoDB.Positron", "OpenStreetMap", "Stamen.TonerLite")

tmap_mode("view")
tmap_options(basemaps = SELECTED_BASEMAPS)

# Constants ---------------------------------------------------------------

DISTRICT_ABBR = c("CW", "WCH", "E", "S", "YTM", "SSP", "KC", "WTS", "KT", "TW", "TM", "YL", "N", "TP", "SK", "ST", "KTS", "I")
DISTRICT_FULL_NAME = hkdatasets::hkdistrict_summary[["District_EN"]]

# Color scheme ------------------------------------------------------------

SEVERITY_COLOR = c(Fatal = "#FF4039", Serious = "#FFB43F", Slight = "#FFE91D")
CATEGORY_COLOR = setNames(as.list(c("#232323", "#232323", "#232323")), c("accidents", "casualties", "vehicles"))

# Fill color palette according to the severity of the accident
fill_palette = leaflet::colorFactor(palette = c("#FF4039", "#FFB43F", "#FFE91D"), domain = c("Fatal", "Serious", "Slight"))

# Custom misc functions ---------------------------------------------------

source(file = "modules/utils.R", local = TRUE)


