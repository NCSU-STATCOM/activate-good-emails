
library(dplyr)
library(lubridate)
library(arules)



# Load the data here instead of doing it within plan
# somehow drake doesn't realize that the data changes

weeklies_input <- read.csv("newsletters/subject_summary_stats.csv", stringsAsFactors = FALSE)

# The first three columns, Subject, Date, and Contacts_Sent_To, will not change. Thus, I use just those 
# columns to begin the weekly newsletter data set. 
# iv is independent variables
weeklies_iv0 <- weeklies_input[, 1:3] %>% rename(subject = Subject, datetime = Date, 
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
  
  weeklies$datetime <- as.POSIXct(weeklies$datetime, tz = "America/New_York", format = "%m/%d/%y %H:%M")
  
  # Feature Engineering
  
  # Time Features
  # Before the pandemic started changing things, and after
  weeklies$covid <- ifelse(weeklies$datetime < as.POSIXct("2020-03-12"), "Before", "After")
  
  # sorting the months into different seasons
  letter_months <- month(weeklies$datetime)
  weeklies$season <- ifelse(letter_months %in% c(12, 1, 2), "Winter", 
                            ifelse(letter_months %in% c(3, 4, 5), "Spring", 
                                   ifelse(letter_months %in% c(6, 7, 8), "Summer", "Fall")))
  
  # number of minutes since midnight
  weeklies$mins_since_midnight <- hour(weeklies$datetime) * 60 + minute(weeklies$datetime)
  
  # Lengths of the subject headings variable
  weeklies$subject_length <- sapply(weeklies$subject, nchar)
  
  # Number of words in the subject
  weeklies$subject_num_words <- lengths(strsplit(weeklies$subject, " "))
  
  return(weeklies)
  
}



# generating the wrangled data set that is only based on subject_summary_stats.csv

weeklies_iv1 = init_ft_engi(weeklies_iv0)

weeklies1 <- data.frame(weeklies_iv1, weeklies_dv)

save(weeklies1, file = "initial_report/weeklies1.RData")











