# -------- #
# server.R #
# -------- #

# DESC: Code here can be much longer and complicated than in ui.R.
#       Is where all the dynamic data manipulation happens, and plot creations.
#       e.g. Filtering based on user inputs and generating plots based on
#            dynamically filtered data.
#       server.R must create a function called server, like below:

server <- function(input, output, session) {

  shinyhelper::observe_helpers(help_dir = "desc")

  # Live language translation
  observeEvent(input$selected_language, {
    print(paste("Language change!", input$selected_language))
    # Update language in session
    shiny.i18n::update_lang(language = input$selected_language)
  })

  # ----- DATA MANIPULATION ----- #
  # Manipulation steps are conducted in "modules/manipulate_data.R", with
  # data exported to "data/data-manipulated/"

  # ----- REACTIVES ----- #


  # ----- OBSERVE EVENTS ----- #


  # ----- TAB: Collision Location Map ----- #
  source(file = "modules/main_map.R", local = TRUE)


  # ----- TAB: Dashboard ----- #

  # Source the module files
  source(file = "modules/district_dsb.R", local = TRUE)
  source(file = "modules/district_dsb_all.R", local = TRUE)
  source(file = "modules/district_dsb_ped.R", local = TRUE)
  source(file = "modules/district_dsb_cyc.R", local = TRUE)


  # ----- TAB: Pedestrian collision hotzones ----- #
  source(file = "modules/hotzones.R", local = TRUE)


  # ----- TAB: Key Facts ----- #


  # ----- TAB: Data Download ----- #


  # ----- TAB: Project Info ----- #
  source(file = "modules/project_info.R", local = TRUE)

}
