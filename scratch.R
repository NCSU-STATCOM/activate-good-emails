library(lubridate)
library(readxl)
library(XML)
library(xml2)
library(rvest)

subscriber_dat <- read.csv("newsletters/csv/intermediate/all_months_201920_dens.csv", stringsAsFactors = FALSE)
str(subscriber_dat)
table(subscriber_dat$date_sent)
unique(subscriber_dat$date_sent)
length(unique(subscriber_dat$date_sent))
strptime(unique(subscriber_dat$date_sent), tz = "America/New_York", format = "%m/%d/%y")
subs_date_sent <- strptime(unique(subscriber_dat$date_sent), tz = "America/New_York", format = "%m/%d/%y")
sort(subs_date_sent)

subscriber_dat$date <- as.POSIXct(subscriber_dat$date, tz = "America/New_York", format = "%Y-%m-%d %H:%M:%S")

# number of minutes since midnight
subscriber_dat$mins_since_midnight <- hour(subscriber_dat$date) * 60 + 
  minute(subscriber_dat$date)

summary(subscriber_dat$mins_since_midnight[subscriber_dat$opens == 1])



subscriber_agg <- read.csv("newsletters/csv/intermediate/all_files_week_agg.csv", stringsAsFactors = FALSE)
str(subscriber_agg)
subscriber_agg$date_sent <- as.POSIXct(subscriber_agg$date_sent, tz = "America/New_York", format = "%Y-%m-%d %H:%M:%S")
table(subscriber_agg$date_sent)
unique(subscriber_agg$date_sent)




links <- read_excel("links/UniqueLinks.xlsx", sheet = 1)

# This seems like the best way to read in html. 
first_news <- readLines("newsletters/html/newsletter01-02-2019.html") 

first_news2 <- htmlTreeParse("newsletters/html/newsletter01-02-2019.html")

first_news3 <- xml2::read_html("newsletters/html/newsletter01-02-2019.html")

# first_news4 <- html("newsletters/html/newsletter01-02-2019.html")



# woman typing keyboard background
# https://staticapp.icpsc.com/icp/resources/mogile/841808/76689b8335887d140a6d8cd9a1218e96.jpeg

# activate good clickable picture
# <a href="https://activategood.org/" style=""><img src="https://staticapp.icpsc.com/icp/resources/mogile/841808/4127d24183a929aa05409bbd0424b12b.png" class="fusionResponsiveImage" alt="" width="450" height="auto" style="display:block;width:450px;height:auto;margin:auto;background-color:transparent;"></a>

# <a href="https://activategood.org/" style=""><img src="https://staticapp.icpsc.com/icp/resources/mogile/841808/3422c23f09f1526350bdc79e915e9560.jpeg" class="fusionResponsiveImage" alt="" width="570" height="auto" style="display:block;width:570px;height:auto;margin:auto;background-color:transparent;"></a>



# count background non-interactive background images and clickable images separately





# (?<!<!--\[if !mso\]><!-->)(?<!<!--\[if !mso\]><!-->)(?<!<!--\[if !mso\]><!-->)(?<!<a href=.+?>)

string_clicks_opp <- read.csv("links/stringlinks/intermediate/string_clicks_opp.csv")

string_clicks_unique <- read.csv("links/stringlinks/intermediate/string_clicks_unique.csv")



link_chars <- read.csv("links/link_characteristics/link_characteristics.csv", header = TRUE)





newsletter <- xml2::read_html(paste0("newsletters/html/", "newsletter11-11-2020.html"))



num_empties <- link_chars %>% group_by(date) %>% summarise(num_na = sum(words_in_link == ""))

dates <- as.POSIXct(num_empties$date, tz = "America/New_York", format = "%m/%d/%y")

num_empties <- num_empties[order(dates),]

all.equal(num_empties$num_na, pt_and_html_df$num_clickable_pics)

which(num_empties$num_na != pt_and_html_df$num_clickable_pics)

# The 47th newsletter on 11/11/20 has the special case. It's not present at all in the newsletter




link_chars <- read.csv("links/link_characteristics/link_characteristics.csv", header = TRUE)

# checking that the last 3 links for each newsletter are the social media links
# answer: nope, not necessarily

# getting the info for the 3 social media links of each newsletter

dates <- unique(link_chars$date)

# just copying link_chars arbitrarily, will be modif later
last3links <- link_chars[1:(3 * length(dates)),]

for (i in 1:length(dates)) {
  
  date_subset <- link_chars[link_chars$date == dates[i],]
  
  # select the last links mentioning social media
  sm_idx <- which(date_subset$address %in% c("https://www.facebook.com/activategood/",
                                   "https://twitter.com/activategood",
                                   "https://www.instagram.com/activategood/"))
  
  sm_idx <- sm_idx[(length(sm_idx) - 2):length(sm_idx)]
  
  last3links[((i - 1)*3 + 1):(i * 3),] <- date_subset[sm_idx, ]
  
}

# last3links name is a misnomer

# so, I have checked that all the social media links have been accounted for correctly. 




links <- read_excel("links/stringlinks/UniqueLinks.xlsx")




link_count_chars <- read.csv("links/link_counts_characteristics.csv", header = T)

link_cat <- read.csv("links/stringlinks/intermediate/all_string_html_cat.csv",
                             header = T)

link_doc_prop <- read.csv("links/stringlinks/intermediate/all_string_html.csv",
                     header = T)



full_link_df <- read.csv("links/full_link_dataset.csv",
                          header = T)
  
