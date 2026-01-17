using Documenter
using JCGECore

makedocs(
    sitename = "JCGECore",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        assets = [
            "assets/deepwiki-chat.css",
            "assets/deepwiki-chat.js",
            "assets/logo-theme.js",
            "assets/logo.css",
        ],
    ),
    pages = [
        "Home" => "index.md",
        "Usage" => "usage.md",
        "API" => "api.md",
        "Citation" => "citation.md",
    ],
)

deploydocs(
    repo = "github.com/equicirco/JCGECore.jl.git",
    devbranch = "main",
    versions = ["stable" => "v^", "v#.#", "dev" => "dev"],
)
