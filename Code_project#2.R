##### PROJECT 2. Bike Rental Prediction


# task 1. Exploratory data analysis:
## Load the dataset and the relevant libraries

setwd(choose.dir())

library(readxl)

bikes <- read_excel(choose.files())

View(bikes)

str(bikes)

summary(bikes)

## Perform data type conversion of the attributes

bikes$dteday <- as.Date(bikes$dteday)
bikes$season <- as.factor(bikes$season)
bikes$yr <- as.factor(bikes$yr)
bikes$mnth <- as.factor(bikes$mnth)
bikes$holiday <- as.factor(bikes$holiday)
bikes$weekday <- as.factor(bikes$weekday)
bikes$workingday <- as.factor(bikes$workingday)
bikes$weathersit <- as.factor(bikes$weathersit)

head(bikes,5)

## Carry out the missing value analysis

missing_val<-data.frame(apply(bikes,2,function(x){sum(is.na(x))}))
names(missing_val)[1]='missing_val'
missing_val

#or 

is.null(bikes)


# Attributes distribution and trends

## Plot monthly distribution of the total number of bikes rented

library(descriptr)
library(ggplot2)
install.packages('ggextra')
library(ggextra)


summary(bikes)

attach(bikes)

g <- ggplot(bikes) + geom_bar(aes(x= mnth,y=cnt, fill = yr), stat = 'identity', position = 'dodge')+
  labs(x= "Month number", y="Monthly Usage Count", title= "Bikes usage monthly for 2011, 2012")

## Plot yearly distribution of the total number of bikes rented

g1 <- ggplot(bikes) + geom_bar(aes(x= yr, y=cnt), stat = 'identity', fill="cyan")+
  labs(x= "Years 2011, 2012", y="Yearly Usage Count", title= "Bikes usage for 2011, 2012")

g1
  
## Plot boxplot for outliers' analysis

summary(bikes$cnt)

#IQR = Q3-Q1
#Q1-1.5*(IQR), Q3+1.5*(IQR)

boxplot(bikes$cnt, main = "Outliers in bikes usage",
        xlab = "Bikes usage",
        ylab = "Total bikes rented daily",
        col = 61)



# Perform the following tasks on the dataset provided using R:
  ## Split the dataset into train and test dataset
  
## preparing dataset for Random Forest analysis
## removing "casual" and "registered" columns as we have total "cnt"
## removing "instant", "dteday" as irrelevant

bikes_df <- subset(bikes, select= -c(instant, dteday, casual, registered))
bikes_df

set.seed(1234)

splitIndex  <-  sample(2, nrow(bikes_df), 
                       replace = TRUE, 
                       prob = c(0.7,0.3))

trainSplit  <-  bikes_df[splitIndex==1,]
testSplit <-  bikes_df[splitIndex==2,]

dim(trainSplit)

dim(testSplit)

head(trainSplit)
head(testSplit)



## Create a model using the random forest algorithm

library(randomForest)
library(caret) 
library(pROC)
library(e1071)

?randomForest

attach(bikes_df)

modelrf <- randomForest(cnt ~ ., data = trainSplit, do.trace=F)
modelrf

#find number of trees that produce lowest test MSE
which.min(modelrf$mse)

##From the output we can see that the model that produced the lowest test mean squared error (MSE) used 336 trees.

#find RMSE of best model
sqrt(modelrf$mse[which.min(modelrf$mse)])

## We can also see that the root mean squared error of that model is 670.05
## We can think of this as the average difference between the predicted value for "cnt" and the actual observed value.


varImpPlot(modelrf)
#create a plot that displays the importance of each predictor variable in the final model


##https://www.statology.org/random-forest-in-r/
modelrf_tuned <- tuneRF(
x=bikes_df[,-1], #define predictor variables
y=bikes_df$cnt, #define response variable
ntreeTry=500,
mtryStart=4, 
stepFactor=1.5,
improve=0.01,
trace=FALSE #don't show real-time progress
)
## This function produces the following plot, which displays the number of predictors
 #used at each split when building the trees on the x-axis and the out-of-bag estimated error on the y-axis


## Predict the performance of the model on the test dataset
## predict - to validate model - to be done on test dataset only

predrf_test <- predict(modelrf, testSplit)
head(predrf_test, 10)

Bikes_predictions <- data.frame(predrf_test)
write.csv(Bikes_predictions,'Bike_Renting_R.CSV',row.names=F)
Bikes_predictions

