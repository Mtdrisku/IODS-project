#### IODS RStudio Exercise 2 #####


# Date: 8.11.2021
# Author: Matilda Riskumäki
# Description: This Rscript includes the code for carrying out the IODS exercise 
# for week 2. The script is divided into two sections according to the exercise:
# 1) Data wrangling and 2) Analysis.

# Working directory----
setwd("/Users/matirisk/Desktop/PhD-kurssit/2021_IODS/IODS-project/Data")

# Libraries----
library(dplyr)
library(ggplot2)
library(GGally)


### 1) Data wrangling----

#* Importing and exploring the data----

lrn14 <- read.table("http://www.helsinki.fi/~kvehkala/JYTmooc/JYTOPKYS3-data.txt",
                   sep = "\t", header = T)

dim(lrn14) # number of observations and variables in the data frame
names(lrn14) # name of each variable (column names)
str(lrn14) #structure of the data frame


#* Create an analysis dataset from the full data----

# The column "Attitude" is a sum of 10 questions related to the students attitude towards statistics.
# This combination variable will be scaled back to the 1-5 scale in a new column "attitude".
lrn14$attitude <- lrn14$Attitude / 10

# Combine variables that  measure the same dimension into one new variable
deep <- c("D03", "D11", "D19", "D27", "D07", "D14", "D22", "D30","D06",  "D15", "D23", "D31") # deep questions
surf <- c("SU02","SU10","SU18","SU26", "SU05","SU13","SU21","SU29","SU08","SU16","SU24","SU32") # surface questions
stra <- c("ST01","ST09","ST17","ST25","ST04","ST12","ST20","ST28") # strategic questions

# Create the columns by selecting them from the data and averaging the values (scaling the combination variables)
deep_cols <- select(lrn14, one_of(deep))
lrn14$deep <- rowMeans(deep_cols)

surf_cols <- select(lrn14, one_of(surf))
lrn14$surf <- rowMeans(surf_cols)

stra_cols <- select(lrn14, one_of(stra))
lrn14$stra <- rowMeans(stra_cols)

# In addition to the combined columns and "attitude", select columns "gender", "Age" and "attitude" for the analysis dataset
analysis_cols <- c("gender", "Age", "attitude", "deep", "stra", "surf", "Points")
learning2014 <- select(lrn14, one_of(analysis_cols))

# Rename the columns with upper case letters 
names(learning2014) # this helps you to check the correct column number
colnames(learning2014)[2] <- "age"
colnames(learning2014)[7] <- "points"

# Exclude observations where variable "points" is zero
learning2014 <- filter(learning2014, points > 0)
str(learning2014) # Final check: all colnames have lower case letters and there are 166 obs. and 7 variables


#* Save the modified dataset----

getwd() # check that the working directory is in IODS-project/Data
write.table(learning2014, file = "learning2014.txt", sep = "\t") # save the dataset as a .txt -file
check.dataset <- read.table("learning2014.txt", sep = "\t") # import the saved dataset to check if it's correct
str(check.dataset) # check the structure and data
str(learning2014) # looks good!



### 2) Analysis----
# This section is included in the full exercise report (find the report in the R Markdown file chapter2.Rmd).

#* Overview of the data----
pairs(learning2014[-1]) # leave out the categorical variable gender
ggpairs(learning2014, mapping = aes(col = gender, alpha = 0.5), 
        lower = list(combo = wrap("facethist", bins = 20)))

summary(learning2014)


#* Regression model----
# Choose three explanatory variables and fit a regression model where "points" is the dependent variable

M1 <- lm(points ~ 1 + attitude + stra + deep, data = learning2014)
summary(M1)

M2 <- lm(points ~ 1 + attitude, data = learning2014)
summary(M2)

AIC(M1, M2)

#* Model validation----
par(mfrow = c(2,2))
plot(M2, which = c(1,2,5)) # plots: residuals vs fitted values, QQ-plot and residuals vs leverage
