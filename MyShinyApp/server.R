#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

#reference https://www.r-bloggers.com/2018/07/call-centre-workforce-planning-using-erlang-c-in-r-language/    

#Functions for Erlang calculation
#INTENSITY:  Determines intensity in Erlangs based on the rate of calls per interval, the total call handling time and the interval time in minutes. All functions default to an interval time of sixty minutes.
intensity <- function(rate, duration, interval = 60) {
    (rate / (60 * interval)) * duration
}

#ERKANG Calculates The Erlang C formula using the number of agents and the variables that determine intensity.
erlang_c <- function(agents, rate, duration, interval = 60) {
    int <- intensity(rate, duration, interval)
    erlang_b_inv <- 1
    for (i in 1:agents) {
        erlang_b_inv <- 1 + erlang_b_inv * i / int
    }
    erlang_b <- 1 / erlang_b_inv
    agents * erlang_b / (agents - int * (1 - erlang_b))
}

#SERVICE LEVEL Calculates the service level. The inputs are the same as above plus the period for the Grade of Service in seconds.
service_level <- function(agents, rate, duration, target, interval = 60) {
    pw <- erlang_c(agents, rate, duration, interval)
    int <- intensity(rate, duration, interval)
    1 - (pw * exp(-(agents - int) * (target / duration)))
}

#RESOURCE: Seeks the number of agents needed to meet a Grade of Service. This function starts with the minimum number of agents (the intensity plus one agent) and keeps searching until it finds the number of agents that achieve the desired Grade of Service.
resource <- function(rate, duration, target, gos_target, interval = 60) {
    agents <-round(intensity(rate, duration, interval) + 1)
    gos <- service_level(agents, rate, duration, target, interval)
    while (gos < gos_target * (gos_target > 1) / 100) {
        agents <- agents + 1
        gos <- service_level(agents, rate, duration, target, interval)
    }
    return(c(agents, gos))
}

#Montecarlo Functions
#INTENSITY:  Determines intensity in Erlangs based on the rate of calls per interval, the total call handling time and the interval time in minutes. All functions default to an interval time of sixty minutes.
intensity_mc <- function(rate_m, rate_sd, duration_m, duration_sd, interval = 60, sims = 1000) { 
    (rnorm(sims, rate_m, rate_sd) / (60 * interval)) * rnorm(sims, duration_m, duration_sd) }

#ERKANG Calculates The Erlang C formula using the number of agents and the variables that determine intensity.
erlang_c_mc <- function(agents, rate_m, rate_sd, duration_m, duration_sd, interval = 60) {
    int <- intensity_mc(rate_m, rate_sd, duration_m, duration_sd, interval)
    erlang_b_inv <- 1
    for (i in 1:agents) {
        erlang_b_inv <- 1 + erlang_b_inv * i / int
    }
    erlang_b <- 1 / erlang_b_inv
    agents * erlang_b / (agents - int * (1 - erlang_b))
}

#SERVICE LEVEL Calculates the service level. The inputs are the same as above plus the period for the Grade of Service in seconds.
service_level_mc <- function(agents, rate_m, rate_sd, duration_m, duration_sd, target, interval = 60, sims = 1000) {
    pw <- erlang_c_mc(agents, rate_m, rate_sd, duration_m, duration_sd, interval)
    int <- intensity_mc(rate_m, rate_sd, duration_m, duration_sd, interval, sims)
    1 - (pw * exp(-(agents - int) * (target / rnorm(sims, duration_m, duration_sd))))
}

#datafrane con i livelli di servizio della montecarlo
# data_frame(ServiceLevel = service_level_mc(agents = 12,
#                                            rate_m = 100,
#                                            rate_sd = 10,
#                                            duration_m = 180,
#                                            duration_sd = 20,
#                                            target = 20,
#                                            interval = 30,
#                                            sims = 1000)) %>%
#     ggplot(aes(ServiceLevel)) +
#     geom_histogram(binwidth = 0.1, fill = "#008da1",  alpha=0.5,) + 
#     geom_vline(xintercept = quantile(t,c( .5)), linetype="dotted", color = "blue", size=1)+ 
#     geom_vline(xintercept = quantile(t,c( .05, .95)), linetype="dotted", color = "red", size=1)+
#     geom_text(aes(x=quantile(t,c( .5)), label="\n50%= ", y=max(hist(ServiceLevel)$counts)/3), colour="blue", angle=90, text=element_text(size=8)) +
#     geom_text(aes(x=quantile(t,c( .95)), label="\n95%", y=max(hist(ServiceLevel)$counts)/4), colour="red", angle=90, text=element_text(size=8)) 

