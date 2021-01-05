
library(drake)
library(dplyr)



wrangling_plan <- drake_plan(
  
  weeklies_input = read.csv("newsletters/subject_summary_stats.csv", stringsAsFactors = FALSE),
  
  # The first three columns, Subject, Date, and Contacts_Sent_To, will not change. Thus, I use just those 
  # columns to begin the weekly newsletter data set. 
  # iv is independent variables
  weeklies_iv0 = weeklies_input[, 1:3] %>% rename(subject = Subject, time = Date, 
                                                  contacts_sent_to = Contacts_Sent_To),
  
  # The later newsletters may have their summary statistics change, so the last four columns,
  # Opened, Clicks, Bounces, and Unsubscribes,
  # of subject_summary_stats.csv may need to be updated.
  # dv is dependent variables
  weeklies_dv = weeklies_input[, -c(1:3)] %>% rename(opened = Opened, clicks = Clicks, 
                                                     bounces = Bounces, 
                                                     unsubscribes = Unsubscribes), 
  
  weeklies_iv1 = init_ft_engi(weeklies_iv0)
  
)



init_ft_engi <- function(weeklies) {
  
  # convert Date into a POSIXlt variable
  
  weeklies$time <- strptime(weeklies$time, tz = "America/New_York", format = "%m/%d/%y %H:%M")
  
  # Feature Engineering
  # Lengths of the subject headings variable
  
  weeklies$subject_length <- sapply(weeklies$subject, nchar)
  
  return(weeklies)
  
}



make(wrangling_plan)




