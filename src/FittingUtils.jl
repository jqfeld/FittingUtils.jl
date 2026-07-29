module FittingUtils

using Statistics
import StatsAPI
using ComponentArrays

include("method.jl")
export TuringJL, LevenbergMarquardt
include("results.jl")
export FitResult
include("fit_model.jl")
export fit_model

end
