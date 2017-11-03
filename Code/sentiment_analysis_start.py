# -*- coding: utf-8 -*-
"""
Created on Wed Nov  1 19:33:38 2017

@author: Oyumaa
"""
import os
import pandas as pd
import re
from nltk.corpus import PlaintextCorpusReader
from nltk.corpus import stopwords
import numpy as np
from sklearn.feature_extraction.text import CountVectorizer
from numpy import *

directory='C:/MSPA/Capstone/Project/Text Mining From Social Media/'
#Read comments from Facebook scrape
sonic = pd.read_csv(os.path.join(directory,'SonicDriveIn_facebook_statuses1.csv'), encoding='latin-1')

sonic.shape #(6,742,9)
sonic.columns.values 
sonic.dtypes

# status_published needs to be converted into datetime
sonic['status_published']=pd.to_datetime(sonic['status_published'])
# remove timestamp from the date
sonic['status_published'] = sonic['status_published'].apply(lambda x: x.date())

# group likes, number of comments and shared by date
date_type_comments=sonic.groupby(['status_published','status_type'],as_index=False).agg({
                                                                'num_likes':'sum'
                                                                ,'num_comments':'sum'
                                                                ,'num_shares':'sum'
                                                                })

# plot likes, comments, shares

date_type_comments.plot(x='status_published'
         ,y='num_comments'
         ,label='Number of Comments'
         ,color='green'
         ,linestyle='dashed')

date_type_comments.plot(x='status_published'
         ,y='num_likes'
         ,label='Number of Likes'
         ,color='blue'
         ,linestyle='dotted')

date_type_comments.plot(x='status_published'
         ,y='num_shares'
         ,label='Number of Shares'
         ,color='red'
         ,linestyle='dotted')

##############################################################################
#isolate customer's comments from the sonic dataset
comments_sonic=sonic['status_message']

# read each rows into 
comments_all=[]
   
for row in comments_sonic:
    comments_all.append(row)

# convert list to dictionary #################################################
my_dict = {}
for index, item in enumerate(comments_all):
    if index % 2 == 0:
        my_dict[item] = comments_all[index+1]

# create string to manipulate the strings 
my_string=str(my_dict)


# create function to prepare the text
def review_words(string):
    # remove non-letters
    string=re.sub('[^a-zA-Z]', ' ', string)
    # tokenize the text
    words=string.lower().split()
    # create a set for stop words
    stops=set(stopwords.words("english"))
    #remove stop words
    meaningful_words=[w for w in words if not w in stops]
    # return the result
    return(" ".join(meaningful_words))

# get the clean review
reviews=review_words(my_string)
###############################################################################
#using scikit-learn to create a bag of words
vectorizer = CountVectorizer(analyzer = "word",   \
                             tokenizer = None,    \
                             preprocessor = None, \
                             stop_words = None,   \
                             max_features = 10000) 

data_features = vectorizer.fit_transform(reviews.split('\n'))
data_features = data_features.toarray()
print (data_features.shape)

vocab = vectorizer.get_feature_names()
print (vocab)

count_words=[]
my_words=[]

dist = np.sum(data_features, axis=0)
for tag, count in zip(vocab, dist):
    count_words.append(count)
    my_words.append(tag)


my_words=pd.DataFrame(my_words)
count_words=pd.DataFrame(count_words)

my_bag_of_words=pd.concat([my_words,count_words],axis=1)
my_bag_of_words.columns=['words','number_of_words']

# my bag of words
my_bag_of_words=my_bag_of_words.sort('number_of_words',ascending=False)

###############################################################################
## Word Dictionary to analysis sentiments
###############################################################################

my_directory = 'C:/MSPA/452_Web Analytcs/Assignment/Individual Assignment 4/Sentiment Analysis/000_sentiment_jump_start/'
positive_list = PlaintextCorpusReader(my_directory, 'Hu_Liu_positive_word_list.txt')
negative_list = PlaintextCorpusReader(my_directory, 'Hu_Liu_negative_word_list.txt',encoding='latin-1')

positive_words = positive_list.words()
negative_words = negative_list.words()

# define bag-of-words dictionaries 
def bag_of_words(words, value):
    return dict([(word, value) for word in words])
    
    
positive_scoring = bag_of_words(positive_words, 1)
negative_scoring = bag_of_words(negative_words, -1)
scoring_dictionary = dict(positive_scoring.items()| negative_scoring.items())

blogcorpus=reviews.split()

blogscore = [0] * len(blogcorpus)  # initialize scoring list

for iword in range(len(blogcorpus)):
    if blogcorpus[iword] in scoring_dictionary:
        blogscore[iword] = scoring_dictionary[blogcorpus[iword]]
        
# report the norm sentiment score for the words in the corpus
print('Corpus Average Sentiment Score:')
print(round(sum(blogscore) / (len(blogcorpus)), 3))        

# Read the blogcorpus from beginning to end
# identifying all the places where the search_word occurs.
# We arbitrarily identify search-string-relevant words
# to be those within three words of the search string.
blogrelevant = [0] * len(blogcorpus)  # initialize blog-relevnat indicator
blogrelevantgroup = [0] * len(blogcorpus)
groupcount = 0  
###############################################################################
search_word='sonic'
###############################################################################
for iword in range(len(blogcorpus)):
    if blogcorpus[iword] == search_word:
        groupcount = groupcount + 1
        for index in range(max(0,(iword - 3)),min((iword + 4), len(blogcorpus))):
            blogrelevant[index] = 1
            blogrelevantgroup[index] = groupcount

# Compute the average sentiment score for the words nearby the search term.
print('Average Sentiment Score Around Search Term')
print(round(sum((array(blogrelevant) * array(blogscore))) / sum(array(blogrelevant)),3))
                
print('RUN COMPLETE')                