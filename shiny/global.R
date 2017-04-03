

# Packages
library(shiny)
library(dplyr)
library(tidyr)
library(movieNetwork)
library(networkD3)

genreList <- movieNetwork::load_genres()$name

action2000 <- read.csv("data/action2000.csv", stringsAsFactors = FALSE)
comedy2000 <- read.csv("data/comedy2000.csv", stringsAsFactors = FALSE)

