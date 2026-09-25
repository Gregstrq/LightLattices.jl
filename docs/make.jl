using Documenter
using LightLattices

makedocs(
    sitename = "LightLattices.jl",
    format = Documenter.HTML(; prettyurls = true),
    modules = [LightLattices],
    authors = "Grigory Starkov",
    pages = ["Contents" => "index.md",
             "Manual" => [
                 "Basics" => "basics.md",
                 "Examples" => "examples.md",
                 "Physical Collections" => "physical_collections.md",
                 "Node Collections" => [
                     "Overview" => "node_collections.md",
                     "Examples" => "node_examples.md",
                 ],
             ],
             "Index" => "list.md"
            ]
)

deploydocs(
    repo = "github.com/Gregstrq/LightLattices.jl.git",
    devbranch = "main"
)
