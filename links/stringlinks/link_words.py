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
import pandas as pd
import datetime as dt

raw = '/Users/naomigiertych/Documents/Grad_School/NCS/STATCOM/github/activate-good-emails/newsletters/plain_text/'
ag = '/Users/naomigiertych/Documents/Grad_School/NCS/STATCOM/AG/'
ag_inter = '/Users/naomigiertych/Documents/Grad_School/NCS/STATCOM/AG/intermediate'


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
    link_strings = [string for string in f_list if re.search('[0-9]].', string) is not None]
    
    # Remove filler words (words not capitalized)
    link_strings_clean = [re.sub(r'\b[a-z]+\b', '', string) for string in link_strings]
    
    # Remove extra spaces
    link_strings_clean = [re.sub('\s+', ' ', string) for string in link_strings_clean]
    
    # Remove the social media accounts
    link_strings_clean = [string for string in link_strings_clean if 'Facebook' not in string]
    
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
    
    # Convert into a dataframe to merge in the list of links
    link_strings_df = pd.DataFrame( {'link_num': link_num, 'string': link_strings_nonums})
    
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


#####################################################
# Count the number of times a link was clicked
#####################################################

all_files_dens = pd.read_csv(ag_inter + '/all_months_201920_dens.csv')

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


#####################################################
# Merge the click counts to the string data
#####################################################

# Merge in the click data that we have for all links
string_clicks = all_string_html.merge(click_counts, on = ['date', 'link'])

######################
# Get all interesting unique links
######################
# Excludes things like shop, donate, blog, mailto, and anything that doesn't link
# to an acivategood.org page
unique_links = pd.read_excel(ag + 'UniqueLinks.xlsx', 'UniqueLinksClean')

# clean the date for merging
unique_links['date'] = [date.strftime("%m/%d/%y") for date in unique_links.Date]
unique_links = unique_links.drop(columns=['Date'])

# Merge to the string and click data
string_clicks_unique = string_clicks.merge(unique_links)
string_clicks_unique.to_csv(ag_inter + '/string_clicks_unique.csv', index = False)

######################
# Get the opportunity only links that we care about
######################
opp_only = pd.read_excel(ag + 'UniqueLinks.xlsx', 'Opportunity_Only')

# clean the date for merging
opp_only['date'] = [date.strftime("%m/%d/%y") for date in opp_only.Date]
opp_only = opp_only.drop(columns=['Date'])

# Merge to the string and click data
string_clicks_opp = string_clicks.merge(opp_only)
string_clicks_opp.to_csv(ag_inter + '/string_clicks_opp.csv', index = False)



