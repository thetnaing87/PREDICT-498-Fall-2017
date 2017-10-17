require(moments)
require(stats)
require(ggplot2)
library(MASS)
library(car)
library(forecast)
library(glmnet)
data.dir   <- 'C:/MSPA/Capstone/Project/498-20170922T004637Z-001/498/'
train.file <- paste0(data.dir, 'sonic_db_sales.csv')
sonic_sales <- read.csv(train.file,stringsAsFactors=F)
str(sonic_sales)
summary(sonic_sales)
drop_var<-c(
            "Prior_MTD_Sales"
            ,"Percentage_Changes_of_Sales"
            ,"Labor_Cost_Variance"
            ,"Food_Cost_Variance"
            ,"Variance_Allowed"
            )
sonic_db<-sonic_sales[,!(names(sonic_sales)%in%drop_var)]   

# validate missing values
sapply(sonic_db, function(x) sum(is.na(x)))

#impute missing values
library(mice)

imputed<-mice(sonic_db,m=5,meth='norm',seed=500)
sonic_df<-complete(imputed,1)
str(sonic_df)
sapply(sonic_df, function(x) sum(is.na(x)))

# Change the date into date format and create month and year variable

sonic_df$Date<-as.Date(sonic_df$Date, format="%m/%d/%Y")
sonic_df$Year<-as.numeric(format(sonic_df$Date, "%Y"))
sonic_df$Month<-as.numeric(format(sonic_df$Date, "%m"))

#*********************************************************************************
# Univariate statistics

summary(sonic_df)
sd(sonic_df$Current_MTD_Sales)

# plot dataset
#seven_hill<-sonic_df[which(sonic_df[,3]=='Seven Hills'),]
#stapleton<-sonic_df[which(sonic_df$Stores=='Stapleton'),]
#smoky<-sonic_df[which(sonic_df$Stores=='Smoky'),]
#sable<-sonic_df[which(sonic_df$Stores=='Sable'),]
abilene<-sonic_df[which(sonic_df$Stores=='Abilene'),]# my stores
#cherry<-sonic_df[which(sonic_df$Stores=='Cherry'),]
tamarac<-sonic_df[which(sonic_df$Stores=='Tamarac'),]# my stores
#reunion<-sonic_df[which(sonic_df$Stores=='Reunion'),]
#brighton<-sonic_df[which(sonic_df$Stores=='Brighton'),]
broomfied<-sonic_df[which(sonic_df$Stores=='Broomfied'),]#my store
#colfax<-sonic_df[which(sonic_df$Stores=='Colfax'),]


dim(abilene)
str(abilene)

# validate missing values

hist(abilene$Current_MTD_Sales,
     breaks=6,
     xlab="Monthly Sales",
     main="Histogram of Monthly Sales for Abilene",
     border ="blue")

hist(abilene$Labor_Cost_Actuals,
     breaks=6,
     xlab="Actual Labor Cost",
     main="Histogram of Actual Labor Cost for Abilene",
     border ="blue")

hist(abilene$Food_Cost_Actual,
     breaks=6,
     xlab="Actual Food Cost",
     main="Histogram of Actual Food Cost for Abilene",
     border ="blue")

hist(abilene$Mystery_Shopper_Score1,
     breaks=6,
     xlab="Mystery Shopper Score 1",
     main="Histogram of Mystery Shopper Score 1 for Abilene",
     border ="blue")

hist(abilene$Mystery_Shopper_Score2,
     breaks=6,
     xlab="Mystery Shopper Score 2",
     main="Histogram of Mystery Shopper Score 2 for Abilene",
     border ="blue")

hist(abilene$FanTrack_Answers,
     breaks=6,
     xlab="Fantrack Response",
     main="Histogram of Fantrack Response for Abilene",
     border ="blue")

hist(abilene$Percentage_of_Response,
     breaks=6,
     xlab="Percentage of Response",
     main="Histogram of percentage Response for Abilene",
     border ="blue")

#pair abilene variables
par(mfrow=c(1,1))
pairs(Current_MTD_Sales~
        Year
      +Month
      +Labor_Cost_Actuals
      +Food_Cost_Actual
      +Mystery_Shopper_Score1
      +Mystery_Shopper_Score2
      +FanTrack_Answers
      +Percentage_of_Response
      , data=abilene, col=4)


