
library(mgcv)
library(itsadug)

load("open_click_models/subscriber_open.RData")



ptm <- proc.time()

m1 <- bam(week_open ~ covid + 
            s(date_sent, by = covid) + 
            s(mins_since_midnight, by = covid) + 
            s(subject_length) + 
            s(date_sent, subscriberid, bs = "fs", m = 1), 
          family = "binomial",
          data = subscriber_open)

save(m1, file = "open_click_models/m1.RData")

proc.time() - ptm
