### A Pluto.jl notebook ###
# v0.12.19

using Markdown
using InteractiveUtils

# ╔═╡ 400cc04e-4784-11eb-11a2-ff8e245cad27
let
	import Pkg
	Pkg.activate(temp = true)
	Pkg.add(["PyCall", "Conda", "PlutoUI", "CSV", "LightGraphs", "DataFrames", "GraphPlot", "CategoricalArrays", "GraphDataFrameBridge", "FreqTables"])
	
	using PlutoUI: TableOfContents, with_terminal
	import CSV
	using DataFrames: DataFrame, groupby, select, select!, combine, transform, transform!, ByRow
	using CategoricalArrays: categorical
	using LightGraphs
	using GraphPlot
	using GraphDataFrameBridge
	using FreqTables
	
	import PyCall
end

# ╔═╡ b201cb56-60e3-11eb-302c-4180510aacf8
md"""
# Getting twitter data with `twint`
"""

# ╔═╡ 5a75f01a-60dc-11eb-3bd1-6f68e4edcd20
file_name = joinpath(".", "twitter-data.csv")

# ╔═╡ e4dcc0a6-60e3-11eb-2717-5347187c73c0
md"""
First we specify what data we want to have.
"""

# ╔═╡ 85838053-8aa3-4e56-ae9d-17293937fe4f
c = let
	# Configure
	c = twint.Config()
	c.Search = "#econtwitter"
	#c.Lang = "dutch"
	#c.Geo = "52.377956,4.897070,5km"
	c.Limit = 500
	c.Output = file_name
	c.Store_csv = true
	c.Min_likes = 2
	c
end

# ╔═╡ fb0aabb5-72ea-48a9-ac83-ebd593d4a2e5
begin
	_x_ = 1
	rm(file_name)
	twint.run.Search(c)
end

# ╔═╡ 04e5ec1a-60e4-11eb-0d45-fd8291a674f9
md"""
# A first glance at the data
"""

# ╔═╡ 14e6dece-60dc-11eb-2d5a-275b8c9e382d
begin
	_x_
	df0 = CSV.File(file_name) |> DataFrame
end

# ╔═╡ 1635940c-60e4-11eb-1b33-5b8faaf933d8
names(df0)

# ╔═╡ f998e4fc-60e3-11eb-0533-1717bea29668
md"""
# Making a network
"""

# ╔═╡ 46021976-60e4-11eb-3797-33b6ff7755d4
md"""
There is more than one way to define a network using this data. One way is to define twitter users to be connected if they use common hashtags in their tweets. Let's ceate such a network.
"""

# ╔═╡ 87f77baa-60e4-11eb-24e2-019e317451f6
md"First select some interesting variables."

# ╔═╡ 97337aec-60e4-11eb-0b15-99ffcf8376fa
md"Then aggregate the list of hashtags for each user."

# ╔═╡ edc6da66-60e4-11eb-1aeb-fb9dbb7ccc88
md"Create a list of edges."

# ╔═╡ 01e4ac58-60e5-11eb-39f3-b5f613ecee35
md"Create the graph."

# ╔═╡ 0b70f90c-60e5-11eb-18da-25e3302a74a8
md"""
# Analyzing the network
"""

# ╔═╡ 4df1e8ae-60ef-11eb-3772-1154f708eecb
md"""
## Highlighting some nodes
"""

# ╔═╡ eea5accc-60db-11eb-3889-c992db2ec8ec
md"""
# Appendix
"""

# ╔═╡ e5a741e8-60dc-11eb-317e-cfdd650ae5f0
TableOfContents()

# ╔═╡ 87b7bc86-60df-11eb-3f9f-2375449c77f6
Base.show(io::IO, ::MIME"text/html", x::CategoricalArrays.CategoricalValue) = print(io, get(x))

# ╔═╡ a1d99d9e-60dc-11eb-391c-b52c2e16aedd
md"""
## Install Python package `twint`
"""

# ╔═╡ 28060fda-60db-11eb-3ba8-b36b75523ed6
twint_installed = let
	util = PyCall.pyimport("importlib.util")
	twint_installed = !isnothing(util.find_spec("twint"))
end

# ╔═╡ a50aa4e4-4785-11eb-1b16-739b802ea3cc
# installing and using Python package "twint" for scraping twitter data
begin
	if !twint_installed
		import Conda
		# install twint from github repo
		run(`$(Conda._pip(Conda.ROOTENV)) install --user --upgrade -e "git+https://github.com/twintproject/twint.git@origin/master#egg=twint"`)
	end
end

# ╔═╡ e072a5e8-4785-11eb-0edd-f1c514f46480
PyCall.@pyimport twint as twint

# ╔═╡ 1f927f3c-60e5-11eb-0304-f1639b68468d
md"""
## Useful functions
"""

