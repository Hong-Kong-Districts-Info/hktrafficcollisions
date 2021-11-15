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