# split dataset

training_abilene_df<-abilene[1:36,]
test_abilene_df<-abilene[37:44,]

# convert dataset into time-series 
is.ts(abilene)
abilene_ts <- ts(abilene,start=c(2014,1),end=c(2017,8),frequency=12)
is.ts(abilene_ts)
#**********************************************************************
par(mfrow=c(1,1))
plot(abilene$Current_MTD_Sales~abilene$Date,
     main='Abilene Store - Monthly Sales',col=4, lty=4,type='l',
     xlab='Date', ylab='Sales ($)')

#************************************************************************************
#Analyze Monthly Sales Dataset
#*******************************************************************************

# split training and test dataset
training_abilene<-window(abilene_ts[,5], start=c(2014,1),end=c(2016,12))
test_abilene<-window(abilene_ts[,5], start=c(2017,1),end=c(2017,8))

# Model 1 - Multivariate linear regression
fit_lm_abilene<-lm(Current_MTD_Sales~
           Year
          +Month
          +Labor_Cost_Actuals
          +Food_Cost_Actual
          +Mystery_Shopper_Score1
          +Mystery_Shopper_Score2
          +FanTrack_Answers
          +Percentage_of_Response
          ,data=training_abilene_df)

# plot model and residuals
par(mfrow=c(2,2))
plot(fit_lm_abilene)
summary(fit_lm_abilene)

res_lm<-residuals(fit_lm_abilene)
par(mfrow=c(1,1))
plot(res_lm
     ,col='red'
     ,type='o'
     ,xlab='Year'
     ,ylab='Residual'
     ,main='Residual of Linear Model')
abline(0,0)
#The residual appears to have a pattern.
#Perhaps the linear model is not the best model

# Model 2 - Random Forest***********************************
library (randomForest)
fit_rf_abilene<- randomForest(Current_MTD_Sales~
                        Year
                      +Month
                      +Labor_Cost_Actuals
                      +Food_Cost_Actual
                      +Mystery_Shopper_Score1
                      +Mystery_Shopper_Score2
                      +FanTrack_Answers
                      +Percentage_of_Response
                      ,data=training_abilene_df
                      ,mtry = 5
                      ,importance =TRUE
                      , type = "regression")
fit_rf_abilene

importance(fit_rf_abilene)

varImpPlot(fit_rf_abilene)

set.seed(1)

# Test Prediction*********************************************************

predict_rf_abilene <- predict(fit_rf_abilene, newdata =test_abilene_df)
predict_lm_abilene<-predict.lm(fit_lm_abilene,newdata = test_abilene_df)

mean_lm_abilene<-sqrt(mean((test_abilene_df$Current_MTD_Sales - predict_lm_abilene)^2))
mean_rf_abilene<-sqrt(mean((test_abilene_df$Current_MTD_Sales - predict_rf_abilene)^2))

plot(test_abilene_df$Current_MTD_Sales
     ,col="cornflowerblue"
     ,xlab="Year"
     ,ylab="Monthly Sales"
     ,type='l'
     ,lwd=2
     ,lty=1
     , main="Model Validation for Abilene")
lines(predict_lm_abilene
      ,col="red"
      ,lty=1
      ,lwd=2)
lines(predict_rf_abilene
      ,col="green"
      ,lty=1
      ,lwd=2)
legend("bottomright",lty=1,col=c("cornflowerblue"
                             ,"red"
                             ,"green"),
       legend=c("Actual Sales"
                ,"LR Forecast"
                ,"RF Forecast"),bty='n')


#*******************************************************************
# Time-series start here
#*******************************************************************

#Model 1 - Seasonal and Trend Decomposition model
par(mfrow=c(1,1))
fit_stl_abilene<-stl(training_abilene,s.window=5)
plot(training_abilene
     ,col="cornflowerblue"
     ,xlab="Year"
     ,ylab="Monthly Sales"
     ,type='l'
     ,lwd=2
     ,lty=1
     , main="Sales Trend for Abilene")
lines(fit_stl_abilene$time.series[,2]
      ,col="red"
      ,lty=1
      ,lwd=2)
legend("topright",lty=1,col=c("cornflowerblue","red"),
       legend=c("Actual Sales","Trend"),bty='n')

