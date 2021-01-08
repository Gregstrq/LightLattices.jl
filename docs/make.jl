using Documenter
using LightLattices

makedocs(
    sitename = "LightLattices",
    format = Documenter.HTML(),
    modules = [LightLattices]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
