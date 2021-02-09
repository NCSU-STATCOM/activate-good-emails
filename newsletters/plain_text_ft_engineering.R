
library(readtext)

# functions for plain-text feature engineering



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

pt_ft_engi <- function() {
  
  
  
}




