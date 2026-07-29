module FittingUtilsNonlinearSolveExt
using FittingUtils, NonlinearSolve

using Distributions
using ComponentArrays

using FiniteDiff, ForwardDiff, LinearAlgebra

import FittingUtils: LevenbergMarquardtFit, fit_model, FitResult


regularization_term(d, x) = error("Regularization term not defined for prior distribution: $(typeof(d))")

regularization_term(d::Dirac, x) = zero(x)
regularization_term(d::Normal, x) = (x - d.μ) / d.σ
regularization_term(d::Uniform, x) = d.a <= x <= d.b ? zero(x) : one(x) * 1.0e30

function regularization_keys(params)
    ks = Vector{Symbol}()
    for (k, v) in zip(keys(params), params)
        if v isa Distribution
            push!(ks, k)
        end
    end
    return ks
end


safe_mean(x) = mean(x) |> y -> y == 0 ? 1 : y
safe_std(x) = std(x) |> y -> isnan(y) ? safe_mean(x) : y # if std returns NaN, use mean as scale

function scale(params, prior)
    μ = map(mean, prior)
    σ = map(safe_std, prior)
    p = map(mean, params)
    return (p - μ) ./ σ
end

function unscale(params, prior)
    μ = map(mean, prior)
    σ = map(safe_std, prior)
    p = map(mean, params)
    return p .* σ + μ
end

unscale_std(std, prior) = std .* map(safe_std, prior)

function create_nonlinear_problem(model, input, data, params)
    # Priors
    resid = if any(std.(data) .== 0.0) || any(isnan.(std.(data)))
        if any([p isa Distribution for p in params])
            @warn "No data uncertainty supplied, no priors are used for the parameters."
        end
        function (p, _)
            return data .- model(input, unscale(p, params))
        end
    else
        function (p, _)

            R = [
            (mean.(data) .- model(input, unscale(p, params))) ./ std.(data);
                [regularization_term(params[k], unscale(p, params)[k]) for k in regularization_keys(params)]
            ]
            return R
        end
    end

    prob = NonlinearLeastSquaresProblem(
        NonlinearFunction(resid),
        scale(params, params)
    )

    return prob
end


function fit_model(
    model, input, data, params, method::LevenbergMarquardtFit;
    disable_geodesic=Val(true), autodiff=AutoForwardDiff(), show_trace=Val(false),
    trace_level=TraceWithJacobianConditionNumber(), maxiters=1000,
    abstol=1.0e-6, reltol=1.0e-3, termination_condition=AbsNormSafeBestTerminationMode(Base.Fix2(norm, 2); patience_steps=10, max_stalled_steps=10)
)

    prob = create_nonlinear_problem(model, input, data, params)

    sol = solve(prob, LevenbergMarquardt(; disable_geodesic, autodiff); show_trace, abstol, reltol, termination_condition, trace_level, maxiters)

    LP = if any(std.(data) .== 0.) || any(isnan.(std.(data)))
        σ² = (sum(abs2, sol.resid) / (length(input) - length(sol.u)))
        function (θ) -sum(abs2, sol.prob.f(θ, [])) / 2 / σ² end
    else
        function(θ) -sum(abs2, sol.prob.f(θ, [])) / 2 end
    end

    H = ForwardDiff.hessian(p -> -LP(p), sol.u)
    if any(isnan, H)
        H = FiniteDiff.finite_difference_hessian(p -> -LP(p), sol.u)
    end

    std_fit = sqrt.(abs.(diag(pinv(H))))

    return FitResult(model, input, Normal.(unscale(sol.u, params), unscale_std(std_fit, params)), sol.resid, nothing)
end





end
