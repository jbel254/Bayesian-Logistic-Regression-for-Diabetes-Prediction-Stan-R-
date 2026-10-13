# Bayesian Logistic Regression for Diabetes Prediction (Stan + R)

A multivariable Bayesian logistic regression that models the probability of a diabetes diagnosis from three predictors: number of pregnancies, plasma glucose and BMI. The model is written in [Stan](https://mc-stan.org/), fitted from R with `rstan`, and used to estimate the full posterior distribution of the risk for a specific individual.

## Overview

The question this project answers:

> What is the probability that a person has diabetes if they have had **2 pregnancies**, a **glucose level of 99** and a **BMI of 27.6**, and how uncertain is that estimate?

Rather than a single point estimate, the Bayesian approach gives a posterior distribution for that probability, which is plotted with a 95% credible interval.

## Model

For each observation *i*:

```
Outcome_i ~ Bernoulli(p_i)
logit(p_i) = b_0 + b_Pregnancies * Pregnancies_i + b_Glucose * Glucose_i + b_BMI * BMI_i
```

No explicit priors are specified, so Stan uses implicit flat priors on all coefficients. See [Possible improvements](#possible-improvements).

## Data

`diabetes.csv` is the Pima Indians Diabetes dataset (768 observations, available on [Kaggle](https://www.kaggle.com/datasets/uciml/pima-indians-diabetes-database)). Columns:

`Pregnancies, Glucose, BloodPressure, SkinThickness, Insulin, BMI, DiabetesPedigreeFunction, Age, Outcome`

Only `Pregnancies`, `Glucose` and `BMI` are used as predictors. `Outcome` is binary (1 = diabetes), and about 34.9% of the observations are positive.

## Repository structure

```
.
├── Multi_variable_linear_regression.R   # Main analysis script (data prep, fitting, diagnostics, plots)
├── diabetes.stan                        # Logistic regression model
├── pred_diabetes.stan                   # Same model + generated quantities for the prediction
├── diabetes.csv                         # Dataset
└── figures/
    ├── Diabetes_iter_1000.pdf           # Trace plots (convergence check)
    ├── plot_model_diabetes.pdf          # Posterior intervals for the coefficients
    ├── predicted_outcome.pdf            # Posterior density of the predicted probability
    └── ggplot_predicted_outcome.pdf     # Predicted risk compared with the overall diabetes rate
```

## Requirements

- R (4.0 or later recommended)
- A working C++ toolchain for Stan ([setup guide](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started))
- R packages:

```r
install.packages(c("rstan", "shinystan", "bayesplot", "ggplot2"))
```

## Usage

1. Clone the repository and open the project folder in R or RStudio:

   ```bash
   git clone https://github.com/<your-username>/<repo-name>.git
   cd <repo-name>
   ```

2. Set the working directory to the repo root so `diabetes.csv` and the `.stan` files are found:

   ```r
   setwd("path/to/repo")
   ```

3. Run `Multi_variable_linear_regression.R`. It will:
   - load and inspect the data,
   - fit a classical `glm` for comparison,
   - fit the Stan model (`diabetes.stan`) with 4 chains, 1000 iterations and 500 warmup,
   - check convergence with trace plots and ShinyStan,
   - plot the posterior estimates of the coefficients,
   - fit `pred_diabetes.stan` and extract the posterior predictive probability `p_hat`.

### Predicting for a different person

The covariate values are hard-coded in the `generated quantities` block of `pred_diabetes.stan`:

```stan
generated quantities {
  real p_hat;        // Predicted probability of Outcome = 1
  int Outcome_hat;   // Simulated binary outcome

  p_hat = inv_logit(b_0 + b_Pregnancies * 2 + b_Glucose * 99 + b_BMI * 27.6);
  Outcome_hat = bernoulli_rng(p_hat);
}
```

Change `2`, `99` and `27.6` to the values you want to predict for.

## Results

| Figure | What it shows |
|---|---|
| [Trace plots](figures/Diabetes_iter_1000.pdf) | The four chains for every coefficient mix well after warmup, which suggests convergence. |
| [Coefficient intervals](figures/plot_model_diabetes.pdf) | Posterior estimates and credible intervals for `b_0`, `b_Pregnancies`, `b_Glucose` and `b_BMI`. |
| [Predicted probability](figures/predicted_outcome.pdf) | Posterior density of `p_hat` with the median and 95% credible interval. |
| [Risk vs. baseline](figures/ggplot_predicted_outcome.pdf) | The same posterior compared with the overall diabetes rate in the dataset (red line). |

For the example person (2 pregnancies, glucose 99, BMI 27.6), the posterior probability of diabetes is concentrated at roughly 5 to 15%, well below the dataset's overall rate of about 35%.

## Possible improvements

- Add weakly informative priors (for example `normal(0, 2)` on the slopes) instead of relying on flat priors.
- Standardize `Glucose` and `BMI` to speed up sampling and make coefficients comparable.
- Add the remaining predictors (`Age`, `DiabetesPedigreeFunction`, etc.) and compare models with LOO cross-validation.
- Handle the zero values in `Glucose`, `BMI`, `BloodPressure`, `SkinThickness` and `Insulin`, which in this dataset usually represent missing measurements.
- Add a posterior predictive check and a curve of predicted risk across glucose values.

## Notes

This project is for learning and demonstration purposes only and is not a medical tool. The Pima dataset covers a specific population and should not be used for clinical decisions.

## License

Add a license of your choice (for example MIT) before publishing. The dataset has its own terms on Kaggle and the UCI repository.