# ╔═╡ 620c76e4-60de-11eb-2c82-d364f55fbe4d
function parse_hashtags(hashtags)
	# start from "['r', 'julialang', 'programming']"
	str = replace(hashtags, "'" => '"')
	# get """["r", "julialang", "programming"]"""::String
	vec_of_strings = eval(Meta.parse(str))
	# get ["r", "julialang", "programming"]::Vector{String}
	
	vec_of_strings
end

# ╔═╡ 5401181c-60dd-11eb-0844-9b4b7b35693c
df = select(df0, :hashtags => ByRow(parse_hashtags),
				 # "parse_hashtags" is defined in the appendix
	   		     :user_id,
				 :username => categorical,
				 :language => categorical,
			renamecols = false)

# ╔═╡ 9d5c72ca-60df-11eb-262d-6f0803d386f5
df2 = combine(
		groupby(df, :username), # group the data by user. Each group consists of all tweets of one user
		:hashtags => ∪ # for each group, take the union (∪) of hashtags
		)

# ╔═╡ 241b8206-60e0-11eb-08bd-f748c90e49c7
begin
	edge_list = DataFrame(user1 = String[], user2 = String[], common_hashtags = Int[])

	for (i, (user₁, hashtags₁)) in enumerate(eachrow(df2))
		for (user₂, hashtags₂) in eachrow(df2[i+1:end,:])
			
			common = hashtags₁ ∩ hashtags₂

			if length(common) > 1
				push!(edge_list, [user₁, user₂, length(common)])
			end
		end
	end
	
	edge_list
end

# ╔═╡ 15ecf0aa-60e2-11eb-1ef4-ebfc215e5ca7
graph = MetaGraph(edge_list, :user1, :user2, weight = :common_hashtags)

# ╔═╡ 5dacc3c2-60e2-11eb-1352-0ddbe3405aec
gplot(graph, nodesize=0.1, NODESIZE=0.025)

# ╔═╡ 635a3b24-60ef-11eb-0d2f-51dbfbd705a1
get_props.(graph, :name, vertices(graph))

# ╔═╡ 5ceea932-60ef-11eb-3c13-37ddf8e09f6f
let
	all_hashtags = vcat(df.hashtags...)
	freqs = freqtable(all_hashtags)
	
	df_hashtags = DataFrame(hashtag = names(freqs)[1], freqs = freqs)
	sort!(df_hashtags, :freqs, rev = true)
end

# ╔═╡ Cell order:
# ╟─b201cb56-60e3-11eb-302c-4180510aacf8
# ╠═5a75f01a-60dc-11eb-3bd1-6f68e4edcd20
# ╟─e4dcc0a6-60e3-11eb-2717-5347187c73c0
# ╠═85838053-8aa3-4e56-ae9d-17293937fe4f
# ╠═fb0aabb5-72ea-48a9-ac83-ebd593d4a2e5
# ╟─04e5ec1a-60e4-11eb-0d45-fd8291a674f9
# ╠═14e6dece-60dc-11eb-2d5a-275b8c9e382d
# ╠═1635940c-60e4-11eb-1b33-5b8faaf933d8
# ╟─f998e4fc-60e3-11eb-0533-1717bea29668
# ╟─46021976-60e4-11eb-3797-33b6ff7755d4
# ╟─87f77baa-60e4-11eb-24e2-019e317451f6
# ╠═5401181c-60dd-11eb-0844-9b4b7b35693c
# ╟─97337aec-60e4-11eb-0b15-99ffcf8376fa
# ╠═9d5c72ca-60df-11eb-262d-6f0803d386f5
# ╟─edc6da66-60e4-11eb-1aeb-fb9dbb7ccc88
# ╠═241b8206-60e0-11eb-08bd-f748c90e49c7
# ╟─01e4ac58-60e5-11eb-39f3-b5f613ecee35
# ╟─0b70f90c-60e5-11eb-18da-25e3302a74a8
# ╠═15ecf0aa-60e2-11eb-1ef4-ebfc215e5ca7
# ╠═5dacc3c2-60e2-11eb-1352-0ddbe3405aec
# ╟─4df1e8ae-60ef-11eb-3772-1154f708eecb
# ╠═5ceea932-60ef-11eb-3c13-37ddf8e09f6f
# ╠═635a3b24-60ef-11eb-0d2f-51dbfbd705a1
# ╟─eea5accc-60db-11eb-3889-c992db2ec8ec
# ╠═400cc04e-4784-11eb-11a2-ff8e245cad27
# ╠═e5a741e8-60dc-11eb-317e-cfdd650ae5f0
# ╠═87b7bc86-60df-11eb-3f9f-2375449c77f6
# ╟─a1d99d9e-60dc-11eb-391c-b52c2e16aedd
# ╠═28060fda-60db-11eb-3ba8-b36b75523ed6
# ╠═a50aa4e4-4785-11eb-1b16-739b802ea3cc
# ╠═e072a5e8-4785-11eb-0edd-f1c514f46480
# ╟─1f927f3c-60e5-11eb-0304-f1639b68468d
# ╠═620c76e4-60de-11eb-2c82-d364f55fbe4d