#plot residual for STL
res_stl<-fit_stl_abilene$time.series[,3]
par(mfrow=c(1,1))
plot(res_stl
     ,col='red'
     ,type='o'
     ,xlab='Year'
     ,ylab='Residual'
     ,main='Residual of STL model')
abline(0,0)

#Decompose three year trends
plot(fit_stl_abilene
    ,main="Decomposition of Time-Series: 3 Year"
    ,col="blue"
    ,lwd=2)

#Monthly Plot - Seasonal Trend
par(mfrow=c(1,1))
monthplot(fit_stl_abilene$time.series[,"seasonal"]
          ,col="blue"
          ,xlab="Month"
          ,ylab="Seasonal"
          ,lwd=2
          ,main="Seasonality: 3 year - Abilene")

#***************************************************************
#Model 2: Winter-Holt Seasonal Method

fit_hw_abilene <- hw(training_abilene,seasonal="additive")
plot(fit_hw_abilene,ylab="Monthly Sales ($)",
     plot.conf=FALSE, type="o", fcol="white", xlab="Year")
lines(fitted(fit_hw_abilene), col="red", lty=2)
lines(fit_hw_abilene$mean, type="o", col="red")
legend("topleft",lty=1, pch=1, col=1:3,bty='n',
       c("Actual Sales","Holt Winters' Additive"))

res_hw<-fit_hw_abilene$residuals
par(mfrow=c(1,1))
plot(res_hw
     ,col='red'
     ,type='o'
     ,xlab='Year'
     ,ylab='Residual'
     ,main='Residual of HW Additive model')
abline(0,0)


#******************************************************************
#test validation

predict_stl_abilene<-forecast(fit_stl_abilene,h=8)
predict_hw_abilene<-forecast(fit_hw_abilene, h=8)

# plot Test validation
plot(test_abilene
     ,col="cornflowerblue"
     ,xlab="Year"
     ,ylab="Monthly Sales"
     ,type='l'
     ,lwd=2
     ,lty=1
     , main="Model Validation for Abilene")
lines(predict_stl_abilene$mean
      ,col="red"
      ,lty=1
      ,lwd=2)
lines(predict_hw_abilene$mean
      ,col="green"
      ,lty=1
      ,lwd=2)
legend("topleft",lty=1,col=c("cornflowerblue"
                             ,"red"
                             ,"green"),
       legend=c("Actual Sales"
                ,"STL Forecast"
                ,"HW Forecast"),bty='n')

mean_stl_abilene<-sqrt(mean((test_abilene - predict_stl_abilene$mean)^2))
mean_hw_abilene<-sqrt(mean((test_abilene - predict_hw_abilene$mean)^2))

#************************************************************************
rbind(mean_stl_abilene
     ,mean_hw_abilene
     ,mean_lm_abilene
     ,mean_rf_abilene)

# It appears that the traditional Time-series models works well for this dataset.
# The STL model is the best performing models among the models

#************************************************************************
#************************************************************************
#************************************************************************
#************************************************************************************
#Analyze Monthly Actual Labor Cost
#*******************************************************************************
par(mfrow=c(1,1))
plot(abilene$Labor_Cost_Actuals~abilene$Date,
     main='Abilene Store - Monthly Labor Cost',col=4, lty=4,type='l',
     xlab='Date', ylab='Cost')

average_labor_cost<-mean(abilene$Labor_Cost_Actuals)
deviation_labor_cost<-sd(abilene$Labor_Cost_Actuals)

# split training and test dataset
training_abilene<-window(abilene_ts[,7], start=c(2014,1),end=c(2016,12))
test_abilene<-window(abilene_ts[,7], start=c(2017,1),end=c(2017,8))

# Model 1 - Multivariate linear regression
fit_lm_abilene<-lm(Labor_Cost_Actuals~
                   Current_MTD_Sales
                   +Year
                   +Month
                   +Food_Cost_Actual
                   +Mystery_Shopper_Score1
                   +Mystery_Shopper_Score2
                   +FanTrack_Answers
                   +Percentage_of_Response
                   ,data=training_abilene_df)

# plot model and residuals
par(mfrow=c(2,2))
plot(fit_lm_abilene)
summary(fit_lm_abilene)

