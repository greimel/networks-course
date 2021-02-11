### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 69209f8a-6c75-11eb-228e-475c3fcde6e7
begin
	_a_ = 1 # make sure this cell is run as cell #1
	
	using Pkg
	Pkg.activate(temp = true)
	
	Pkg.add(PackageSpec(name = "PlutoUI", version = "0.6.11-0.6"))
	using PlutoUI
end

# ╔═╡ 60483912-6c80-11eb-27ba-55477555f345
begin
	_b_ = _a_ + 1 # Cell #2
	
	fancy = false
	
	if fancy
		Pkg.add(["WGLMakie", "JSServe"])
		using WGLMakie, JSServe
		Page(exportable = true)
	else
		Pkg.add("CairoMakie")
		using CairoMakie
		CairoMakie.activate!(type = "png")
	end
	
	Pkg.add("AlgebraOfGraphics")
	Pkg.add("NetworkLayout")
	
	using AlgebraOfGraphics
	using NetworkLayout: NetworkLayout
end

# ╔═╡ 6b906ab0-6c80-11eb-29a9-ab1e42290019
begin
	_c_ = _b_ + 1 # Cell #3
	
	Pkg.add([
		PackageSpec(name = "DataAPI", version="1.4"),
		PackageSpec(name = "LightGraphs", version = "1.3"),
		PackageSpec(name = "DataFrames", version = "0.22"),
		PackageSpec(name = "WorldBankData", version = "0.4.1-0.4"),
		#PackageSpec(name = "Plots", version = "1.10"),	
		PackageSpec(url = "https://github.com/greimel/Shapefile.jl", rev="multipolygon"),
		#PackageSpec(url = "https://github.com/greimel/WeightedGraphs.jl")
			])
	
	Pkg.add([
			"GeometryBasics", "FreqTables",
			"PooledArrays", "CategoricalArrays",
			"Colors",
			"Plots",
			"Chain", "UnPack",
			"ZipFile",
			"SimpleWeightedGraphs", "GraphDataFrameBridge",
			"CSV", "HTTP"
			])

	using Statistics, SparseArrays, LinearAlgebra
	
	#using WorldBankData
	#using FreqTables
	using Colors
	using Chain: @chain
	using UnPack: @unpack
	using ZipFile, Shapefile
	import CSV, HTTP
	using DataFrames#, PooledArrays, CategoricalArrays, Underscores
	#using Plots
	#Plots.gr(fmt = :png)
	
	using GeometryBasics
	
	
end

# ╔═╡ 1f7e15e2-6cbb-11eb-1e92-9f37d4f3df40
begin
	_d_ = _c_ + 1 # cell #4
	nothing
	
	using LightGraphs, SimpleWeightedGraphs, GraphDataFrameBridge
	const LG = LightGraphs
	
	weighted_adjacency_matrix(graph::LightGraphs.AbstractGraph) = LG.weights(graph) .* adjacency_matrix(graph)
	
	LG.adjacency_matrix(graph::SimpleWeightedGraphs.SimpleWeightedGraph) = LG.weights(graph) .> 0
	
	function LG.katz_centrality(graph::AbstractGraph, α::Real=0.3; node_weights = ones(nv(graph)))
		v = node_weights

	    A = weighted_adjacency_matrix(graph)
    	v = (I - α * A) \ v
    	v /=  norm(v)
	end
	
	function LG.eigenvector_centrality(graph::AbstractGraph)
		A = weighted_adjacency_matrix(graph)
		eig = LightGraphs.eigs(A, which=LightGraphs.LM(), nev=1)
		eigenvector = eig[2]
	
		centrality = abs.(vec(eigenvector))
	end
end

# ╔═╡ 47594b98-6c72-11eb-264f-e5416a8faa32
md"""
`facebook.jl` | **Version 0.5** | *last updated: Feb 11*
"""

# ╔═╡ 6712b2f0-6c72-11eb-0cb1-b12b78ab5556
md"""
!!! danger "Preliminary version"
    Nice that you've found this notebook on github. We appreciate your engagement. Feel free to have a look. Please note that the notebook is subject to change until a link is is uploaded to *Canvas*.
"""

