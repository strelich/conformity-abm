library(shiny)
library(DT)
library(plotly)
library(tidyverse)


# Generates agents based on specified population size (num_of_agents) and proportion of hipsters (hip_prop)
agentgenerate <- function(num_of_agents,hip_prop,beard_prop) {

  # Generates vector of hipsters
  hipsters <- rep("Hipster", floor(num_of_agents * hip_prop))

  # Generates vector of conformists
  conformists <- rep("Conformist", num_of_agents - length(hipsters))

  # Create data frame of agents (hipsters and conformists)
  agent_pool <- data.frame("Group" = c(hipsters,conformists))

  # Define options for facial hair
  options <- c("Bearded","Clean-Shaven")

  # Randomly assign facial hair to agents
  agent_pool$face <- sample(options, num_of_agents, replace = T,prob = c(beard_prop, 1-beard_prop))

  # Output the data frame of agents
  return(agent_pool)
}



# Define server logic
function(input, output, session) {

  # Create data frame for plot data
  foo <- eventReactive(input$simulate, {

    agents <- agentgenerate(input$num_of_agents, input$hip_prop, input$beard_prop)

    plot_data <- data.frame(
      "Year" = 0:input$years,
      "Conformists" = NA_real_,
      "Hipsters" = NA_real_,
      "All" = NA_real_) %>%
      dplyr::rows_update( # Write data for Year Zero
        tibble(
          Year = 0,
          Conformists = mean(agents$face[agents$Group == "Conformist"] == "Bearded"),
          Hipsters = mean(agents$face[agents$Group == "Hipster"] == "Bearded"),
          All = mean(agents$face == "Bearded")
        )
      )

    # Loop through population over the years

    for(y in 1:input$years) {

      # Set up indexing variables
      a <- 1
      p <- rep(NA,nrow(agents))

      # Each agent assesses facial hair of every other agent
      for(a in 1:nrow(agents)) {
        perspective <- agents$face[-a] # All agents except focal agent
        p[a] <- mean(perspective == "Bearded") # Proportion of bearded faces for focal agent
      }

      # Agents decide whether to switch facial hair style
      for(a in 1:nrow(agents)) {
        if(agents$Group[a] == "Conformist") {
          # For conformists, probability of growing beard = proportion WITH beard
          agents$face[a] <- ifelse(rbinom(1, 1, p[a]),"Bearded","Clean-Shaven")
        } else {
          # For hipsters, Probability of growing bear = proportion WITHOUT beard
          agents$face[a] <- ifelse(rbinom(1, 1, 1-p[a]),"Bearded","Clean-Shaven")
        }
      }

      # Add proportion of bearded agents to appropriate row of plot data frame
      plot_data$Conformists[(y+1)] <- mean(agents$face[agents$Group == "Conformist"] == "Bearded")
      plot_data$Hipsters[(y+1)] <- mean(agents$face[agents$Group == "Hipster"] == "Bearded")
      plot_data$All[(y+1)] <- mean(agents$face == "Bearded")
    }

    return(plot_data)
  })


  output$main_tab <- renderDT(foo() %>% mutate(across(c(Conformists, Hipsters, All), \(x) scales::percent(x, 0.1))))


  output$main_plot <- renderPlotly({
    p <- ggplot(foo(),
                mapping = aes(x = Year, y = All))+
      labs(y = "Proportion of all agents with beards")+
      coord_cartesian(ylim = c(0,1))+
      geom_line()+ geom_rug(sides = "r", alpha = 0.4) +
      geom_smooth(method = "loess", se = FALSE, span = .2)

    plotly::ggplotly(p)
  })


  output$distro_plot <- renderPlotly({
    p <- ggplot(foo(),
                mapping = aes(x = All))+
      coord_cartesian(xlim = c(0,1))+
      geom_density(bounds = c(0,1)) +
      geom_vline(xintercept = 0.5, linetype = 3) +
      labs(x="Proportion of agents with beards",y="Density")

    plotly::ggplotly(p)
  })

}
