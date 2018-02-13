library(data.table)
library(dplyr)
library(ggplot2)
library(plotly)
library(ggthemes)
library(car)
setwd('~/Documents/DataScienceAcademy/Python/ScrapingProject/')

DOEdata <- fread('./data/doe.csv')
inflation <- fread('./data/inflation.csv')
schools <- fread('./data/schools.csv')
ratings <- fread('./data/ratings.csv')



NumRate <- ggplot(data=ratings) + geom_histogram(aes(rat), binwidth = 0.5, bins = 9)
NumRate <- ggplotly(NumRate)
NumRate

NumDiff <- ggplot(data=ratings) + geom_histogram(aes(diff), binwidth = 1, bins = 5)
NumDiff <- ggplotly(NumDiff)
NumDiff

aggRatings <- ratings %>% group_by(name, hot, school, dept) %>% summarise(meanRat = mean(rat), meanDiff = mean(diff), N = n())
aggRatingsHot <- ratings %>% group_by(as.factor(hot)) %>% summarise(meanRat = mean(rat), meanDiff = mean(diff), N = n())

RateDiff <- ggplot(data=aggRatings, aes(meanDiff, meanRat, color = aggRatings$N)) + geom_point(shape = 7, alpha = 0.4) + labs(x = 'Mean Difficulty Rating per Instructor', y = 'Mean Quality Rating per Instructor', 
  title = '138,747 Rate My Professor Reviews Averaged by Instructor', color = '# Reviews') + geom_smooth(method = 'lm') + scale_color_gradientn(colours = rainbow(3)) +
  theme(plot.title=element_text(size=16, face="bold", color="darkgreen"))
RateDiff
RateDiff <- ggplotly(RateDiff)
RateDiff

HotNot <- ggplot(data=aggRatings, aes(meanDiff, meanRat, color = factor(aggRatings$hot))) + geom_point(shape = 7, alpha = 0.7) + labs(x = 'Mean Difficulty Rating per Instructor', y = 'Mean Quality Rating per Instructor', 
title = '138,747 Rate My Professor Reviews Averaged by Instructor', color = 'Hot?') + theme(plot.title=element_text(size=16, face="bold", color="darkgreen"))
HotNot
HotNot <- ggplotly(HotNot)
HotNot

HistHotRat <- ggplot(ratings) + geom_histogram(aes(rat, fill = hot), binwidth = 0.5, bins = 9)
HistHotRat

HistHotDiff <- ggplot(ratings) + geom_histogram(aes(diff, fill = hot), binwidth = 1, bins = 5)
HistHotDiff

DoeAgg <- DOEdata %>% mutate(delta = (exp - rev)) %>%  group_by(school, delta) %>% summarise(Rate = mean(rate, na.rm = T), SAT = mean(SAT, na.rm = T))
SchoolaggRatings <- ratings %>% group_by(school) %>% summarise(meanRat = mean(rat), meanDiff = mean(diff), N = n())
SchoolSpendComp <- inner_join(SchoolaggRatings, DoeAgg, by = 'school')

SpendOut1 <- ggplot(data=SchoolSpendComp, aes(x = delta, y = meanRat, label = school)) + geom_point(shape = 7, alpha = 0.4)
SpendOut1 <- ggplotly(SpendOut1) + labs(x = 'Difference Between Instructional Expenditures and Costs \n per FTE Equivalent', y = 'Mean Quality Rating per Instructor', 
                                        title = 'Examining the Influence of Net Instructional Expenditures on ', color = 'Hot?') + theme(plot.title=element_text(size=16, face="bold", color="darkgreen"))
SpendOut1

SpendOut2 <- ggplot(data=SchoolSpendComp, aes(x = delta, y = meanDiff, label = school)) + geom_point(shape = 7, alpha = 0.4) + xlim(NA, 20000)
SpendOut2 + geom_smooth(method = 'lm')

SpendOut2 <- ggplotly(SpendOut2)
SpendOut2

model1 = lm(meanRat~delta, data=SchoolSpendComp)
model2 = lm(meanDiff~delta, data=SchoolSpendComp)
model1
model2
InfluenceRat <- influencePlot(model1,	id.method="identify", main="Influence Plot for Model of Mean Quality Rating vs \n Net Instructional Expenditures", sub="Circle size is proportial to Cook's Distance")
InfluenceDiff <- influencePlot(model1,	id.method="identify", main="Influence Plot for Model of Mean Difficulty Rating vs \n Net Instructional Expenditures", sub="Circle size is proportial to Cook's Distance")

GradeInflRecent <- inflation %>% filter(year > 2005) %>% group_by(school) %>% summarise(meanGPA = mean(GPA, na.rm=T))
SchoolsGradesRat <- inner_join(SchoolSpendComp, GradeInflRecent, by = 'school')
InflGradesRat <- ggplotly(ggplot(SchoolsGradesRat, aes(x = meanGPA, y = meanRat, label = school)) + geom_point())
InflGradesRat

InflGradesDiff <- ggplotly(ggplot(SchoolsGradesRat, aes(x = meanGPA, y = meanDiff, label = school)) + geom_point())
InflGradesDiff

test <- ratings %>% group_by(dept) %>% summarise(meanRat = mean(rat))

### Run trimws(gsub(".*the\\s*|department*", "", x), which = 'right')

test$dept <- trimws(gsub(".*the\\s*|department*", "", test$dept), which = 'right')

test$class = grepl(PSM, test$dept)

PSM = 'Actuarial|Aerospace|Astronomy|Chemistry|Engineering|Computer|Earth|Electrical|Industrial|Macromolecular|Materials|Mathematics|
        Nuclear|Physics|Statistics'

test$classif = grepl('Actuarial|Aerospace|Astronomy|Chemistry|Engineering|Computer|Earth|Electrical|Industrial|Macromolecular|Materials|Mathematics|Nuclear|Physics|Statistics', test$dept)

test$class = grepl(PSM, test$dept)
PStestPlot <- ggplot(test, aes(x=classif, y = meanRat)) + geom_boxplot()
PStestPlot

PStest <- test %>% group_by(test$class) %>% summarize(meanRat = mean(meanRat))


