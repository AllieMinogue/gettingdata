setwd("D:/R Projects/gettingdata")
getwd()

## 1st step

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile = "projectData.zip",mode = "wb")
unzip("projectData.zip")

library(dplyr)

x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

x_raw <- rbind(x_test,x_train)
y_raw <- rbind(y_test,y_train)
subject_raw <- rbind(subject_test,subject_train)

features <- read.table("./UCI HAR Dataset/features.txt")
names(x_raw) <- features[,2]
y_raw <- rename(y_raw,activityLabel = V1)
subject_raw <- rename(subject_raw,subjectLabel = V1)

data_raw <- cbind(x_raw,y_raw,subject_raw)

## 2nd step

meanstdfilter <- c(
    grep("\\b(mean()|std())\\b",names(data_raw[,1:561])),
    562,563)
data_2 <- data_raw[,meanstdfilter]

## 3rd step

atvtlabel <- read.table("./UCI HAR Dataset/activity_labels.txt")
atvtlabel <- rename(atvtlabel,activityLabel = V1,activity = V2)
data_3 <- left_join(data_2,atvtlabel,by = "activityLabel")

## 4th step

data_4 <- data_3
names(data_4) <- sub("^t","Time",names(data_4))
names(data_4) <- sub("^f","Freq",names(data_4))
names(data_4) <- sub("\\(\\)","",names(data_4))
names(data_4) <- gsub("-","_",names(data_4))

## 5th step

data_5 <- data_4 %>% group_by(activity,subjectLabel) %>% select(-activityLabel) %>% summarize_all(mean)
names(data_5) <- paste("mean",names(data_5),sep = "")
data_5 <- rename(data_5,activity = meanactivity,subjectLabel = meansubjectLabel)
write.table(data_5,file = "data_5.txt",row.names = FALSE)
