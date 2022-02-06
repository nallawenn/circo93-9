rm(list = ls())
setwd("D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app")
library("readstata13")
library("dplyr")
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
ville <- 'Romainville'

# User interface
ui = fluidPage(
  fluidRow(
    column(4,h3('Bondy', style="text-align:center"), streamgraphOutput('sg1')),
    column(4,h3('Noisy-le-Sec', style="text-align:center"), streamgraphOutput('sg2')),
    column(4,h3('Romainville', style="text-align:center"), streamgraphOutput('sg3'))
  ),
  fluidRow(
    column(4,h3('Les Lilas', style="text-align:center"), streamgraphOutput('sg4'))
  )
)

# Serveur
server = function(input, output) {
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
}

shinyApp(ui = ui, server = server)