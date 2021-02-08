
# load weeklies1 to merge in the number of characters in subject
load("initial_report/weeklies1.RData")

subscriber_agg <- read.csv("newsletters/csv/intermediate/all_files_week_agg.csv", stringsAsFactors = FALSE)
str(subscriber_agg)
subscriber_agg$date_sent <- as.POSIXct(subscriber_agg$date_sent, tz = "America/New_York", format = "%Y-%m-%d %H:%M:%S")
table(subscriber_agg$date_sent)
unique(subscriber_agg$date_sent)

# include number of characters in the subject, as well as other covariates from 
# subject_summary_stats.csv

# in order to merge weeklies1$subject_length into subscriber_agg, I need a shared variable
# i.e. the date without the timestamp

weeklies1$date <- format(weeklies1$datetime, format = "%Y-%m-%d")

subscriber_agg$date <- format(subscriber_agg$date_sent, format = "%Y-%m-%d")  



sub_agg_merged <- merge(subscriber_agg, subset(weeklies1,
                                         select = c("subject", "covid", "mins_since_midnight",
                                                    "subject_length", "date")),
                  by = "date")




# construct 2 dataframes, one for the open model, the other for the click model

subscriber_open <- subset(sub_agg_merged, select = c("date_sent", "subscriberid", "covid", 
                                                     "mins_since_midnight", "subject_length", 
                                                     "week_open"))

subscriber_open$week_open[sub_agg_merged$unsubscribes == 1] <- 0

save(subscriber_open, file = "open_click_models/subscriber_open.RData")

  


  
# exploration and checking

all.equal(sort(weeklies1$date), sort(unique(subscriber_agg$date)))


# week_open and opened are actually similar anyways
table(sub_agg_merged$neither, sub_agg_merged$week_open)

# small proportion of bounces, and can still open even if bounced, so I decided
# to ignore bounces

table(sub_agg_merged$bounces, sub_agg_merged$week_open)

mean(sub_agg_merged$bounces)



# Seems like a significant amount of unsubscribes do occur. Thus, I will set week_open as 0 if there's
# an unsubscribe.

table(sub_agg_merged$unsubscribes, sub_agg_merged$week_open)

879 / nrow(sub_agg_merged)



# EDA

cor(subscriber_agg[, c(4:8)])



