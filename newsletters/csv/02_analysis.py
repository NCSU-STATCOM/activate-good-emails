#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jan  6 13:58:01 2021

@author: naomigiertych
"""

#####################################################
# Paths and Libraries
#####################################################

import pandas as pd
import numpy as np

path = '/Users/naomigiertych/Documents/Grad_School/NCS/STATCOM/AG'
inter = path + '/intermediate'

#####################################################
# Bring in the cleaned file
#####################################################

all_files_dens = pd.read_csv(inter + '/all_months_201920_dens.csv')

#####################################################
# Get count data
#####################################################


# Convert dates into datetypes
all_files_week = all_files_dens.copy()
all_files_week = all_files_week.rename(columns = {'date': 'date_str', 'date_sent': 'date_sent_str'})
all_files_week['date'] = pd.to_datetime(all_files_week['date_str'], format='%Y-%m-%d %H:%M:%S')
all_files_week['date_sent'] = pd.to_datetime(all_files_week['date_sent_str'], format='%m/%d/%y %H:%M:%S')
all_files_week['diff_date'] = [(i - j).days for i,j in zip(all_files_week.date, all_files_week.date_sent)]

# Make indicators for whether the recipient interacted with the email 
# in some way within in a week
    # Week indicator
all_files_week['week_ind'] = (all_files_week.diff_date <= 7)*1 
    # Determine whether the email was opened within a week
all_files_week['week_open'] = all_files_week.week_ind*all_files_week.opens

# Keep only the columns we care about
keep = ['subscriberid','clicks', 'unsubscribes','bounces', 'neither',
        'date_sent', 'final_zip', 'week_open']
all_files_week_keep_col = all_files_week[keep]

# Change the nans to 0's for future summing
all_files_week_keep_col = all_files_week_keep_col.fillna(0)

# Aggregate the data based on what we care about
all_files_week_agg = all_files_week_keep_col.groupby(['subscriberid', 'final_zip', 'date_sent'],
                                 as_index = False).agg({'clicks': 'max',
                                           'unsubscribes': 'max',
                                           'bounces': 'max',
                                           'neither': 'max',
                                           'week_open': 'max'})
# Change the missing zip codes back to NA
all_files_week_agg.loc[all_files_week_agg.final_zip == 0, 'final_zip'] = np.nan

# Output to a csv
all_files_week_agg.to_csv(inter + '/all_files_week_agg.csv', index = False)
