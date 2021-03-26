library(mgcv)
library(itsadug)
library(forecast)
library(tidymv)

load("open_click_models/subscriber_clicks.RData")



# trying to subset the data to speed things up

subid <- unique(subscriber_clicks$subscriberid)

set.seed(232)

subid_sample <- subid[sample(1:length(subid), size = length(subid) / 10)]

dat_sample <- subscriber_clicks[subscriber_clicks$subscriberid %in% subid_sample,]



ptm <- proc.time()

m1 <- bam(clicks ~ covid + 
            s(days_since_start, by = covid) + 
            s(mins_since_midnight, by = covid) + 
            s(subject_length) + 
            s(num_words) + 
            s(num_links) + 
            s(num_clickable_pics) + # 10 unique values
            s(num_unclickable_pics, k = 5) + # 5 unique values
            s(subscriberid, bs = "re"), 
          family = "binomial",
          data = dat_sample, 
          discrete = TRUE)

save(m1, file = "open_click_models/m1_clicks.RData")

proc.time() - ptm

# takes 3 minutes



