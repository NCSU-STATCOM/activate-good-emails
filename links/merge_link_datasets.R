library("dplyr")

link_characteristics = read.csv("link_characteristics/link_characteristics.csv")
link_characteristics$link_char_flag = 1
link_characteristics$address <- trimws(link_characteristics$address)

link_click_counts = read.csv("stringlinks/intermediate/click_counts.csv")
link_click_counts$link_click_flag = 1
link_click_counts$link <- trimws(link_click_counts$link)

html_df = read.csv("stringlinks/intermediate/all_string_html.csv")
html_df$html_flag = 1
html_df$link <- trimws(html_df$link)

# drop index
link_click_counts = link_click_counts[, !names(link_click_counts) %in% "X" ]


full_df = merge(x = link_characteristics,
                y = link_click_counts,
                by.x = c("date", "address"),
                by.y = c("date", "link"), 
                all.x = TRUE,
                all.y = FALSE)

full_df = merge(x = full_df,
                y = html_df,
                by.x = c("date", 'address', 'link_num'),
                by.y = c("date", 'link', 'link_num'),
                all.x = TRUE,
                all.y = FALSE)

full_df$font_color = gsub("\\s+", '', full_df$font_color)


unique(full_df$font_color)


font_colors = c(NA, "(89,89,89)", "(255,255,255)", "(0,136,168)", "(0,109,131)",
                "(85,142,190)", "(127,127,127)", 
                "(17,85,204)", "(242,136,0)", "(0,0,0)", "(57,57,57)", 
                "(56,88,152)", "(67,67,67)", "(29,33,41)", "(242,124,0)", 
                "(206,86,0)", "(34,34,34)", "(238,135,2)", "(255,150,0)", 
                "(102,94,208)", "(231,93,38)", "(13,0,0)", "(233,93,20)", 
                "(148,45,27)", "(179,183,27)", "(152,154,38)", "(85,85,85)",
                "(97,97,97)", "(228,134,9)", "(10,10,10)", "(248,118,0)", 
                "(146,46,33)", "(55,55,55)", "(255,151,9)", "(228,104,16)")
# https://www.color-blindness.com/color-name-hue/
color_names = c(NA, "Mortar", "White", "Eastern Blue", "Teal",
                "Danube", "Grey",
                "Denim", "Tangerine", "Black", "Eclipse",
                "Mariner", "Charcoal", "Black Pearl", "Tangerine",
                "Tenne", "Nero", "Tangerine", "Orange Peel", 
                "Slate Blue", "Cinnabar", "Tyrian Purple", "Chocolate",
                "Falu Red", "Bahia", "Citron", "Mortar",
                "Dim Gray", "Gamboge", "Black", "Tangerine",
                "Mandarian Orange", "Eclipse", "Orange Peel", "Chocolate")
color_names_rgb = paste0(color_names, " ", font_colors)

my_hash_table = new.env()

for( i in seq(length(font_colors))){
  my_hash_table[[font_colors[i] ]] = color_names[i]
}
mget("(0,0,0)", envir=my_hash_table)

full_df$color_name = unlist(mget(unlist(full_df$font_color), envir=my_hash_table))
full_df$color_name_rgb = paste0(full_df$color_name, " ", full_df$font_color)

write.csv(full_df, file = "full_link_dataset.csv", row.names = FALSE)