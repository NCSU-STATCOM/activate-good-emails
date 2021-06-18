
library(rvest)
library(xml2)
library(stringr)

#' Function to return dataframe mapping the link to its characteristics
#'
#' @param newsletter the html file to find the links in
#' @export
link_characteristics <- function(newsletter) {
  
  # list of addresses in newsletter
  address <- newsletter %>% html_nodes("a") %>% html_attr("href")
  
  link_info <- data.frame(link_num = 1:length(address))
  
  # list of words making up the link
  link_info$words_in_link <- newsletter %>% html_nodes("a") %>% html_text()
  
  # image flag
  image_nodeset <- newsletter %>% html_nodes("a") %>% html_node("img")
  link_info$is_image <- sapply(image_nodeset, function(node) !is.na(node))
  
  # retrieve html node attributes related to image dimensions
  # notes: the width is the only relevant feature. The height is either 
  # 65 (for social media links) or "auto". 
  # width may be a number or 100%.
  link_info$image_width <- newsletter %>% html_nodes("a") %>% 
    html_node("img") %>% html_attr("width")
  # link_info$image_height <- newsletter %>% html_nodes("a") %>% 
  #   html_node("img") %>% html_attr("height")
  # link_info$image_style <- newsletter %>% html_nodes("a") %>% 
  #   html_node("img") %>% html_attr("style")
  
  # If width is 100%, change it to 199 if it's in a group of three, 
  # and 280 if it's in a group of two.
  
  # first make a helper variable nbr100perc with values NA, 2, and 3
  nbr100perc <- rep(NA, length = length(address))
  # nbr100perc is 2 if image is 100% and one neighbor is also 100%
  image_width <- link_info$image_width
  image_width[is.na(image_width)] <- 0
  for (i in 1:length(address)) {
    if (image_width[i] == "100%") {
      if (i > 1 & image_width[i - 1] == "100%") {
        nbr100perc[i] <- 2
      }
      else if (i < length(address) & image_width[i + 1] == "100%") {
        nbr100perc[i] <- 2
      }
    }
  }
  # nbr100perc is 3 if image is 100% and both of its neighbors are also 100%
  # additionally, those neighbors will have nbr100perc of 3, so 
  # nbr100perc will then indicate whether a 100% image is in a group of 2 or 3
  for (i in 1:length(address)) {
    if (image_width[i] == "100%") {
      if (i > 1 & image_width[i - 1] == "100%") {
        if (i < length(address) & image_width[i + 1] == "100%") {
          nbr100perc[i] <- 3
          nbr100perc[i - 1] <- 3
          nbr100perc[i + 1] <- 3
        }
      }
    }
  }
  
  # If width is 100%, change it to 199 if it's in a group of three, 
  # and 280 if it's in a group of two.
  link_info$image_width <- ifelse(image_width == "100%", ifelse(
  nbr100perc == 2, 280, ifelse(nbr100perc == 3, 199, link_info$image_width)),
  link_info$image_width)
  
  # turn image_width into numeric
  link_info$image_width <- as.numeric(link_info$image_width)
  
  # indicator of whether link is bolded (has strong tag)
  strong_nodeset <- newsletter %>% html_nodes("a") %>% html_node("strong")
  link_info$bolded <- sapply(strong_nodeset, function(node) !is.na(node))
  
  # font characteristics (use regex to get font size and color)
  font_characteristics <- newsletter %>% html_nodes("a") %>% html_attr("style")
  
  # font size 
  font_size <- str_extract(font_characteristics, pattern = 'font-size:\\d+')
  font_size <- as.numeric(gsub("font-size:", "", font_size))
  # there may be a missing font size even when the link has words in it. In this case, 
  # the font size is set to the default at 15, at least for the first newsletter. 
  # Hopefully the default doesn't change. 
  # I also need to ignore the social media buttons, which have font characteristics
  # for some reason.
  font_size[font_characteristics != "" & 
              font_characteristics != "text-decoration:none;cursor:pointer;box-sizing:content-box;" &
              is.na(font_size)] <- 15
  link_info$font_size <- font_size
  
  # font color
  font_color <- str_extract(font_characteristics, pattern = '(?<!background-)color:rgb\\(\\d+, *\\d+, *\\d+\\)')
  font_color <- gsub("color:rgb", "", font_color)
  link_info$font_color <- font_color
  
  # finally, the href addresses themselves
  link_info$address <- address
  
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
  
  # flag for duplicates after the first one
  dup_after_first <- duplicated(link_info$address)
  
  # flag for any duplicates, including first ones
  dup_addresses <- unique(link_info$address[dup_after_first])
  dup <- link_info$address %in% dup_addresses
  
  # flag for links that have images associated with them
  # this will include image links and text links that also have images associated with them
  image_addresses <- unique(link_info$address[link_info$is_image])
  image_assoc <- link_info$address %in% image_addresses
  
  link_info <- data.frame(link_info, dup = dup, dup_after_first = dup_after_first, 
                          image_assoc = image_assoc)
  
})

link_info_df <- do.call("rbind", link_info_list)

# remove the 18th link for the 11-11-2020 newsletter 
link_info_df <- link_info_df[-which(link_info_df$date == "11/11/20" & link_info_df$link_num == 18),]

write.csv(link_info_df, file = "links/link_characteristics/link_characteristics.csv", 
          row.names = FALSE)

# make another version, removing image links and any duplicates 
# that isn't the first text link

link_info_df_no_dup <- link_info_df[link_info_df$is_image == FALSE,]

text_dup <- duplicated(cbind(link_info_df_no_dup$date, link_info_df_no_dup$address))

link_info_df_no_dup <- link_info_df_no_dup[text_dup == FALSE,]

# add images back in, at the bottom

link_info_df_no_dup <- rbind(link_info_df_no_dup, link_info_df[link_info_df$is_image == TRUE,])



write.csv(link_info_df_no_dup, file = "links/link_characteristics/link_characteristics_no_dup.csv", 
          row.names = FALSE)





