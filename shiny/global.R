

# Packages
library(shiny)
library(dplyr)
#library(tidyr)

library(movieNetwork)
library(networkD3)

genreList <- movieNetwork::load_genres()$name

load("action2000.Rda")
load("comedy2000.Rda")


