using FittingUtils
using Documenter

DocMeta.setdocmeta!(FittingUtils, :DocTestSetup, :(using FittingUtils); recursive=true)

makedocs(;
    modules=[FittingUtils],
    authors="Jan Kuhfeld <jankuhfeld@plasma-matters.nl> and contributors",
    sitename="FittingUtils.jl",
    format=Documenter.HTML(;
        canonical="https://jqfeld.github.io/FittingUtils.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jqfeld/FittingUtils.jl",
    devbranch="main",
)
