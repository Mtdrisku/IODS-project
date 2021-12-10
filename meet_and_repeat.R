#### IODS RStudio Exercise 6 #####


# Date: 9.12.2021
# Author: Matilda Riskumäki
# Description: This Rscript includes the code for carrying out the IODS exercise 
# data wrangling part for week 6.

# Working directory----
setwd("/Users/matirisk/Desktop/PhD-kurssit/2021_IODS/IODS-project/Data")

# Libraries----
library(dplyr)
library(tidyr)

#### Week 4 ####
# Importing and exploring the data----
bprs <- read.table("https://raw.githubusercontent.com/KimmoVehkalahti/MABS/master/Examples/data/BPRS.txt",
                   sep = "", header = T)
rats <- read.table("https://raw.githubusercontent.com/KimmoVehkalahti/MABS/master/Examples/data/rats.txt",
                   sep = "\t", header = T)

names(bprs)
names(rats)
str(bprs)
str(rats)


#* Modify the data----
# convert categorical variables to factors
bprs[,2] <- as.factor(bprs[,2]) # convert columns 1 and 2)
rats[,2] <- as.factor(rats[,2]) # convert columns 1 and 2

# change the data sets from wide to long form
bprs_long <- bprs %>% gather(key = weeks, value = bprs, -treatment, -subject) 
rats_long <- rats %>% gather(key = wd, value = weight, -ID, -Group) 

# add a week variable to the bprs_long and a time variable to rats
bprs_long <- bprs_long %>% mutate(week = as.integer(substr(weeks,5,5)))
rats_long <- rats_long %>% mutate(time = as.integer(substr(wd,3,4)))

# explore the data sets
dim(bprs)
dim(bprs_long)
names(bprs)
names(bprs_long)
str(bprs_long)
# instead of having the weeks (week0 - week8) in different columns, they are under one column named "week"
# and the corresponding values are in column "bprs"
dim(rats)
dim(rats_long)
names(rats)
names(rats_long)
str(rats_long)
# instead of having WDs in different columns they are under one column named "wd" and the 
# corresponding values are in column "weight".

#* Save the data sets in the Data folder----
write.table(bprs, "bprs.txt", sep = "\t")
write.table(bprs_long, "bprs_long.txt", sep = "\t")
write.table(rats, "rats.txt", sep = "\t")
write.table(rats_long, "rats_long.txt", sep = "\t")
