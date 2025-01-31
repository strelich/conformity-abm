library(plotly)
library(shiny)

fluidPage(

    # Application title
    titlePanel("Conformity"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
          sliderInput("num_of_agents", "Number of agents",
                      value = 100, min = 100, max = 1000, step = 100),

          sliderInput("hip_prop", "Proportion of hipsters",
                      value = 0.05, min = 0, max = 0.2, step = 0.01),

          sliderInput("years", "Number of years",
                      value = 200, min = 100, max = 1000, step = 100),

          sliderInput("beard_prop", "Proportion of beards",
                      value = 0.5, min = 0, max = 1, step = 0.05),

          actionButton("simulate", "Simulate!")
        ),

        # Show a plot of the generated distribution
        mainPanel(
          plotlyOutput('main_plot')
        )
    )
)
