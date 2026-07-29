abstract type FitMethod end


struct TuringFit <: FitMethod end
dependency(::TuringFit) = "Turing"

struct LevenbergMarquardtFit <: FitMethod end
dependency(::LevenbergMarquardtFit) = "NonlinearSolve"