res_lm<-residuals(fit_lm_abilene)
par(mfrow=c(1,1))
plot(res_lm
     ,col='red'
     ,type='o'
     ,xlab='Year'
     ,ylab='Residual'
     ,main='Residual of Linear Model')
abline(0,0)

# Model 2 - Random Forest***********************************
library (randomForest)
fit_rf_abilene<- randomForest(Labor_Cost_Actuals~
                              Current_MTD_Sales
                              +Year
                              +Month
                              +Food_Cost_Actual
                              +Mystery_Shopper_Score1
                              +Mystery_Shopper_Score2
                              +FanTrack_Answers
                              +Percentage_of_Response
                              ,data=training_abilene_df
                              ,mtry = 5
                              ,importance =TRUE
                              , type = "regression")
fit_rf_abilene

importance(fit_rf_abilene)

varImpPlot(fit_rf_abilene)

set.seed(1)

# Test Prediction*********************************************************

predict_rf_abilene <- predict(fit_rf_abilene, newdata =test_abilene_df)
predict_lm_abilene<-predict.lm(fit_lm_abilene,newdata = test_abilene_df)

mean_lm_abilene<-sqrt(mean((test_abilene_df$Labor_Cost_Actuals - predict_lm_abilene)^2))
mean_rf_abilene<-sqrt(mean((test_abilene_df$Labor_Cost_Actuals - predict_rf_abilene)^2))

plot(test_abilene_df$Labor_Cost_Actuals
     ,col="cornflowerblue"
     ,xlab="Year"
     ,ylab="Monthly Labor Cost"
     ,type='l'
     ,lwd=2
     ,lty=1
     ,ylim=c(18,22)
     , main="Labor Cost Model Validation for Abilene")
lines(predict_lm_abilene
      ,col="red"
      ,lty=1
      ,lwd=2)
lines(predict_rf_abilene
      ,col="green"
      ,lty=1
      ,lwd=2)
legend("bottomright",lty=1,col=c("cornflowerblue"
                                 ,"red"
                                 ,"green"),
       legend=c("Actual Labor Cost"
                ,"LR Forecast"
                ,"RF Forecast"),bty='n')


#*******************************************************************
# Time-series start here
#*******************************************************************

#Model 1 - Seasonal and Trend Decomposition model
par(mfrow=c(1,1))
fit_stl_abilene<-stl(training_abilene,s.window=5)
plot(training_abilene
     ,col="cornflowerblue"
     ,xlab="Year"
     ,ylab="Monthly Labor Cost"
     ,type='l'
     ,lwd=2
     ,lty=1
     , main="Sales Trend for Abilene")
lines(fit_stl_abilene$time.series[,2]
      ,col="red"
      ,lty=1
      ,lwd=2)
legend("topright",lty=1,col=c("cornflowerblue","red"),
       legend=c("Actual Labor","Trend"),bty='n')

#plot residual for STL
res_stl<-fit_stl_abilene$time.series[,3]
par(mfrow=c(1,1))
plot(res_stl
     ,col='red'
     ,type='o'
     ,xlab='Year'
     ,ylab='Residual'
     ,main='Residual of STL model')
abline(0,0)

#Decompose three year trends
plot(fit_stl_abilene
     ,main="Decomposition of Time-Series: 3 Year"
     ,col="blue"
     ,lwd=2)

#Monthly Plot - Seasonal Trend
par(mfrow=c(1,1))
monthplot(fit_stl_abilene$time.series[,"seasonal"]
          ,col="blue"
          ,xlab="Month"
          ,ylab="Seasonal"
          ,lwd=2
          ,main="Seasonality: 3 year Labor Cost - Abilene")

#***************************************************************
#Model 2: Winter-Holt Seasonal Method

fit_hw_abilene <- hw(training_abilene,seasonal="additive")
plot(fit_hw_abilene,ylab="Monthly Labor Cost",
     plot.conf=FALSE, type="o", fcol="white", xlab="Year")
lines(fitted(fit_hw_abilene), col="red", lty=2)
lines(fit_hw_abilene$mean, type="o", col="red")
legend("topleft",lty=1, pch=1, col=1:3,bty='n',
       c("Actual Labor","Holt Winters' Additive"))

