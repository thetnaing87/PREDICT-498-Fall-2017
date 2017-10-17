require(moments)
require(stats)
require(ggplot2)
library(MASS)
library(car)
library(forecast)
library(glmnet)
library(reshape) # for summarizing data
data.dir   <- 'C:/MSPA/Capstone/Project/498-20170922T004637Z-001/498/Ticket/store 4818/'
train.file <- paste0(data.dir, 'volume_trend_analysis_4818.csv')
sonic_ticket <- read.csv(train.file,stringsAsFactors=F)

# validate missing values
sapply(sonic_ticket, function(x) sum(is.na(x)))

#impute missing values
#library(mice)

#imputed<-mice(sonic_ticket,m=5,meth='norm',seed=500)
#sonic_ticket<-complete(imputed,1)
#str(sonic_ticket)
#sapply(sonic_ticket, function(x) sum(is.na(x)))


#*********************************************************************************

str(sonic_ticket)
sonic_ticket$BUSINESS_DATE<-as.Date(as.character(sonic_ticket$BUSINESS_DATE, format="%m/%d/%Y"))
sonic_ticket<-sonic_ticket[order(as.Date(sonic_ticket$BUSINESS_DATE, format="%m/%d/%Y"), decreasing=FALSE),]
#summary of dataset
summary(sonic_ticket)


##############################################################
#Start EDA
##############################################################
#summary of dataset
summary(sonic_ticket)
 # isolate sales with excessive discount

newset<-sonic_ticket[sonic_ticket$SALES_AMOUNT>0,]
excessive_discount<-sonic_ticket[sonic_ticket$SALES_AMOUNT<=0,]
summary(newset)
sd(newset$SALES_AMOUNT)
sd(newset$HOP_OUT_TIME)
sd(newset$TICKET_NUM)
sd(newset$AVE_SALE_PER_ORDER)
sd(newset$AVE_SALE_PER_SERVICE_MINUTE)
attach(newset)

# Aggregate Sales by Business Day
total_sales_1<- aggregate(SALES_AMOUNT~BUSINESS_DATE, data=newset,sum)
par(mfrow=c(1,2))
ggplot(data=total_sales_1,aes(x=BUSINESS_DATE
                              ,y=SALES_AMOUNT
                              ,colour=SALES_AMOUNT))+geom_line()+
  ggtitle("SALES ($) by BUSINESS DAY")+theme_bw()



# Hop Out Time  by YEAR  
boxplot(HOP_OUT_TIME~YEAR,data=newset,
        main="Service time by YEAR",
        ylab="Service Time (min)",
        xlab="YEAR",
        border=c("red","blue","black"))


# Sales  by YEAR  
boxplot(SALES_AMOUNT~YEAR,data=newset,
        main="SALES before tax by YEAR",
        ylab="Sales ($)",
        xlab="YEAR",
        border=c("red","blue","black"))

# Ticket Number  by YEAR  
boxplot(TICKET_NUM~YEAR,data=newset,
        main="TOTAL TICKET by YEAR",
        ylab="Number of Ticket",
        xlab="YEAR",
        border=c("red","blue","black"))


outlier_hop_out<-newset[newset$HOP_OUT_TIME>=15,]
outlier_sales<-newset[newset$SALES_AMOUNT>=2500,]
outlier_ticket<-newset[newset$TICKET_NUM>=300,]

pairs(SALES_AMOUNT~
        TICKET_NUM
      +HOP_OUT_TIME
      +YEAR
      +MONTH,
      data=newset
      ,col=4
      ,main='Correlation Plot'
      )

#Plot sales with ticket number and Service time
ggplot(data = newset, aes(x = HOP_OUT_TIME, y = SALES_AMOUNT))+
  geom_point(aes(color = DAY_PART),size = 2) + 
  ggtitle("SALES and Service Time Plot")+
  theme_bw()

ggplot(data = newset, aes(x = TICKET_NUM, y = SALES_AMOUNT))+
  geom_point(aes(color = DAY_PART),size = 2) + 
  ggtitle("SALES and Number of Customer Plot")+
  theme_bw()


# Histogram for Sales and Number of Customers

par(mfrow=c(1,1))
ggplot(data=newset, aes(SALES_AMOUNT)) + 
  geom_histogram(col="cornflowerblue",
                 fill="white",
                 alpha = .2) + 
  labs(title="Histogram for SALES $") +
  labs(x="SALES", y="Count")+theme_bw()