# ╔═╡ 7f8a57f0-6c72-11eb-27dd-2dae50f00232
md"""
# Social Connectedness: What Friendships on Facebook Tell Us About the World

This notebook will be the basis for part of **Lecture 5** *and* **Assignment 3**. Here is what we will cover.

1. We will see how socially connected a region is other regions.

2. We will regard the social connectedness index as the weights of network of regions. We will analyze the properties of this network.

3. We will compute the network concentration of a region and see that this measure has important socio-economic correlates.

4. 
"""

# ╔═╡ 547d93f4-6c74-11eb-28fe-c5be4dc7aaa6
md"""
# Visualizing Social Connectedness

There at least two ways to visualize social connectedness.

1. [Chorepleth maps](https://en.wikipedia.org/wiki/Choropleth_map) allow visualizing the social connectedness of one region with other regions.

2. Heatmaps allow visualizing social connectedness of the full network.
"""

# ╔═╡ 710d5dfe-6cb2-11eb-2de6-3593e0bd4aba
country = "BE"

# ╔═╡ e90eb932-6c74-11eb-3338-618a4ea9c211
md"""
# Social Connectedness as Weights of a Network of Regions
"""

# ╔═╡ 8838d306-6c75-11eb-354a-7dadbf6e973f
md"""
# Network Concentration
"""

# ╔═╡ 3062715a-6c75-11eb-30ef-2953bc64adb8
md"""
# Appendix
"""

# ╔═╡ 186246ce-6c80-11eb-016f-1b1abb9039bd
md"""
## Downloading the SCI Data
"""

# ╔═╡ 7f85031a-6c75-11eb-0d7b-31519ba1c2f9
url_country_country = "https://data.humdata.org/dataset/e9988552-74e4-4ff4-943f-c782ac8bca87/resource/7c8f6c93-6272-4d39-9e5d-99cdc0053dfc/download/2020-12-16_country_country.tsv"

# ╔═╡ 5427cfc6-6c80-11eb-24c8-e1a56dfd20f1
url_county = "https://data.humdata.org/dataset/e9988552-74e4-4ff4-943f-c782ac8bca87/resource/3e3a1a7e-b557-4191-80cf-33d8e66c2e51/download/county_county_aug2020.tsv"

# ╔═╡ 5a0d2490-6c80-11eb-0985-9de4f34412f1
function csv_from_url(url)
	csv = CSV.File(HTTP.get(url).body)
	df = DataFrame(csv)
end

# ╔═╡ 9d80ae04-6c80-11eb-2c03-b7b45ca6e0bf
get_country_sci() = csv_from_url(url_country_country)

# ╔═╡ be47304a-6c80-11eb-18ad-974bb077e53f
get_county_sci() = csv_from_url(url_county)

# ╔═╡ a6939ede-6c80-11eb-21ce-bdda8fe67acc
md"""
## Constructing a Network From SCI Data
"""

# ╔═╡ ca92332e-6c80-11eb-3b62-41f0301d6330
function make_sci_graph(df_sci)
	# get the list of nodes
	node_names = unique([df_sci.user_loc; df_sci.fr_loc])
	# enumerate the nodes (node_id == index)
	node_dict = Dict(n => i for (i,n) in enumerate(node_names))
	# add columns with node_id
	@chain df_sci begin
		transform!([:user_loc, :fr_loc] .=> ByRow(x -> node_dict[x]) .=> [:from, :to])
		#sort!([:from, :to])
	end
	# create the weight matrix
	sparse_wgts = sparse(df_sci.from, df_sci.to, df_sci.scaled_sci)	
	wgts = float.(Matrix(sparse_wgts))
	
	wgts = wgts - Diagonal(diag(wgts))

	wgts ./= maximum(wgts)
	
	(; node_names, wgts)
end

# ╔═╡ 72619534-6c81-11eb-07f1-67f833293077
md"""
## Downloading the Maps
"""

