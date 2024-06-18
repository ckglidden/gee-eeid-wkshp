setwd('/Users/cglidden/Desktop/GEE_EEID') # change to your wd

##---- set up packages ----##
library(raster)
library(ggplot2)
# install.packages('ggspatial',dependencies=TRUE)
library(ggspatial)
# install.packages('rworldmap',dependencies=TRUE)
library(rworldmap)
library(dplyr)
library(tidyr)

##------- data setup (load Hansen Global Forest Change) ---------##
### if your raster only has one band, you use raster(), if there are multiple bands, you use stack()
forest_change <- stack('global_forest_change_manaus.tif')
print(forest_change) ## you will see the different bands, they are formatted as a list

##------- select band to visualize -----------------------------##
tree_cover <- forest_change[['treecover2000']] # pull the forest loss band out of the list
# or
# tree_cover <- forest_change[[1]]

# inspect distribution of raster values
hist(tree_cover)

##------ visualize with raster package ------------------------##

# it uses the same function as base R so sometimes you need to specify you want to use the raster package with raster::plot()

plot(tree_cover)

# save to your working directory
png('manaus_treeCover_2000_raster.png')
plot(tree_cover, #col = # can put custom color palette,
)
dev.off()

##------ visualize with ggplot2  (geospatial) package ------##

# turn raster into a tibble
cover_df <- tree_cover %>%  as.data.frame(xy = TRUE) %>%  na.omit() %>%  as_tibble()
names(cover_df) # should be x (longitude), y (latitude), and treecover2000 (the band name)

# plot in R (this can take a long time)
cover_figure <- ggplot(cover_df) +  
  geom_raster(aes(x = x, y = y, fill = treecover2000)) +  
  coord_equal()  +  
  # scale_fill_gradientn(colors = mean_pal) +  # you can use this to customize the color palette
  theme_void() # remove lat & long lines; make it on a white background

cover_figure

# it is usually faster to export the figure
ggsave('manaus_treeCover_2000.png', cover_figure, dpi = 300)