ggplot(data=newset, aes(TICKET_NUM)) + 
  geom_histogram(col="cornflowerblue",
                 fill="white",
                 alpha = .2) + 
  labs(title="Histogram for Number of CUstomers") +
  labs(x="Number of Customers", y="Count")+theme_bw()



# The Number of Customer by Day Part

ggplot(data=newset,aes(x=DAY_PART
                       ,y=TICKET_NUM))+
  ggtitle("Number of Customer by DAY PART")+
  theme_bw()+
  geom_boxplot(aes(colour = DAY_PART))

# The number of customer by DAYOFWEEK

ggplot(data=newset,aes(x=DAYOFWEEK
                       ,y=TICKET_NUM))+
  ggtitle("Number of Customer by DAY OF WEEK")+
  theme_bw()+
  geom_boxplot(aes(colour = DAYOFWEEK))


# the number of customer by MONTH

boxplot(TICKET_NUM~MONTH,data=newset,
        main="Number of Customer by Month",
        ylab="Number of Customer",
        xlab="MONTH",
        border=c("red","blue","green","yellow","orange","purple","black"))

# number of customers by YEAR

boxplot(AVE_SALE_PER_ORDER~YEAR,data=newset,
        main="Average Sales Per Ticket by YEAR",
        ylab="Average Sales Per Ticket",
        xlab="YEAR",
        border=c("red","blue","green","yellow","orange","purple","black"))


#************************************************************************************
#Analyze the average sales per ticket
#************************************************************************************

library(pivottabler)
qhpvt(newset, c("YEAR", "MONTH"), NULL,  
      c("Total Sales"="sum(SALES_AMOUNT)", "Std Dev"="sd(SALES_AMOUNT)"),
      formats=list("%.2f", "%.1f"))

qhpvt(newset, c("YEAR"), NULL,  
      c("AVERAGE SALES PER TICKET"="mean(AVE_SALE_PER_ORDER)"),
      formats=list("%.2f"))

qhpvt(newset, c("MONTH"), NULL,  
      c("AVERAGE SALES PER TICKET"="mean(AVE_SALE_PER_ORDER)"),
      formats=list("%.2f"))

qhpvt(newset, c("DAYOFWEEK"), NULL,  
      c("AVERAGE SALES PER TICKET"="mean(AVE_SALE_PER_ORDER)"),
      formats=list("%.2f"))


#Average sales per ticket by day part
ggplot(data=newset,aes(x=DAY_PART
                       ,y=AVE_SALE_PER_ORDER))+
  ggtitle("Average Sales Per Ticket by DAY PART")+
  theme_bw()+
  geom_boxplot(aes(colour = DAY_PART))


# Average sales per day part and day of week
average_sales_daypart<- aggregate(SALES_AMOUNT~DAYOFWEEK+DAY_PART, data=newset,mean)
par(mfrow=c(1,1))
ggplot(data=average_sales_daypart,aes(x=DAYOFWEEK
                                      ,y=SALES_AMOUNT
                                      ,group=DAY_PART
                                      ,colour=DAY_PART))+
  geom_line()+
  ggtitle("AVERAGE SALES ($) by DAY OF WEEK and DAYPART")+
  theme_bw()+
  geom_point(size=3)



qqnorm(SALES_AMOUNT, ylab = "Sales",
       main = "Q-Q Plot of Density of Sales", col = "red")
qqline(SALES_AMOUNT,col="black")

#Aggregate Total Customer data by Business Day and Day Part
total_customer<- aggregate(TICKET_NUM~BUSINESS_DATE+DAY_PART, data=newset,sum)
par(mfrow=c(1,1))
ggplot(data=total_customer,aes(x=BUSINESS_DATE
                            ,y=TICKET_NUM
                            ,group=DAY_PART
                            ,colour=DAY_PART))+geom_line()+
  ggtitle("Number of Customer by DAY PART for BUSINESS DAY")+theme_bw()



# Average NUmber of Customer for Day of WEEK
average_customer<- aggregate(TICKET_NUM~DAYOFWEEK+DAY_PART, data=newset,mean)
par(mfrow=c(1,1))
ggplot(data=average_customer,aes(x=DAYOFWEEK
                            ,y=TICKET_NUM
                            ,group=DAY_PART
                            ,colour=DAY_PART))+geom_line()+
  ggtitle("Weekly Number of Customer by Day part")+
  theme_bw()+
  geom_point(size=3)

