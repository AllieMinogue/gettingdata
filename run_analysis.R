setwd("D:/R Projects/gettingdata")
getwd()

## 1st step

library(dplyr)

x_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")

x_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")
subject_train <- read.table("./train/subject_train.txt")

x_raw <- rbind(x_test,x_train)
y_raw <- rbind(y_test,y_train)
subject_raw <- rbind(subject_test,subject_train)

features <- read.table("features.txt")
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

library(dplyr)

atvtlabel <- read.table("activity_labels.txt")
atvtlabel <- rename(atvtlabel,activityLabel = V1,activity = V2)
data_3 <- left_join(data_2,atvtlabel,by = "activityLabel")

## 4th step

data_4 <- data_3
names(data_4) <- sub("^t","Time",names(data_4))
names(data_4) <- sub("^f","Freq",names(data_4))
names(data_4) <- sub("\\(\\)","",names(data_4))
names(data_4) <- gsub("-","_",names(data_4))

## 5th step

activity_data <- data_4 %>% group_by(activity) %>% select(-activityLabel,-subjectLabel) %>% summarize_all(mean)
subject_data <- data_4 %>% group_by(subjectLabel) %>% select(-activityLabel,-activity) %>% summarize_all(mean)
