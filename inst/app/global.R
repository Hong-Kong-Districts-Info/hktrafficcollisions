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


# System settings -------------------------------------------------------------

Sys.setenv(TZ = "Asia/Hong_Kong")


# Metadata -------------------------------------------------------------

# opengraph properties
OPENGRAPH_PROPS = list(
  title = "香港車禍傷亡資料庫 | Hong Kong Traffic Injury Collision Database",
  url = "https://streetreset.shinyapps.io/hktrafficcollisions/",
  image = "https://user-images.githubusercontent.com/29334677/183444210-1b983c91-476c-4534-8425-10999051f132.jpg",
  description = "香港車禍傷亡資料庫旨在利用互動地圖和儀表版，將香港車禍位置和相關數據可視化。"
)

## Translation

# file with translations
i18n = Translator$new(translation_csvs_path = "./translation")

# Set Traditional Chinese as default language
i18n$set_translation_language("zh")
i18n$use_js()


# Data import -------------------------------------------------------------

## Take data from {hkdatasets}
hk_collisions <- fst::read_fst("./data/hk_collisions.fst")
hk_vehicles <- fst::read_fst("./data/hk_vehicles.fst")
hk_casualties <- fst::read_fst("./data/hk_casualties.fst")

hotzone_streets = read_sf("./data/hotzone_streets.gpkg")

## Project info data
terminology = read.csv("./data/terminology.csv")

## Manipulated data, generated from `modules/manipulate_data.R`
hk_collisions_valid_sf = read_sf("./data/data-manipulated/hk_collisions_valid_sf.gpkg")
hotzone_out_df = fst::read_fst("./data/data-manipulated/hotzone_out_df.fst")

# interactive thematic map mode option ------------------------------------

# Subset basemap providers to be used for interactive maps
SELECTED_BASEMAPS = c("Stadia.StamenTonerLite", "OpenStreetMap", "CartoDB.Positron")

tmap_mode("view")
tmap_options(basemaps = SELECTED_BASEMAPS)

# Constants ---------------------------------------------------------------

DISTRICT_ABBR = c("CW", "WCH", "E", "S", "YTM", "SSP", "KC", "WTS", "KT", "TW", "TM", "YL", "N", "TP", "SK", "ST", "KTS", "I")
DISTRICT_FULL_NAME = hkdatasets::hkdistrict_summary[["District_EN"]]

# Color scheme ------------------------------------------------------------

SEVERITY_COLOR = c(Fatal = "#FF4039", Serious = "#FFB43F", Slight = "#FFE91D")
CATEGORY_COLOR = setNames(as.list(c("#232323", "#232323", "#232323")), c("collisions", "casualties", "vehicles"))

# Fill color palette according to the severity of the accident
fill_palette = leaflet::colorFactor(palette = c("#FF4039", "#FFB43F", "#FFE91D"), domain = c("Fatal", "Serious", "Slight"))

# Custom misc functions ---------------------------------------------------

source(file = "modules/utils.R", local = TRUE)


