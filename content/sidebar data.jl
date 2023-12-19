Dict(
    :main => [
        "welcome" => collections["welcome"].pages,
        "Preliminaries" => collections["julia-basics"].pages,
        #"Module 2: Social Science & Data Science" => collections["module2"].pages,
        #"Module 3: Climate Science" => collections["module3"].pages,

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