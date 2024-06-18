setwd('/Users/cglidden/Desktop/GEE_EEID') # change to your wd

##---- set up packages ----##
library(dplyr)
library(tidyr)
library(lubridate)
library(sf)
library(ggplot2)

##------------------------------- data setup (load CA county ERA5 data) -------------------------------##
era5_data_wide <- read.csv('CA_county_monthly_temps.csv')
names(era5_data_wide) # notice each month-year is a column

##------ use pivot longer to restructure time series for mean temp ------##
era5_mean_long <- era5_data_wide |>
  select(-contains('_median')) |> # get rid of median columns
  tidyr::pivot_longer(cols = ends_with("mean"), 
                      names_to = "time_point",
                      values_to = "temperature_2m_mean") |>
  extract(time_point, into = c("year", "month"),
          regex = "X(\\d{4})(\\d{2})_temperature_2m_mean",
          remove = FALSE) |>
  mutate(year = as.integer(year),
         month = as.integer(month),
         tempC_mean = temperature_2m_mean - 273.15) |> # convert to celcius
  select('GEOID', 'NAME', 'tempC_mean', 'month', 'year')  # select important variables and unique identifiers

summary(era5_mean_long) # quick check of results

##---------------------- plot time series to check results --------------------##
humboldt <- era5_mean_long |> # isolate to one county for easy visualization
  filter(NAME == 'Humboldt') |>
  mutate(date_column = make_date(year, month))

ggplot(humboldt, aes(x = date_column, y = tempC_mean)) + 
  geom_line() + 
  theme_bw()


##--------------##
ca_counties <- st_read('california_counties') |>
ca_counties <- ca_counties %>% filter(is.na(ISLAND))

ca_era5_shape <- ca_counties |>
  inner_join(era5_mean_long, by = "GEOID")

# plot one time point: temperature in august 2022

ca_era5_aug2022 <- ca_era5_shape |>
  filter(month == 08 & year == 2022)

ca_era5_aug22_fig <- ggplot() +
  geom_sf(data = ca_era5_aug2022, aes(fill = tempC_mean)) +
  scale_fill_gradient(low = "blue", high = "red", name = 'temp (C)') +
  ggtitle("mean air temp - August 2022") +
  theme_void()
ggsave('ca_county_aug2022_temps.png', ca_era5_aug22_fig, dpi = 300)

ca_counties_save <- ca_era5_shape %>%
  select(GEOID, COUNTY_NAM) %>%
  rename("NAME" = "COUNTY_NAM") %>% distinct()









