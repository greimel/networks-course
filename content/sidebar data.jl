Dict(
    :main => [
        "welcome" => collections["welcome"].pages,
        "Preliminaries" => collections["julia-basics"].pages,
        "Networks basics" => collections["networks-basics"].pages,
        #"Diffusion on Networks" => collections["diffusion"].pages,
        "Financial networks" => collections["financial-networks"].pages,
    ],
    :about => Dict(
        :authors => [
            (name = "Fabian Greimel", url = "https://www.greimel.eu"),
            (name = "Simon Trimborn", url = "https://www.simontrimborn.de")
        ],
        :title => "Networks in Economics and Finance",
        :subtitle => "Theory, Computation and Data",
        :term => "Spring 2024",
        :institution => "University of Amsterdam",
        :institution_url => "http://www.uva.nl",
        :institution_logo => "uva-logo.svg",
        :institution_logo_darkmode => "uva-logo.svg"
    )
)