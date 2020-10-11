# -------- #
# server.R #
# -------- #

# DESC: Code here can be much longer and complicated than in ui.R.
#       Is where all the dynamic data manipulation happens, and plot creations.
#       e.g. Filtering based on user inputs and generating plots based on
#            dynamically filtered data.
#       server.R must create a function called server, like below:

server <- function(input, output, session) {

  # ----- REACTIVES ----- #


  # ----- OBSERVE EVENTS ----- #


  # ----- TAB: Collision Location Map ----- #


  # RenderPlot: Districts ---------------------------------------------------
  source(file = "modules/plotly_testvisual.R", local = TRUE)


  # ----- TAB: Dashboard ----- #


  # ----- TAB: Hotspots and Worst Roads ----- #


  # ----- TAB: Key Facts ----- #


  # ----- TAB: Data Download ----- #


  # ----- TAB: Project Info ----- #

}
