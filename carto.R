rm(list = ls())
library(leaflet)
library(leafpop) # for leafpop
library(sf) # for reading shapefile
library(mapview) # for export
library(scales)

path <- "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9"

# Shapefile des iris
iris <- st_read(paste0(path,"/shp/iris.shp"))
st_crs(iris) <- 2154 # Lambert93
iris <- st_transform(iris, 4326) # EPGS84

# Shapefile des parcelles cadastrales
parc <- st_read(paste0(path,"/shp/parcelle.shp"))
st_crs(parc) <- 2154 # Lambert93
parc <- st_transform(parc, 4326) # EPGS84

# Shapefile du zonage carroyé
car <- st_read(paste0(path,"/shp/carreaux200.shp"))
st_crs(car) <- 2154 # Lambert93
car <- st_transform(car, 4326) # EPGS84
car$pauv <- car$Men_pauv/car$Men

# Palette
pal <- colorNumeric(colorRampPalette(colors = c("#ffffff", "#ff0a99"), space = "Lab")(180), domain = car$pauv)

# Map
m <- leaflet(iris) %>%
  setView(2.45, 48.89, 13) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = iris,
              color = '#ff0a99',
              weight = 2,
              opacity = 1.0,
              fillOpacity = 0,
              group = "Iris") %>%
  addPolygons(data = parc,
              color = '#ff0a99',
              weight = 0.5,
              opacity = 1.0,
              fillOpacity = 0,
              group = "Parcelles cadastrales") %>%
  addPolygons(data = car,
              fillColor = ~pal(pauv),
              weight = 2,
              opacity = 0.2,
              color = "#ffffff",
              dashArray = "1",
              fillOpacity = 0.7,
              highlightOptions = highlightOptions(
                weight = 3,
                color = "#ffffff",
                dashArray = "",
                fillOpacity = 1,
                bringToFront = TRUE),
              group = "Pauvrete carroyee") %>%
 addLayersControl(overlayGroups  = c("Iris",
                                    'Parcelles cadastrales',
                                    'Pauvrete carroyee'),
                 options = layersControlOptions(collapsed = FALSE))
m

mapshot(m, url = paste0(path, "/map.html"))
