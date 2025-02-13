setwd("~/Desktop/MSiA 420/speed-dating-project")
data <- read.csv("Speed Dating Data.csv")
library(caret)

# check NA
na_rate <- rep(1, dim(data)[2])
# drop the variables that end with _3 
for (i in 1:156){
  na_rate[i] <- sum(is.na(data[,i]))/nrow(data)
}
na_columns <- colnames(data)[na_rate > 0.5]

library(dplyr)
data <- data %>% 
  select(-na_columns)

data$gender <- as.factor(data$gender)
data$career_c <- as.factor(data$career_c)
data$samerace <- as.factor(data$samerace)
data$race <- as.factor(data$race)
data$dec <- as.factor(data$dec)
data$date <- as.factor(data$date)


# scale the ratings
data <- data %>% 
  mutate(pf_sum_o = pf_o_att + pf_o_sin + pf_o_int + pf_o_fun + pf_o_amb + pf_o_sha,
         sum_o = attr_o + sinc_o + intel_o + fun_o + amb_o + shar_o,
         sum1_1 = attr1_1 + sinc1_1 + intel1_1 + fun1_1 + amb1_1 + shar1_1,
         sum4_1 = attr4_1 + sinc4_1 + intel4_1 + fun4_1 + amb4_1 + shar4_1,
         sum2_1 = attr2_1 + sinc2_1 + intel2_1 + fun2_1 + amb2_1 + shar2_1,
         sum3_1 = attr3_1 + sinc3_1 + intel3_1 + fun3_1 + amb3_1,
         sum5_1 = attr5_1 + sinc5_1 + intel5_1 + fun5_1 + amb5_1,
         sum1_2 = attr1_2 + sinc1_2 + intel1_2 + fun1_2 + amb1_2 + shar1_2,
         sum4_2 = attr4_2 + sinc4_2 + intel4_2 + fun4_2 + amb4_2 + shar4_2,
         sum2_2 = attr2_2 + sinc2_2 + intel2_2 + fun2_2 + amb2_2 + shar2_2,
         sum3_2 = attr3_2 + sinc3_2 + intel3_2 + fun3_2 + amb3_2,
         sum5_2 = attr5_2 + sinc5_2 + intel5_2 + fun5_2 + amb5_2) %>% 
  mutate_at(c("pf_o_att", "pf_o_sin", "pf_o_int", "pf_o_fun", "pf_o_amb", "pf_o_sha"), 
            funs(./pf_sum_o*100)) %>% 
  mutate_at(c("attr_o", "sinc_o", "intel_o", "fun_o", "amb_o", "shar_o"), 
            funs(./sum_o*100)) %>% 
  mutate_at(c("attr1_1", "sinc1_1", "intel1_1", "fun1_1", "amb1_1", "shar1_1"), 
            funs(./sum1_1*100)) %>% 
  mutate_at(c("attr4_1", "sinc4_1", "intel4_1", "fun4_1", "amb4_1", "shar4_1"), 
            funs(./sum4_1*100)) %>% 
  mutate_at(c("attr2_1", "sinc2_1", "intel2_1", "fun2_1", "amb2_1", "shar2_1"), 
            funs(./sum2_1*100)) %>%
  mutate_at(c("attr3_1", "sinc3_1", "fun3_1", "intel3_1", "amb3_1"), 
            funs(./sum3_1*100)) %>%
  mutate_at(c("attr5_1", "sinc5_1", "fun5_1", "intel5_1", "amb5_1"), 
            funs(./sum5_1*100)) %>%
  mutate_at(c("attr1_2", "sinc1_2", "intel1_2", "fun1_2", "amb1_2", "shar1_2"), 
            funs(./sum1_2*100)) %>%
  mutate_at(c("attr4_2", "sinc4_2", "intel4_2", "fun4_2", "amb4_2", "shar4_2"), 
            funs(./sum4_2*100)) %>%
  mutate_at(c("attr2_2", "sinc2_2", "intel2_2", "fun2_2", "amb2_2", "shar2_2"), 
            funs(./sum2_2*100)) %>%
  mutate_at(c("attr3_2", "sinc3_2", "intel3_2", "fun3_2", "amb3_2"), 
            funs(./sum3_2*100)) %>%
  mutate_at(c("attr5_2", "sinc5_2", "intel5_2", "fun5_2", "amb5_2"), 
            funs(./sum5_2*100)) %>%
  select(-c("pf_sum_o", "sum_o", "sum1_1", "sum4_1", "sum2_1", "sum3_1", 
            "sum5_1", "sum1_2", "sum4_2", "sum2_2", "sum3_2", "sum5_2"))

