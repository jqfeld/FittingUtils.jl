abstract type FitMethod end


struct TuringJL <: FitMethod end
dependency(::TuringJL) = "Turing"

struct LevenbergMarquardt <: FitMethod end
dependency(::LevenbergMarquardt) = "NonlinearSolve"
