# activate-good-emails
Analyze weekly newsletters for factors that affect the rate of opens/clicks.

We focus on 54 weekly newsletters sent during the years 2019 and 2020.

# Data

## Newsletters

In the newsletters folder, there are the plain-text and html files for each of the 54 weekly newsletters from 2019-2020. 

There is subject_summary_stats.csv, which contains the aggregate opened, clicked, bounced and unsubscribed percentages for each of the 54 newsletters.
This data is used in the initial report. 

In csv/intermediate/, there is all_months_201920_dens.csv, which contains desensitized granular data on each subscriber, i.e. whether the subscriber opened, clicked, bounced, or unsubscribed, the links clicked on, and the zip code.

There is also plain_text_ft_engineering.R and html_ft_engineering.R, which will extract useful features from the plain-text and html, respectively.

## Donor Newsletters

In the donor_newsletters folder, there are the plain-text and html files for five donor newsletters, which started on August 2020 and are sent out monthly. Analyzing these is of secondary interest.



# Subprojects 

## Initial Report

The initial_report folder contains the data wrangling and analysis of subject_summary_stats.csv (see Newsletters above). This initial report was sent to Activate Good on January 11, 2021. 

## Open/Click Models

These models are an extension of the analyses in the initial report. The response variable of interest is a binary variable of whether an individual subscriber opened a newsletter (clicked on a newsletter). 

The open_click_models folder contains the data wrangling of all_months_201920_dens.csv for the models and gamm_open_click.R, which will fit generalized additive mixed models to the data. Hopefully the models will make the trends featured in the initial report more clear. 

## Link Model

The response variable is the click percentage for an individual link. Hopefully the model will indicate which characteristics (e.g. link mentions puppies) would lead to more clicks. 

The links folder also includes a table of the most frequently clicked opportunity links in link_presentation.pdf.