# ╔═╡ ca30bfda-6c81-11eb-20fa-0defd9b240b2
function download_zipped_shapes(url, map_name)
	zipfile = download(url)
	z = ZipFile.Reader(zipfile)	
	
	for f in z.files
		if startswith(f.name, map_name)
			open(f.name, "w") do io
				write(io, read(f))
			end
		end
	end
	close(z)
	
	Shapefile.Table(joinpath(".", map_name))
end

# ╔═╡ 9b6dfc1a-6c81-11eb-194a-35cb323ef2af
function download_country_shapes()
	url = "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_countries.zip"
	map_name = "ne_110m_admin_0_countries"
	download_zipped_shapes(url, map_name)
end

# ╔═╡ c812c08e-6c81-11eb-2ef1-97a4920d5170
function download_county_shapes()
	url = "https://biogeo.ucdavis.edu/data/gadm3.6/shp/gadm36_USA_shp.zip"
	map_name = "gadm36_USA_2"
	download_zipped_shapes(url, map_name)
end

# ╔═╡ 713ce11e-6c85-11eb-12f7-d7fac18801fd
function extract_shapes_df(shp_table)
	#fips = shp_table.FIPS_10_
	iso3c = shp_table.ADM0_A3
	country = shp_table.ADMIN
	population = shp_table.POP_EST
	gdp = shp_table.GDP_MD_EST
	#continent = shp_table.CONTINENT
	shape = shp_table.Geometry
	df = DataFrame(; shape, population, gdp, iso3c, country)
	filter!(:shape => !ismissing, df)
	disallowmissing!(df)
	
	df
end

# ╔═╡ 8ba27720-6c81-11eb-1a5b-47db233dce61
function get_shapes()
	shp_table = download_country_shapes()
	
	df = extract_shapes_df(shp_table)
end

# ╔═╡ 8575cb62-6c82-11eb-2a76-f9c1af6aab50
md"""
## Translating Country Codes
"""

# ╔═╡ a91896c6-6c82-11eb-018e-e514ca265b1a
url_country_codes = "https://datahub.io/core/country-codes/r/country-codes.csv"

# ╔═╡ 09109488-6c87-11eb-2d64-43fc9df7d8c8
csv_from_url(url_country_codes)

# ╔═╡ c8d9234a-6c82-11eb-0f81-c17abae3e1c7
iso2c_to_fips = begin
	df = csv_from_url(url_country_codes)
	select!(df, "ISO3166-1-Alpha-2" => :iso2c,
				"ISO3166-1-Alpha-3" => :iso3c,
				:FIPS => :fips, 
				:official_name_en => :country, :Continent => :continent)
	dropmissing!(df)
	
	missing_countries = DataFrame([
			(iso2c = "XK", iso3c = "KOS", country = "Kosovo", fips = "KV", continent = "EU"),
			(iso2c = "TW", iso3c = "TWN", country = "Taiwan", fips = "TW", continent = "AS")
			])
	
	[df; missing_countries]
end

# ╔═╡ 15139994-6c82-11eb-147c-59013c36a518
md"""
## Matching SCI and Map Shapes
"""

# ╔═╡ 3dc97a66-6c82-11eb-20a5-635ac0b6bac1
country_df = get_country_sci()

# ╔═╡ aa423d14-6cb3-11eb-0f1c-65ebbf99d539
@unpack node_names, wgts = make_sci_graph(country_df);

# ╔═╡ baecfe58-6cb6-11eb-3a4e-31bbb8da02ae
begin
	df_nodes = DataFrame(; node_names, id = 1:length(node_names))
	df_nodes = leftjoin(df_nodes, iso2c_to_fips, on = :node_names => :iso2c) |> disallowmissing
	
	sort!(df_nodes, :continent)
end

# ╔═╡ cd3fd39a-6cb7-11eb-1d7f-459f25a393e4
begin
	labels = combine(groupby(df_nodes, :continent), :continent => length => :width)
	labels.start = [0; cumsum(labels.width)[1:end-1]]
	labels.mid = labels.start + (labels.width ./ 2)
	labels
