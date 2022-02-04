#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#  PROJET   : DASHBOARD ANALYSE ELECTORALE DE LA 9E CIRCONSCRIPTION DE SEINE-SAINT-DENIS
#  C.E.		: A. Solnon
#  DATE		: 01-02-2022
#_______________________________________________________________________________________________________________________
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
library("DT")

# To-do :

#   - ajouter graphiques

# 2 SERVER -------------------------------------------------------------------------------------------------------------
server <- function(input, output) {

  # 2.1 PRÉPARATION DES DONNÉES ÉLECTORALES --------------------------------------------------------------------------------
  # Import des données
  # Au bureau de vote...
  scores_bvote <- read.dta13("dat/scores_bvote.dta", convert.factors = TRUE)
  attr(scores_bvote, "variable.labels") <- attr(scores_bvote,"var.labels")
  # Ou à la commune...
  scores_com <- read.dta13("dat/scores_com.dta", convert.factors = TRUE)
  attr(scores_com, "variable.labels") <- attr(scores_com,"var.labels")
  # Et enregistrement dans un dataframe reactif
  REACTscores <- reactive({
    if (input$granu == TRUE) { scores_bvote }
    else { scores_com }
  })

  # Liste des variables identifiantes selon la granularité
  REACTlist <- reactive({
    if (input$granu == TRUE) { c('parti','com','libcom','bvote') }
    else { c('parti','libcom','com') }
  })

  # Filtrage et calcul de l'indicateur
  REACTdat1 <- reactive({
    REACTscores() %>%
      rename(voix = input$scrutin) %>%
      group_by(id) %>%
      mutate(pct_unit = voix[parti == 'INSCRITS'] - voix[parti == 'ABSTENTION'] - voix[parti == 'BLANCS'] - voix[parti == 'NULS']) %>%
      mutate(pct_unit = ifelse(parti == 'ABSTENTION', lag(voix), pct_unit)) %>%
      filter(parti %in% input$outcomes) %>%
      group_by(parti) %>%
      mutate(pct_circ = sum(voix)) %>%
      ungroup() %>%
      select(-REACTlist()) %>%
      group_by(across(all_of(c('id')))) %>%
      summarise_all(funs(sum)) %>%
      mutate(pct_unit = 100*voix * length(input$outcomes) / pct_unit) %>%
      mutate(pct_circ = 100*voix / pct_circ) %>%
      rename(toplot = input$calcul)
  })


  # 2.2 PRÉPARATION DES FORMES ---------------------------------------------------------------------------------------------
  # Shapefile des communes + données électorales
  com <- st_read("shp/com.shp")
  st_crs(com) <- 2154 # Lambert93
  com <- st_transform(com, 4326) # EPGS84
  com <- mutate(com, id =  paste(com, sep = ''))

  # Shapefile des iris
  iris <- st_read("shp/iris.shp")
  st_crs(iris) <- 2154 # Lambert93
  iris <- st_transform(iris, 4326) # EPGS84

  # Shapefile des bureaux de votes + données électorales
  bvote <- st_read("shp/bvote.shp")
  st_crs(bvote) <- 2154 # Lambert93
  bvote <- st_transform(bvote, 4326) # EPGS84 %>%
  bvote <- mutate(bvote, libcom =  paste0(libcom,"<br/>BV ", bvote))
  bvote <- mutate(bvote, id =  paste(com, bvote, sep = ''))

  # Shapefile des parcelles cadastrales
  parc <- st_read("shp/parcelle.shp")
  st_crs(parc) <- 2154 # Lambert93
  parc <- st_transform(parc, 4326) # EPGS84

  # Shapefile du zonage carroyé
  car <- st_read("shp/carreaux200.shp")
  st_crs(car) <- 2154 # Lambert93
  car <- st_transform(car, 4326) # EPGS84
  car$pauv <- car$Men_pauv/car$Men

  # Ajout des formes aux données
  REACTdat2 <- reactive({
     if (input$granu == TRUE) { st_sf(merge(bvote, REACTdat1(), by = 'id', all=TRUE)) }
     else { st_sf(merge(com, REACTdat1(), by = 'id',  all=TRUE ))}
  })

  # 2.3 CARTOGRAPHIE REACTIVE LEAFLET ----------------------------------------------------------------------------------
  # Labels selon l'outcome :
  REACTmax <- reactive({
    if (input$calcul == 'voix') { max(REACTdat2()$toplot) }
    else { 100 }
  })

  # Max de la palette
  REACTlabel <- reactive({
    if (input$calcul == 'voix') { "N= %g" }
    else { "%000.1f %%" }
  })

  # Palette
  # pal_car <- colorNumeric(colorRampPalette(colors = c("#ffffff", "#ff0a99"), space = "Lab")(180), domain = car$pauv)
  # pal_gra <- reactive({colorBin("YlOrRd", domain = REACTdat2()$voix, bins = 7)})
  # pal_gra <- reactive({colorNumeric(colorRampPalette(colors = c("#440154", "#375b8d", "#1f948c", "#45bf70", "#f3ee22", "#fa9c3c", "#de6064", "#9714a0", "#0d0887"), space = "Lab")(180), domain = c(0,REACTmax()))})
  # pal_gra <- reactive({colorNumeric(colorRampPalette(colors = c("#440154", "#375b8d", "#1f948c", "#45bf70", "#f3ee22", "#fa9c3c", "#de6064", "#9714a0", "#0d0887"), space = "Lab")(180), domain = REACTdat2()$toplot)})
  # Rose : pal_gra <- reactive({colorNumeric(colorRampPalette(colors = c("#ffffff", "#ff0a99"), space = "Lab")(180), domain = c(0,REACTmax()))})
  # bleu to rose : pal_gra <- reactive({colorNumeric(colorRampPalette(colors = c("#4CC9F0","#4895EF","#4361EE","#3F37C9","#7209B7","#B5179E","#D61E92","#F72585","#F72585","#F72585","#F72585","#F72585"), space = "Lab")(180), domain = c(0,REACTmax()))})
  pal_gra <- reactive({colorNumeric("YlGnBu", domain = c(0,REACTmax()))})


  # Map
  output$leafletMap <- renderLeaflet({
    leaflet(iris) %>%
      setView(2.45, 48.89, 13) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(data = REACTdat2(),            # popup = popupTable(REACTdat2()),
                  label =  sprintf(paste0("<strong>%s</strong><br/>",REACTlabel()),
                    REACTdat2()$libcom, REACTdat2()$toplot
                  ) %>% lapply(htmltools::HTML),
                  fillColor = ~pal_gra()(REACTdat2()$toplot),
                  color = 'white',
                  weight = 1,
                  opacity = 1,
                  fillOpacity = 1,
                  highlightOptions = highlightOptions(
                    weight = 3,
                    color = "#ffffff",
                    fillOpacity = 1,
                    bringToFront = TRUE)
      ) %>%
      addLegend(pal = pal_gra(),
                values = ~REACTdat2()$toplot,
                opacity = 0.9,
                title = NULL,
                position = "bottomright")
  })
  output$current = renderDataTable({
    REACTscores()
  })
}
#shinyApp(ui = ui, server = server)
