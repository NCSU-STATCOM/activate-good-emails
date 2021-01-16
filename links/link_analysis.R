library(dplyr)
library(stringr)
library(rvest)

full_data = read.csv("newsletters/csv/intermediate/all_months_201920_dens.csv")

opp_data = full_data %>% 
                select("link") %>%
                mutate_all(funs(str_replace(.,"#.*", ""))) %>%
                filter(grepl("opportunity/\\d+", link))

length(unique(opp_data$link))
# there are 138 unique opportunities


link_df = as.data.frame(sort(table(opp_data$link), decreasing= TRUE))
names(link_df) = c("link", "click count")
link_df$title = NA

for(row in 1:nrow(link_df)){
  url_string = toString(link_df$link[row])
  # print(url_string)
  
  url = html(url_string)
  link_df$title[row] = url %>% 
                        html_node("strong") %>% 
                        html_text()
}

save(link_df, file="link_df.RData")
