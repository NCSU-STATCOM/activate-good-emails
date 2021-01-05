
# The later newsletters may have their summary statistics change, so the last four columns,
# Opened, Clicks, Bounces, and Unsubscribes,
# of subject_summary_stats.csv may need to be updated

weeklies <- read.csv("newsletters/subject_summary_stats.csv", stringsAsFactors = FALSE)

# The first three columns, Subject, Date, and Contacts_Sent_To, will not change. Thus, I use just those 
# columns to begin the weekly newsletter data set. 

weeklies <- weeklies[, 1:3]

# The last four columns, Opened, Clicks, Bounces, and Unsubscribes, can be added to the data set later, 
# as they get updated. 



# Lengths of the subject headings

weeklies$subject_length <- sapply(weeklies$Subject, nchar)



# convert Date into an actual date variable





