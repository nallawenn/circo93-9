#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#  PROJET   : DASHBOARD ANALYSE ELECTORALE DE LA 9E CIRCONSCRIPTION DE SEINE-SAINT-DENIS
#  C.E.		: A. Solnon
#  DATE		: 01-02-2022
#_______________________________________________________________________________________________________________________

rm(list = ls())
#setwd("D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app")
library("leaflet")
library("leafpop") # for leafpop
library("sf") # for reading shapefile
library("mapview") # for export
library("scales")
library("readstata13")
library("htmltools")
library("shiny")
library("shinyWidgets")
library("dplyr")
library("rsconnect")
library("streamgraph")



# 3 USER INTERFACE -----------------------------------------------------------------------------------------------------
ui <- fluidPage(
  h3("Resultats electoraux 2017-2021"),
  h4("9e circonscription de Seine-Saint-Denis"),
  fluidRow(
    column(4,
           sliderTextInput(
             "scrutin",
             "Choisissez un scrutin :",
             grid = TRUE,
             force_edges = TRUE,
             choices = c('PRS17_T1','PRS17_T2','LGS17_T1','LGS17_T2','MUN20_T1','MUN20_T2','DEP21_T1','DEP21_T2','REG21_T1','REG21_T2'),
             selected = 'PRS17_T1'
           )
    ),
    column(4,
           selectInput(
             inputId = "outcomes",
             label = "Choisissez une ou plusieurs variables :",
             multiple = TRUE,
             choices = c('INSCRITS','ABSTENTION','NULS','BLANCS','LO','NPA','POI','LFI','PIRATE','ANIM','CIT_DVG','DVG','EELV','PCF','PS','RDG','UDMF','VOLT','LREM','UPR','UDI','LR','NDA','RN','AUTRE'),
             selected = "ABSTENTION"
           )
    ),
    column(4,
           selectInput(
             inputId = "calcul",
             label = "Choisissez un mode de calcul :",
             multiple = FALSE,
             choices = c("Nombre (N)" = 'voix',"Score (%) au sein de commune / BV" = 'pct_unit',"Poids (%) au sein de la circo" = 'pct_circ'),
             selected = "Nombre (N)"
           )
    ),
  ),
  prettySwitch(
    inputId = "granu",
    label = "Bureaux de vote"
   ),
  leafletOutput("leafletMap"),
  h3("Evolution par commune"),
  fluidRow(
    column(4,h4('Bondy', style="text-align:center"), streamgraphOutput('sg1')),
    column(4,h4('Noisy-le-Sec', style="text-align:center"), streamgraphOutput('sg2')),
    column(4,h4('Romainville', style="text-align:center"), streamgraphOutput('sg3'))
  ),
  fluidRow(
    column(4,h4('Les Lilas', style="text-align:center"), streamgraphOutput('sg4')),
    column(4,h4('Le Pre-Saint-Gervais', style="text-align:center"), streamgraphOutput('sg5'))
  ),
  dataTableOutput("current")
)
