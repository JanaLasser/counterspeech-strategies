library(pROC)
N <- 4000 # sample, both for measurement estimate and total estimation
R <- 0.2 # fraction of 1s in variable


# We simulate the regression problem

YRflip <- 200/1000 #fraction of flipped X values in Y (dependent variable)

Xtrue <- (runif(n=N, min=0, max=1)<R)
Yflip <- sample(c(rep(T,N*YRflip), rep(F, N*(1-YRflip))))
Y <- Xtrue
Y[Yflip] <- !Y[Yflip]

# Y contains DV and Xtrue contains the errorless measure of the IV
table(Xtrue,Y)


# Error level: probability of flipping each value of X, i.e. misclassification in ML model
Rflip <- 200/1000
Xmeasure <- Xtrue
flip <- sample(c(rep(T,N*Rflip), rep(F, N*(1-Rflip))))
Xmeasure[flip] <- !Xmeasure[flip]

# Using prediction probabilities based on noisy data
# Toy model: logistic regression of Y based on noisy measurement of X
# Training is done on the first half of the data, use is on the second
model <- glm(Xtrue[1:(N/2)]~Xmeasure[1:(N/2)], family="binomial")
ppreds <- predict(model, newdata=data.frame(Xmeasure=Xmeasure[(N/2+1):N]), type="response")

model1 <- glm(Y[(N/2+1):N] ~ Xtrue[(N/2+1):N], family="binomial")
summary(model1) # errorless estimate

model2 <- glm(Y[(N/2+1):N] ~ Xmeasure[(N/2+1):N], family="binomial")
summary(model2) # estimate with error but ignoring it

model3 <- glm(Y[(N/2+1):N] ~ ppreds, family="binomial")
summary(model3) # estimate with error but accounting for it
# coefficient should be closer to errorless estimate than the model ignoring error and se should be larger


df <- data.frame()
Rflip <- seq(50,450, by=10)/1000  #Probability of flipping a measurement of the binary predictor

for (iR in Rflip)
{
  flip <- sample(c(rep(T,N*iR), rep(F, N*(1-iR)))) #sample random flips with this iteration's prob
  Xmeasure <- Xtrue
  Xmeasure[flip] <- !Xmeasure[flip]
  model <- glm(Xtrue[1:(N/2)]~Xmeasure[1:(N/2)], family="binomial")
  # logistic regression model with first half of data

  flip <- sample(c(rep(T,N*iR), rep(F, N*(1-iR))))
  Xmeasure <- Xtrue
  Xmeasure[flip] <- !Xmeasure[flip]
  ppreds <- predict(model, newdata=data.frame(Xmeasure=Xmeasure[(N/2+1):N]), type="response")
  # estimation based on the second half of data
  
  model2 <- glm(Y[(N/2+1):N] ~ Xmeasure[(N/2+1):N], family="binomial")
  cimeasure <- confint(model2) # We calculate confidence intervals and are interested in the second coefficient
  model3 <- glm(Y[(N/2+1):N] ~ ppreds, family="binomial")  #ppreds is already for the second half
  cipreds <- confint(model3)
  
  AUC = roc(predictor=model$fitted.values, response=Xtrue[1:(N/2)])$auc # AUC of logistic regressior as more interpretable classifier quality
  df <- rbind(df, data.frame(AUC = AUC,  
                             error=iR,
                             estmeasure=coefficients(model2)[2],
                             estpred=coefficients(model3)[2],
                             lowmeasure=cimeasure[2,1],
                             lowpred=cipreds[2,1],
                             highmeasure=cimeasure[2,2],
                             highpred=cipreds[2,2]
                             ))  
}


# We take the range of high and low CI values for the plot
plot(df$AUC, df$estmeasure, ylim=range(c(df$lowmeasure,df$highmeasure,df$lowpred,df$highpred,coef(model1)[2])),
     xlab="predictor quality (AUC)", ylab="regression coefficient estimate")
abline(h=coef(model1)[2]) # we plot the errorless estimation and CI as horizontal lines
cimodel <- confint(model1)
abline(h=cimodel[2,1], col="gray")
abline(h=cimodel[2,2], col="gray")

points(df$AUC, df$estpred, col="red")

lines(df$AUC, df$lowmeasure)
lines(df$AUC, df$highmeasure)

lines(df$AUC, df$lowpred, col="red")
lines(df$AUC, df$highpred, col="red")




# We take the range of high and low CI values for the plot
plot(df$error, df$estmeasure, ylim=range(c(df$lowmeasure,df$highmeasure,df$lowpred,df$highpred,coef(model1)[2])),
     xlab="predictor error", ylab="regression coefficient estimate")
abline(h=coef(model1)[2]) # we plot the errorless estimation and CI as horizontal lines
cimodel <- confint(model1)
abline(h=cimodel[2,1], col="gray")
abline(h=cimodel[2,2], col="gray")

points(df$error, df$estpred, col="red")

lines(df$error, df$lowmeasure)
lines(df$error, df$highmeasure)

lines(df$error, df$lowpred, col="red")
lines(df$error, df$highpred, col="red")

lowAUC <- 0.73
highAUC <- 0.94

sels <- which(df$AUC>0.73)
pos <- sels[length(sels)]
df$AUC[pos]

abline(v=df$error[pos], lty=2)

sels <- which(df$AUC<0.94)
pos <- sels[1]
df$AUC[pos]
abline(v=df$error[pos], lty=2)

