using FittingUtils
using Test
using Aqua
using JET

@testset "FittingUtils.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(FittingUtils)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(FittingUtils; target_defined_modules = true)
    end
    # Write your tests here.
end
