#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#  PROJET   : DASHBOARD ANALYSE ELECTORALE DE LA 9E CIRCONSCRIPTION DE SEINE-SAINT-DENIS
#  C.E.		: A. Solnon
#  DATE		: 01-02-2022
#_______________________________________________________________________________________________________________________
rm(list = ls())
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

# 1 DEPLOYING APP ------------------------------------------------------------------------------------------------------
#runApp("D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app")
setAccountInfo(name='nallawenn',
               token='FA1AE942A691CA7E5E518B7164AB3C95',
               secret='oOoF8mOHf91UeO4wZtztf+jBdTPiGM7jP13D/XAk')
#showLogs(appName="circo93-9",streaming=TRUE)
deployApp("D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app", appName="circo93-9")


# # 3 DESSIN DE LA CARTE--------------------------------------------------------------------------------------------------
#
# # Paramètres
# granularite <- 'bvote'
# outcome <- 'INSCRITS'
# scrutin <- 'PRS17_T1'
# mapdata <- get(granularite)
# if (granularite == 'bvote') title <- "Bureaux de vote"
# if (granularite == 'com')   title <- "Communes"
#
# # Palette
# pal_car <- colorNumeric(colorRampPalette(colors = c("#ffffff", "#ff0a99"), space = "Lab")(180), domain = car$pauv)
# pal_gra <- colorBin("YlOrRd", domain = mapdata[mapdata$parti == outcome,][[scrutin]])
#
# # Map
# m <- leaflet(iris) %>%
#   setView(2.45, 48.89, 13) %>%
#   addProviderTiles(providers$CartoDB.Positron) %>%
#   addPolygons(data = mapdata[mapdata$parti == outcome,],
#               popup = popupTable(mapdata[mapdata$parti == outcome,]),
#               label = ~htmlEscape(get(granularite)),
#               fillColor = ~pal_gra(get(scrutin)),
#               color = 'white',
#               weight = 1,
#               opacity = 1,
#               fillOpacity = 1,
#               highlightOptions = highlightOptions(
#                 weight = 3,
#                 color = "#ffffff",
#                 fillOpacity = 1,
#                 bringToFront = TRUE),
#               group = title) %>%
#   addPolygons(data = iris,
#               color = 'white',
#               weight = 1,
#               opacity = 1.0,
#               fillOpacity = 0,
#               group = "Iris") %>%
#   addPolygons(data = parc,
#               color = 'white',
#               weight = 0.5,
#               opacity = 1.0,
#               fillOpacity = 0,
#               group = "Parcelles cadastrales") %>%
#   addPolygons(data = car,
#               fillColor = ~pal_car(pauv),
#               weight = 2,
#               opacity = 0.2,
#               color = "#ffffff",
#               dashArray = "1",
#               fillOpacity = 0.7,
#               highlightOptions = highlightOptions(
#                 weight = 3,
#                 color = "#ffffff",
#                 dashArray = "",
#                 fillOpacity = 1,
#                 bringToFront = TRUE),
#               group = "Pauvrete carroyee") %>%
#  addLayersControl(overlayGroups  = c(title,
#                                      'Iris',
#                                      'Parcelles cadastrales',
#                                      'Pauvrete carroyee'),
#                  options = layersControlOptions(collapsed = FALSE))
#m

#mapshot(m, url = "map.html")