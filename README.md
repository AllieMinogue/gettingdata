---
title: "gettingdata course project"
author: "AllieMinogue"
date: "27th February 2024"
output:
  word_document: default
  pdf_document: default
---
# Introduction

This is a project submission for the course on **Getting and Cleaning data** on Coursera (<https://www.coursera.org/learn/data-cleaning>), by *AllieMinogue*. In this document I'll walk you through the step-by-step process to carry out & deliver the requirements of the course project.

# Step 1
## 1.1 
Here I simply downloaded the .zip file from the link within the assignment, & unzip it into my working directory

```
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile = "projectData.zip",mode = "wb")
unzip("projectData.zip")
```
## 1.2 
Then I read the necessary file into the necessary objects:

- x_test|x_train: the testing & training data set that contain all the observations of all the variables

- y_test|y_train: the activity **6** labels

- subject_train|subject_test: the **30** subject labels
```
library(dplyr)

x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
```
## 1.3 
Here I combine the testing data set with the training data set, rename the header for activity label & subject label table. Eventually I combine the data set (x_raw) with activity label (y_raw) & subject label (subject_raw) in to the 1 required data set (data_raw).

```
x_raw <- rbind(x_test,x_train)
y_raw <- rbind(y_test,y_train)
subject_raw <- rbind(subject_test,subject_train)

features <- read.table("./UCI HAR Dataset/features.txt")
names(x_raw) <- features[,2]
y_raw <- rename(y_raw,activityLabel = V1)
subject_raw <- rename(subject_raw,subjectLabel = V1)

data_raw <- cbind(x_raw,y_raw,subject_raw)
```
# Step 2
Here I use `grep` function to get the column name index of columns on mean & standarad deviation only, within `data_raw`, then create the `data_2` table that contain on such columns.
```
meanstdfilter <- c(
    grep("\\b(mean()|std())\\b",names(data_raw[,1:561])),
    562,563)
data_2 <- data_raw[,meanstdfilter]
```
# Step 3
Here I am using `rename` to rename column names in the "activity_labels.txt" file, then use such file to match the `activity` to corresponding `activityLabel` column in data_3 file
```
atvtlabel <- read.table("./UCI HAR Dataset/activity_labels.txt")
atvtlabel <- rename(atvtlabel,activityLabel = V1,activity = V2)
data_3 <- left_join(data_2,atvtlabel,by = "activityLabel")
```
# Step 4
The step to get descriptive variable names in column names as below. More explanation for column names can be found in the codebook

- Replace "t" by "Time"
- Replace "f" by "Frequency"
- Remove "()" string
- Replace "-" by "_"
```
data_4 <- data_3
names(data_4) <- sub("^t","Time",names(data_4))
names(data_4) <- sub("^f","Freq",names(data_4))
names(data_4) <- sub("\\(\\)","",names(data_4))
names(data_4) <- gsub("-","_",names(data_4))
```
# Step 5
Here I first group up the data set by `activity`, then by `subjectLabel`, then use `summarize_all` function to create a new data set that show the average of each variable for each activity & each subject. Then I add the prefix "mean" to all column names to reflect the correct calculation of the variables.
Eventually `write.table` helps to write into the final data set required by the course project.

```
data_5 <- data_4 %>% group_by(activity,subjectLabel) %>% select(-activityLabel) %>% summarize_all(mean)
names(data_5) <- paste("mean",names(data_5),sep = "")
data_5 <- rename(data_5,activity = meanactivity,subjectLabel = meansubjectLabel)
write.table(data_5,file = "data_5.txt",row.names = FALSE)
```