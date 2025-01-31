library(plotly)
library(bslib)
library(shiny)

page_sidebar(
  title = "Conformity",
  theme = bslib::bs_theme(bootswatch = "flatly"),

  # Sidebar with slider inputs
  sidebar = sidebar(
    title = "Parameters",
    sliderInput("num_of_agents", "Number of agents",
                value = 100, min = 100, max = 1000, step = 100),

    sliderInput("hip_prop", "Proportion of hipsters",
                value = 0.05, min = 0, max = 0.2, step = 0.01),

    sliderInput("years", "Number of years",
                value = 200, min = 100, max = 1000, step = 100),

    sliderInput("beard_prop", "Proportion of beards",
                value = 0.5, min = 0, max = 1, step = 0.05),

    actionButton("simulate", "Simulate!")),

  # Show plots
  card(
    card_header("Agents with beards by year"),
    card_body(plotlyOutput('main_plot'))
  ),
  card(
    card_header("Distribution"),
    card_body(plotlyOutput('distro_plot'))
  )
)