end


# ╔═╡ f25cf8be-6cb3-11eb-0c9c-f9ed04ded513
let
	fig = Figure()
	ax = Axis(fig[1,1], title = "Social Connectedness Between Countries of the World", xgridvisible = false, ygridvisible = false)
	
	vlines!(ax, labels.start, color = :gray80)
	hlines!(ax, labels.start, color = :gray80)
	
	ax.xticks = (labels.mid, labels.continent)
	ax.yticks = (labels.mid, labels.continent)
	
	
	
	image!(ax, RGBA.(0,0,0, min.(1.0, wgts[df_nodes.id, df_nodes.id] .* 100)))
	
	fig
end

# ╔═╡ b5464c40-6cbb-11eb-233a-b1557763e8d6
sort(df_nodes, :eigv_c, rev = true)

# ╔═╡ 29479030-6c75-11eb-1b96-9fd35f6d0840
g = SimpleWeightedGraph(wgts)

# ╔═╡ 3fd2482e-6c82-11eb-059a-c546e5053143
county_df = get_county_sci()

# ╔═╡ 60e9f650-6c83-11eb-270a-fb57f2449762
begin
	tbl = download_country_shapes()
	shapes_df = extract_shapes_df(tbl)
	shapes_df = leftjoin(shapes_df, iso2c_to_fips, on = :iso3c, makeunique = true)
end;

# ╔═╡ 96cd1698-6cbb-11eb-0843-f9edd8f58c80
begin
	df_nodes.eigv_c = eigenvector_centrality(g)
	df_nodes.katz_c = katz_centrality(g)
	df_nodes1 = rightjoin(shapes_df, df_nodes, on = :iso2c => :node_names, makeunique = true, matchmissing = :equal)
	select!(df_nodes1, :eigv_c, :katz_c, :shape)
	dropmissing!(df_nodes1)
end

# ╔═╡ 4b8fba92-6cb0-11eb-0c53-b96600bc760d
function sci(country)
	
	df0 = filter(:user_loc => ==(country), country_df)
	select!(df0, Not(:user_loc))
	df = leftjoin(df0, iso2c_to_fips, on = :fr_loc => :iso2c)
	df1 = leftjoin(df, shapes_df, on = :iso3c, makeunique = true)
	filter!(:shape => !ismissing, df1)
	filter!(:fr_loc => !=(country), df1)
	disallowmissing!(df1, :shape)
	
end

# ╔═╡ 4f14a79c-6cb3-11eb-3335-2bbb61da25d9
sort(sci(country), :scaled_sci, rev=true)

# ╔═╡ 64b321e8-6c84-11eb-35d4-b16736c24cea
begin
	no_data = filter(:iso2c => !in(node_names), iso2c_to_fips)
	no_data = leftjoin(no_data, shapes_df, on = :iso3c, makeunique=true)
	
	filter!(:shape => !ismissing, no_data)
	disallowmissing!(no_data)
end

# ╔═╡ 6d30c04a-6cb2-11eb-220b-998e7d5cc469
let
	fig = Figure()
	ax = Axis(fig[1,1], title = "Social connectedness with $country")
	hidedecorations!(ax)
	hidespines!(ax)
	
	sci_country = sci(country)
	color_variable = log.(sci_country.scaled_sci ./ 100_000)
	
	attr = (tellwidth = true, width = 30)
	
	# Plot the chosen country
	poly!(ax, filter(:iso2c => (x -> !ismissing(x) && (x == country)), shapes_df).shape, color = :red)
	# Plot the countries for which there is no SCI data
	poly!(ax, no_data.shape, color = :gray95)
	# Plot the countries with sci data
	poly!(ax, sci_country.shape, color = color_variable)
	
	cb = Colorbar(fig[1,2], limits = extrema(color_variable); attr..., label="log(sci)")

	fig
	
end