library(ggplot2)
# career distribution plot
career_label <- c("Lawyer", "Academic/Research", "Psychologist",  
                  "Doctor/Medicine", "Engineer", "Creative Arts/Entertainment", 
                  "Banking/Business", "Real Estate", "International Affairs", 
                  "Undecided", "Social Work", "Speech Pathology", "Politics", 
                  "Sports/Athletics", "Other", "Journalism", "Architecture")

data %>% 
  filter(!is.na(career_c)) %>% 
  select(iid, gender, career_c) %>% 
  unique(by = iid) %>% 
  ggplot() +
  geom_bar(aes(career_c, fill=gender)) + 
  scale_x_discrete(label = career_label) + coord_flip() + 
  labs(title = "Distribution of Career Fields", x = "Career Field", y = "Count") + 
  scale_fill_manual(values=c(rgb(0.7, 0.3, 0.5, 0.4), rgb(0.2, 0.5, 0.8, 0.4)), 
                    "Gender", labels = c("Female", "Male")) +  theme_light()


# age distribution plot
temp_age <- data %>% 
  filter(!is.na(age)) %>% 
  filter(age < max(age)) %>% 
  select(iid, gender, age) %>% 
  unique(by = iid) 

ggplot(data = temp_age, aes(x = age,fill = gender)) + coord_flip() + 
  geom_histogram(data = subset(temp_age, gender == "0"), binwidth = 2, color = "white") +  
  geom_histogram(data = subset(temp_age, gender == "1"), 
                 aes(y = ..count.. * (-1)), binwidth = 2, color = "white") + 
  scale_y_continuous(breaks = seq(-70, 70, 10), labels = abs(seq(-70, 70, 10)))+ 
  scale_x_continuous(breaks = seq(10, 45, 5), labels = seq(10, 45,5)) + 
  labs(title = "Distribution of Age", x = "Age", y = "Count") + 
  scale_fill_manual(values=c(rgb(0.7, 0.3, 0.5, 0.4), rgb(0.2, 0.5, 0.8, 0.4)), 
                    "Gender", labels = c("Female", "Male")) +  theme_light()


# race distribution plot
race_label <- c("Black/African American", "European/Caucasian American", 
                "Latino/Hispanic American", "Asian/Asian American", 
                "Naitive American", "Other")

data %>% 
  filter(!is.na(race)) %>% 
  select(iid, gender, race) %>% 
  unique(by = iid) %>% 
  ggplot() + 
  geom_bar(aes(x = gender, fill = race), position = "fill") + 
  labs(title = "Distribution of Race", x = "Gender", y = "Relative Frequency") +
  scale_fill_brewer(palette="Set3", name="Race", labels = race_label) + 
  scale_x_discrete(labels=c("0" = "Male", "1" = "Female")) + theme_light() 


hist(data$match)


library(fmsb)
# what do you look for in the opposite sex
test1 <- data %>% 
  filter(!is.na(attr1_1 + sinc1_1 + intel1_1 + fun1_1 + amb1_1 + shar1_1)) %>% 
  select(iid, gender, attr1_1:shar1_1) %>% 
  unique(by = idd) %>% 
  group_by(gender) %>% 
  summarise(Attractive = mean(attr1_1), Sincere = mean(sinc1_1), 
            Intelligent = mean(intel1_1), Fun = mean(fun1_1), 
            Ambitious = mean(amb1_1), Interest = mean(shar1_1))

test1forplot <- test1 %>% 
  select(-gender)

maxmin <- data.frame(
  Attractive = c(36, 0),
  Sincere = c(36, 0),
  Intelligent = c(36, 0),
  Fun = c(36, 0),
  Ambitious = c(36, 0),
  Interest = c(36, 0))

