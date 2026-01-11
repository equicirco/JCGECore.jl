using Documenter
using JCGECore

makedocs(
    sitename = "JCGECore",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        assets = ["assets/jcge_core_logo_light.png", "assets/jcge_core_logo_dark.png"],
        logo = "assets/jcge_core_logo_light.png",
        logo_dark = "assets/jcge_core_logo_dark.png",
    ),
    pages = [
        "Home" => "index.md",
        "Usage" => "usage.md",
        "API" => "api.md",
    ],
)
