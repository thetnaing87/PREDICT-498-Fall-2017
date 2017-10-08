# -*- coding: utf-8 -*-
"""
Created on Thu Sep 28 11:56:02 2017

@author: kennedyo
"""

import pandas as pd
import os
import datetime as dt

directory = os.path.join('C:/MSPA/Capstone/Project/498-20170922T004637Z-001/498/Ticket/store 3797/')
""" 
def get_sorted_files(directory):
    filenamelist = []
    for root, dirs, files in os.walk(directory):
        for name in files:
            fullname = os.path.join(name)
            filenamelist.append(fullname)
            
    return sorted(filenamelist)

# list of file names    
excel_files=get_sorted_files(directory)

# create store dataset
store_3797=pd.read_csv(os.path.join(directory,excel_files[0]),encoding='latin-1', sep=',')

#append all data from excel files into new dataset
nFiles=len(excel_files)
for i in range(nFiles):
    filename=excel_files[i]
    store_data=pd.read_csv(os.path.join(directory,filename),encoding='latin-1', sep=',')
    store_3797=store_3797.append(store_data)

#remove duplicate records   
store_3797=store_3797.drop_duplicates()

    
store_3797.head()
store_3797.dtypes
print(store_3797.columns)     

# convert object to date
store_3797['BUSINESS_DATE']=pd.to_datetime(store_3797['BUSINESS_DATE'])
store_3797['TICKET_CLOSE_TIME']=pd.to_datetime(store_3797['TICKET_CLOSE_TIME'])
store_3797['TICKET_OPEN_TIME']=pd.to_datetime(store_3797['TICKET_OPEN_TIME'])


# create derived variables for further analysis
store_3797['YEAR']=store_3797['BUSINESS_DATE'].dt.year
store_3797['MONTH']=store_3797['BUSINESS_DATE'].dt.month
store_3797['HOUR']=store_3797['TICKET_OPEN_TIME'].dt.hour
store_3797['WEEK']=store_3797['BUSINESS_DATE'].dt.weekday_name
        
# create hourly range        
        
def hourly(df):
    if df['HOUR']==0:
        return '24-12am to 1am'
    elif df['HOUR']==1:
        return '01-1am to 2am'
    elif df['HOUR']==2:
        return '02-2am to 3am'
    elif df['HOUR']==3:
        return '03-3am to 4am'
    elif df['HOUR']==4:
        return '04-4am to 5am'
    elif df['HOUR']==5:
        return '05-5am to 6am'
    elif df['HOUR']==6:
        return '06-6am to 7am'
    elif df['HOUR']==7:
        return '07-7am to 8am'
    elif df['HOUR']==8:
        return '08-8am to 9am'
    elif df['HOUR']==9:
        return '09-9am to 10am'
    elif df['HOUR']==10:
        return '10-10am to 11am'
    elif df['HOUR']==11:
        return '11-11am to 12pm'
    elif df['HOUR']==12:
        return '12-12pm to 1pm'
    elif df['HOUR']==13:
        return '13-1pm to 2pm'
    elif df['HOUR']==14:
        return '14-2pm to 3pm'
    elif df['HOUR']==15:
        return '15-3pm to 4pm'
    elif df['HOUR']==16:
        return '16-4pm to 5pm'
    elif df['HOUR']==17:
        return '17-5pm to 6pm'
    elif df['HOUR']==18:
        return '18-6pm to 7pm'
    elif df['HOUR']==19:
        return '19-7pm to 8pm'
    elif df['HOUR']==20:
        return '20-8pm to 9pm'
    elif df['HOUR']==21:
        return '21-9pm to 10pm'
    elif df['HOUR']==22:
        return '22-10pm to 11pm'
    else:
        return '23-11pm to 12am'


store_3797['HOURLY']=store_3797.apply(hourly,axis=1)

# Create DayPart

def daypart(df):
    if (
        df['HOURLY']=='05-5am to 6am'
        or   
        df['HOURLY']=='06-6am to 7am'
        or
        df['HOURLY']=='07-7am to 8am'
        or
        df['HOURLY']=='08-8am to 9am'
        or
        df['HOURLY']=='09-9am to 10am'
        or
        df['HOURLY']=='10-10am to 11am'):
        return '01-Breakfast'
    elif ( 
        df['HOURLY']=='11-11am to 12pm'
        or
        df['HOURLY']=='12-12pm to 1pm'
        or
        df['HOURLY']=='13-1pm to 2pm'
        or
        df['HOURLY']=='14-2pm to 3pm'):
        return '02-Lunch'
    elif (    
        df['HOURLY']=='15-3pm to 4pm'
        or 
        df['HOURLY']=='16-4pm to 5pm'):
        return '03-Snack'
        
    elif ( 
        df['HOURLY']=='17-5pm to 6pm'
        or
        df['HOURLY']=='18-6pm to 7pm'
        or
        df['HOURLY']=='19-7pm to 8pm'
        or
        df['HOURLY']=='20-8pm to 9pm'):
        return '04-Dinner'
    else:  
        return '05-Late Night Snack'

store_3797['DAY_PART']=store_3797.apply(daypart,axis=1)


def dayofweek(df):
    if df['WEEK']=='Monday':
        return '01-Monday'
    elif df['WEEK']=='Tuesday':
        return '02-Tuesday'
    elif df['WEEK']=='Wednesday':
        return '03-Wednesday'
    elif df['WEEK']=='Thursday':
        return '04-Thursday'
    elif df['WEEK']=='Friday':
        return '05-Friday'
    elif df['WEEK']=='Saturday':
        return '06-Saturday'
    else:
        return '07-Sunday'

store_3797['DAYOFWEEK']=store_3797.apply(dayofweek,axis=1)



def seasonal(df):
    if (
        df['MONTH']==12
          or 
        df['MONTH']==11
          or
        df['MONTH']==1
          or
        df['MONTH']==2):
       return 'Cold Season'
    elif (
        df['MONTH']==3
          or 
        df['MONTH']==4
          or
        df['MONTH']==5
          or
        df['MONTH']==9
          or 
        df['MONTH']==10):
       return 'Cool Season'
    else:
       return 'Hot Season'

store_3797['SEASONAL']=store_3797.apply(seasonal,axis=1)

# drop WEEK column
store_3797=store_3797.drop('WEEK', axis=1)
store_3797.head()
store_3797.to_csv(os.path.join(directory,'consolidated_3797.csv'), index=False)
"""
store_3797=pd.read_csv(os.path.join(directory,'consolidated_3797.csv'),encoding='latin-1', sep=',')
store_3797.dtypes
# separate transactions to products and condiments
condiment_used=store_3797[store_3797['ITEM_PRICE']==0]
actual_sales=store_3797[store_3797['ITEM_PRICE']!=0]
actual_sales['SALES_AMOUNT']=actual_sales['ITEM_PRICE']*actual_sales['ITEM_QUANTITY']



