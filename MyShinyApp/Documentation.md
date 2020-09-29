Call Center Workforce Planning 
Montecarlo Simulation
===========================================

This app is design to simulate a call center operations to allow the identification of the optimum number of Agets to be 
used to guarantee a desired Service Level.
The Service Level is defined as the percentage of calls aswered under a target level of seconds.

We use the formula to describe the relationship between the grade of Service and various variable you can modify with the slider.

Inputs:
Is it possible to modify the following parameters to generate different simulations:

Number of Calls per Hours (Average & SD) this is the expected number of calls received by the call center within an hour
Call Duration in seconds (Average & SD) this is the expected duration in second of a call to the call center
Max Time to Answer a call (in Seconds) this is the required time to answer the call do be considered in the service level
Target Percentage of Call Answered in time This is the target minimum percentage of call needed to be answered within the max seconds to answer a call
Montecarlo Simulation Loops This define the number of montecarlo loop in the simulation

The application execute the montecarlo simulation starting from an optimal number of agents selected from the erlang c formula

Outputs:
Call Centre Simulation - Erlang-C Formula Plot This chart shows the rechead Sevice Level at the growing of Agents; the blu line is the target level of service defined
Optimum number of Agents Is the selected minimum number of agents to be used to respect the service level targetCall Center Service Level - Montecarlo simulation This chart shows the Montecarlo distribution of the service level for the selected number of agents
Montecarlo Quantili The chart and the details shows the service level reached with the 50% and 95% of probability


The app is inspired by the R-Blogger Article of Peter Prevos https://www.r-bloggers.com/2018/07/call-centre-workforce-planning-using-erlang-c-in-r-language/