# Getting and Cleaning Data Course Project October 2014
# Jerold Paulson
#The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

#One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
  
#  http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

#Here are the data for the project: 
  
#  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

#You should create one R script called run_analysis.R that does the following. 
#_________________________________________________________________________________________________________
#1.  Merges the training and the test sets to create one data set.
#_________________________________________________________________________________________________________
# First we set the working directory to the appropriate folder
setwd("D:/Documents/CloudStation/Data Science/Getting and Cleaning Data/Class Project")
# Now we load the libraries that are needed
library(reshape)
library(plyr)
# Load the training x and y data as well as the subject identifiers
trainingXData = read.table("./UCI HAR Dataset/train/X_train.txt")
trainingYData = read.table("./UCI HAR Dataset/train/Y_train.txt")
trainingSubjectData = read.table("./UCI HAR Dataset/train/subject_train.txt")
# Now do the same for the test x and y data as well as the subject identifiers
testXData = read.table("./UCI HAR Dataset/train/X_train.txt")
testYData = read.table("./UCI HAR Dataset/train/Y_train.txt")
testSubjectData = read.table("./UCI HAR Dataset/train/subject_train.txt")
#-------
# OK - now let's start formatting the X data
# We need to format variable names
#   - First, load variable names from features file
variableNamesDF = read.table("./UCI HAR Dataset/features.txt")
variableNames = variableNamesDF$V2

# transfer headings to data set
colnames(trainingXData) = variableNames
colnames(testXData) = variableNames
#-------
# OK - now let's work on the Y data
# format y datasets
# change V1 variable to "activity name"
testYData <- rename(testYData, c(V1="activity_name"))
trainingYData <- rename(trainingYData, c(V1="activity_name"))

# change data values in testYData according to activity_labels.txt file
# there are 6 activities
activityNamesDF  = read.table("./UCI HAR Dataset/activity_labels.txt")

# convert variable names to lowercase
activities = tolower(levels(activityNamesDF$V2))

# convert $activity to factor and add descriptive labels
trainingYData$activity_name = factor(
  trainingYData$activity_name, 
  labels = activities
)

testYData$activity_name = factor(
  testYData$activity_name, 
  labels = activities
)
# Format subject variables 
# change subject variable name to be descriptive
trainingSubjectData <- rename(trainingSubjectData, c(V1="participant_id"))
testSubjectData <- rename(testSubjectData, c(V1="participant_id"))
#-------
# Merge the training and the test sets to create one data set.
# combine (all the tables) for each of the training and test sets
trainData = cbind(trainingXData, trainingSubjectData, trainingYData)
testData = cbind(testXData, testSubjectData, testYData)

# combine train and test set
allData = rbind(trainData, testData)
#________________________________________________________________________________________________________
#2.  Extracts only the measurements on the mean and standard deviation for each measurement. 
#_________________________________________________________________________________________________________
# Data Extraction: 
# Keep only the measurements on the mean and standard deviation for each measurement, along with the activity column.
# 

pattern = "mean|std|participant_id|activity_name"
allTidyData = allData[,grep(pattern , names(allData), value=TRUE)]


#_________________________________________________________________________________________________________
#3.  Uses descriptive activity names to name the activities in the data set
#_________________________________________________________________________________________________________
# this step was done as part of the consolidation in step 1

#_________________________________________________________________________________________________________
#4.  Appropriately labels the data set with descriptive variable names. 
#_________________________________________________________________________________________________________
# Let's neaten up the variable names which are already somewhat descriptive, but messy...
# Remove underscores and hyphens, change to lowercase.
tidyNames = gsub("\\(|\\)|-|,", "", names(allTidyData))
names(allTidyData) <- tolower(tidyNames)

#_________________________________________________________________________________________________________
#5.  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#_________________________________________________________________________________________________________
# summarize data
result = ddply(allTidyData, .(activity_name, participant_id), numcolwise(mean))

# write file to output
write.table(result, file="outputData.txt", sep = "\t", append=F,row.name=FALSE)
