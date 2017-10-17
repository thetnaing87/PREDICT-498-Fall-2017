# -*- coding: utf-8 -*-
"""
Created on Thu Sep 28 11:56:02 2017

@author: kennedyo
"""

import pandas as pd
import os
import csv

directory = os.path.join('C:/MSPA/Capstone/Project/498-20170922T004637Z-001/498/Ticket/store 4818/')
store_4818=pd.read_csv(os.path.join(directory,'consolidated_4818.csv'),encoding='latin-1', sep=',')
store_4818.count()


"""
*******************************************************************************
#Product Analysis

*******************************************************************************
"""
# Need to exclude discount from the product description 
#
exclude_discount=store_4818[store_4818['ITEM_PRICE']>=0]
discount=store_4818[store_4818['ITEM_PRICE']<0]

exclude_discount.head(50)
# create unique identification for with business day and ticket number
exclude_discount['UNIQUE']=exclude_discount['BUSINESS_DATE'].astype(str)+exclude_discount['TICKET_NUM'].astype(str)


# split dataset for daypart
breakfast=exclude_discount[exclude_discount['DAY_PART']=='01-Breakfast']
lunch=exclude_discount[exclude_discount['DAY_PART']=='02-Lunch']
snack=exclude_discount[exclude_discount['DAY_PART']=='03-Snack']
dinner=exclude_discount[exclude_discount['DAY_PART']=='04-Dinner']
late_night=exclude_discount[exclude_discount['DAY_PART']=='05-Late Night Snack']


#split dayparts into season

breakfast_hot=breakfast[breakfast['SEASONAL']=="Hot Season"]
breakfast_cool=breakfast[breakfast['SEASONAL']=="Cool Season"]
breakfast_cold=breakfast[breakfast['SEASONAL']=="Cold Season"]

lunch_hot=lunch[lunch['SEASONAL']=="Hot Season"]
lunch_cool=lunch[lunch['SEASONAL']=="Cool Season"]
lunch_cold=lunch[lunch['SEASONAL']=="Cold Season"]

dinner_hot=dinner[dinner['SEASONAL']=="Hot Season"]
dinner_cool=dinner[dinner['SEASONAL']=="Cool Season"]
dinner_cold=dinner[dinner['SEASONAL']=="Cold Season"]

snack_hot=snack[snack['SEASONAL']=="Hot Season"]
snack_cool=snack[snack['SEASONAL']=="Cool Season"]
snack_cold=snack[snack['SEASONAL']=="Cold Season"]

night_hot=late_night[late_night['SEASONAL']=="Hot Season"]
night_cool=late_night[late_night['SEASONAL']=="Cool Season"]
night_cold=late_night[late_night['SEASONAL']=="Cold Season"]

##############################################################################

# Breakfast and Dinner don't need to be split into parts

#breakfast during summer

ticket_list = list(breakfast_hot['UNIQUE'].unique())
breakfast_hot=breakfast_hot[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

breakfast_hot_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = breakfast_hot[breakfast_hot['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    breakfast_hot_list_of_lists.append(ticket_product_list)
    
# examine the structure of the list of lists
print(type(breakfast_hot_list_of_lists)) 
print(breakfast_hot_list_of_lists)

csvfile = os.path.join(directory,'breakfast_hot_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(breakfast_hot_list_of_lists)

#breakfast during cool

ticket_list = list(breakfast_cool['UNIQUE'].unique())
breakfast_cool=breakfast_cool[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

breakfast_cool_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = breakfast_cool[breakfast_cool['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    breakfast_cool_list_of_lists.append(ticket_product_list)
    
# examine the structure of the list of lists
print(type(breakfast_cool_list_of_lists)) 
print(breakfast_cool_list_of_lists)

csvfile = os.path.join(directory,'breakfast_cool_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(breakfast_cool_list_of_lists)

    
#breakfast during cold

ticket_list = list(breakfast_cold['UNIQUE'].unique())
breakfast_cold=breakfast_cold[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

breakfast_cold_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = breakfast_cold[breakfast_cold['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    breakfast_cold_list_of_lists.append(ticket_product_list)
    
# examine the structure of the list of lists
print(type(breakfast_cold_list_of_lists)) 
print(breakfast_cold_list_of_lists)

csvfile = os.path.join(directory,'breakfast_cold_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(breakfast_cold_list_of_lists)    
    
    
###############################################################################

ticket_list = list(dinner_hot['UNIQUE'].unique())
dinner_hot=dinner_hot[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

dinner_hot_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = dinner_hot[dinner_hot['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    dinner_hot_list_of_lists.append(ticket_product_list)
    
# examine the structure of the list of lists
print(type(dinner_hot_list_of_lists)) 
print(dinner_hot_list_of_lists)

csvfile = os.path.join(directory,'dinner_hot_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(dinner_hot_list_of_lists)

#dinner during cool

ticket_list = list(dinner_cool['UNIQUE'].unique())
dinner_cool=dinner_cool[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

dinner_cool_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = dinner_cool[dinner_cool['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    dinner_cool_list_of_lists.append(ticket_product_list)
    
# examine the structure of the list of lists
print(type(dinner_cool_list_of_lists)) 
print(dinner_cool_list_of_lists)

csvfile = os.path.join(directory,'dinner_cool_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(dinner_cool_list_of_lists)

    
#dinner during cold

ticket_list = list(dinner_cold['UNIQUE'].unique())
dinner_cold=dinner_cold[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

dinner_cold_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = dinner_cold[dinner_cold['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    dinner_cold_list_of_lists.append(ticket_product_list)
    
# examine the structure of the list of lists
print(type(dinner_cold_list_of_lists)) 
print(dinner_cold_list_of_lists)

csvfile = os.path.join(directory,'dinner_cold_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(dinner_cold_list_of_lists)    

    
###############################################################################

# Late Night Split for the weekend

night_hot=late_night[late_night['SEASONAL']=="Hot Season"]
night_cool=late_night[late_night['SEASONAL']=="Cool Season"]
night_cold=late_night[late_night['SEASONAL']=="Cold Season"]


night_hot_weekend1=night_hot[night_hot['DAYOFWEEK']=='05-Friday']
night_hot_weekend2=night_hot[night_hot['DAYOFWEEK']=='06-Saturday']

night_hot_weekend=night_hot_weekend1.append(night_hot_weekend2)

ticket_list = list(night_hot_weekend['UNIQUE'].unique())
night_hot_weekend=night_hot_weekend[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

night_hot_weekend_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = night_hot_weekend[night_hot_weekend['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    night_hot_weekend_list_of_lists.append(ticket_product_list)
    
# examine the structure of the list of lists
print(type(night_hot_weekend_list_of_lists)) 
print(night_hot_weekend_list_of_lists)

csvfile = os.path.join(directory,'night_hot_weekend_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(night_hot_weekend_list_of_lists)    
                          
# get late night hot weekday dataset

