module FittingUtils

using Statistics
import StatsAPI
using ComponentArrays

import ForwardDiff, FiniteDiff
import Distributions
using EmpiricalDistributions

include("method.jl")
export TuringFit, LevenbergMarquardtFit

include("results.jl")
export FitResult
using StatsAPI: coef, coefnames, stderror, nobs, dof, rss, weights, residuals
export coef, coefnames, stderror, nobs, dof, rss, weights, residuals, mse

include("fit_model.jl")
export fit_model


end
