
library(lubridate)

# load weeklies1 to merge in the number of characters in subject
load("initial_report/weeklies1.RData")

subscriber_agg <- read.csv("newsletters/csv/intermediate/all_files_week_agg.csv", stringsAsFactors = FALSE)
subscriber_agg$date_sent <- as.POSIXct(subscriber_agg$date_sent, tz = "America/New_York", format = "%Y-%m-%d %H:%M:%S")

# include number of characters in the subject, as well as other covariates from 
# subject_summary_stats.csv

# in order to merge weeklies1$subject_length into subscriber_agg, I need a shared variable
# i.e. the date without the timestamp

weeklies1$date <- format(weeklies1$datetime, format = "%Y-%m-%d")

subscriber_agg$date <- format(subscriber_agg$date_sent, format = "%Y-%m-%d")  



sub_agg_merged <- merge(subscriber_agg, subset(weeklies1,
                                         select = c("subject", "covid", "season", "mins_since_midnight",
                                                    "subject_length", "date")),
                  by = "date")




# construct 2 dataframes, one for the open model, the other for the click model

# first, for the open model: 

subscriber_open <- subset(sub_agg_merged, select = c("date_sent", "subscriberid", "covid", "season", 
                                                     "mins_since_midnight", "subject_length", 
                                                     "week_open", "clicks"))

subscriber_open$week_open[sub_agg_merged$unsubscribes == 1] <- 0

# make week_open, subscriberid, season and covid into factors

subscriber_open$week_open <- as.factor(subscriber_open$week_open)

subscriber_open$subscriberid <- as.factor(subscriber_open$subscriberid)

subscriber_open$covid <- factor(subscriber_open$covid, levels = c("Before", "After"))

subscriber_open$month <- month(subscriber_open$date_sent)

subscriber_open$season <- factor(subscriber_open$season, levels = c("Winter", "Spring",
                                                                   "Summer", "Fall"))

subscriber_open$season_num <- as.numeric(subscriber_open$season)

# making days_since_start variable because the gamm function needs numeric rather than date

study_start <- as.POSIXct("2019-01-01", tz = "America/New_York", format = "%Y-%m-%d")

subscriber_open$days_since_start <- as.numeric(subscriber_open$date_sent - study_start)



save(subscriber_open, file = "open_click_models/subscriber_open.RData")



  

# now, for the click model: 

load("open_click_models/subscriber_open.RData")

# load pt_and_html_df to merge in plain-text and html info
load("newsletters/pt_and_html_df.RData")

# in order to merge pt_and_html_df into subscriber_open, I need a shared variable
# i.e. the date without the timestamp

pt_and_html_df$date <- as.character(as.POSIXct(substr(pt_and_html_df$doc_id, start = 11, stop = 20),
                                               format = "%m-%d-%Y"))

subscriber_open$date <- format(subscriber_open$date_sent, format = "%Y-%m-%d")  



sub_agg_merged2 <- merge(subscriber_open, subset(pt_and_html_df,
                                               select = c("num_words", "num_links", "num_clickable_pics",
                                                          "num_unclickable_pics", "date")),
                        by = "date")

subscriber_clicks <- subset(sub_agg_merged2, select = c("date_sent", "subscriberid", "covid", 
                                                     "mins_since_midnight", "subject_length", 
                                                     "clicks", "days_since_start", "num_words", 
                                                     "num_links", "num_clickable_pics", 
                                                     "num_unclickable_pics"))

save(subscriber_clicks, file = "open_click_models/subscriber_clicks.RData")


  
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



