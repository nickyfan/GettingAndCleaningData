#use dplyr and migrittr packages
install.packages("magrittr")
install.packages("dplyr")
library(magrittr)
library(dplyr)
#merges the trainning and the test sets to create one data set
testData <- read.table("./test/X_test.txt")
trainData <- read.table("./train/X_train.txt")
X <- rbind(testData,trainData)
#get features and name X columns
features <- read.table("./features.txt")
names(X)  <- features[,2]


#Read subjects and name S columns
testSub <- read.table("./test/subject_test.txt")
trainSub <- read.table("./train/subject_train.txt")
S <- rbind(testSub,trainSub)
names(S) <- c("subjectID")

#Read labels and name Y columns
testlabel <- read.table("./test/y_test.txt")
trainlabel <- read.table("./train/y_train.txt")
Y <- rbind(testlabel,trainlabel)
names(Y) <- c("activityID")

#remmove unused objects
rm(testData)
rm(trainData)
rm(testSub)
rm(trainSub)
rm(testlabel)
rm(trainlabel)

#get the labels
actlabels <- read.table("./activity_labels.txt")
names(actlabels)  <- c("activityID", "activityType")


#only keep the measurements on the mean and standard deviation 
#for each measurement
X <- X[, grep("-std|-mean", names(X))]

#combine all the data together
totalData <- cbind(Y,S,X)

#Sort by activityid, subjectID
totalData <- arrange(totalData, activityID, subjectID)

#Add labels for activities
totalData$activityName <- factor(totalData$activityID,
                                 levels=actlabels$activityID, 
                                 labels=actlabels$activityType)

#Write combined data to disk
write.table(totalData, "totalData.txt")

#Calculate means by activity, subject
totalMeans <-totalData %>%
        group_by(activityID,activityName,subjectID)%>%
        summarise_each(funs(mean),3:81)
        
#write file meansData.txt
write.table(totalMeans, "meansData.txt",row.name=FALSE)