#create differet dataset for time series analysis to project foot traffic

seasonal_volume=actual_sales.groupby(['SEASONAL'
                                ,'SALES TYPE'
                                ,'BUSINESS_DATE'
                                ,'STORE_ID'
                                ,'YEAR'
                                ,'MONTH'
                                ,'DAYOFWEEK'
                                ,'DAY_PART'
                                ,'TICKET_NUM'
                                ,'HOP_OUT_TIME'
                                ],as_index=False).agg({'SALES_AMOUNT':'sum' 
                                                                })

seasonal_volume1=seasonal_volume.groupby(['SEASONAL'
                                ,'SALES TYPE'
                                ,'BUSINESS_DATE'
                                ,'STORE_ID'
                                ,'YEAR'
                                ,'MONTH'
                                ,'DAYOFWEEK'
                                ,'DAY_PART'
                                ],as_index=False).agg({
                                                        'TICKET_NUM':'count'
                                                        ,'HOP_OUT_TIME':'mean'
                                                        ,'SALES_AMOUNT':'sum'
                                                                })



seasonal_volume1['AVE_SALE_PER_ORDER']=seasonal_volume1['SALES_AMOUNT']/seasonal_volume1['TICKET_NUM']
seasonal_volume1['AVE_SALE_PER_SERVICE_MINUTE']=seasonal_volume1['AVE_SALE_PER_ORDER']/seasonal_volume1['HOP_OUT_TIME']

seasonal_volume1.to_csv(os.path.join(directory,'volume_trend_analysis_3797.csv'), index=False)



"""
*******************************************************************************
#Product Analysis

*******************************************************************************
"""
