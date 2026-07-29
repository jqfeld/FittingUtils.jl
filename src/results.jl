struct FitResult{F, X, P, R, W}
    model::F
    input::X
    params::P
    resid::R
    wt::W
end

Base.getindex(fr::FitResult, k::Symbol) = fr.params[k]

function _component_func(ps, func)
    type = typeof(ps).name.wrapper
    return type(; [k => func(ps[k]) for k in keys(ps)]...)
end



StatsAPI.coef(fr::FitResult) = _component_func(fr.params, Statistics.mean)
StatsAPI.coefnames(fr::FitResult) = keys(fr.params)
StatsAPI.stderror(fr::FitResult) = _component_func(fr.params, Statistics.std)

StatsAPI.nobs(fr::FitResult) = length(fr.resid)
StatsAPI.dof(fr::FitResult) = StatsAPI.nobs(fr) - length(StatsAPI.coef(fr))
StatsAPI.rss(fr::FitResult) = sum(abs2, fr.resid)
StatsAPI.weights(fr::FitResult) = fr.wt
StatsAPI.residuals(lfr::FitResult) = lfr.resid
mse(fr::FitResult) = StatsAPI.rss(fr) / StatsAPI.dof(fr)

Base.show(io::IO, fr::FitResult) =
    print(io, "FitResult(nobs=", StatsAPI.nobs(fr), ", coef=", StatsAPI.coef(fr), ")")
