library(aws.s3)
library(nanoparquet)
library(dplyr)
library(lubridate)
library(forcats)
library(aws.ec2metadata) 

# preparing data for DASH Posit connect dashboard

pv <- aws.s3::s3read_using(FUN = nanoparquet::read_parquet, object = "ProduceView/produce_view.parquet", bucket = "s3-ranch-045")
pv <- pv |> 
  mutate(date = ymd(date),
         country = case_when(country == "United States Of America" ~ "USA", 
                             country == "Viet Nam" ~ "Vietnam",
                             .default = country),
         date01 = ymd(paste(year(date), month(date), "01", sep = "-")),
         promo = case_when(on_promotion == 0 ~ "N",
                           on_promotion == 1 ~ "Y")) |> 
  filter(!country %in% c("NA", "Non Shown", "-- NA --")) |> 
  select(date, category, sub_category, product_group, country)

saveRDS(pv, "./data/pv.rds")
