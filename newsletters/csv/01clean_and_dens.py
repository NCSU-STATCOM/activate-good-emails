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
import numpy as np

path = '/Users/naomigiertych/Documents/Grad_School/NCS/STATCOM/AG'
raw = path + '/raw'
inter = path + '/intermediate'

#####################################################
# Functions
#####################################################

def zip_fun(x):
    try:
        x = int(x)
    except:
        x = np.nan
    return(x)

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
    hour = int(files[i][9:11])
    mnt = int(files[i][12:14])
    sec = int(files[i][15:17])
    
    # datetime(year, month, day, hour, minute, second, microsecond)
    date = dt.datetime(year, month, day, hour, mnt, sec)
    temp_file['date_sent'] = date.strftime("%m/%d/%y %H:%M:%S")
    
    # append to the all of the other files
    all_files = all_files.append(temp_file)
    
# output the compiled raw data to a csv
all_files.to_csv(inter + '/all_months_201920.csv', index = False)

#####################################################
# Clean up the zipcode information
#####################################################

# Get the zip codes from some of the addresses
all_files_clean = all_files.copy()


    # for those with the comma
all_files_clean['zip_start'] = all_files.address1.str.find(', NC 27')
zc = all_files_clean[all_files_clean.zip_start.notna() & (all_files_clean.zip_start > 0)].copy()
zc_min = zc[['subscriberid' , 'address1', 'zip_start']].drop_duplicates().copy()
zc_min.zip_start = zc_min.zip_start.astype(int) + 5
zc_min['zfa1'] = zc_min.apply(lambda zc_min: zc_min['address1'][zc_min['zip_start']:zc_min['zip_start']+5], axis=1)
    # Convert to integer to check that all are numbers
zc_min.zfa1 = zc_min.zfa1.astype(int)
    # Check if there are any anomalies
zc_min.zfa1.min()
    # Save only the necessary information
zc_min = zc_min[['subscriberid', 'zfa1']].copy()
    # Merge into the entire data  
merged1 = all_files_clean.merge(zc_min, how = 'left', on = 'subscriberid')


    # for those without the comma
zc = merged1[merged1.zfa1.isna() & merged1.address1.notna()].copy()
zc_min = zc[['subscriberid' , 'address1', 'zip_start']].drop_duplicates().copy()
zc_min['zfa2'] = zc_min.address1.str[-5:]
    # Fix a typo in the data
zc_min.loc[zc_min.zfa2 == '12616', 'zfa2'] = '27616'
    # Convert the zip codes to numbers
zc_min['zfa2'] = zc_min['zfa2'].apply(zip_fun)   
    # Remove the PO boxes or apartments
zc_min.loc[zc_min.zfa2 == 2874, 'zfa2'] = np.nan
zc_min.loc[zc_min.zfa2 == 2633, 'zfa2'] = np.nan
    # Save only the necessary information
zc_min_naomit = zc_min[['subscriberid', 'zfa2']].dropna().copy()
    # Merge into the entire data
merged2 = merged1.merge(zc_min_naomit, how = 'left', on = 'subscriberid')


    # Check for any additional missing zip codes
view = merged2[merged2.address1.notna() & merged2.zip.isna() 
               & merged2.zfa1.isna() & merged2.zfa2.isna()]['address1'].drop_duplicates().copy()


    # cleanup the zip code information 
    # note that the original zip code could be from a business address
    # the new zip code information is the billing address zip code
    # if zfa1 and zfa2 are blank; billing and mailing addresses are assumed to be the same
final_clean = merged2.copy()
final_clean['final_zip'] = final_clean.zfa1
final_clean.loc[final_clean.zfa1.isna(), 'final_zip'] = final_clean.zfa2
final_clean.loc[final_clean.final_zip.isna() & final_clean.zip.notna(), 'final_zip'] = final_clean.zip

#####################################################
# Desensitize the data
#####################################################

# Drop all uncessary columns to de-sensitize the data
drop_list = ['email', 'fname', 'lname', 'fullname', 'recip', 'status',
             'prefix', 'suffix', 'business', 'address1', 'address2', 'city',
             'state', 'zip', 'phone', 'fax', 'zip_start', 'zfa1', 'zfa2']

final_clean_dens = final_clean.drop(columns = drop_list).copy()

# Drop duplicates
final_clean_dens = final_clean_dens.drop_duplicates()


# output the densitized version of the raw
final_clean_dens.to_csv(inter + '/all_months_201920_dens.csv', index = False)