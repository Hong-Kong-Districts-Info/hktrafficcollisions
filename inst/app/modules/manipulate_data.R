# NOT USED IN DEPLOYMENT
# Steps below are performed in advance, the output data are stored in `data/data-manipulated/`
# Retained temporarily for reference (for future updates to the data)

# Mutated data for use in various parts of the dashboard

## ------- Core manipulated datasets (vehicles & collision) with joint attributes ---------

# Get information of all types of vehicles involved in the accidents to show in popup
hk_vehicles_involved <- hk_vehicles %>%
  group_by(serial_no) %>%
  summarize(vehicle_class_involved = paste(sort(unique(vehicle_class)), collapse = ", "))

# Get casualty role involved in each accident to show in popup
casualty_role_n = hk_casualties %>% count(serial_no, casualty_role)

collisions_cas_type <- casualty_role_n %>%
  pivot_wider(
    id_cols = serial_no,
    names_from = casualty_role,
    values_from = n, values_fill = 0
  ) %>%
  rename(cas_ped_n = Pedestrian, cas_pax_n = Passenger, cas_dvr_n = Driver)


# Add date floored to first day of the month for easier month filter handling
hk_collisions <- mutate(hk_collisions, year_month = floor_date_to_month(date_time))

hk_collisions_join <- hk_collisions %>%
  left_join(collisions_cas_type, by = "serial_no") %>%
  left_join(hk_vehicles_involved, by = "serial_no") %>%
  # Show full name of district in popup of maps
  left_join(data.frame(DC_Abbr = DISTRICT_ABBR, DC_full_name = DISTRICT_FULL_NAME),
            by = c("district" = "DC_Abbr"))


## ------- Collision Map data ---------

hk_collisions_valid <- filter(hk_collisions_join, !is.na(latitude) & !is.na(longitude))

# Leaflet default expect WGS84 (crs 4326), need custom CRS for HK1980 Grid (crs 2326)
# https://rstudio.github.io/leaflet/projections.html
hk_collisions_valid_sf <- st_as_sf(x = hk_collisions_valid, coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)

# Overwrite the output once updated
# st_write(hk_collisions_valid_sf, "./inst/app/data/data-manipulated/hk_collisions_valid_sf.gpkg", append = FALSE)

## ------- Pedestrian hot zone data ---------

hotzone_out_df = hotzone_streets %>%
  st_centroid() %>%
  st_transform(crs = st_crs(4326)) %>%
  mutate(lng = sf::st_coordinates(.)[,1], lat = sf::st_coordinates(.)[,2]) %>%
  # create the required data zooming into the feature with gomap.js
  mutate(zoom_in_map_link =
           paste('<a class="go-map" href=""',
                 'data-lat="', lat, '" data-lng="', lng,
                 '"><i class="fas fa-search-plus"></i></a>',
                 sep="")
  ) %>%
  st_drop_geometry() %>%
  dplyr::select(-c(lat, lng)) %>%
  dplyr::relocate(Area_RK, zoom_in_map_link)

# Write the output once updated
# write_fst(hotzone_out_df, "./inst/app/data/data-manipulated/hotzone_out_df.fst")

