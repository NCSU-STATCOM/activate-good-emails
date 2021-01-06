
library(drake)
library(readtext)
library(dplyr)

plan <- drake_plan(
  
  pt_dir = file.path("newsletters", "plain_text"), 
  
  # read in all the plain-text of the newsletters into a data.frame, 
  # in order of their sent out date
  pt_df = read_in_plain_text(pt_dir),
  
  pt_fts <- pt_ft_engi(pt_df)
  
)




read_in_plain_text <- function(pt_dir) {
  
  pt_df <- readtext(pt_dir)  
  
  # get the sent out dates of the newsletters, from their filenames
  sent_date <- substring(pt_df$doc_id, first = 11, last = 20)
  
  # make them into POSIXlt
  sent_date <- strptime(sent_date, tz = "America/New_York", format = "%m-%d-%Y")
  
  pt_df <- pt_df %>% slice(order(sent_date))
  
  return(pt_df)
  
}



# to-do: number of links, to standardize the click count? 



make(plan)





