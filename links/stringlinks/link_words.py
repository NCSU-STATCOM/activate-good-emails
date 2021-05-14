#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar  5 12:32:17 2021

@author: naomigiertych

Purpose: Things for click rate model
"""

#####################################################
# Paths and Libraries
#####################################################

import os
import re
import string
import numpy as np
import pandas as pd
import datetime as dt

from nltk.tokenize import RegexpTokenizer
# Create a reference variable for Class RegexpTokenizer
tk = RegexpTokenizer('\s+', gaps = True)

from wordcloud import WordCloud
import matplotlib.pyplot as plt

raw = '/Users/naomigiertych/Documents/Grad_School/NCS/STATCOM/github/activate-good-emails/newsletters/plain_text/'
ag = '/Users/naomigiertych/Documents/Grad_School/NCS/STATCOM/AG/'
ag_inter = '/Users/naomigiertych/Documents/Grad_School/NCS/STATCOM/AG/intermediate/'
ag_output = '/Users/naomigiertych/Documents/Grad_School/NCS/STATCOM/AG/output/'

#####################################################
# Functions
#####################################################

def newsletter_counts(df):
    
    total = pd.DataFrame()
    
    for link in df.clean.unique():
    
        dates = df[df.clean == link].date
        newsletter_clicks = df.merge(dates).clicks.sum()
        
        temp = pd.DataFrame({'clean': [link],
                             'news_total': [newsletter_clicks]})
        
        total = total.append(temp)
        
    total = total.reset_index(drop = True)
    
    return(total)

def word_counts(df, token_list):
    
    word_counts = pd.DataFrame()  
  
    # For each word, sum the clicks for everytime it showed up in a string
    # Also get the total number of clicks of the associated links across all newsletters 
    for i in range(len(token_list)):
    
       # Create a true/false list based on whether the string contains the word
        tf = [re.search(token_list[i], string) is not None for string in df.string]
        temp = df[tf]
            # count the clicks for every link
        word_count = temp.clicks.sum()
            # get the total across (unique) newsletters
        word_total = temp.drop_duplicates(subset = ['clean']).news_total.sum()
        
        word = pd.DataFrame({'word': [token_list[i]], 'wcount': [word_count],
                             'total': word_total})
        
        word_counts = word_counts.append(word)
        
    word_counts = word_counts.reset_index(drop = True)
        
    return(word_counts)

def word_cloud_gen(links_to_keep, name, click_df, strings_df):
    
    # Get the links interested in
    unique_links = pd.read_excel(ag + 'UniqueLinks.xlsx', links_to_keep)
    
    # clean the date for merging
    unique_links['date'] = [date.strftime("%m/%d/%y") for date in unique_links.Date]
    unique_links = unique_links.drop(columns=['Date'])
    
    # Merge to the click data with the cleaned links data
    click_df_unique = click_df.merge(unique_links, on = ['date', 'link'])
    
    # Sum the counts by the unique links
    click_df_un_sum = click_df_unique.groupby(['date', 'clean'],
                                                      as_index = False).clicks.sum()
    
    # Identify how popular the newsletters associated with a particular link were
        # note: this is based on the cleaned link
    link_news_clicks = newsletter_counts(click_df_un_sum)
    
        # merge into the click counts
    click_df_un_sum = click_df_un_sum.merge(link_news_clicks)
    
    # Merge this new click count into the unique links and drop the old count
    click_df_unique = click_df_unique.drop(columns = ['clicks'])
    click_df_unique = click_df_unique.merge(click_df_un_sum, on = ['date', 'clean'])
    
    
    #####################################################
    # Create a dataframe with the following structure
    # word  number of clicks across links  number of clicks across newsletters
    #####################################################
    
    # Merge in the click data that we have for the unique links
    string_clicks = strings_df.merge(click_df_unique, on = ['date', 'link'])
    
    # Get a list of all the unique words in the dataset
        # creates a large string of all the words
    text = " ".join(string for string in string_clicks.string)
        # creates a list of all the words
    token = tk.tokenize(text)
        # keeps only the unique ones
    token = list(set(token))
    
    word_counts_unique = word_counts(string_clicks, token)
    
    # Save the dataset
    word_counts_unique.to_csv(ag_inter + '/word_counts' + links_to_keep + '.csv', index = False)
    
    # Create the word cloud
    word_counts_unique['percentage'] = (word_counts_unique.wcount/word_counts_unique.total)*100
    temp_dict = word_counts_unique.set_index('word')['percentage'].to_dict()
    
    wc = WordCloud(background_color="white", max_words=1000)
    wc.generate_from_frequencies(temp_dict)
    plt.imshow(wc, interpolation="bilinear")
    plt.axis("off")
    plt.savefig(ag_output + name + '.png',
                        bbox_inches = 'tight', dpi = 600)
    plt.close()
    
    return(word_counts_unique)

#####################################################
# Get the words associated with links
#####################################################

# Get a list of all of the files in the directory
files = os.listdir(raw)

all_string_html = pd.DataFrame()

for i in range(len(files)):

    f = open(raw + files[i])
    f_list = f.read().split('\n')
    
    # Get all of the strings with an associated link
    # This will include the entire line as seen in the email; i.e. to a '\n'
    link_strings = [string for string in f_list if (re.search('[0-9]].', string) is not None)
                    and ('Facebook' not in string)]
    
    # Get the proportion of the document each line is
    link_prop = [f_list.index(string)/len(f_list) for string in link_strings]
        
    # Remove filler words (words not capitalized)
    link_strings_clean = [re.sub(r'\b[a-z]+\b', '', string) for string in link_strings]
    
    # Remove extra spaces
    link_strings_clean = [re.sub('\s+', ' ', string) for string in link_strings_clean]
    
    # Get the link numbers
    link_num = [re.search('[[0-9][0-9]]', string).group() for string in link_strings_clean]
        # remove brackets
    link_num = [re.sub('\[', '', string) for string in link_num]
    link_num = [re.sub('\]', '', string) for string in link_num]
    
    # Remove the numbers from the strings
    link_strings_nonums = [re.sub('[[0-9][0-9]]', '', string) for string in link_strings_clean]
    
    # Remove any punctuation
    translator = str.maketrans('', '', string.punctuation)
    link_strings_nonums = [string.translate(translator) for string in link_strings_nonums]
    
    # Remove remaining extra spaces
    link_strings_nonums = [re.sub(' +', ' ', string.strip()) for string in link_strings_nonums]
    
    # Convert into a dataframe to merge in the list of links
    link_strings_df = pd.DataFrame( {'link_num': link_num, 
                                     'string': link_strings_nonums,
                                     'doc_prop': link_prop})
    
    # Get a list of the actual links in the newsletter
    idx = f_list.index('References') + 2
    link_html = [string for string in f_list[idx:] if re.search('[1-9]\.', string) is not None]
    link_num = [string[:re.search('\.', string).span()[0]] for string in link_html]
    
    # Clean the htmls to remove the number
    link_html = [string[re.search('\.', string).span()[0]+2:] for string in link_html]
    
    # Put the numbers and the htmls in a dataframe
    link_html_df = pd.DataFrame( {'link_num': link_num, 'link': link_html})
    
    # Merge the dataframe with the strings to the dataframe with the links
        # Keep only the ones with associated strings
    string_html = link_strings_df.merge(link_html_df)
    
    # create date of when the newsletter was sent
    month = int(files[i][10:12])
    day = int(files[i][13:15])
    year = int(files[i][16:20])
    
    date = dt.datetime(year, month, day)
    string_html['date'] = date.strftime('%m/%d/%y')
    
    # append to the all of the other files
    all_string_html = all_string_html.append(string_html, ignore_index = True)

# drop any blanks
all_string_html.drop(all_string_html[all_string_html.string == ''].index, inplace=True)

# save this dataset for other analyses
all_string_html.to_csv(ag_inter + 'all_string_html.csv', index = False)

#####################################################
# In Excel we categorized the strings
#####################################################

all_string_html_cat = pd.read_csv(ag_inter + 'all_string_html_cat.csv')
all_string_html_cat = all_string_html_cat.drop(columns = 'string')
all_string_html_cat = all_string_html_cat.rename(columns = {'cat': 'string'})

#####################################################
# Count the number of times a link was clicked
#####################################################

all_files_dens = pd.read_csv(ag_inter + 'all_months_201920_dens.csv')

# Keep only the columns we care about
raw_click_data = all_files_dens[['subscriberid', 'clicks', 'link', 'date_sent']].copy()

# Keep observations when someone clicked on a link
clicks_only = raw_click_data[raw_click_data.clicks == 1].copy()

# Drop duplicate clicks by subscriberid
clicks_nodups = clicks_only.drop_duplicates().copy()

# Count the number of clicks for a link per newsletter
click_counts = clicks_nodups.groupby(['date_sent', 'link'], as_index = False).clicks.count()

# Remove the time from the date sent variable
click_counts['date'] = [string[0:8] for string in click_counts.date_sent]

# Output this dataset
click_counts.to_csv(ag_inter + 'click_counts.csv')

#####################################################
# Generate word clouds based on the relative frequency
# of clicks for a word
#####################################################

click_counts_unique = word_cloud_gen('UniqueLinksClean', 'UniqueLinksClean', click_counts, all_string_html)
click_counts_opp = word_cloud_gen('Opportunity_Only', 'Opportunity_Only', click_counts, all_string_html)
click_counts_cat = word_cloud_gen('UniqueLinksClean', 'UniqueLinksClean_cat', click_counts, all_string_html_cat)
