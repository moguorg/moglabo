#zokusei <- read.csv("oubo_zokusei.csv", header=F)

#summary(zokusei)
#length(zokusei$V1)
#nenrei <- na.omit(zokusei$V3) 
#summary(nenrei)
#boxplot(nenrei)

#kiroku <- read.csv("oubo_kiroku.csv", header=F)

#summary(kiroku)
#length(kiroku$V1)
#jikantai <- kiroku$V2
#plot(jikantai)

library(chron)
day2week <- function(day){
	strday <- strsplit(day, " ")[[1]][1]
	ymd <- strsplit(strday, "/")
	week <- day.of.week(ymd[[1]][2], ymd[[1]][3], ymd[[1]][1])
	
	week
}

#jikantai_week <- jikantai[sapply(jikantai, day2week)]
#plot(jikantai_week)



