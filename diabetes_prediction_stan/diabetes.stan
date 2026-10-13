
// The input data is a vector 'y' of length 'N'.
data {
  int<lower=1> N; //The number of the observation
  array[N] int<lower=0, upper=1> Outcome; //Binary outcome as a response variable
  vector[N] Pregnancies; //The Variable 1
  vector[N] Glucose; // The variable 2
  vector[N] BMI; //The variable 3
  
}
parameters {
  real b_0; //The intercept
  real b_Pregnancies; // The slope for the Pregnancies
  real b_Glucose; //The slope for the Glucose levels
  real b_BMI; //The slope for the BMI
}

model {
  Outcome ~ bernoulli_logit(b_0 + b_Pregnancies*(Pregnancies)+b_Glucose*(Glucose)+b_BMI*(BMI)); //The likelihood
}

