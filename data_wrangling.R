
library(drake)
library(dplyr)



wrangling_plan <- drake_plan(
  
  weeklies_input = read.csv("newsletters/subject_summary_stats.csv", stringsAsFactors = FALSE),
  
  # The first three columns, Subject, Date, and Contacts_Sent_To, will not change. Thus, I use just those 
  # columns to begin the weekly newsletter data set. 
  weeklies_iv0 = weeklies_input[, 1:3], # iv is independent variables
  
  # The later newsletters may have their summary statistics change, so the last four columns,
  # Opened, Clicks, Bounces, and Unsubscribes,
  # of subject_summary_stats.csv may need to be updated
  weeklies_dv = weeklies_input[, -c(1:3)], # dv is dependent variables
  
  weeklies_iv1 = init_ft_engi(weeklies_iv0)
  
)



init_ft_engi <- function(weeklies) {
  
  # convert Date into a POSIXlt variable
  
  weeklies$Date <- strptime(weeklies$Date, tz = "America/New_York", format = "%m/%d/%y %H:%M")

  # renaming variables to snake case
  
  weeklies <- weeklies %>% rename(subject = Subject, time = Date, 
                                  contacts_sent_to = Contacts_Sent_To)
  
  # Feature Engineering
  # Lengths of the subject headings variable
  
  weeklies$subject_length <- sapply(weeklies$Subject, nchar)
  
  return(weeklies)
  
}





