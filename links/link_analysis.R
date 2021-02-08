library(dplyr)
library(stringr)
library(rvest)
library(chron)

full_data = read.csv("newsletters/csv/intermediate/all_months_201920_dens.csv")

# filter for only opportunities 
# combine opportunity/1234 and opportunity/1234#tab-****
opp_data = full_data %>% 
                distinct(link, subscriberid) %>%
                select("link") %>%
                mutate_all(funs(str_replace(.,"#.*", ""))) %>%
                filter(grepl("opportunity/\\d+", link))

length(unique(opp_data$link))
# there are 138 unique opportunities


link_df = as.data.frame(sort(table(opp_data$link), decreasing= TRUE))
names(link_df) = c("link", "click count")
link_df$title = NA
link_df$dates_sent = NA


# get title for each url
for(row in 1:nrow(link_df)){
  url_string = toString(link_df$link[row])

  url = html(url_string)
  link_df$title[row] = url %>% 
            html_node("strong") %>% 
            html_text()
}

clean_date = function(x){
  return(unlist(strsplit(as.character(x), " ", 1))[1])
}

# get dates sent for each url
for(row in 1:nrow(link_df)){
  # get date sent
  date = full_data %>% 
    filter(grepl(link_df$link[row],link)) %>%
    select(date_sent)
  
  date_fix = lapply(unlist(unique(date)), clean_date)
  
  link_df$dates_sent[row][[1]] = sort(unlist(date_fix))
}


save(link_df, file="link_df.RData")



#############
# make sure this accounts for one person clicking the same link multiple times
##########