res_hw<-fit_hw_abilene$residuals
par(mfrow=c(1,1))
plot(res_hw
     ,col='red'
     ,type='o'
     ,xlab='Year'
     ,ylab='Residual'
     ,main='Residual of HW Additive model')
abline(0,0)


#******************************************************************
#test validation

predict_stl_abilene<-forecast(fit_stl_abilene,h=8)
predict_hw_abilene<-forecast(fit_hw_abilene, h=8)

# plot Test validation
plot(test_abilene
     ,col="cornflowerblue"
     ,xlab="Year"
     ,ylab="Monthly Labor Cost"
     ,type='l'
     ,lwd=2
     ,lty=1
     ,ylim=c(18,22)
     , main="Model Validation for Abilene")
lines(predict_stl_abilene$mean
      ,col="red"
      ,lty=1
      ,lwd=2)
lines(predict_hw_abilene$mean
      ,col="green"
      ,lty=1
      ,lwd=2)
legend("topleft",lty=1,col=c("cornflowerblue"
                             ,"red"
                             ,"green"),
       legend=c("Actual Labor Cost"
                ,"STL Forecast"
                ,"HW Forecast"),bty='n')

mean_stl_abilene<-sqrt(mean((test_abilene - predict_stl_abilene$mean)^2))
mean_hw_abilene<-sqrt(mean((test_abilene - predict_hw_abilene$mean)^2))

#************************************************************************
rbind(mean_stl_abilene
      ,mean_hw_abilene
      ,mean_lm_abilene
      ,mean_rf_abilene)
# It appears that random forest is the best model

#*********************************************************************
#*********************************************************************
#*********************************************************************

# Actual Food Cost 

par(mfrow=c(1,1))
plot(abilene$Food_Cost_Actual~abilene$Date,
     main='Abilene Store - Monthly Food Cost',col=4, lty=4,type='l',
     xlab='Date', ylab='Cost')

average_food_cost<-mean(abilene$Food_Cost_Actual)
deviation_food_cost<-sd(abilene$Food_Cost_Actual)

# split training and test dataset
training_abilene<-window(abilene_ts[,11], start=c(2014,1),end=c(2016,12))
test_abilene<-window(abilene_ts[,11], start=c(2017,1),end=c(2017,8))

# Model 1 - Multivariate linear regression
fit_lm_abilene<-lm(Food_Cost_Actual~
                     Current_MTD_Sales
                   +Year
                   +Month
                   +Labor_Cost_Actuals
                   +Mystery_Shopper_Score1
                   +Mystery_Shopper_Score2
                   +FanTrack_Answers
                   +Percentage_of_Response
                   ,data=training_abilene_df)

# plot model and residuals
par(mfrow=c(2,2))
plot(fit_lm_abilene)
summary(fit_lm_abilene)

res_lm<-residuals(fit_lm_abilene)
par(mfrow=c(1,1))
plot(res_lm
     ,col='red'
     ,type='o'
     ,xlab='Year'
     ,ylab='Residual'
     ,main='Residual of Linear Model')
abline(0,0)

# Model 2 - Random Forest***********************************
library (randomForest)
fit_rf_abilene<- randomForest(Food_Cost_Actual~
                                Current_MTD_Sales
                              +Year
                              +Month
                              +Labor_Cost_Actuals
                              +Mystery_Shopper_Score1
                              +Mystery_Shopper_Score2
                              +FanTrack_Answers
                              +Percentage_of_Response
                              ,data=training_abilene_df
                              ,mtry = 5
                              ,importance =TRUE
                              , type = "regression")
fit_rf_abilene

importance(fit_rf_abilene)

varImpPlot(fit_rf_abilene)

set.seed(1)

# Test Prediction*********************************************************

predict_rf_abilene <- predict(fit_rf_abilene, newdata =test_abilene_df)
predict_lm_abilene<-predict.lm(fit_lm_abilene,newdata = test_abilene_df)

mean_lm_abilene<-sqrt(mean((test_abilene_df$Food_Cost_Actual - predict_lm_abilene)^2))
mean_rf_abilene<-sqrt(mean((test_abilene_df$Food_Cost_Actual - predict_rf_abilene)^2))

