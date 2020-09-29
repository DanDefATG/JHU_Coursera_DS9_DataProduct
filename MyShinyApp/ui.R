library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Call Center Workforce Planning - Montecarlo Simulation"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("calls_per_hours",
                        "Number of Calls per Hours (Average):",
                        min = 1,
                        max = 200,
                        value = 100),
            sliderInput("calls_per_hours_sd",
                        "Number of Calls per Hours (Standard Dev):",
                        min = 1,
                        max = 50,
                        value = 10),
            sliderInput("average_call_time",
                        "Call Duration in seconds (Average):",
                        min = 1,
                        max = 400,
                        value = 180),
            sliderInput("average_call_time_sd",
                        "Call Duration in seconds (Standard Dev.):",
                        min = 1,
                        max = 100,
                        value = 20),
            sliderInput("max_time_to_answer",
                        "Max Time to Answer a call (in Seconds):",
                        min = 1,
                        max = 100,
                        value = 20),
            sliderInput("target_level",
                        "Target Percentage of Call Answered in time:",
                        min = 1,
                        max = 100,
                        value = 80),
            sliderInput("sims",
                        "Montecarlo Simulation Loops:",
                        min = 100,
                        max = 1000,
                        value = 200),
            submitButton("Apply")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(type = "tabs",
              tabPanel("Montecarlo Simulation",
                #tableOutput("Agenttab"),
                plotOutput("AgentsPlot"),
                htmlOutput("Num_Agents"),
                plotOutput("servLevDistPlot"),
                htmlOutput("Service_Lev_prob")
              ),
              tabPanel("Documentation",
              h1("Call Center Workforce Planning"),
              h2("Call Center Montecarlo simulation for optimum Agents Number selection"),
              p("This app is design to simulate a call center operations to allow the identification of the optimum number of Agets to be 
                used to guarantee a desired Service Level."),
              p("The Service Level is defined as the percentage of calls aswered under a target level of seconds."),
              br(),
              p("We use the", span(" Erlang C", style = "color:blue"), "formula to describe the relationship between the grade of Service and various variable you can modify with the slider."),
              br(),
              strong("Inputs:"),
              p("Is it possible to modify the following parameters to generate different simulations:"),
              p( span("Number of Calls per Hours (Average & SD)"  , style = "color:blue"), " this is the expected number of calls received by the call center within an hour"),
              p( span("Call Duration in seconds (Average & SD)"   , style = "color:blue"), " this is the expected duration in second of a call to the call center"),
              p( span("Max Time to Answer a call (in Seconds)"    , style = "color:blue"), " this is the required time to answer the call do be considered in the service level"),
              p( span("Target Percentage of Call Answered in time", style = "color:blue"), " This is the target minimum percentage of call needed to be answered within the max seconds to answer a call"),
              p( span("Montecarlo Simulation Loops"               , style = "color:blue"), " This define the number of montecarlo loop in the simulation"),
              br(),
              p("The application execute the montecarlo simulation starting from an optimal number of agents selected from the erlang c formula"),
              br(),
              strong("Outputs:"),
              p( span("Call Centre Simulation - Erlang-C Formula Plot"  , style = "color:blue"), " This chart shows the rechead Sevice Level at the growing of Agents; the blu line is the target level of service defined"),
              p( span("Optimum number of Agents "  , style = "color:blue"), " Is the selected minimum number of agents to be used to respect the service level target"),
              p( span("Call Center Service Level - Montecarlo simulation "  , style = "color:blue"), " This chart shows the Montecarlo distribution of the service level for the selected number of agents"),
              p( span("Montecarlo Quantili "  , style = "color:blue"), " The chart and the details shows the service level reached with the 50% and 95% of probability"),
              br(),
              p("The app is inspired by the R-Blogger Article of Peter Prevos https://www.r-bloggers.com/2018/07/call-centre-workforce-planning-using-erlang-c-in-r-language/")
              )
            )
        )
    )
))
