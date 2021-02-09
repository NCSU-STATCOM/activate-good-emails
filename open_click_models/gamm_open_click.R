
library(mgcv)
library(itsadug)

load("open_click_models/subscriber_open.RData")



# trying to subset the data to speed things up

subid <- unique(subscriber_open$subscriberid)

set.seed(232)

subid_sample <- subid[sample(1:length(subid), size = length(subid) / 100)]

dat_sample <- subscriber_open[subscriber_open$subscriberid %in% subid_sample,]

m0 <- bam(week_open ~ covid + 
            s(days_since_start, by = covid) + 
            s(mins_since_midnight, by = covid) + 
            s(subject_length) + 
            s(days_since_start, subscriberid, bs = "fs", m = 1), 
          family = "binomial",
          data = dat_sample)



checkresiduals(m0)



ptm <- proc.time()

m1 <- bam(week_open ~ covid + 
            s(days_since_start, by = covid) + 
            s(mins_since_midnight, by = covid) + 
            s(subject_length) + 
            s(days_since_start, subscriberid, bs = "fs", m = 1), 
          family = "binomial",
          data = subscriber_open)

save(m1, file = "open_click_models/m1.RData")

proc.time() - ptm




ptm <- proc.time()

m2 <- bam(week_open ~ covid + 
            s(days_since_start, by = covid) + 
            s(mins_since_midnight, by = covid) + 
            s(subject_length) + 
            s(subscriberid, bs = "re"), 
          family = "binomial",
          data = subscriber_open)

save(m2, file = "open_click_models/m2.RData")

proc.time() - ptm
