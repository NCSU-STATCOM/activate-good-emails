
library(mgcv)
library(itsadug)
library(forecast)
library(tidymv)

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



ptm <- proc.time()

m3 <- bam(week_open ~ covid + 
            s(days_since_start, by = covid) + 
            s(mins_since_midnight, by = covid) + 
            s(subject_length) + 
            s(subscriberid, bs = "re"), 
          family = "binomial",
          data = subscriber_open, 
          discrete = TRUE)

save(m3, file = "open_click_models/m3.RData")

proc.time() - ptm



# trying to subset the data to speed things up

subid <- unique(subscriber_open$subscriberid)

set.seed(232)

subid_sample <- subid[sample(1:length(subid), size = length(subid) / 10)]

dat_sample <- subscriber_open[subscriber_open$subscriberid %in% subid_sample,]



ptm <- proc.time()

m4 <- bam(week_open ~ covid + 
            s(days_since_start, by = covid) + 
            s(mins_since_midnight, by = covid) + 
            s(subject_length) + 
            s(subscriberid, bs = "re"), 
          family = "binomial",
          data = dat_sample, 
          discrete = TRUE)

save(m4, file = "open_click_models/m4.RData")

proc.time() - ptm



ptm <- proc.time()

m5 <- bam(week_open ~ covid + 
            s(days_since_start, by = covid) + 
            s(mins_since_midnight, by = covid) + 
            s(subject_length) + 
            s(days_since_start, subscriberid, bs = "fs", m = 1), 
          family = "binomial",
          data = dat_sample, 
          discrete = TRUE)

save(m5, file = "open_click_models/m5.RData")

proc.time() - ptm

# R-sq.(adj) =  0.412



ptm <- proc.time()

m6 <- bam(week_open ~ covid +
            s(days_since_start, by = covid) + 
            s(mins_since_midnight, by = covid) + 
            s(subject_length) + 
            s(subscriberid, bs = "re") +
            s(subscriberid, days_since_start, bs = "re"), 
          family = "binomial",
          data = dat_sample, 
          discrete = TRUE)

save(m6, file = "open_click_models/m6.RData")

proc.time() - ptm

# R-sq.(adj) =  0.429 



ptm <- proc.time()

m7 <- bam(week_open ~ covid +
          s(days_since_start, by = covid) + 
            s(month, bs = "cc", by = covid) +
            s(mins_since_midnight, by = covid) + 
            s(subject_length) + 
            s(subscriberid, bs = "re"), 
          family = "binomial",
          data = dat_sample, 
          discrete = TRUE)

save(m7, file = "open_click_models/m7.RData")

proc.time() - ptm

# R-sq.(adj) =  0.399



#######

load("~/Documents/NCSU_Spring_2021/activate_good_project/open_click_models/m4.RData")



# There doesn't seem to be severe autocorrelation in time. 

# checkresiduals(m4)