test11 <- rbind(maxmin, test1forplot)

test11male <- test11[c(1,2,4),]
test11female <- test11[c(1,2,3),]

radarchart(test11,
           pty = 32,
           axistype = 0,
           pcol = c(rgb(0.7, 0.3, 0.5, 0.4), rgb(0.2, 0.5, 0.8, 0.4)),
           pfcol = c(rgb(0.7, 0.3, 0.5, 0.4), rgb(0.2, 0.5, 0.8, 0.4)),
           plty = 1,
           plwd = 3,
           cglty = 1,
           cglcol = "gray88",
           centerzero = TRUE,
           seg = 5,
           vlcex = 0.75,
           palcex = 0.75,
           title = "What do people look for in the opposite sex?")
legend(x = 1, y = 1.2, legend = c("Female", "Male"),
       bty = "n", pch = 20 , col = c(rgb(0.7, 0.3, 0.5, 0.4), rgb(0.2, 0.5, 0.8, 0.4)), 
       text.col = "black", cex = 0.8, pt.cex = 2)



## Decision Tree
# drop 3 or s
data <- data[, !grepl(".*_[3s]$",colnames(data))]

# drop columns with >50% null values
t = data.frame(colSums(is.na(data))/nrow(data))
colnames(t)=c("nullrate")
t <- t %>% subset(nullrate<0.5)
data <- data[,rownames(t)]

# other
data <- data[, colnames(data)!='match_es']
data <- data[, colnames(data)!='pid']
data <- data[, colnames(data)!='dec_o']
data <- data[, colnames(data)!='dec']
data <- data[, colnames(data)!='like_o']
data <- data[, colnames(data)!='like']
data <- data[, colnames(data)!='partner']
# data <- data[, colnames(data)!='attr_o']
# data <- data[, colnames(data)!='attr']


data$income <- as.numeric(data$income)
data$tuition <- as.numeric(data$tuition)
data <- data[, !(colnames(data) %in% c('zipcode','from','career','field','undergra','mn_sat','attr5_2'
                                       ,'attr5_1'))]


# fit inital model by cv
library(rpart)
set.seed(420)
control <- rpart.control(minbucket = 5, cp = 0.001, maxsurrogate = 0, usesurrogate = 0, xval = 10)
date.tr <- rpart(match ~.,data, method = "class", control = control) 
plotcp(date.tr) #plot of CV r^2 vs. size


date.tr1 <- prune(date.tr, cp=0.011)
date.tr1$variable.importance


# data preprocessing
selected = colnames(data) %in%
  c("fun", "prob_o", "prob", "attr", "shar", "fun_o", "attr_o", "intel_o", "pf_o_int", "match")
dataNN = data[,selected]
dataNN[,1] = as.factor(dataNN[,1])
dataNN[, -1] <- sapply(dataNN[,-1], function(x) 
  (x-min(x, na.rm = TRUE))/(max(x, na.rm=TRUE) - min(x, na.rm = TRUE)))
data_clean <- dataNN %>% 
  mutate_at(vars(colnames(dataNN[-1])), ~ifelse(is.na(.), median(., na.rm = TRUE), .))
write.csv(data_clean, '~/Desktop/MSiA 420/speed-dating-project/data_clean.csv')





#=======================   end of data cleaning   ========================
  
  
  ## Logistic regression

hist(data_clean$attr)
hist(data_clean$attr_o)
hist(data_clean$fun_o)
hist(data_clean$fun)
hist(data_clean$prob)
table(data_clean$match)


logistic1 <- glm(match ~., data=data_clean, family = 'binomial')
summary(logistic1)

library(car)
vif(logistic1) # no multicollinearity

# cv function
CVInd <- function(n,K) {  # n is sample size; K is number of parts; returns K-length list of 
  # indices for each part   
  m <- floor(n/K)  #approximate size of each part   
  r <-n - m*K     
  I <- sample(n,n)  #random reordering of the indices   
  Ind <- list()  #will be list of indices for all K parts   
  length(Ind) <- K   
  for (k in 1:K) {      
    if (k <= r) kpart <- ((m+1)*(k-1)+1):((m+1)*k)           
    else kpart <- ((m+1)*r+m*(k-r-1)+1):((m+1)*r+m*(k-r))      
    Ind[[k]] <- I[kpart]  #indices for kth part of data   
  }   
  Ind
}

