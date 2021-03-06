library(xml2)
library(rvest)

# script for html feature engineering

# reading in pt_df to get the list of newsletter ids

load("newsletters/pt_df.RData")

# replace ".txt" with ".html"

newsletter_id <- gsub(".txt", ".html", pt_df$doc_id)



num_clickable_pics <- rep(NA, length(newsletter_id))
num_unclickable_pics1 <- rep(NA, length(newsletter_id))
num_unclickable_pics2 <- rep(NA, length(newsletter_id))



for (i in 1:length(newsletter_id)) {
  
  suppressWarnings(news_html <- readLines(paste0("newsletters/html/", newsletter_id[i])))
  
  # find the interactive pictures with link associated with it
  # example string to match:
  # <a href="https://activategood.org/" style=""><img src="https://staticapp.icpsc.com/icp/resources/mogile/841808/3422c23f09f1526350bdc79e915e9560.jpeg" class="fusionResponsiveImage" alt="" width="570" height="auto" style="display:block;width:570px;height:auto;margin:auto;background-color:transparent;"></a>
  
  num_clickable_pics[i] <- sum(str_count(news_html, pattern = "<a href=.+?><img src="))
  
  # find the non-interactive pictures without a link associated with it.
  # examples of two different kinds:
  # <td style='background-color:rgb(0,136,168);padding:7px 0px;border-color:transparent;border-width:0px;border-style:none;background-image:url("https://staticapp.icpsc.com/icp/resources/mogile/841808/76689b8335887d140a6d8cd9a1218e96.jpeg");background-position:center center;background-repeat:repeat;'>
  # <img src="https://staticapp.icpsc.com/icp/resources/mogile/841808/5aa2b33d3328e7ac86b764f9d139aa56.png" class="fusionResponsiveImage" alt="" width="240" height="auto" style="display:block;width:240px;height:auto;margin:auto;background-color:transparent;">
  
  num_unclickable_pics1[i] <- sum(str_count(news_html, pattern = "background-image:url"))
  num_unclickable_pics2[i] <- sum(str_count(news_html, pattern = '^ *<img src=\\".+?"(?=.*\\bwidth\\b)(?=.*\\bheight\\b)'))
  
}












