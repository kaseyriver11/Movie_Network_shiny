

# Packages
library(shiny)
library(dplyr)
library(tidyr)
library(igraph)
library(Hmisc)

library(movieNetwork)
library(networkD3)

genreList <- movieNetwork::load_genres()$name

#load("shiny/action2000.Rda")
#load("shiny/comedy2000.Rda")