#Parameters
interval <- 60#minutes                          ##lo fissiamo a 60 e facciamo tutto sull'ora
# calls_per_hours <- 100                          ##input
# calls_per_hours_sd <- 10                         ##input
# average_call_time <- 180 # seconds                         ##input
# average_call_time_sd <- 20 # seconds                         ##input

# agents <- 8                         ##calcolato dalla resource
# max_time_to_answer <- 20 #seconds                          ##input
# sims= 1000 #number of montecarlo sim                          ##input
# target_level <- 80 # percentage of answered calls within 20 seconds                          ##input

# test
# resource(calls_per_hours, average_call_time, max_time_to_answer, target_level, interval)
# 
# t <- service_level_mc(agents, calls_per_hours, calls_per_hours_sd, average_call_time, average_call_time_sd , max_time_to_answer, interval, sims)
# 
# quantile(t,c(.05, .5, .95))

#Target The centre needs to answer 80% of calls within 20 seconds

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    agents_calc <-  reactive ({resource(input$calls_per_hours, input$average_call_time, input$max_time_to_answer, input$target_level, interval)
    })
    
    service_level_df <- reactive ({ #with sapply simualte the service level reached started from the optimum agent number all the steps
        data.frame(agents = round(agents_calc()[1]/1.5,0):round(agents_calc()[1]*1.5,0),
                                           GoS = sapply(round(agents_calc()[1]/1.5,0):round(agents_calc()[1]*1.5,0),function(i){
                                                        service_level(i ,rate = input$calls_per_hours,
                                                        duration = input$average_call_time, target = input$max_time_to_answer/interval,
                                                        interval = interval)}))
    })
    
    serv_lev_montecarlo <- reactive ({
     data_frame(ServiceLevel = service_level_mc(agents_calc()[1], input$calls_per_hours, input$calls_per_hours_sd, input$average_call_time, 
                                                                      input$average_call_time_sd , input$max_time_to_answer, interval, input$sims) )
    })
    
    output$Num_Agents <- renderText({
         paste0("<H2>Optimal Number Of Agents: ", agents_calc()[1], "</H2>")
    })
    
    output$AgentsPlot <- renderPlot({
        service <- service_level_df()
        ggplot(service, aes(agents, GoS)) +
            geom_line() +
            scale_x_continuous(breaks = min(service$agents):max(service$agents)) +
            scale_y_continuous(labels = scales::percent) +
            geom_hline(yintercept = (input$target_level)/100, col = "blue") +
            theme_bw(base_size = 10) +
            ggtitle( "Call Centre Simulation - Erlang-C Formula")+ 
            theme(plot.title = element_text(size = 28, face = "bold", hjust = 0.5))
    })

    output$Agenttab <- renderTable( service_level_df())
    
    output$servLevDistPlot <- renderPlot({
        
        serv_lev <- serv_lev_montecarlo()
        # generate bins based on input$bins from ui.R
        ggplot(serv_lev, aes(ServiceLevel)) +
             geom_histogram(binwidth = 0.1, fill = "#008da1")+ 
             geom_vline(xintercept = quantile(serv_lev$ServiceLevel,c( .5)), linetype="dotted", color = "blue", size=1)+ 
             geom_vline(xintercept = quantile(serv_lev$ServiceLevel,c( .05, .95)), linetype="dotted", color = "red", size=1)+
             geom_text(aes(x=quantile(serv_lev$ServiceLevel,c( .5)), label="\n50%= ", y=max(hist(serv_lev$ServiceLevel)$counts)/3), colour="blue", angle=90, text=element_text(size=8)) +
             geom_text(aes(x=quantile(serv_lev$ServiceLevel,c( .95)), label="\n95%", y=max(hist(serv_lev$ServiceLevel)$counts)/4), colour="red", angle=90, text=element_text(size=8))+
            ggtitle( "Call Center Service Level - Montecarlo simulation")+ 
            theme(plot.title = element_text(size = 28, face = "bold", hjust = 0.5))
                 
             
    })
    
    output$Service_Lev_prob <- renderText({
        serv_lev <- serv_lev_montecarlo()
        paste0("<H2>The 50% of times the Service Level is more than ",round(quantile(serv_lev$ServiceLevel, c(.5))*100,2), "% </H2> <br>", 
               "<H2>The 95% of times the Service Level is more than ",round(quantile(serv_lev$ServiceLevel, c(.95))*100,2), "% </H2> <br>")
    })

})
