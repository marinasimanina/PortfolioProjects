##### PROJECT 1. Flights delays

# task 1. read the dataset

setwd(choose.dir())

library(readxl)

flights <- read_excel(choose.files())

View(flights)

str(flights)

is.null(flights)

install.packages("descriptr")
install.packages(('ggplot2'))

library(descriptr)
library(ggplot2)


summary(flights)

attach(flights)

#histogram

hist(schedtime,
     main = "Histogram for Scheduled Time for Flights",
     xlab = "schedtime")

# colored histogram with specified bins

hist(schedtime,
     breaks =10,
     col = "whitesmoke", border = "tomato3")

ggplot(flights, aes(x=schedtime, fill=carrier)) +
  geom_histogram( color='#e9ecef', alpha=0.6, position='identity', binwidth = 50)

ggplot(flights, aes(x=schedtime, fill=dest)) +
  geom_histogram( color='#e9ecef', alpha=0.6, position='identity', binwidth = 50)

ggplot(flights, aes(x=schedtime, fill=origin)) +
  geom_histogram( color='#e9ecef', alpha=0.6, position='identity', binwidth = 50)

ggplot(flights, aes(x=schedtime, fill=weather)) +
  geom_histogram( color='red', alpha=0.6, position='identity', binwidth = 50)

ggplot(flights, aes(x=schedtime, fill=dayweek)) +
  geom_histogram( color='#e9ecef', alpha=0.6, position='identity', binwidth = 50)



#scatter plot

length(which(delay=='ontime'))
length(which(delay=='delayed'))

plot(schedtime, deptime,  main = "Flights on time vs Flights delayed", pch = 21, col= 'blue')



# box plot
summary(flights$daymonth)

boxplot(daymonth ~ delay, main = "Days when flight are delayed and ontime",
        xlab = "delay",
        ylab = "daymonth",
        horizontal = FALSE, col = 61)

#IQR = Q3-Q1
#Q1-1.5*(IQR), Q3+1.5*(IQR)



#define hours

library("stringr")
?str_pad
deptime1 <- str_pad(deptime, width = nchar("xxx") + 1, side = c("left"), pad = "0") #add 0 to xxx variables

hour <- strptime(deptime1, format = "%H%M")

hour

hour1 <- substring(hour, 12, 13)


#categorical representation using a table

flights$weather <- as.factor(flights$weather)
flights$delay <- as.factor(flights$delay)

str(flights)

table(weather,hour1)

table(delay, hour1)

table(weather, delay)


#summary of major variables

summary(flights)


#plot histograms of major variables

ggplot(flights, aes(x=deptime, fill=delay)) +
  geom_histogram( color='#e9ecef', alpha=0.6, position='identity', binwidth = 50)

ggplot(flights, aes(x=deptime, fill=weather)) +
  geom_histogram( color='#e9ecef', alpha=0.6, position='identity', binwidth = 50)


#PIE CHART

?pie

count <- c(length(which(delay=="delayed")), length(which(delay=="ontime")))

pie(count, labels = c("delayed", "ontime"), main = "How many flights are delayed")


#Pie with %

pie_labels <- round(count/sum(count)*100)

pie_labels1 <-paste(c("delayed", "ontime"), " ", pie_labels, "%", sep="")

pie(count, labels = pie_labels1, col= topo.colors(2), cex = 2, main = "How many flights are delayed")

