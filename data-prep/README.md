# Data preparation

Notebooks that build the datasets used on the course website. They are not part of the website.

- `movies-data.jl` downloads movies and their casts from the [TMDB API](https://developer.themoviedb.org/) and writes `movies/movies.csv`, `movies/actors.csv` and `movies/genres.csv`. Assignment 2 (`src/networks-basics/actors.jl`) reads `movies.csv` and `actors.csv`. Start Julia with the environment variable `TMDB_API_KEY` set to your API key.
