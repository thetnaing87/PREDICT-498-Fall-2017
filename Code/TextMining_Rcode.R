#Sonic Yelp Comments:Denver Area

############################################ 
#Install Packages 
############################################ 
install.packages ("Rcpp")
install.packages ("tm")
install.packages ("SnowballC")
install.packages ("RColorBrewer")
install.packages ("wordcloud")
install.packages ("ggplot2")

############################################ 
#Read library of each package
############################################ 
library(tm)
library(RColorBrewer)
library(wordcloud)
library ("Rcpp")
library ("SnowballC")
library (ggplot2)

############################################ 
#Set Working Directory
############################################ 
setwd ("~/Desktop/PREDICT 498/TEXT ANALYSIS")

############################################ 
#Read in data
############################################ 
SonicData = read.csv("SonicData.csv")
names (SonicData)
dim (SonicData)
View (SonicData)

############################################ 
#Input Question Name needed (field with comments)
############################################ 
QuestionName<-"Comment"
 
############################################ 
#Create document source to use with text mining tools
############################################ 
MYSonicData<-Corpus(VectorSource(as.character(SonicData[[QuestionName]])))

############################################ 
#Step 1: strip out extra whitespace
############################################ 
MYSonicData2<-tm_map(MYSonicData,stripWhitespace)

############################################ 
#Step 2: convert to all lower case
############################################ 
MYSonicData2<-tm_map(MYSonicData2,tolower)

############################################ 
#Step 3: delete english "stopwords"
############################################ 
MYSonicData2<-tm_map(MYSonicData2,removeWords,c(stopwords("english"))

############################################ 
#Step 4: delete punctuation
############################################ 
MYSonicData2<-tm_map(MYSonicData2,removePunctuation)

############################################ 
#Step 5: create corpus
############################################ 
MyCorpus<-MYSonicData2
 
 
############################################ 
##Step 6: Review all words
############################################ 
AllConcepts <- TermDocumentMatrix(MYSonicData2)
m <- as.matrix(AllConcepts)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 150)




############################################ 
#Step 7: Stem words (Not sure if necessary)
############################################ 

#MYSonicData2<-tm_map(MYSonicData2, stemDocument)
#write.table(MYSonicData2,sep='\t',row.name=F,file="Stemmed.xls")

############################################
##Step 8:create term document matrix
############################################
#Mydtm<-DocumentTermMatrix(MYSonicData2)
Mydtm<-TermDocumentMatrix(MYSonicData2)
temp2 <- inspect(Mydtm)
 
#########################################
##Step 9:Find frequent terms
#########################################
findFreqTerms(x=Mydtm, lowfreq=30, highfreq=Inf)

 

#########################################
##Step 10: Complete the stems to their original form (if stem above)
#########################################

##doesn't work: MYOE2<-tm_map(MYOE2,stemCompletion,dictionary= MyCorpus) 
##complete to original form manually
#for (j in seq(MYOE2)){
#  MYOE2[[j]]<-gsub("alway","always",MYOE2[[j]])
#  MYOE2[[j]]<-gsub("lot","alot",MYOE2[[j]])
#  MYOE2[[j]]<-gsub("qualiti","quality",MYOE2[[j]])
#  MYOE2[[j]]<-gsub("select","selection",MYOE2[[j]])
#  MYOE2[[j]]<-gsub("varieti","variety",MYOE2[[j]])
#  MYOE2[[j]]<-gsub("cloth","Clothing",MYOE2[[j]])
#}
#MYOE2<-tm_map(MYOE2,PlainTextDocument)

#for (j in seq(MYOE2)){
    MYOE2[[j]]<-gsub("caloth","Clothing",MYOE2[[j]])
#}
#MYOE2<-tm_map(MYOE2,PlainTextDocument)


#########################################
##Step 11:create term document matrix again (if stem above)
#########################################
#Mydtm<-TermDocumentMatrix(MYSonicData2)
#findFreqTerms(x=Mydtm, lowfreq=10, highfreq=Inf)


#########################################
##Step 12: exploratory analysis: horizontal bar chart showing frequently used words
#########################################
term.freq <-rowSums(as.matrix(Mydtm))
term.freq <-subset(term.freq, term.freq >= 20)
df <-data.frame(term=names(term.freq), freq=term.freq)
ggplot(df, aes(x=term, y = freq)) + geom_bar(stat="identity") +  
  xlab("Terms") + ylab("Count") + coord_flip()
 
#########################################
##Step 13: Create Wordcloud
#########################################
set.seed(1234)
Mydtm<-DocumentTermMatrix(MYSonicData2)
ap.m <- as.matrix(Mydtm)
ap.v <- sort(colSums(ap.m),decreasing=TRUE)
ap.d <- data.frame(word = names(ap.v),freq=ap.v)
### create color palette
pal2 <- brewer.pal(8,"Dark2")
wordcloud(ap.d$word,ap.d$freq, scale=c(8,.2),min.freq=1,max.words=25, 
          random.order=FALSE, rot.per=.15, colors=pal2)
#data <- tm_map(df, removeWords, "noble")
write.table(ap.d,sep='\t',row.name=F,file="WordCloud_word_freq.xls")
### if the top words are vertical, rerun wordcloud until we get them horizontal


#########################################
##Cluster Analysis (optional)
#########################################

Mydtm<-TermDocumentMatrix(MYSonicData2)
Mydtm2 <- removeSparseTerms(Mydtm, sparse = .95)
m2 <- as.matrix(Mydtm2)
distMatrix <-dist(scale(m2))
fit2 <- hclust(distMatrix, method = "ward.D")
plot(fit2)
rect.hclust(fit2, k=3)


#########################################
##Each word can become a variable by changing TermDocumentMatrix to DocumentTermMatrix
#########################################
#AllConcepts <- TermDocumentMatrix(MYSonicData2)
AllConcepts <- DocumentTermMatrix(MYSonicData2)
m <- as.matrix(AllConcepts)
#########################################
##Append Word Matrix to original file:SonicData
#########################################

FinalData=cbind(SonicData,m)
names (FinalData)
 
#########################################
##Run Random Forests model using 'Stars' as dependent variable and words as indpendent (optional)
#########################################


install.packages (randomForest)
library(randomForest)
library(foreign)




rftest<-randomForest(as.numeric(Stars)~order+fast+wrong+time+never+like+service,data=FinalData,na.action=na.omit,importance=T,nTrees=1000)
write.table(rftest$importance/rftest$importanceSD,sep="\t",file="clipboard")


#########################################
##Topic Analysis (optional)
#########################################

Mydtm.topic<-as.TermDocumentMatrix(Mydtm2)
install.packages("topicmodels")
library(topicmodels)

lda <-LDA(Mydtm2.topic, k=4)
term <- terms(lda,4)
term






