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
library("streamgraph")

# Fonction de labelling du streamgraph (aurait dû être dans le package)
sg_add_marker <- function(sg, x, label="", stroke_width=0.5, stroke="#7f7f7f", space=5,
                          y=0, color="#7f7f7f", size=12, anchor="start") {

  if (inherits(x, "Date")) { x <- format(x, "%Y-%m-%d") }

  mark <- data.frame(x=x, y=y, label=label, color=color, stroke_width=stroke_width, stroke=stroke,
                     space=space, size=size, anchor=anchor, stringsAsFactors=FALSE)

  if (is.null(sg$x$markers)) {
    sg$x$markers <- mark
  } else {
    sg$x$markers <- bind_rows(mark, sg$x$markers)
  }

  sg
}

# To-do :
#   - ajouter graphiques

# 2 SERVER -------------------------------------------------------------------------------------------------------------
server <- function(input, output) {
  # Données
  com_reshaped <- read.dta13("dat/scores_com.dta", convert.factors = TRUE)
  attr(com_reshaped, "variable.labels") <- attr(com_reshaped,"var.labels")
  com_reshaped <- com_reshaped %>% tidyr::gather("scrutin", "voix", c(PRS17_T1:REG21_T2))

  # Replacement des dates
  com_reshaped <- com_reshaped %>% filter(!(scrutin %in% c('PRS17_T2','LGS17_T2','MUN20_T2','DEP21_T2','REG21_T2')))
  com_reshaped <- com_reshaped %>% mutate(scrutin= ifelse(scrutin == 'PRS17_T1', "1", scrutin))
  com_reshaped <- com_reshaped %>% mutate(scrutin= ifelse(scrutin == 'PRS17_T2', "2", scrutin))
  com_reshaped <- com_reshaped %>% mutate(scrutin= ifelse(scrutin == 'LGS17_T1', "3", scrutin))
  com_reshaped <- com_reshaped %>% mutate(scrutin= ifelse(scrutin == 'LGS17_T2', "4", scrutin))
  com_reshaped <- com_reshaped %>% mutate(scrutin= ifelse(scrutin == 'MUN20_T1', "5", scrutin))
  com_reshaped <- com_reshaped %>% mutate(scrutin= ifelse(scrutin == 'MUN20_T2', "6", scrutin))
  com_reshaped <- com_reshaped %>% mutate(scrutin= ifelse(scrutin == 'DEP21_T1', "7", scrutin))
  com_reshaped <- com_reshaped %>% mutate(scrutin= ifelse(scrutin == 'DEP21_T2', "8", scrutin))
  com_reshaped <- com_reshaped %>% mutate(scrutin= ifelse(scrutin == 'REG21_T1', "9", scrutin))
  com_reshaped <- com_reshaped %>% mutate(scrutin= ifelse(scrutin == 'REG21_T2', "10", scrutin))

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

  # Libellé string du niveau de granularité
  REACTgranu <- reactive({
    if (input$granu == TRUE) { "Bureaux de vote" }
    else { "Communes" }
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
                    bringToFront = TRUE),
                  group = REACTgranu()
      ) %>%
      addLegend(pal = pal_gra(),
                values = ~REACTdat2()$toplot,
                opacity = 0.9,
                title = NULL,
                position = "bottomright"
      )
  })
  output$current = renderDataTable({
    REACTscores()
  })

  # Stream graph
  plot_sg <- function(ville,plotname) {
    temp <- com_reshaped %>%  filter(!(parti %in% c('INSCRITS'))) %>%
      filter(libcom == ville)
    sg <- streamgraph(temp, key="parti", value="voix", date="scrutin", height="500px", width="1000px", scale="continuous") %>%
      sg_add_marker(1, label = "PRS 2017", stroke = "#FFFFFF", y = -200, color = "grey10") %>%
      sg_add_marker(3, label = "LGS 2017", stroke = "#FFFFFF", y = -200, color = "grey10") %>%
      sg_add_marker(5, label = "MUN 2020", stroke = "#FFFFFF", y = -200, color = "grey10") %>%
      sg_add_marker(7, label = "DEP 2021", stroke = "#FFFFFF", y = -200, color = "grey10") %>%
      sg_add_marker(9, label = "REG 2021", stroke = "#FFFFFF", y = -200, color = "grey10")
    sg$x$legend <- TRUE
    sg$x$x_tick_format <- NULL
    sg$x$legend_label <- "Choisissez un parti :"
    sg$x$fill <- "manual"
    sg$x$palette <- c('#EDECE5','#45BF70','#C7F4E6','#FFFFFF','#EA4491','#192A90','#EE678B','#9CE289','#000000','#BB0200','#7A0200','#3254C2','#FD9C3C','#9B0200','#EDF6F2','#D1122A','#C1826F','#7A2100','#E62154','#F0636A','#00005E','#C48419','#009069','#302573','#F25F48')
    sg
  }
  output$sg1 <- renderStreamgraph(plot_sg('Bondy'))
  output$sg2 <- renderStreamgraph(plot_sg('Noisy-le-Sec'))
  output$sg3 <- renderStreamgraph(plot_sg('Romainville'))
  output$sg4 <- renderStreamgraph(plot_sg('Les Lilas'))
  output$sg5 <- renderStreamgraph(plot_sg('Le Pre-Saint-Gervais'))

}

# Shiny
#shinyApp(ui = ui, server = server)
