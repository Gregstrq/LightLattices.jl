using Documenter
using LightLattices

makedocs(
    sitename = "LightLattices.jl",
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [LightLattices],
    authors = "Grigory Starkov",
    pages = ["Contents" => "index.md",
             "Manual" => "manual.md",
             "Examples" => "examples.md",
             "Index" => "list.md"
            ]
)

deploydocs(
    repo = "github.com/Gregstrq/LightLattices.jl.git",
    devbranch = "main"
)