average_customer1<- aggregate(TICKET_NUM~MONTH+DAY_PART, data=newset,mean)
par(mfrow=c(1,1))
ggplot(data=average_customer1,aes(x=MONTH
                                 ,y=TICKET_NUM
                                 ,group=DAY_PART
                                 ,colour=DAY_PART))+geom_line()+
  ggtitle("Monthly average number of Customer by Day part")+
  theme_bw()+
  geom_point(size=3)



#**********************************************************************
# Breakfast Customer
#**********************************************************************
breakfast<-newset[which(newset$DAY_PART=='01-Breakfast'),]# my stores
breakfast<-breakfast[order(as.Date(breakfast$BUSINESS_DATE, format="%m/%d/%Y"), decreasing=FALSE),]
str(breakfast)
boxplot(TICKET_NUM~SALES.TYPE,data=breakfast,
        main="Number of Tickets by Sales Type",
        ylab="Number of Tickets",
        xlab="Sales Type",
        border=c("red","blue","green","yellow","orange","purple","black"))

boxplot(AVE_SALE_PER_ORDER~SALES.TYPE,data=breakfast,
        main="Average Sales Per Ticket by Sales Type",
        ylab="Average Sales Per Tickets",
        xlab="Sales Type",
        border=c("red","blue","green","yellow","orange","purple","black"))

#**********************************************************************
# 
breakfast_ticket<- aggregate(TICKET_NUM~YEAR+MONTH+DAYOFWEEK+SALES.TYPE, data=breakfast,sum)
breakfast_ticket<-breakfast_ticket[with(breakfast_ticket, order(YEAR,MONTH,DAYOFWEEK),decreasing=FALSE),]


# create dummy variable with 
library(dummy)
breakfast_dummy<-dummy(breakfast_ticket,p="all",int=TRUE)

drop_var<-c("SALES.TYPE"
            ,"DAYOFWEEK")

breakfast_df<-breakfast_ticket[,!(names(breakfast_ticket)%in%drop_var)]
str(breakfast_df)
breakfast_df<-cbind(breakfast_df,breakfast_dummy)
str(breakfast_df)

#Split dataset into two sets

training_set<-breakfast_df[1:350,]
test_set<-breakfast_df[351:406,]

#######################################################################
#MODEL 1. POISSON
#**************************************************************************
poisson<-glm(TICKET_NUM~.,family="poisson",data=training_set)
summary(poisson)
with(poisson,cbind(res.deviance=deviance,df=df.residual, p=pchisq(deviance,df.residual,lower.tail = FALSE)))
plot(residuals(poisson),
     main="Residuals of Poisson Model"
     ,ylab="Residuals"
     ,xlab="Period"
     ,col="red")
pred_poisson<-predict(poisson,test_set,type="response",se.fit=TRUE)

write.csv(pred_poisson, file="C:/MSPA/Capstone/Project/498-20170922T004637Z-001/498/Ticket/store 4818/breakfast_pred_poisson.csv",row.names=FALSE)
write.csv(test_set, file="C:/MSPA/Capstone/Project/498-20170922T004637Z-001/498/Ticket/store 4818/breakfast.csv",row.names=FALSE)


head(pred$fit)
head(test_set$TICKET_NUM)

#######################################################################

# Model 2 - Multivariate linear regression
fit_lm_abilene<-lm(TICKET_NUM~.,data=training_set)

# plot model and residuals
par(mfrow=c(2,2))
plot(fit_lm_abilene)
summary(fit_lm_abilene)

res_lm<-residuals(fit_lm_abilene)
par(mfrow=c(1,1))
plot(res_lm
     ,col='red'
     ,xlab='Period'
     ,ylab='Residual'
     ,main='Residual of Linear Model')
abline(0,0)

predict_lm_abilene <- predict(fit_lm_abilene, newdata =test_set)


#Model 3*
#Gradient Boosting Model

library(gbm)
set.seed(1)

gbm_model<- gbm(TICKET_NUM ~ ., data = training_set, distribution="gaussian",
                 n.trees = 3000, shrinkage=0.005, interaction.depth = 4) # 1205 11945 err: 0.10


summary(gbm_model)

