#MultiVariable Logistic Regression
#Load libraries
library(rstan)
library(shinystan)
library(bayesplot)
library(ggplot2)
#Download the data from Kaggle and store in WD
#Read in from working directory
data <- read.csv("diabetes.csv")
str(data)
sum(is.na(data))

#Select some variables
linear_model <- glm(Outcome ~ ., data = data, family = binomial)
summary(linear_model)

#Data design in Stan
#outcome = b0 + b1(pregnancy) + b2(glucose) + b3(BMI)
data_stan <- list(N = nrow(data), #number of observations
                  Outcome = data$Outcome, #Binary Response variable
                  Pregnancies = data$Pregnancies, #Variable 1
                  Glucose = data$Glucose, #variable 2
                  BMI = data$BMI)
################################################################################
#Run the model
model_diabetes <- stan(file = "diabetes.stan",
                       data = data_stan,
                       iter = 1000,
                       warmup = 500)
print(model_diabetes)
###############################################################################
#Check for the convergence
launch_shinystan(model_diabetes)
traceplot(model_diabetes, inc_warmup=FALSE)
################################################################################
#Posterior extraction of the best estimates
#Extract the estimate of the parameters that we are interested in
posterior <- extract(model_diabetes,
        inc_warmup = FALSE)
class(posterior)
plot(posterior$b_0, type = "l")
plot(model_diabetes)
################################################################################
#Prediction and forecasting 
#We want to test the probability that someone has diabetes if they had 
#2 pregnancies, Glucose levels of 99, and a BMI of 27.6
pred_model_diabetes <- stan(file = "pred_diabetes.stan",
     data = data_stan,
     iter = 1000,
     warmup = 500,
     chains = 4)
print(pred_model_diabetes)
quants <- apply(as.matrix(pred_model_diabetes),
      MARGIN = 2,
      FUN = quantile,
      probs = (1:100/100))

# Extract the posterior draws of the predicted probability
p_draws <- as.matrix(pred_model_diabetes, pars = "p_hat")

# Density with a shaded 95% credible interval and the median marked
mcmc_areas(p_draws, prob = 0.95, point_est = "median") +
  labs(title = "Posterior probability of diabetes",
       subtitle = "2 pregnancies, glucose 99, BMI 27.6",
       x = "P(Outcome = 1)")

##or ggplot
ggplot(data.frame(p = p_draws[, 1]), aes(p)) +
  geom_density(fill = "steelblue", alpha = 0.5) +
  geom_vline(xintercept = median(p_draws), linewidth = 1) +
  geom_vline(xintercept = quantile(p_draws, c(0.025, 0.975)), linetype = "dashed") +
  geom_vline(xintercept = mean(data$Outcome), colour = "red") +  # baseline rate
  labs(x = "P(Outcome = 1)", y = "Posterior density",
       title = "Predicted risk vs. overall diabetes rate (red)")