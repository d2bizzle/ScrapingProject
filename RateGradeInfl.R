library(data.table)
library(dplyr)
library(ggplot2)
library(plotly)
library(ggthemes)
library(car)
library(boot)
library(stats)
setwd('~/Documents/DataScienceAcademy/Python/ScrapingProject/') # comment this out 

DOEdata <- fread('./AggData/DOEschoolData.csv') #DOE College Scorecard data
inflation <- fread('./AggData/inflation.csv') # data on grade inflation
schools <- fread('./AggData/schools.csv') # information/classification on schools 
ratings <- fread('./AggData/ratings.csv') # Rate My Prof reviews


# Make Histograms for both Quality and Difficulty

NumRate <- ggplot(data=ratings) + geom_histogram(aes(rat), col = 'red', fill = 'blue', binwidth = 0.5, bins = 9) + labs(x = 'Quality Ratings', y = 'Frequency of Occurrence', 
      title = 'Quality: 138,747 Reviews') + theme(plot.title=element_text(size=16, face="bold", color="darkgreen"))
NumRate

NumDiff <- ggplot(data=ratings) + geom_histogram(aes(diff), col = 'red', fill = 'blue', binwidth = 1, bins = 5) +  labs(x = 'Difficulty Ratings', y = 'Frequency of Occurrence', 
        title = 'Difficulty: 138,747 Reviews') + theme(plot.title=element_text(size=16, face="bold", color="darkgreen"))
NumDiff

# Aggregate Ratings by instructor for more detailed analysis
aggRatings <- ratings %>% group_by(name, hot, school, dept) %>% summarise(meanRat = mean(rat), meanDiff = mean(diff), N = n())
aggRatingsHot <- ratings %>% group_by(as.factor(hot)) %>% summarise(meanRat = mean(rat), meanDiff = mean(diff), N = n())

# Create plot that explores relationship between percieved quality and difficulty
RateDiff <- ggplot() + geom_point(data=aggRatings, aes(x = meanDiff, y = meanRat, color = aggRatings$N), shape = 7, alpha = 0.4) + labs(x = 'Mean Difficulty Rating per Instructor', y = 'Mean Quality Rating per Instructor', 
  title = '138,747 Rate My Professor Reviews Averaged by Instructor', color = '# Reviews') + geom_smooth(data=aggRatings, aes(x = meanDiff, y = meanRat), method = 'lm', formula = y ~ poly(x,3)) 
+ theme(plot.title=element_text(size=16, face="bold", color="darkgreen"))
RateDiff

EZQ <- lm(rat~(hot - diff), ratings)
summary(EZQ)

RatDiffTest <- cor.test(ratings$rat, ratings$diff)


HotNot <- ggplot(data=aggRatings, aes(meanDiff, meanRat, color = factor(aggRatings$hot))) + geom_point(shape = 7, alpha = 0.7) + labs(x = 'Mean Difficulty Rating per Instructor', y = 'Mean Quality Rating per Instructor', 
title = '138,747 Rate My Professor Reviews Averaged by Instructor', color = 'Hot?') + theme(plot.title=element_text(size=12, face="bold", color="darkgreen")) + scale_colour_manual(name="Hot \n or \n Not?",  values =c("blue", "red"))
HotNot

HistHotRat <- ggplot(ratings, aes(x = rat, color = hot)) + geom_histogram(binwidth = 0.5, bins = 9, alpha = 0.5, position = 'identity') + labs(x = 'Quality Rating', y = 'Frequency of Occurrence', 
                            title = 'Quality: 138,747 Reviews') + theme(plot.title=element_text(size=16, face="bold", color="darkgreen")) +  scale_colour_manual(name="Hot \n or \n Not?",  values =c("blue", "red"))
HistHotRat

HistHotDiff <- ggplot(ratings,aes(x = diff, color = hot)) + geom_histogram(alpha = 0.5, position = 'identity', binwidth = 1, bins = 5)+ labs(x = 'Difficulty Rating', y = 'Frequency of Occurrence', 
                            title = 'Difficulty: 138,747 Reviews') + theme(plot.title=element_text(size=16, face="bold", color="darkgreen")) +  scale_colour_manual(name="Hot \n or \n Not?",  values =c("blue", "red"))
HistHotDiff

DoeAgg <- DOEdata %>% mutate(delta = (exp - rev)) %>%  group_by(school, delta) %>% summarise(Rate = mean(rate, na.rm = T), SAT = mean(SAT, na.rm = T))
SchoolaggRatings <- ratings %>% group_by(school) %>% summarise(meanRat = mean(rat), meanDiff = mean(diff), N = n())
SchoolSpendComp <- inner_join(SchoolaggRatings, DoeAgg, by = 'school')