gbm_pred <- predict.gbm(gbm_model, newdata = test_set,
                          n.trees = 3000)

plot(test_set$TICKET_NUM
     ,type='l'
     ,col=4)
lines(gbm_pred)

##################################################################
breakfast_ts<- aggregate(TICKET_NUM~YEAR+MONTH+DAYOFWEEK, data=breakfast,sum)
breakfast_ts<-breakfast_ts[with(breakfast_ts, order(YEAR,MONTH,DAYOFWEEK),decreasing=FALSE),]
dim(breakfast_ts)


is.ts(breakfast_ts)
breakfast_ts <- ts(breakfast_ts,frequency=52)
is.ts(breakfast_ts)

train_ts<-breakfast_ts[1:133,]
test_ts<-breakfast_ts[134:198,]
train_ts<-ts(train_ts, frequency = 52)
test_ts<-ts(test_ts, frequency = 52)
# Auto Arima Model

par(mfrow=c(1,1))
fit_auto_arima<-auto.arima(train_ts[,4], seasonal = TRUE)
summary(fit_auto_arima)
plot(train_ts[,4]
     ,col="cornflowerblue"
     ,ylab="Number of Customers"
     ,type='l'
     ,lwd=2
     ,lty=1
     , main="Number of Customers Trend for Abilene")
lines(fit_auto_arima$fitted
      ,col="red"
      ,lty=1
      ,lwd=2)
legend("topright",lty=1,col=c("cornflowerblue","red"),
       legend=c("Actual Number of Customers","Auto Arima"),bty='n')

plot(fit_stl_abilene
     ,main="Decomposition of Time-Series"
     ,col="blue"
     ,lwd=2)

plot(residuals(fit_auto_arima)
     ,col='red'
     ,xlab='Period'
     ,ylab='Residual'
     ,main='Residual of AUTO ARIMA Model')
abline(0,0)

predict_arima<-forecast(fit_auto_arima,h=65)
#************************************************************
#plot is not working
#************************************************************
plot(test_ts[,4]
     ,col="cornflowerblue"
     ,ylab="Number of Customer"
     ,type='l'
     ,lwd=2
     ,lty=1
     , main="Model Validation for Abilene")
lines(predict_arima$mean
      ,col="red"
      ,lty=1
      ,lwd=2)
legend("topleft",lty=1,col=c("cornflowerblue"
                             ,"red"),
       legend=c("Test Set"
                ,"Auto Arima"), bty='n')

mean_arima_abilene<-sqrt(mean((test_ts[,4] - predict_arima$mean)^2))

accuracy(predict_arima,test_ts[,4])
summary(fit_auto_arima)

AIC(poisson,fit_lm_abilene)
BIC(poisson,fit_lm_abilene)

rmse_lm_abilene<-sqrt(mean((test_set$TICKET_NUM - predict_lm_abilene)^2))
rmse_poisson_abilene<-sqrt(mean((test_set$TICKET_NUM - pred_poisson$fit)^2))
mae_lm_abilene<-sum(abs(test_set$TICKET_NUM - predict_lm_abilene))/length(test_set$TICKET_NUM)
mae_poisson_abilene<-sum(abs(test_set$TICKET_NUM - pred_poisson$fit))/length(test_set$TICKET_NUM)
rmse_gbm_abilene<-sqrt(mean((test_set$TICKET_NUM - gbm_pred)^2))
mae_gbm_abilene<-sum(abs(test_set$TICKET_NUM - gbm_pred))/length(test_set$TICKET_NUM)

# Plot Test Dataset

plot(test_set$TICKET_NUM
     ,type='l'
     ,col="red"
     ,lwd=2
     ,xlab="Period"
     ,ylab="Number of Customer"
     ,main="Model Validation")
lines(pred_poisson$fit
      ,col="blue"
      ,lwd=2)
lines(predict_lm_abilene
      ,col="green"
      ,lwd=1)
lines(gbm_pred
      ,col="black"
      ,lwd=1)
legend("topright",lty=1,col=c("red","blue","green","black"),
       legend=c("Actual Sales"
                ,"POISSON Model"
                ,"Liner Regression"
                ,"Gradient Boosting"),bty='n')


write.csv(predict_lm_abilene, file="C:/MSPA/Capstone/Project/498-20170922T004637Z-001/498/Ticket/store 4818/breakfast_pred_linear.csv",row.names=FALSE)



