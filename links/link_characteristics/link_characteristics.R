
library(rvest)
library(xml2)

#' Function to return dataframe mapping the link to its characteristics
#'
#' @param newsletter the html file to find the links in
#' @export
link_characteristics <- function(newsletter) {
  
  # list of addresses in newsletter
  address <- newsletter %>% html_nodes("a") %>% html_attr("href")
  
  link_info <- data.frame(link_num = 1:length(address))
  
  link_info$address <- address
  
  # list of words making up the link
  link_info$words_in_link <- newsletter %>% html_nodes("a") %>% html_text()
  
  return(link_info)
  
}



# turn data.frame into csv with additional columns link_num and date

html_names <- list.files("newsletters/html/")

dates <- as.POSIXct(substr(html_names, start = 11, stop = 20), tz = "America/New_York", format = "%m-%d-%Y")

# reorder the filenames according to the dates

html_names <- html_names[order(dates)]

# reorder the dates now
dates <- sort(dates)

# grab the dates, change them to %m/%d/%y format
formatted_dates <- format(dates, format = "%m/%d/%y")



# for each file name in html_names, create html then put into function

link_info_list <- lapply(html_names, function(file_name) {
  
  newsletter <- xml2::read_html(paste0("newsletters/html/", file_name))
  link_info <- link_characteristics(newsletter)
  formatted_date <- format(as.POSIXct(substr(file_name, start = 11, stop = 20),
                                      tz = "America/New_York", format = "%m-%d-%Y"), format = "%m/%d/%y")
  link_info <- data.frame(date = formatted_date, link_info)
  
})

link_info_df <- do.call("rbind", link_info_list)

write.csv(link_info_df, file = "links/link_characteristics/link_characteristics.csv", 
          row.names = FALSE)



# then maybe make function to extract from it accordingly




#' Function to return dataframe mapping the link to its characteristics
#'
#' @param newsletter the html file to find the links in
#' @export






