module FittingUtilsTuringExt

using FittingUtils, Turing
import FittingUtils: TuringFit, fit_model, FitResult, _component_func

using ComponentArrays
using Distributions
using Statistics
using LinearAlgebra
using StatsBase, EmpiricalDistributions

# Fitting spectra with unknown uncertainties

@model function create_turing_model(model, input, data::AbstractArray{S}, priors) where {S<:Distribution}

    # Priors
    params ~ product_distribution(priors)


    # Likelihood
    μ = model(input, ComponentVector(params, getaxes(priors)))


    joint_distribution = product_distribution(data)
    Turing.@addlogprob! logpdf(joint_distribution, μ)


end

function fit_model(
    model, input, data, params, method::TuringFit;
    sampler=NUTS(), num_samples=1000, num_chains=1, progress=true
)

    posterior = create_turing_model(model, input, data, params)
    parallel = num_chains == 1 ? MCMCSerial() : MCMCThreads()
    chain = sample(posterior, sampler, parallel, num_samples, num_chains; progress)

    # @infiltrate

    ps = ComponentVector([UvBinnedDist(fit(Histogram, vec(getindex.(chain[:params], i)))) for i in eachindex(params)], getaxes(params))
    return FitResult(
        model,
        input,
        ps,
        model(input, mean.(ps)) - mean.(data),
        # model(input, _component_func(ps, mean)) - data,
        nothing
    )
end




end
