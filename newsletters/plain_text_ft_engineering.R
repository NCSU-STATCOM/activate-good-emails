
library(readtext)
library(tidyverse)
library(tokenizers)
library(stringi)

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



# Including plain-text features

pt_dir <- file.path("newsletters", "plain_text")

# read in all the plain-text of the newsletters into a data.frame,
# in order of their sent out date
pt_df <- read_in_plain_text(pt_dir)



# String Cleaning

# All weekly newsletters have bracketed numbers throughout and a list of references at the bottom.
# Consider removing those before tokenization. 

# Thus, you can remove all bracketed numbers and things from "[22]Facebook [23]Twitter [24]Instagram" down.

# remove the bottom part (social media and references) first

text_rm_bottom <- sapply(pt_df$text, function(x) {
  
  gsub("\\[\\d+\\]Facebook \\[\\d+\\]Twitter \\[\\d+\\]Instagram.*", "", x)
  
}, USE.NAMES = FALSE)

text_rm_bracket_nums <- sapply(text_rm_bottom, function(x) {
  
  gsub("\\[\\d+\\]", "", x)
  
}, USE.NAMES = FALSE)

word_tokens_list <- tokenize_words(text_rm_bracket_nums)

pt_df$num_words <- sapply(word_tokens_list, length)



# count the number of links

pt_df$num_links <- sapply(pt_df$text, function(x) {
  
  # index right before list of links 
  ref_index <- stri_locate_last(x, regex = "References")[2] + 1
  
  str_count(substr(x, start = ref_index, stop = str_length(x)), pattern = "\\\n\\d*\\. ")
  
}, USE.NAMES = FALSE)



save(pt_df, file = "newsletters/pt_df.RData")



