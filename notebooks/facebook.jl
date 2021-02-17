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

# ╔═╡ 131244a8-7130-11eb-3770-a18a06eac45f
Pkg.add("StatsBase"); using StatsBase

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
`facebook.jl` | **Version 0.7** | *last updated: Feb 17*
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

#### Lecture Notes

1. Define the Social Connectedness Index, discuss its limitations
2. Measuring concentration of Social Networks

#### Pluto Notebook

3. Visualize social connectedness of a region
4. Regard the social connectedness index as the weights of network of regions. Analyze the properties of this network.
5. Compute the network concentration of a region and see that this measure has important socio-economic correlates.
"""

# ╔═╡ 547d93f4-6c74-11eb-28fe-c5be4dc7aaa6
md"""
# Visualizing Social Connectedness

There at least two ways to visualize social connectedness.

1. [Choropleth maps](https://en.wikipedia.org/wiki/Choropleth_map) allow visualizing the social connectedness of one region with other regions.

2. Heatmaps allow visualizing social connectedness of the full network.
"""

# ╔═╡ 710d5dfe-6cb2-11eb-2de6-3593e0bd4aba
country = "BE"

# ╔═╡ 8bee74ea-7140-11eb-3441-330ab08a9f38
md"""
## Visualizing the full network with a Heatmap
"""

# ╔═╡ 8bee74ea-7140-11eb-3441-330ab08a9f38
md"""
## Visualizing the full network with a Heatmap
"""

# ╔═╡ e90eb932-6c74-11eb-3338-618a4ea9c211
md"""
# Social Connectedness as Weights of a Network of Regions
"""

# ╔═╡ 7b50095c-6f9a-11eb-2cf5-31805fc10804
md"""
## (End of Lecture)
"""

# ╔═╡ 8a0e113c-6f9a-11eb-3c3b-bfb0c9220562
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ 94895ab8-6f9a-11eb-3c04-dbe13f545acc
group_number = 99

# ╔═╡ a3176884-6f9a-11eb-1831-41486221dedb
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the randomly generated names above by the names of your group and put the right group number in the top cell.
	"""
end

# ╔═╡ 96e4482c-6f9a-11eb-0e47-c568006368b6
md"""
### Task 1: Social connectedness is not distance (2 points)

The social connectedness is strongly correlated with distance. The closest geographical regions often have the highest social connectedness index.

👉 Think about a country for which you expect high social connectedness with a country far away. Replace the variable `country` (now *$(country)*) with the two-letter abbreviation of the country of your choice.

👉 Explain in <200 words why you would expect high social connectedness with this distant country. (Common) history? A stereotype?
"""

# ╔═╡ 6114ed16-6f9d-11eb-1bd4-1d1710b7f9df
answer1 = md"""
Your answer

goes here ...
"""

# ╔═╡ 2338f91c-6f9e-11eb-0fb5-33421b7ae810
md"""
### Task 2: Measuring centrality in the network of regions (4 points)

Take another look at the list of *most central countries* according to the social connectedness index. *(Shown below.)*
"""

# ╔═╡ da7f397a-6fa6-11eb-19d5-972c93f11f91
md"""
This list contains some surprises countries. Would you have thought that Papua New Guinea and Vanuatu are the most central countries? There are two possibilities.

1. Our prior beliefs are wrong.

2. We don't measure what we want to measure.

Before we update our beliefs, let us think a bit about measuring centrality.

👉 (2.1 | 1 points) Discuss what problems you see with our measure of centrality. ( <200 words)
"""


# ╔═╡ d5c448e6-713c-11eb-1b3b-9b8e4af8ae5f
answer21 = md"""
Your answer

goes here ...
"""

# ╔═╡ 55ab86e6-6fa8-11eb-2ac4-9f0548598014
md"""
👉 (2.2 | 2 points) Suggest an improved measure of centrality. Explain which of the problems you identified above are mitigated and how. (<200 words)
"""

# ╔═╡ dcb2cd6c-713c-11eb-1f3d-2de066d25c6f
answer22 = md"""
Your answer

goes here ...
"""

# ╔═╡ 74c2e86c-6fa8-11eb-32f7-a97c939225ef
md"""
👉 (2.3 | 1 point) Calculate your suggested centrality measure and compare it to the measure from the lecture. 
"""

# ╔═╡ 778053a0-713d-11eb-10d9-0be586250eb1
# your

# ╔═╡ 7b89e48e-713d-11eb-3838-a5de7e13f72b
# analysis

# ╔═╡ 7f2a8d46-713d-11eb-08f1-3b310beea91c
# goes

# ╔═╡ 840a7d80-713d-11eb-19d5-594bcbb61ec0
# here

# ╔═╡ df16a43e-713c-11eb-15db-cdcdb1756588
answer23 = md"""
Your answer

goes here ...
"""

# ╔═╡ e4a28c46-6fa8-11eb-0b80-658ffbab932b
md"""
### Task 3: Using the Social Connectedness Index (4 points)

The Social Connectedness Index dataset is a very recent dataset. Thus, there is plenty of room for further exploration.

Look for papers that have used the Social Connectedness Index for economic research. (You can start on [Theresa Kuchler's website](http://pages.stern.nyu.edu/~tkuchler/index.html)). Select the two papers that have the most interesting titles or abstracts.
"""

# ╔═╡ 39ea6d9a-6fab-11eb-2b00-f3eda1cd2677
md"""
👉 (3.1 | 2 points) List the two papers and explain in <150 words (per paper) why the papers are interesting from a network and/or policy perspective.
"""

# ╔═╡ 2816c75e-713d-11eb-11ec-5391cb16ecc3
answer31 = md"""
Your answer

goes here ...
"""

# ╔═╡ 272f7770-6fab-11eb-32b9-01af616ae967
md"""
👉 (3.2 | 2 points) Formulate in <300 words a (research) question that can be answered using the Social Connectedness Index and describe how the SCI can help.
"""

# ╔═╡ 2a61d17a-713d-11eb-2457-11e5c4dd792f
answer32 = md"""
Your answer

goes here ...
"""

# ╔═╡ a81a894a-713d-11eb-0dd8-9d9e8dffee35
md"""
#### Before you submit ...

👉 Make sure you have added your names and your group number at the top.

👉 Make sure that that **all group members proofread** your submission (especially your little essay).

👉 Make sure that you are **within the word limit**. Short and concise answers are appreciated. Answers longer than the word limit will lead to deductions.

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. In addition, **upload the source code** of the notebook (the .jl file).
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
	df_nodes0 = DataFrame(; node_names, id = 1:length(node_names))
	df_nodes0 = leftjoin(df_nodes0, iso2c_to_fips, on = :node_names => :iso2c) |> disallowmissing
	
	sort!(df_nodes0, :continent)
end

# ╔═╡ cd3fd39a-6cb7-11eb-1d7f-459f25a393e4
begin
	labels = combine(groupby(df_nodes0, :continent), :continent => length => :width)
	labels.start = [0; cumsum(labels.width)[1:end-1]]
	labels.mid = labels.start + (labels.width ./ 2)
	labels
end


# ╔═╡ 29479030-6c75-11eb-1b96-9fd35f6d0840
g = SimpleWeightedGraph(wgts)

# ╔═╡ 3fd2482e-6c82-11eb-059a-c546e5053143


# ╔═╡ 60e9f650-6c83-11eb-270a-fb57f2449762
begin
	tbl = download_country_shapes()
	shapes_df = extract_shapes_df(tbl)
	shapes_df = leftjoin(shapes_df, iso2c_to_fips, on = :iso3c, makeunique = true)
end;

# ╔═╡ 96cd1698-6cbb-11eb-0843-f9edd8f58c80
begin
	df_nodes = df_nodes0
	df_nodes.eigv_c = eigenvector_centrality(g)
	df_nodes.katz_c = katz_centrality(g)
	df_nodes1 = rightjoin(shapes_df, df_nodes, on = :iso2c => :node_names, makeunique = true, matchmissing = :equal)
	select!(df_nodes1, :eigv_c, :katz_c, :shape)
	dropmissing!(df_nodes1)
end;

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

# ╔═╡ d1fd17dc-6fa6-11eb-245d-8bc905079f2f
df_nodes1; sort(df_nodes, :eigv_c, rev = true)

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
sci_country_fig = let
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

# ╔═╡ ac0bbc28-6f9b-11eb-1467-6dbd9d2b763a
sci_country_fig

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

# ╔═╡ c069fd72-6f9a-11eb-000c-1fa67ae5bed4
md"""
## Other stuff
"""

# ╔═╡ 6bec11fe-6c75-11eb-2494-25e57c4c84c8
TableOfContents()

# ╔═╡ c9de87e2-6f9a-11eb-06cf-d778ae009fb6
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
	function wordcount(text)
    	words=split(string(text), (' ','\n','\t','-'))
    	length(words)
	end
end

# ╔═╡ b0f46e9c-6f9d-11eb-1ed0-0fddd637fb6c
md"(You have used approximately **$(wordcount(answer1))** words.)"

# ╔═╡ 7156d9ac-6f9d-11eb-36e1-77f5eda39e16
if answer1 == md"""
Your answer

goes here ...
"""
	keep_working(md"Place your cursor in the code cell and replace the dummy text, and evaluate the cell.")
elseif wordcount(answer1) > 1.1 * 200
	almost(md"Try to shorten your text a bit, to get below 500 words.")
else
	correct(md"Great, we are looking forward to reading your answer!")
end

# ╔═╡ 477b9a84-713d-11eb-2b48-0553087b0735
md"(You have used approximately **$(wordcount(answer21))** words.)"

# ╔═╡ 3e69678e-713d-11eb-3591-ff5c3563d0eb
md"(You have used approximately **$(wordcount(answer22))** words.)"

# ╔═╡ 4dd44354-713d-11eb-164b-0d143e507815
md"(You have used approximately **$(wordcount(answer31))** words.)"

# ╔═╡ 54291450-713d-11eb-37d2-0db48a0e8a85
md"(You have used approximately **$(wordcount(answer32))** words.)"

# ╔═╡ c79b5e38-6f9a-11eb-05d3-9bf4844896f8
members = let
	str = ""
	for (first, last) in group_members
		str *= str == "" ? "" : ", "
		str *= first * " " * last
	end
	str
end

# ╔═╡ 44ef5554-713f-11eb-35fc-1b93349ca7fa
md"*Assignment submitted by* **$members** (*group $(group_number)*)"

# ╔═╡ 50e332de-6f9a-11eb-3888-d15d986aca8e
md"""
# Assignment 3: The Social Connectedness Index

*submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ Cell order:
# ╟─47594b98-6c72-11eb-264f-e5416a8faa32
# ╟─44ef5554-713f-11eb-35fc-1b93349ca7fa
# ╟─6712b2f0-6c72-11eb-0cb1-b12b78ab5556
# ╟─7f8a57f0-6c72-11eb-27dd-2dae50f00232
# ╟─547d93f4-6c74-11eb-28fe-c5be4dc7aaa6
# ╟─710d5dfe-6cb2-11eb-2de6-3593e0bd4aba
# ╟─6d30c04a-6cb2-11eb-220b-998e7d5cc469
# ╠═4f14a79c-6cb3-11eb-3335-2bbb61da25d9
# ╠═aa423d14-6cb3-11eb-0f1c-65ebbf99d539
# ╟─8bee74ea-7140-11eb-3441-330ab08a9f38
# ╠═f25cf8be-6cb3-11eb-0c9c-f9ed04ded513
# ╠═baecfe58-6cb6-11eb-3a4e-31bbb8da02ae
# ╠═cd3fd39a-6cb7-11eb-1d7f-459f25a393e4
# ╟─e90eb932-6c74-11eb-3338-618a4ea9c211
# ╠═29479030-6c75-11eb-1b96-9fd35f6d0840
# ╠═96cd1698-6cbb-11eb-0843-f9edd8f58c80
# ╠═b5464c40-6cbb-11eb-233a-b1557763e8d6
# ╠═d38c51d4-6cbb-11eb-09dc-a92080dea6c7
# ╟─7b50095c-6f9a-11eb-2cf5-31805fc10804
# ╠═8a0e113c-6f9a-11eb-3c3b-bfb0c9220562
# ╠═94895ab8-6f9a-11eb-3c04-dbe13f545acc
# ╟─a3176884-6f9a-11eb-1831-41486221dedb
# ╟─50e332de-6f9a-11eb-3888-d15d986aca8e
# ╟─96e4482c-6f9a-11eb-0e47-c568006368b6
# ╟─ac0bbc28-6f9b-11eb-1467-6dbd9d2b763a
# ╠═6114ed16-6f9d-11eb-1bd4-1d1710b7f9df
# ╟─b0f46e9c-6f9d-11eb-1ed0-0fddd637fb6c
# ╟─7156d9ac-6f9d-11eb-36e1-77f5eda39e16
# ╟─2338f91c-6f9e-11eb-0fb5-33421b7ae810
# ╠═d1fd17dc-6fa6-11eb-245d-8bc905079f2f
# ╟─da7f397a-6fa6-11eb-19d5-972c93f11f91
# ╠═d5c448e6-713c-11eb-1b3b-9b8e4af8ae5f
# ╟─477b9a84-713d-11eb-2b48-0553087b0735
# ╟─55ab86e6-6fa8-11eb-2ac4-9f0548598014
# ╟─dcb2cd6c-713c-11eb-1f3d-2de066d25c6f
# ╠═3e69678e-713d-11eb-3591-ff5c3563d0eb
# ╟─74c2e86c-6fa8-11eb-32f7-a97c939225ef
# ╠═778053a0-713d-11eb-10d9-0be586250eb1
# ╠═7b89e48e-713d-11eb-3838-a5de7e13f72b
# ╠═7f2a8d46-713d-11eb-08f1-3b310beea91c
# ╠═840a7d80-713d-11eb-19d5-594bcbb61ec0
# ╠═df16a43e-713c-11eb-15db-cdcdb1756588
# ╟─e4a28c46-6fa8-11eb-0b80-658ffbab932b
# ╟─39ea6d9a-6fab-11eb-2b00-f3eda1cd2677
# ╠═2816c75e-713d-11eb-11ec-5391cb16ecc3
# ╟─4dd44354-713d-11eb-164b-0d143e507815
# ╟─272f7770-6fab-11eb-32b9-01af616ae967
# ╠═2a61d17a-713d-11eb-2457-11e5c4dd792f
# ╟─54291450-713d-11eb-37d2-0db48a0e8a85
# ╟─a81a894a-713d-11eb-0dd8-9d9e8dffee35
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
# ╠═131244a8-7130-11eb-3770-a18a06eac45f
# ╠═6b906ab0-6c80-11eb-29a9-ab1e42290019
# ╟─3399e1f8-6cbb-11eb-329c-811efb68179f
# ╠═1f7e15e2-6cbb-11eb-1e92-9f37d4f3df40
# ╟─3bdf7df2-6cbb-11eb-2ea4-f5e465bd0e63
# ╠═2aa908f0-6cbb-11eb-1ee5-3399373632a5
# ╟─c069fd72-6f9a-11eb-000c-1fa67ae5bed4
# ╠═6bec11fe-6c75-11eb-2494-25e57c4c84c8
# ╠═c9de87e2-6f9a-11eb-06cf-d778ae009fb6
# ╠═c79b5e38-6f9a-11eb-05d3-9bf4844896f8
