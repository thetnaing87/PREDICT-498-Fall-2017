# Association Rules for Market Basket Analysis (R)
detach(package:tm, unload=TRUE) 
library(arules)  # association rules
library(arulesViz)  # data visualization of association rules
library(RColorBrewer)  # color palettes for plots

data.dir   <- 'C:/MSPA/Capstone/Project/498-20170922T004637Z-001/498/Ticket/store 4818/'
file1 <- paste0(data.dir, 'drive_through_list_of_lists.csv')
file2 <- paste0(data.dir, 'stall_list_of_lists.csv')
file3 <- paste0(data.dir, 'patio_list_of_lists.csv')
file4 <- paste0(data.dir, 'call_in_list_of_lists.csv')

# Read Dataset as Transaction
drive_through <- read.transactions(file1,format='basket',sep=',')
stall <- read.transactions(file2,format='basket',sep=',')
patio <- read.transactions(file3,format='basket',sep=',')
call_in <- read.transactions(file4,format='basket',sep=',')

# Get summary statistics
summary(drive_through)
summary(stall)
summary(patio)
summary(call_in)

print(head(itemInfo(drive_through)))

# Get Frequency Plot
itemFrequencyPlot(drive_through,
                  type='relative',
                  support = 0.025,
                  cex.names=1.0,
                  xlim = c(0,0.2),
                  horiz = TRUE,
                  col = "cornflowerblue",
                  las = 1,
                  xlab = paste("Frequency of Drive Through Orders",
                               "\n(Item Relative Frequency or Support)"))

itemFrequencyPlot(stall,
                  type='relative',
                  support = 0.025,
                  cex.names=1.0,
                  xlim = c(0,0.2),
                  horiz = TRUE,
                  col = "seagreen",
                  las = 1,
                  xlab = paste("Frequency of Stall Orders",
                               "\n(Item Relative Frequency or Support)"))

itemFrequencyPlot(patio,
                  type='relative',
                  support = 0.025,
                  cex.names=1.0,
                  xlim = c(0,0.3),
                  horiz = TRUE,
                  col = "tomato",
                  las = 1,
                  xlab = paste("Frequency of Patio Orders",
                               "\n(Item Relative Frequency or Support)"))

itemFrequencyPlot(call_in,
                  type='relative',
                  support = 0.025,
                  cex.names=1.0,
                  xlim = c(0,0.2),
                  horiz = TRUE,
                  col = "orange",
                  las = 1,
                  xlab = paste("Frequency of Call in Orders",
                               "\n(Item Relative Frequency or Support)"))


# Set the rule with 0.0025 support and 0.5 Confidence
rules_drive_through <- apriori(drive_through, parameter = list(supp=0.01, conf=0.50)) # set with low parameters
rules_stall <- apriori(stall, parameter = list(supp=0.01, conf=0.50)) # set with low parameters
rules_patio <- apriori(patio, parameter = list(supp=0.025, conf=0.80)) # set with low parameters
rules_call_in <- apriori(call_in, parameter = list(supp=0.02, conf=0.80)) # set with low parameters


#Sort the rules by lift
rules_drive_through <- sort(rules_drive_through, by='lift', decreasing = TRUE)
rules_stall <- sort(rules_stall, by='lift', decreasing = TRUE)
rules_patio <- sort(rules_patio, by='lift', decreasing = TRUE)
rules_call_in <- sort(rules_call_in, by='lift', decreasing = TRUE)

# Summary of association rules

summary(rules_drive_through)
summary(rules_patio)
summary(rules_stall)
summary(rules_call_in)

#inspect the top 30 rules

drive_through_top_50<-rules_drive_through[1:50]
stall_top_50<-rules_stall[1:50]
patio_top_50<-rules_patio[1:20]
call_in_top_50<-rules_call_in[1:20]

inspect(drive_through_top_50)
inspect(stall_top_50)
inspect(patio_top_50)
inspect(call_in_top_50)

#Plot top 30 rules
plot(drive_through_top_50, 
     control=list(jitter=2, col = rev(brewer.pal(9, "Blues")[4:9])),
     shading = "lift")   

plot(stall_top_50, 
     control=list(jitter=2, col = rev(brewer.pal(9, "Greens")[4:9])),
     shading = "lift")   

plot(patio_top_50, 
     control=list(jitter=2, col = rev(brewer.pal(9, "Reds")[4:9])),
     shading = "lift") 

plot(call_in_top_50, 
     control=list(jitter=2, col = rev(brewer.pal(9, "Blues")[4:9])),
     shading = "lift")   


# plot association rules graph for 30 rules
plot(drive_through_top_50,
     method="graph",
     main="Drive Through: Top 50 Rules")
 
plot(stall_top_50,
     method="graph",
     main="Stall: Top 50 Rules")

plot(patio_top_50,
     method="graph",
     main="Patio: Top 20 Rules")

plot(call_in_top_50,
     method="graph",
     main="Call In: Top 20 Rules")

# Plot matrix rules

plot(drive_through_top_50, method = "grouped", col='cornflowerblue')
plot(stall_top_50, method = "grouped", col='seagreen')
plot(patio_top_50, method = "grouped", col='tomato')
plot(call_in_top_50, method = "grouped", col='orange')
#######################################################################
