library("dplyr")

link_characteristics = read.csv("link_characteristics/link_characteristics.csv")
link_click_counts = read.csv("stringlinks/intermediate/click_counts.csv")

# drop index
link_click_counts = link_click_counts[, !names(link_click_counts) %in% "X" ]

test = "(244, 123, 99)"
test = strsplit(test, ",")
gsub("[^0-9.-]", "", test)


full_df = merge(x = link_characteristics,
                y = link_click_counts,
                by.x = c("date", "address"),
                by.y = c("date", "link"),
                all = TRUE)

write.csv(full_df, file = "link_counts_characteristics.csv")