# ╔═╡ d38c51d4-6cbb-11eb-09dc-a92080dea6c7
let
	fig = Figure()
	ax = Axis(fig[1,1], title = "Centrality According to Facebook")
	hidedecorations!(ax)
	hidespines!(ax)
	
	color_variable = log.(df_nodes1.eigv_c)
	
	attr = (tellwidth = true, width = 30)
	
	# Plot the countries for which there is no SCI data
	poly!(ax, no_data.shape, color = :gray95)
	# Plot the countries with sci data
	poly!(ax, df_nodes1.shape, color = color_variable)
	
	cb = Colorbar(fig[1,2], limits = extrema(color_variable); attr..., label="log(centrality)")

	fig
	
end

# ╔═╡ 05dcc1a2-6c83-11eb-3b62-2339a8e8863e
all(in(iso2c_to_fips.iso2c), node_names)

# ╔═╡ 4da91cd0-6c86-11eb-31fd-2fe037228a52
filter(:continent => ismissing, shapes_df)

# ╔═╡ fdc229f8-6c84-11eb-1ae9-d133fc05035e
nomatch = filter(!in(filter(!ismissing, shapes_df.iso2c)), node_names)

# ╔═╡ 34b2982a-6c89-11eb-2ae6-77e735c49966
filter(:iso2c => in(nomatch), iso2c_to_fips) # too small

# ╔═╡ 71a3ea90-6c89-11eb-3ca5-813352af8243
let
	shape_df = get_shapes()
	df = transform!(shape_df, :population => (x -> x/1_000_000) => :pop)

	fig = Figure()
	ax = Axis(fig[1,1])
	hidedecorations!(ax)
	hidespines!(ax)
	
	color_variable = log.(df.pop)
	
	attr = (tellwidth = true, width = 30)
	poly!(ax, df.shape, color = color_variable)
	cb = Colorbar(fig[1,2], limits = extrema(color_variable); attr..., label="log(population)")

	fig
end

# ╔═╡ 39d717a4-6c75-11eb-15f0-d537959a41b8
md"""
## Package Environment
"""

# ╔═╡ 3399e1f8-6cbb-11eb-329c-811efb68179f
md"""
## Patch 1: Weights and Centralities
"""

# ╔═╡ 3bdf7df2-6cbb-11eb-2ea4-f5e465bd0e63
md"""
## Patch 2: Dense Graphs
"""

# ╔═╡ 2aa908f0-6cbb-11eb-1ee5-3399373632a5
let
	# note LG == LightGraphs
	struct DenseWeightedGraph{T, M <: AbstractMatrix{T}} <: LG.AbstractGraph{T}
		wgts::M
	end
	
	LG.is_directed(graph::DenseWeightedGraph) = !issymmetric(weights(graph))
	LG.weights(graph::DenseWeightedGraph) = graph.wgts
	LG.adjacency_matrix(graph::DenseWeightedGraph) = LG.weights(graph) .> 0
	LG.nv(graph::DenseWeightedGraph) = size(LG.weights(graph), 1)
	LG.ne(graph::DenseWeightedGraph) = sum(adjacency_matrix(graph))
	LG.has_edge(graph::DenseWeightedGraph, i, j) = LG.weights(graph)[i,j] > 	0
	LG.inneighbors(graph::DenseWeightedGraph, i) = LG.weights(graph)[:,i] .> 0
	LG.outneighbors(graph::DenseWeightedGraph, j) = LG.weights(graph)[i,:] .> 0
end

# ╔═╡ 6bec11fe-6c75-11eb-2494-25e57c4c84c8
TableOfContents()

