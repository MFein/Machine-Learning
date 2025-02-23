require(tidyverse)
require(glmnet)
require(ISLR)
require(MASS)


# Import data with strings as factors
data.all <- read.csv("bigml_59c28831336c6604c800002a.csv")
#clean data for analysis by removing uninformative attributes (phone number and state)
data.cl <- data.all[ , -c(1:4)]


##EDA
#uninterpretable
pairs(data.cl, col= data.cl$churn)

#zoom in
pairs(data.cl[ , - c(1:2,17)], col = data.cl$churn)

#High multicollinearity between minutes and charges- removed minutes and kept charges
data.cl <- data.cl[ , -c(4,7,10,13)]


#log.all <- glm(churn~.-churn, data = data.cl, family = binomial)

#summary(log.all)
#coef(log.all)
#summary(log.all)$coef

#predicted churn with full dataset
#glm.probs=predict(log.all,type="response")

#glm.pred=ifelse(glm.probs<0.5,"False", "True")
#glm.pred[glm.probs<.5]="False"
#attach(data.cl)
#table(glm.pred,churn)

train <- data.cl[1:2222, ]
test <- data.cl[2223:3333, ]



#UTILIZE LASSO for feature selection

lasso.x = model.matrix(glm(churn~.-churn, data = train, family = binomial))[,-1]
lasso.x2 = model.matrix(glm(churn~.-churn, data = test, family = binomial))[,-1]
y.train = as.integer(train$churn)
y.test <- as.integer(test$churn)

lasso.mod=glmnet(lasso.x,y.train,alpha=1)
plot(lasso.mod)

cv.out=cv.glmnet(lasso.x,y.train,alpha=1)
plot(cv.out)
bestlam=cv.out$lambda.min
lasso.pred=predict(lasso.mod,s=bestlam,newx=lasso.x2)
mean((lasso.pred-y.test)^2)
out=glmnet(lasso.x,lasso.y,alpha=1)
lasso.coef=predict(out,type="coefficients",s=bestlam)
lasso.coef
lasso.coef[lasso.coef!=0]
# all attributes other than number of voice mails are useful for the current model



#evaluation
lasso.pred=ifelse(glm.probs.test<0.8,"False", "True")
glm.pred.test[glm.probs.test<.8]="False"
attach(test)
table(lasso.pred,churn)
accuracy <- (931+10)/1111
print(accuracy)



# The LASSO itself is accurate 85% of the time.

##Use LASSO feauter selection to run simple logistic model

log.train <- glm(churn~.-voice.mail.plan, data = train, family = binomial)

glm.probs.train=predict(log.train,type="response")

glm.pred.train=ifelse(glm.probs.train<0.8,"False", "True")
glm.pred.train[glm.probs<.8]="False"
attach(train)
table(glm.pred.train,churn)
accuracy <- (1916+8)/2222
print(accuracy)
detach(train)

log.test <- glm(churn~.-churn, data = test, family = binomial)

glm.probs.test=predict(log.test,type="response")

glm.pred.test=ifelse(glm.probs.test<0.8,"False", "True")
glm.pred.test[glm.probs.test<.8]="False"
attach(test)
table(glm.pred.test,churn)
accuracy <- (931+10)/1111
print(accuracy)

##Logistic model with threshold of 0.8 yields ~85-86% accuracy


coef(log.all)
summary(log.test)
##Day time charges, evening charges and # of customer service calls are most sig