plot(test_abilene_df$Food_Cost_Actual
     ,col="cornflowerblue"
     ,xlab="2017"
     ,ylab="Monthly Food Cost"
     ,type='l'
     ,lwd=2
     ,lty=1
     ,ylim=c(22,25)
     , main="Food Cost Model Validation for Abilene")
lines(predict_lm_abilene
      ,col="red"
      ,lty=1
      ,lwd=2)
lines(predict_rf_abilene
      ,col="green"
      ,lty=1
      ,lwd=2)
legend("bottomright",lty=1,col=c("cornflowerblue"
                                 ,"red"
                                 ,"green"),
       legend=c("Actual Food Cost"
                ,"LR Forecast"
                ,"RF Forecast"),bty='n')


#*******************************************************************
# Time-series start here
#*******************************************************************

#Model 1 - Seasonal and Trend Decomposition model
par(mfrow=c(1,1))
fit_stl_abilene<-stl(training_abilene,s.window=5)
plot(training_abilene
     ,col="cornflowerblue"
     ,xlab="Year"
     ,ylab="Monthly Food Cost"
     ,type='l'
     ,lwd=2
     ,lty=1
     , main="Food Cost for Abilene")
lines(fit_stl_abilene$time.series[,2]
      ,col="red"
      ,lty=1
      ,lwd=2)
legend("topright",lty=1,col=c("cornflowerblue","red"),
       legend=c("Actual Food Cost","Trend"),bty='n')

#plot residual for STL
res_stl<-fit_stl_abilene$time.series[,3]
par(mfrow=c(1,1))
plot(res_stl
     ,col='red'
     ,type='o'
     ,xlab='Year'
     ,ylab='Residual'
     ,main='Residual of STL model')
abline(0,0)

#Decompose three year trends
plot(fit_stl_abilene
     ,main="Decomposition of Time-Series: 3 Year"
     ,col="blue"
     ,lwd=2)

#Monthly Plot - Seasonal Trend
par(mfrow=c(1,1))
monthplot(fit_stl_abilene$time.series[,"seasonal"]
          ,col="blue"
          ,xlab="Month"
          ,ylab="Seasonal"
          ,lwd=2
          ,main="Seasonality: 3 year Labor Cost - Abilene")

#***************************************************************
#Model 2: Winter-Holt Seasonal Method

fit_hw_abilene <- hw(training_abilene,seasonal="additive")
plot(fit_hw_abilene,ylab="Monthly Food Cost",
     plot.conf=FALSE, type="o", fcol="white", xlab="Year")
lines(fitted(fit_hw_abilene), col="red", lty=2)
lines(fit_hw_abilene$mean, type="o", col="red")
legend("topright",lty=1, pch=1, col=1:3,bty='n',
       c("Actual Food Cost","Holt Winters' Additive"))

res_hw<-fit_hw_abilene$residuals
par(mfrow=c(1,1))
plot(res_hw
     ,col='red'
     ,type='o'
     ,xlab='Year'
     ,ylab='Residual'
     ,main='Residual of HW Additive model')
abline(0,0)


#******************************************************************
#test validation

predict_stl_abilene<-forecast(fit_stl_abilene,h=8)
predict_hw_abilene<-forecast(fit_hw_abilene, h=8)

# plot Test validation
plot(test_abilene
     ,col="cornflowerblue"
     ,xlab="Year"
     ,ylab="Monthly Food Cost"
     ,type='l'
     ,lwd=2
     ,lty=1
     ,ylim=c(18,25)
     , main="Model Validation for Abilene")
lines(predict_stl_abilene$mean
      ,col="red"
      ,lty=1
      ,lwd=2)
lines(predict_hw_abilene$mean
      ,col="green"
      ,lty=1
      ,lwd=2)
legend("topleft",lty=1,col=c("cornflowerblue"
                             ,"red"
                             ,"green"),
       legend=c("Actual Food Cost"
                ,"STL Forecast"
                ,"HW Forecast"),bty='n')

mean_stl_abilene<-sqrt(mean((test_abilene - predict_stl_abilene$mean)^2))
mean_hw_abilene<-sqrt(mean((test_abilene - predict_hw_abilene$mean)^2))

#************************************************************************
rbind(mean_stl_abilene
      ,mean_hw_abilene
      ,mean_lm_abilene
      ,mean_rf_abilene)