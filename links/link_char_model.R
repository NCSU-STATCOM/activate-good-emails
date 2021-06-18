########################################################################
# Create a simple model between the link characteristics and the click count
########################################################################
library(ggplot2)
library(chron)
library(stats)

link_char_count <- read.csv("full_link_dataset.csv")

# Note that a missing click count actually indicates no clicks and not missing
link_char_count_date_clean <- link_char_count
link_char_count_date_clean[is.na(link_char_count$clicks),]$clicks <- 0

# correct the date sent column due to these "missing" click counts
date_map <- unique(link_char_count[is.na(link_char_count$date_sent) == FALSE, cbind('date', 'date_sent')])
colnames(date_map) <- c('date', 'date_sent_clean')
  # convert to datetime object
date_map$date_sent_clean <- strptime(date_map$date_sent_clean, "%m/%d/%y %H:%M:%S", tz = '')

  # Add in an hour variable
date_map$hour <- sapply(date_map$date_sent_clean, hours)

  # Add in a COVID-19 indicator
covid <- as.Date(strptime('03/12/20', '%m/%d/%y'))
date_map$covid_ind <- as.Date(strptime(date_map$date, '%m/%d/%y')) < covid

link_char_count_date_clean <- merge(link_char_count_date_clean, date_map)

# remove missing link numbers and duplicate entries
cond1 <- is.na(link_char_count_date_clean$link_num) == FALSE
cond2 <- link_char_count_date_clean$dup_after_first == FALSE
link_char_count_clean <- link_char_count_date_clean[(cond1) & (cond2),]

# Add in a counter variable
link_char_count_clean$count = 1

# Split into image, text without image, and text with image
link_char_count_clean$type = 'image only'
link_char_count_clean[(link_char_count_clean$is_image == FALSE) & 
                        (link_char_count_clean$image_assoc == FALSE),]$type = 'text only'
link_char_count_clean[(link_char_count_clean$is_image == FALSE) & 
                        (link_char_count_clean$image_assoc == TRUE),]$type = 'text and image'

# Get the average number of times a link was clicked based on whether it was a picture or not
prop_df <- aggregate(cbind(clicks, count) ~ type, data = link_char_count_clean, FUN = sum)
prop_df$mean <- prop_df$clicks/prop_df$count
ggplot(data = prop_df, aes(x = type, y = mean)) + geom_bar(stat = 'identity') +
  labs(x = 'Type of Link', y = 'Average Number of Clicks')

# Whether or not it was bolded
prop_df <- aggregate(cbind(clicks, count) ~ bolded, data = link_char_count_clean, FUN = sum)
prop_df$mean <- prop_df$clicks/prop_df$count
ggplot(data = prop_df, aes(x = bolded, y = mean)) + geom_bar(stat = 'identity') +
  labs(x = 'Bolded Link', y = 'Average Number of Clicks')

# Were people more or less active during COVID?
  # average number of times a link was clicked before and during COVID
prop_df <- aggregate(cbind(clicks, count) ~ covid_ind, data = link_char_count_clean, FUN = sum)
prop_df$mean <- prop_df$clicks/prop_df$count
ggplot(data = prop_df, aes(x = covid_ind, y = mean)) + geom_bar(stat = 'identity') +
  labs(x = 'During COVID?', y = 'Average Number of Clicks')

# Were people more likely to click on something with an image?
prop_df <- aggregate(cbind(clicks, count) ~ image_assoc, data = link_char_count_clean, FUN = sum)
prop_df$mean <- prop_df$clicks/prop_df$count
ggplot(data = prop_df, aes(x = image_assoc, y = mean)) + geom_bar(stat = 'identity') +
  labs(x = 'During COVID?', y = 'Average Number of Clicks')

# top 5 colors
# click

# Look at the other variables
pairs(link_char_count_clean[c('clicks', 'link_num', 'font_size', 'hour')])

# Consider only links with text (text only or text and image)
text_only <- link_char_count_clean[link_char_count_clean$type != 'image only',]
text_only <- text_only[c('clicks', 'link_num', 'bolded', 'font_color', 'font_size',
                         'hour', 'covid_ind', 'image_assoc')]
text_only <- na.omit(text_only)

text_lm <- lm(clicks ~ link_num + bolded + font_color + font_size + hour + covid_ind + image_assoc,
              data = text_only)

ggplot() + geom_point(aes(text_only$clicks, text_lm$fitted.values)) + 
  labs(title = 'Observed Number of Clicks vs. Fitted Values')

plot(text_only$clicks, text_lm$fitted.values)

# transform the number of clicks
text_only$sqrt_click <- sqrt(text_only$clicks)

text_lm_sqrt <- lm(sqrt_click ~ link_num + bolded + font_color + font_size + hour + covid_ind + image_assoc,
                   data = text_only)

plot(text_only$sqrt_click, text_lm$fitted.values)
qqnorm(text_lm$residuals)
qqline(text_lm$residuals)

plot(text_only$link_num, text_lm$residuals)
plot(text_only$font_size, text_lm$residuals)
plot(text_only$hour, text_lm$residuals)

# Check against a Poisson/Negative Binomial Link
text_glm <- glm(clicks ~ link_num + bolded + font_color + font_size + hour + covid_ind + image_assoc,
                family = quasipoisson(link = 'log'), data = text_only)

plot(text_only$clicks, text_glm$fitted.values)