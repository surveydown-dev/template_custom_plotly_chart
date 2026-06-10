# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown-dev/surveydown', # Development version from GitHub
#   'shiny',
#   'plotly'
# ))

# Load packages
library(surveydown)
library(shiny)
library(plotly)

# Database setup --------------------------------------------------------------
#
# Details at: https://surveydown.org/docs/storing-data
#
# surveydown stores data on any PostgreSQL database. We recommend
# https://supabase.com/ for a free and easy to use service.
#
# Once you have your database ready, run the following function to store your
# database configuration parameters in a local .env file:
#
# sd_db_config()
#
# Once your parameters are stored, you are ready to connect to your database.
# This template runs in preview mode (set via `mode: preview` in survey.qmd),
# which saves responses locally instead of to a database. To collect real
# responses, run sd_db_config() to store your database credentials, then
# change `mode` to `database` in the survey.qmd YAML header.

db <- sd_db_connect()

# UI setup --------------------------------------------------------------------

ui <- sd_ui()

# Server setup ----------------------------------------------------------------

# Example with plotly
server <- function(input, output, session) {
  # Create plotly output
  output$scatter_plot <- renderPlotly({
    plot_ly(
      mtcars,
      x = ~wt,
      y = ~mpg,
      type = "scatter",
      mode = "markers",
      source = "scatter_plot"
    ) %>% # Add source identifier
      layout(dragmode = "select") # Enable point selection
  })

  # Reactive value for selected point
  selected_point <- reactiveVal(NULL)

  # Click observer - update selected_point with the chosen point
  observeEvent(event_data("plotly_click", source = "scatter_plot"), {
    click <- event_data("plotly_click", source = "scatter_plot")
    if (!is.null(click)) {
      selected_point(sprintf("Weight: %0.1f, MPG: %0.1f", click$x, click$y))
    }
  })

  # Create question to store the selected state in resulting survey data
  sd_question_custom(
    id = "point_selection",
    label = "Click on a point in the scatter plot:",
    # The output is the output widget - here we use plotlyOutput()
    output = plotlyOutput("scatter_plot", height = "400px"),
    # The value is the reactive value that will be stored in the data
    value = selected_point
  )

  # Run surveydown server and define database
  sd_server(db = db)
}

# Launch the app
shiny::shinyApp(ui = ui, server = server)