SpendOut1 <- ggplot(data=SchoolSpendComp, aes(x = delta, y = meanRat, label = school, size = Rate, fill = Rate)) + geom_point(shape = 23, alpha = 0.7) + labs(x = 'Difference Between Instructional Expenditures \n and Costs per FTE Equivalent', y = 'Mean Quality Rating per Instructor', 
            title = 'Examining the Influence of Net \n Instructional Expenditures on \n Quality Rating') + theme(plot.title=element_text(size=16, face="bold", color="darkgreen")) + scale_color_gradientn(colours = rainbow(3))
SpendOut1

SpendOut2 <- ggplot(data=SchoolSpendComp, aes(x = delta, y = meanDiff, label = school, size = Rate, fill = Rate)) + geom_point(shape = 23, alpha = 0.7) + 
  labs(x = 'Difference Between Instructional Expenditures \n and Costs per FTE Equivalent', y = 'Mean Difficulty Rating per Instructor',title = 'Examining the Influence of Net \n Instructional Expenditures on \n Difficulty Rating') + 
  theme(plot.title=element_text(size=16, face="bold", color="darkgreen")) + scale_color_gradientn(colours = rainbow(3))
SpendOut2

model1 = lm(meanRat~delta, data=SchoolSpendComp)
model2 = lm(meanDiff~delta, data=SchoolSpendComp)
model1
model2
InfluenceRat <- influencePlot(model1,	id.method="identify", main="Influence Plot for Model of \n Mean Quality Rating vs \n Net Instructional Expenditures", sub="Circle size is proportial to Cook's Distance")
InfluenceDiff <- influencePlot(model1,	id.method="identify", main="Influence Plot for Model of \n Mean Difficulty Rating vs \n Net Instructional Expenditures", sub="Circle size is proportial to Cook's Distance")

GradeInflRecent <- inflation %>% filter(year > 2005) %>% group_by(school) %>% summarise(meanGPA = mean(GPA, na.rm=T))
SchoolsGradesRat <- inner_join(SchoolSpendComp, GradeInflRecent, by = 'school')
InflGradesRat <- ggplot(SchoolsGradesRat, aes(x = meanGPA, y = meanRat)) + geom_point(shape = 7, alpha = 0.7, size = SchoolsGradesRat$Rate, fill = SchoolsGradesRat$Rate) + 
  labs(x = 'Mean GPA', y = 'Mean Quality Rating per Instructor', title = 'Quality Rating and GPA') + 
  theme(plot.title=element_text(size=12, face="bold", color="darkgreen")) + geom_smooth(method = 'lm')
InflGradesRat

InflGradesDiff <- ggplot(SchoolsGradesRat, aes(x = meanGPA, y = meanDiff, label = school)) + geom_point(shape = 7, alpha = 0.7, size = SchoolsGradesRat$Rate, fill = SchoolsGradesRat$Rate)+ 
  labs(x = 'Mean GPA', y = 'Mean Difficulty Rating per Instructor', title = 'Difficulty Rating and GPA') + 
  theme(plot.title=element_text(size=12, face="bold", color="darkgreen")) + geom_smooth(method = 'lm')
InflGradesDiff

test <- ratings %>% group_by(dept) %>% summarise(meanRat = mean(rat), meanDiff = mean(diff))

### all below for future analyses

test$dept <- trimws(gsub(".*the\\s*|department*", "", test$dept), which = 'right')

test$class = grepl(PSM, test$dept)

PSM = 'Actuarial|Aerospace|Astronomy|Chemistry|Engineering|Computer|Earth|Electrical|Industrial|Macromolecular|Materials|Mathematics|
        Nuclear|Physics|Statistics'

test$classif = grepl('Actuarial|Aerospace|Astronomy|Chemistry|Engineering|Computer|Earth|Electrical|Industrial|Macromolecular|Materials|Mathematics|Nuclear|Physics|Statistics', test$dept)


PStestPlotRat <- ggplot(test, aes(x=classif, y = meanRat)) + geom_boxplot(notch = TRUE, color="orange", fill='blue', alpha=0.2 ) + labs(x = 'Physical Science/Math or Other', y = 'Mean Quality Rating per Instructor', title = 'Quality Rating and Disciplines') + 
  theme(plot.title=element_text(size=12, face="bold", color="darkgreen"))
PStestPlotRat

PStestPlotDiff <- ggplot(test, aes(x=classif, y = meanDiff)) + geom_boxplot(notch = TRUE, color="orange", fill='blue', alpha=0.2 ) + labs(x = 'Physical Science/Math or Other', y = 'Mean Difficulty Rating per Instructor', title = 'Difficulty Rating and Disciplines') + 
  theme(plot.title=element_text(size=12, face="bold", color="darkgreen"))
PStestPlotDiff
