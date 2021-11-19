##### IODS RStudio Exercise 3 #####

# Date: 16.11.2021
# Author: Matilda Riskumäki
# Description: This Rscript includes the code for carrying out the data wrangling part
# for the IODS exercise 3.
# Data: https://archive.ics.uci.edu/ml/datasets/Student+Performance


# Working directory----
setwd("/Users/matirisk/Desktop/PhD-kurssit/2021_IODS/IODS-project/Data")

# Libraries----
library(dplyr)


### 1) Data wrangling----
# The data is imported in two separate .csv -files that will be merged later

##* Importing data----

math <- read.csv("student-mat.csv", sep = ";") # performance in mathematics
dim(math) # 395 observations of 33 variables
str(math)

port <- read.csv("student-por.csv", sep = ";") # performance in Portuguese language
dim(port) # 649 observations of 33 variables
str(port)


##* Merging the two data.frames----
# join the two data sets, but exclude variables "failures", "paid", "absences", "G1", "G2", "G3"
# keep only students present in both data sets

# define an ID for both data sets
port_id <- port %>% mutate(id=1000+row_number())
math_id <- math %>% mutate(id=2000+row_number())

# which columns vary in data sets
free_cols <- c("id","failures","paid","absences","G1","G2","G3")

# the rest of the columns are common identifiers used for joining the data sets
join_cols <- setdiff(colnames(port_id),free_cols)
portmath_free <- port_id %>% bind_rows(math_id) %>% select(one_of(free_cols))

# combine the data sets

portmath <- port_id %>% 
  bind_rows(math_id) %>%
  # Aggregate data (more joining variables than in the example)  
  group_by(.dots=join_cols) %>%  
  # Calculating required variables from two obs  
  summarise(                                                           
    n=n(),
    id.p=min(id),
    id.m=max(id),
    failures=round(mean(failures)),     #  Rounded mean for numerical
    paid=first(paid),                   #    and first for chars
    absences=round(mean(absences)),
    G1=round(mean(G1)),
    G2=round(mean(G2)),
    G3=round(mean(G3))    
  ) %>%
  # Remove lines that do not have exactly one obs from both datasets
  #   There must be exactly 2 observations found in order to joining be succesful
  #   In addition, 2 obs to be joined must be 1 from por and 1 from math
  #     (id:s differ more than max within one dataset (649 here))
  filter(n==2, id.m-id.p>650) %>%  
  # Join original free fields, because rounded means or first values may not be relevant
  inner_join(portmath_free,by=c("id.p"="id"),suffix=c("",".p")) %>%
  inner_join(portmath_free,by=c("id.m"="id"),suffix=c("",".m")) %>%
  # Calculate other required variables  
  ungroup %>% mutate(
    alc_use = (Dalc + Walc) / 2,
    high_use = alc_use > 2,
    cid=3000+row_number()
  )

dim(portmath) # 370 obs. of 51 variables
str(portmath) # tibble
# make the tibble into a data.frame 
portmath <- as.data.frame(portmath)


#* Save the joined and modified data

getwd() # check if your working directory is the 'Data' folder
write.table(portmath, file = "student-portmath.txt", sep = "\t")