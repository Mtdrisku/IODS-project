#### IODS RStudio Exercise 4 and 5 #####


# Date: 29.11.2021
# Author: Matilda Riskumäki
# Description: This Rscript includes the code for carrying out the IODS exercise 
# data wrangling part for weeks 4 and 5. 

# Working directory----
setwd("/Users/matirisk/Desktop/PhD-kurssit/2021_IODS/IODS-project/Data")

# Libraries----
library(dplyr)

#### Week 4 ####
# Importing and exploring the data----

hd <- read.csv("http://s3.amazonaws.com/assets.datacamp.com/production/course_2218/datasets/human_development.csv", 
               stringsAsFactors = F, sep = ",") # data for human development

gii <- read.csv("http://s3.amazonaws.com/assets.datacamp.com/production/course_2218/datasets/gender_inequality.csv", 
                stringsAsFactors = F, na.strings = "..", sep = ",") # data for gender inequality

dim(hd) # number of observations and variables in the data frame
dim(gii)
names(hd) # name of each variable (column names)
names(gii)
str(hd) #structure of the data frame
str(gii)


# Modify the data----

# rename some of the variables (create shorter names)
hd <- hd %>% rename( HDI = Human.Development.Index..HDI.,
                     Life.exp = Life.Expectancy.at.Birth, 
                     Edu.exp = Expected.Years.of.Education,
                     Edu.mean = Mean.Years.of.Education,
                     GNI = Gross.National.Income..GNI..per.Capita,
                     GNI.minus.rank = GNI.per.Capita.Rank.Minus.HDI.Rank)

gii <- gii %>% rename(GII = Gender.Inequality.Index..GII.,
                      Mat.mor = Maternal.Mortality.Ratio,
                      Ado.birth = Adolescent.Birth.Rate,
                      Parli.F = Percent.Representation.in.Parliament,
                      Edu2.F = Population.with.Secondary.Education..Female.,
                      Edu2.M = Population.with.Secondary.Education..Male.,
                      Labo.F = Labour.Force.Participation.Rate..Female.,
                      Labo.M = Labour.Force.Participation.Rate..Male.)

# create two new variables in the 'gii' data set
# a variable for the ratio of female and male populations with secondary education in each country
gii$Edu2.FM <- gii$Edu2.F/gii$Edu2.M

# a variable for the ratio of labour force participation of females and males in each country
gii$Labo.FM <- gii$Labo.F/gii$Labo.M


# Join the two data sets and save----

# use inner_join and join by variable 'Country'
human <- inner_join(hd, gii, by = "Country")

# save the data in your 'Data' folder
getwd() # check if your working directory is in the 'Data' folder
write.table(human, file = "human.txt", sep = "\t")


#### Week 5 ####
human <- read.table("human.txt", sep = "\t") # import the joined data

# Mutate the data----
human$GNI <- as.numeric(sub("," , "", human$GNI)) # the values include comma as a thousands separator and we want to get rid of that
human <- dplyr::select(human, c("Country", "Edu2.FM", "Labo.FM", "Edu.exp", "Life.exp", "GNI", "Mat.mor", "Ado.birth", "Parli.F"))
human <- na.omit(human)
rownames(human) <- human$Country
human <- human[,-1]
rownames(human) # 7 last rows relate to regions rather than countries
human <- human[-c(156:162),] # remove those 7 rows

# save the modified data
write.table(human, file = "human.txt", sep = "\t")
