using Documenter
using JCGECore

makedocs(
    sitename = "JCGECore",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        assets = [
            "assets/logo-theme.js",
            "assets/logo.css",
        ],
    ),
    pages = [
        "Home" => "index.md",
        "Usage" => "usage.md",
        "API" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/equicirco/JCGECore.jl.git",
    devbranch = "main",
    versions = ["stable" => "v^", "v#.#", "dev" => "dev"],
)
