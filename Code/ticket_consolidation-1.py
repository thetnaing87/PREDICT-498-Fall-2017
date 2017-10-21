# -*- coding: utf-8 -*-
"""
Created on Thu Sep 28 11:56:02 2017

@author: kennedyo
"""

import pandas as pd
import os
import datetime as dt

directory = os.path.join('C:/MSPA/Capstone/Project/498-20170922T004637Z-001/498/Ticket/')
my_file='Ticket Detail Test 2.csv' # read csv file into python. 

ticket_1=pd.read_csv(os.path.join(directory,my_file),encoding='latin-1', sep=',')

# drop extra non-sense
        
ticket_1.head()
ticket_1.dtypes
print(ticket_1.columns)     

# convert object to date
ticket_1['BUSINESS_DATE']=pd.to_datetime(ticket_1['BUSINESS_DATE'])
ticket_1['TICKET_CLOSE_TIME']=pd.to_datetime(ticket_1['TICKET_CLOSE_TIME'])
ticket_1['TICKET_OPEN_TIME']=pd.to_datetime(ticket_1['TICKET_OPEN_TIME'])
#ticket_1['SERVICE_TIME']=ticket_1['TICKET_CLOSE_TIME']-ticket_1['TICKET_OPEN_TIME']
#ticket_1['SERVICE_TIME']=ticket_1['SERVICE_TIME']/dt.timedelta(minutes=1)


# create derived variables for further analysis
ticket_1['YEAR']=ticket_1['BUSINESS_DATE'].dt.year
ticket_1['MONTH']=ticket_1['BUSINESS_DATE'].dt.month
ticket_1['DAYOFWEEK']=ticket_1['BUSINESS_DATE'].dt.weekday_name
ticket_1['HOUR']=ticket_1['TICKET_OPEN_TIME'].dt.hour

        
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


ticket_1['HOURLY']=ticket_1.apply(hourly,axis=1)

# Create DayPart

def daypart(df):
    if (
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

ticket_1['DAY_PART']=ticket_1.apply(daypart,axis=1)

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

ticket_1['SEASONAL']=ticket_1.apply(seasonal,axis=1)
      
  
# separate transactions to products and condiments
condiment_used=ticket_1[ticket_1['ITEM_PRICE']==0]
actual_sales=ticket_1[ticket_1['ITEM_PRICE']!=0]

seasonal_volume=actual_sales.groupby(['SEASONAL'
                                ,'BUSINESS_DATE'
                                ,'STORE_ID'
                                ,'YEAR'
                                ,'MONTH'
                                ,'DAYOFWEEK'
                                ,'DAY_PART'
                                ,'HOURLY'],as_index=False).agg({'TICKET_NUM':'count'
                                                                ,'TOTAL_SALES_AMOUNT':'sum'
                                                                ,'HOP_OUT_TIME':'mean'
                                                                })


seasonal_volume.to_csv(os.path.join(directory,'volume_trend_analysis.csv'), index=False)

"""
*******************************************************************************
#Product Analysis

*******************************************************************************
"""
