# fit interface
fit_model(model, input, output, initial_params, method::M) where M <: FitMethod =
    error("fit_model not implemented for method $(typeof(method)). Try `using $(dependency(method))`.")

fit_model(model, input, output, output_uncertainty, initial_params, method::M) where M <: FitMethod =
    error("fit_model not implemented for method $(typeof(method)). Try `using $(dependency(method))`.")