# misclass rate (return the best rate threshold)
misclass <- function(rate = seq(0,1,0.01), true_class, predicted_value) {
  misclass_ratio <- c()
  model_class <- c()
  result_table <- data.frame()
  for (i in rate) {
    predicted_class <- as.character(ifelse(predicted_value > i, 1, 0))
    model_class <- c(model_class, predicted_class)
    temp <- mean(predicted_class != as.character(true_class))
    misclass_ratio <- c(misclass_ratio, temp)
  }
  # index <- which(misclass_ratio == min(misclass_ratio))
  return(c(min(misclass_ratio), rate[which(misclass_ratio == min(misclass_ratio))]))
}

K <- 5  # K-fold CV on each replicate
n <- nrow(data_clean)
Ind <- CVInd(n, K)
y <- data_clean$match

yhat <- as.numeric(y)
yhat_class <- as.character(y)
misclassCV <- c()

set.seed(2020)
for (k in 1:K) {  
  out <- glm(match ~., family = 'binomial', data = data_clean[-Ind[[k]],])
  yhat[Ind[[k]]] <- predict(out, newdata = data_clean[Ind[[k]],-1], 
                            type = 'response')
  temp <- misclass(true_class = y[Ind[[k]]], predicted_value = yhat[Ind[[k]]])
  mc <- temp[1]
  threshold <- temp[2]
  yhat_class[Ind[[k]]] <- as.character(ifelse(yhat[Ind[[k]]] > threshold, 1, 0))
  misclassCV <- c(misclassCV, mc)
}
misclass_logistic <- mean(misclassCV)
misclass_logistic  # 0.1471695
confusionMatrix(as.factor(yhat_class), y)


## Ridge
selected_ridge <- c('match','fun','prob_o','attr','attr_o','fun_o','prob','shar','amb_o',
                    'shar_o','age_o','sinc_o','intel_o','pf_o_int','tuition',
                    'attr2_2','attr3_1','shopping','fun1_1','sinc4_1','sinc2_2','pf_o_fun', 
                    'income','fun3_2','sinc5_1','sinc','theater','pf_o_sin','pf_o_amb','intel1_1')
data_ridge = data[, selected_ridge]
data_ridge[,1] = as.factor(data_ridge[,1])
data_ridge[, -1] <- sapply(data_ridge[,-1], function(x) 
  (x-min(x, na.rm = TRUE))/(max(x, na.rm=TRUE) - min(x, na.rm = TRUE)))
data_ridge <- data_ridge %>% 
  mutate_at(vars(colnames(data_ridge[-1])), ~ifelse(is.na(.), median(., na.rm = TRUE), .))

library(glmnet)
x <- model.matrix(match~., data_ridge)[,-1]
y <- data_ridge$match
cv.ridge <- cv.glmnet(x, y, alpha = 0, family = "binomial")
ridge1 <- glmnet(x, y, alpha = 0, family = "binomial",
                 lambda = cv.ridge$lambda.min)
cv.ridge$lambda.min
coef(ridge1)

K <- 5  # K-fold CV on each replicate
n <- nrow(data_clean)
Ind <- CVInd(n, K)

yhat <- as.numeric(y)
misclassCV <- c()

set.seed(2020)
for (k in 1:K) {  
  out <- glmnet(x[-Ind[[k]],], y[-Ind[[k]]], alpha = 0, family = "binomial",
                lambda = cv.ridge$lambda.min)
  yhat[Ind[[k]]] <- predict(out, newx = x[Ind[[k]],], type = 'response')
  temp <- misclass(true_class = y[Ind[[k]]], predicted_value = yhat[Ind[[k]]])
  misclassCV <- c(misclassCV, temp)
}
misclass_ridge <- mean(misclassCV)
misclass_ridge  # 0.1466937