# ╔═╡ Cell order:
# ╟─47594b98-6c72-11eb-264f-e5416a8faa32
# ╟─6712b2f0-6c72-11eb-0cb1-b12b78ab5556
# ╟─7f8a57f0-6c72-11eb-27dd-2dae50f00232
# ╟─547d93f4-6c74-11eb-28fe-c5be4dc7aaa6
# ╠═710d5dfe-6cb2-11eb-2de6-3593e0bd4aba
# ╠═6d30c04a-6cb2-11eb-220b-998e7d5cc469
# ╠═4f14a79c-6cb3-11eb-3335-2bbb61da25d9
# ╠═aa423d14-6cb3-11eb-0f1c-65ebbf99d539
# ╠═f25cf8be-6cb3-11eb-0c9c-f9ed04ded513
# ╠═baecfe58-6cb6-11eb-3a4e-31bbb8da02ae
# ╠═cd3fd39a-6cb7-11eb-1d7f-459f25a393e4
# ╟─e90eb932-6c74-11eb-3338-618a4ea9c211
# ╠═29479030-6c75-11eb-1b96-9fd35f6d0840
# ╠═96cd1698-6cbb-11eb-0843-f9edd8f58c80
# ╠═b5464c40-6cbb-11eb-233a-b1557763e8d6
# ╠═d38c51d4-6cbb-11eb-09dc-a92080dea6c7
# ╟─8838d306-6c75-11eb-354a-7dadbf6e973f
# ╟─3062715a-6c75-11eb-30ef-2953bc64adb8
# ╟─186246ce-6c80-11eb-016f-1b1abb9039bd
# ╠═7f85031a-6c75-11eb-0d7b-31519ba1c2f9
# ╠═5427cfc6-6c80-11eb-24c8-e1a56dfd20f1
# ╠═5a0d2490-6c80-11eb-0985-9de4f34412f1
# ╠═9d80ae04-6c80-11eb-2c03-b7b45ca6e0bf
# ╠═be47304a-6c80-11eb-18ad-974bb077e53f
# ╟─a6939ede-6c80-11eb-21ce-bdda8fe67acc
# ╠═ca92332e-6c80-11eb-3b62-41f0301d6330
# ╟─72619534-6c81-11eb-07f1-67f833293077
# ╠═8ba27720-6c81-11eb-1a5b-47db233dce61
# ╠═9b6dfc1a-6c81-11eb-194a-35cb323ef2af
# ╠═c812c08e-6c81-11eb-2ef1-97a4920d5170
# ╠═ca30bfda-6c81-11eb-20fa-0defd9b240b2
# ╠═713ce11e-6c85-11eb-12f7-d7fac18801fd
# ╟─8575cb62-6c82-11eb-2a76-f9c1af6aab50
# ╠═a91896c6-6c82-11eb-018e-e514ca265b1a
# ╠═09109488-6c87-11eb-2d64-43fc9df7d8c8
# ╠═c8d9234a-6c82-11eb-0f81-c17abae3e1c7
# ╟─15139994-6c82-11eb-147c-59013c36a518
# ╠═3dc97a66-6c82-11eb-20a5-635ac0b6bac1
# ╠═4b8fba92-6cb0-11eb-0c53-b96600bc760d
# ╠═3fd2482e-6c82-11eb-059a-c546e5053143
# ╠═60e9f650-6c83-11eb-270a-fb57f2449762
# ╠═64b321e8-6c84-11eb-35d4-b16736c24cea
# ╠═05dcc1a2-6c83-11eb-3b62-2339a8e8863e
# ╠═4da91cd0-6c86-11eb-31fd-2fe037228a52
# ╠═fdc229f8-6c84-11eb-1ae9-d133fc05035e
# ╠═34b2982a-6c89-11eb-2ae6-77e735c49966
# ╠═71a3ea90-6c89-11eb-3ca5-813352af8243
# ╟─39d717a4-6c75-11eb-15f0-d537959a41b8
# ╠═69209f8a-6c75-11eb-228e-475c3fcde6e7
# ╠═60483912-6c80-11eb-27ba-55477555f345
# ╠═6b906ab0-6c80-11eb-29a9-ab1e42290019
# ╟─3399e1f8-6cbb-11eb-329c-811efb68179f
# ╠═1f7e15e2-6cbb-11eb-1e92-9f37d4f3df40
# ╟─3bdf7df2-6cbb-11eb-2ea4-f5e465bd0e63
# ╠═2aa908f0-6cbb-11eb-1ee5-3399373632a5
# ╠═6bec11fe-6c75-11eb-2494-25e57c4c84c8
