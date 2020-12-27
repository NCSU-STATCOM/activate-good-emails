#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 20 16:01:01 2020

@author: naomigiertych

Purpose: Aggregate the newsletters from Activate Good
"""

#####################################################
# Paths and Libraries
#####################################################

import pandas as pd
import os
import datetime as dt

path = '/Users/naomigiertych/Documents/Grad_School/NCS/STATCOM/AG'
raw = path + '/raw'
inter = path + '/intermediate'

#####################################################
# Combine all of the datafiles into one
#####################################################

# Get a list of all of the files in the directory
files = os.listdir(raw)

all_files = pd.DataFrame()

for i in range(len(files)):
    
    # read in the individual CSV
    temp_file = pd.read_csv(raw + '/' + files[i])
    
    # convert date read to datetime object
    temp_file.date = pd.to_datetime(temp_file.date)
    

    # create date of when the newsletter was sent
    month = int(files[i][0:2])
    day = int(files[i][3:5])
    year = int(files[i][6:8])
    date = dt.datetime(year, month, day)
    temp_file['date_sent'] = date.strftime("%m/%d/%y")

    
    # append to the all of the other files
    all_files = all_files.append(temp_file)
    
# output the compiled raw data to a csv
all_files.to_csv(inter + '/all_months_201920.csv', index = False)

#####################################################
# Desensitize the data
#####################################################

# Get the zip codes from some of the addresses
all_files_clean = all_files.copy()

    # for those with the comma
all_files_clean['zip_start'] = all_files.address1.str.find(', NC 27')
zc = all_files_clean[all_files_clean.zip_start.notna() & (all_files_clean.zip_start > 0)].copy()
zc_min = zc[['subscriberid' , 'address1', 'zip_start']].drop_duplicates().copy()
zc_min.zip_start = zc.zip_start.astype(int) + 5
zc_min['zfa1'] = zc_min.apply(lambda zc_min: zc_min['address1'][zc_min['zip_start']:zc_min['zip_start']+5], axis=1)
zc_min = zc_min[['subscriberid', 'zfa1']].copy()
all_files_clean = all_files_clean.merge(zc_min, how = 'left', on = 'subscriberid')

    # for those without the comma
all_files_clean['zip_start'] = all_files.address1.str.find('  NC 27')
zc = all_files_clean[all_files_clean.zip_start.notna() & all_files_clean.zfa1.isna() 
                       & all_files_clean.address1.notna()
                       & (all_files_clean.address1 != all_files_clean.address1.iloc[4311])].copy()
zc_min = zc[['subscriberid' , 'address1', 'zip_start']].drop_duplicates().copy()
zc_min.zip_start = zc_min.address1.str.find('27').astype(int)
zc_min['zfa2'] = zc_min.apply(lambda zc_min: zc_min['address1'][zc_min['zip_start']:zc_min['zip_start']+5], axis=1)
    # replace mistakes
zc_min.loc[zc_min.subscriberid == 65885153, 'zfa2'] = 37857
zc_min.loc[zc_min.subscriberid == 69429388, 'zfa2'] = 27616
zc_min = zc_min[['subscriberid', 'zfa2']].copy()
all_files_clean = all_files_clean.merge(zc_min, how = 'left')

    # cleanup the zip code information 
    # note that the original zip code is the mailing address zip code
    # the new zip code information is the billing address zip code
    # if zfa1 and zfa2 are blank; billing and mailing addresses are assumed to be the same
all_files_clean['billing_zip'] = all_files_clean.zfa1
all_files_clean.loc[all_files_clean.zfa1.isna(), 'billing_zip'] = all_files_clean.zfa2
all_files_clean.loc[all_files_clean.billing_zip.isna() & all_files_clean.zip.notna(), 'billing_zip'] = all_files_clean.zip

# rename the zip to the mailing zip
all_files_clean = all_files_clean.rename(columns = {'zip': 'mailing_zip'})

# Drop all uncessary columns to de-sensitize the data
drop_list = ['email', 'fname', 'lname', 'fullname', 'recip', 'status',
             'prefix', 'suffix', 'business', 'address1', 'address2', 'city',
             'state', 'phone', 'fax', 'zip_start', 'zfa1', 'zfa2']

all_files_dens = all_files_clean.drop(columns = drop_list).copy()

# output the densitized version of the raw
all_files_dens.to_csv(inter + '/all_months_201920_dens.csv', index = False)











