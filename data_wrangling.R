
library(dplyr)
library(readtext)

source("plain_text_ft_engineering.R")



# Load the data here instead of doing it within plan
# somehow drake doesn't realize that the data changes

weeklies_input <- read.csv("newsletters/subject_summary_stats.csv", stringsAsFactors = FALSE)

# The first three columns, Subject, Date, and Contacts_Sent_To, will not change. Thus, I use just those 
# columns to begin the weekly newsletter data set. 
# iv is independent variables
weeklies_iv0 <- weeklies_input[, 1:3] %>% rename(subject = Subject, time = Date, 
                                                 contacts_sent_to = Contacts_Sent_To)

# The later newsletters may have their summary statistics change, so the last four columns,
# Opened, Clicks, Bounces, and Unsubscribes,
# of subject_summary_stats.csv may need to be updated.
# dv is dependent variables
weeklies_dv <- weeklies_input[, -c(1:3)] %>% rename(opened = Opened, clicks = Clicks, 
                                                    bounces = Bounces, 
                                                    unsubscribes = Unsubscribes)



# Reading in the first dataset subject_summary_stats.csv and engineering features from it

# possible to-do: make time variables, like weekday/weekend, morning/night
init_ft_engi <- function(weeklies) {
  
  # convert Date into a POSIXlt variable
  
  weeklies$time <- as.POSIXct(weeklies$time, tz = "America/New_York", format = "%m/%d/%y %H:%M")
  
  # Feature Engineering
  
  # Before the pandemic started changing things, and after
  weeklies$covid <- ifelse(weeklies$time >= as.POSIXct("2020-03-12"), TRUE, FALSE)
  
  # Lengths of the subject headings variable
  weeklies$subject_length <- sapply(weeklies$subject, nchar)
  
  return(weeklies)
  
}



# generating the wrangled data set that is only based on subject_summary_stats.csv

weeklies_iv1 = init_ft_engi(weeklies_iv0)

weeklies1 <- data.frame(weeklies_iv1, weeklies_dv)

save(weeklies1, file = "wrangled_data/weeklies1.RData")



# Including plain-text features

pt_dir <- file.path("newsletters", "plain_text")

# read in all the plain-text of the newsletters into a data.frame, 
# in order of their sent out date
pt_df <- read_in_plain_text(pt_dir)

# pt_fts <- pt_ft_engi(pt_df)







