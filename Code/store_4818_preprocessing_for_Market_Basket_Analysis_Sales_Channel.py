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
discount['Discount']=discount['ITEM_PRICE']*discount['ITEM_QUANTITY']

discount.count()

discount_by_sales=discount.groupby(['SEASONAL'
                           ,'SALES TYPE'
                           ,'BUSINESS_DATE'
                           ,'YEAR'
                           ,'MONTH'
                           ,'DAYOFWEEK'
                           ,'DAY_PART'
                           ],as_index=False).agg({
                                                  'TICKET_NUM':'count'
                                                  ,'Discount':'mean'
                                                   })

discount_by_sales.to_csv(os.path.join(directory,'discount.csv'))


# create unique identification for with business day and ticket number
exclude_discount['UNIQUE']=exclude_discount['BUSINESS_DATE'].astype(str)+exclude_discount['TICKET_NUM'].astype(str)


# split dataset for sales type
drive_through=exclude_discount[exclude_discount['SALES TYPE']=='Drive Through Window']
stall=exclude_discount[exclude_discount['SALES TYPE']=='Stall']
patio=exclude_discount[exclude_discount['SALES TYPE']=='Patio']
call_in=exclude_discount[exclude_discount['SALES TYPE']=='Call In']

#Sales through Drive Through

ticket_list = list(drive_through['UNIQUE'].unique())
drive_through=drive_through[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

drive_through_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = drive_through[drive_through['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    drive_through_list_of_lists.append(ticket_product_list)
    


csvfile = os.path.join(directory,'drive_through_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(drive_through_list_of_lists)


    
#Sales through Stall

ticket_list = list(stall['UNIQUE'].unique())
stall=stall[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

stall_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = stall[stall['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    stall_list_of_lists.append(ticket_product_list)
    


csvfile = os.path.join(directory,'stall_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(stall_list_of_lists)

# Sales Through Patio

ticket_list = list(patio['UNIQUE'].unique())
patio=patio[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

patio_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = patio[patio['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    patio_list_of_lists.append(ticket_product_list)
    


csvfile = os.path.join(directory,'patio_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(patio_list_of_lists)

# Sales through call In

ticket_list = list(call_in['UNIQUE'].unique())
call_in=call_in[['UNIQUE','ORIG_PRODUCT_DESCRIPTION']]

call_in_list_of_lists = []  # initialize list of lists as needed for associaiton rules
# work with one user at a time
for ticket in ticket_list:
    # gather subset data frame for this user
    this_ticket_data = call_in[call_in['UNIQUE'] == ticket]
    print('\n',this_ticket_data)
    # get list of areas for this user
    ticket_product_list = list(this_ticket_data['ORIG_PRODUCT_DESCRIPTION'])
    print(ticket_product_list)
    # add this user's list of sites to the list of lists
    call_in_list_of_lists.append(ticket_product_list)
    


csvfile = os.path.join(directory,'call_in_list_of_lists.csv')
with open(csvfile, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    writer.writerows(call_in_list_of_lists)

   