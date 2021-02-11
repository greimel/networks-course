### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 3f6c816c-6627-11eb-2bfb-b1b99f569133
begin
	_a_ = 1 # make sure this cell is run as cell #1
	
	using Pkg
	Pkg.activate(temp = true)
	
	Pkg.add(PackageSpec(name = "PlutoUI", version = "0.6.11-0.6"))
	using PlutoUI
end

# ╔═╡ 4e132d0e-6627-11eb-2012-59da6190e583
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

# ╔═╡ 686939ac-6627-11eb-2d3a-0f49463c1e80
begin
	_c_ = _b_ + 1 # Cell #3
	
	Pkg.add([
		PackageSpec(name="DataAPI", version="1.4"),
		PackageSpec(name = "LightGraphs", version = "1.3"),
		PackageSpec(name = "DataFrames", version = "0.22"),
		PackageSpec(name = "WorldBankData", version = "0.4.1-0.4"),
		PackageSpec(name = "Plots", version = "1.10"),	
		PackageSpec(url = "https://github.com/greimel/Shapefile.jl", rev="multipolygon")	
			])
	
	Pkg.add([
			"GeometryBasics", "FreqTables",
			"PooledArrays", "CategoricalArrays",
			"Underscores",
			"Plots",
			"Chain",
			"ZipFile",
			"SimpleWeightedGraphs", "GraphDataFrameBridge",
			"CSV", "HTTP"
			])

	using Statistics, SparseArrays, LinearAlgebra
	
	using WorldBankData
	using FreqTables
	using Chain: @chain
	using ZipFile, Shapefile
	using CSV, HTTP
	using DataFrames, PooledArrays, CategoricalArrays, Underscores
	using Plots
	Plots.gr(fmt = :png)
	
	using GeometryBasics
	
	
end

# ╔═╡ 33c4be58-685c-11eb-1ec2-551b92d6b275
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

# ╔═╡ ae5b5f84-6628-11eb-198b-7780f2f1df0c
md"""
`facebook.jl` | **Version 0.4** | *last updated: Feb 6*
"""

# ╔═╡ b6ec0220-6628-11eb-29ee-75ac6cf45e88
md"""
!!! danger "Preliminary version"
    Nice that you've found this notebook on github. We appreciate your engagement. Feel free to have a look. Please note that the assignment notebook is subject to change until a link is is uploaded to *Canvas*.
"""

# ╔═╡ d00377a2-6628-11eb-049a-e3e603d25976
md"""
# Social Connectedness: What Friendships on Facebook Tell Us About the World

This notebook will be the basis for part of **Lecture 5** *and* **Assignment 3**. Here is what we will cover.

1. 
"""

# ╔═╡ 5d87bd26-290d-11eb-2bfb-11b14ce73461
md"""
# Social connectedness

[Access the data](https://data.humdata.org/dataset/social-connectedness-index)

Reading:

Social Connectedness: Measurement, Determinants, and Effects
Michael Bailey, Rachel Cao, Theresa Kuchler, Johannes Stroebel, and Arlene Wong

(Journal of Economic Perspectives)

Plan:

* How to use the index
* Scatterplots, Histograms and Choropleths
* Connectedness of Amsterdam / the Netherlands
* Social connectedness and tradeflows
* Compute centralities

## The Social Connectedness Index (SCI): The Relative Probability of Friendship

Let $i$ and $j$ be two regions. Then the probability of friendship is defined as

```math
\text{relative probability of friendship} = \frac{\#F_{i,j}}{\#i \#j}
```
"""


# ╔═╡ 16ba7b92-2910-11eb-1d12-6f077e13e822
md"""
### Exercises

Regard the *relative probability of friendship* between two regions as weighted, undirected graph, where each region $i$ is a node the relative probability of friendship is the weight of the edge between nodes $i$ and $j$.

#### More concrete or interesting

* How does social connectedness correlate with Biden vote-share?
* How does social connectedness correlate with spread of Corona virus? (see NBER WP)

#### Less concrete or interesting

* Which European Country is the most central in this network?
* How does centrality correlate with population density?
* How does centrality correlate with vote-share of populist parties?
"""

# ╔═╡ 96a5beea-67cf-11eb-134a-cfa3c863dc35
md"""
# Social connectedness of the Netherlands
"""

# ╔═╡ 1ec06cb2-5029-11eb-013a-3975374db0c1
md"""
# Determining the central countries
"""

# ╔═╡ 171f03d8-686b-11eb-311e-23e332e76331


# ╔═╡ edd12b54-2928-11eb-1b5a-0551391e58b1
md"""
### To do

* Filter out small countries
* Plot a map with connectedness
* Interpret magnitudes
"""


# ╔═╡ e7e8fcb6-4ffd-11eb-3858-5b996fc3d669
md"""
# Social connectedness across US counties
"""

# ╔═╡ f6344148-6887-11eb-35e4-0fb1703301c6
md"""
## A first look
"""

# ╔═╡ 469ad5ee-502c-11eb-1322-f506ad275a0c
md"""
## US Presidential Election 2020

Let's see if we can find a relationship between social connectedness and the results of the US presidential election. Are more connected counties more likely or less likely to vote for Donald Trump?
"""

# ╔═╡ e7ab8dea-4ffd-11eb-2be0-d17e9e57e3b8
url_elect = "https://raw.githubusercontent.com/tonmcg/US_County_Level_Election_Results_08-20/master/2020_US_County_Level_Presidential_Results.csv"

# ╔═╡ 0c5176ea-502c-11eb-00dd-591685ca23f5
f_elect = CSV.File(HTTP.get(url_elect).body);

# ╔═╡ e1ffd48e-503a-11eb-0502-371d5b6bb750
elect_df0 = DataFrame(f_elect)

# ╔═╡ f43f6c1a-503a-11eb-22f2-f387b285320a
pop_df = select(elect_df0, :county_fips, :state_name, :total_votes)

# ╔═╡ bd00d952-687f-11eb-1855-d3aeaf9be425
md"""
## Concentration of social networks: What fraction of your friends live within 100 miles?
"""

# ╔═╡ 7bfa23bc-6881-11eb-221a-a3a955ee1c81
begin
	zipfile = download("https://data.nber.org/distance/2010/sf1/county/sf12010countydistance100miles.csv.zip")
	
	z = ZipFile.Reader(zipfile)	
	file_in_zip = only(z.files)

	dff = CSV.File(read(file_in_zip)) |> DataFrame
end

# ╔═╡ 20656098-6889-11eb-3d43-23f5409ac77b
unique(dff.county1) |> length

# ╔═╡ b7ce7d40-6889-11eb-131b-337d96477cf9


# ╔═╡ 6c5d25b4-5038-11eb-35b2-835c7c9fcf71
md"
## Potential Assignment

The plot above suggests that more socially connected counties where more likely to vote for Trump.

Convince me of the opposite.
"


# ╔═╡ 7ca3cee8-5031-11eb-36c8-dfb8f18fee2c
md"
# Appendix
"

# ╔═╡ 650cbc3e-502e-11eb-0373-ef5d9a5d8da8
PlutoUI.TableOfContents()

# ╔═╡ b54c75ce-67d3-11eb-0c15-7b7a3c1c36a9
md"""
## Translating country codes
"""

# ╔═╡ af2f97b6-2921-11eb-3e75-edbe4ed3b6f2
url_country_codes = "https://datahub.io/core/country-codes/r/country-codes.csv"

# ╔═╡ 6f526d02-67d4-11eb-2580-af247f14d669
df_countries = let
	f_cc = CSV.File(HTTP.get(url_country_codes).body)
	DataFrame(f_cc)
end

# ╔═╡ 4ad5626c-67d0-11eb-33f9-b95056de3d3f
iso2c_to_fips = dropmissing(select(df_countries, "ISO3166-1-Alpha-2" => :iso2c, :FIPS => :fips, :official_name_en => :country))

# ╔═╡ 8b2a68e0-678e-11eb-0db1-eb7f9c91f52f
md"""
## Downloading the maps
"""

# ╔═╡ 90693a54-688b-11eb-3caf-cf814d76a8de
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

# ╔═╡ 954f2bb2-678e-11eb-3572-23d7b93ee43e
function download_country_shapes()
	url = "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_countries.zip"
	map_name = "ne_110m_admin_0_countries"
	download_zipped_shapes(url, map_name)
end

# ╔═╡ 0990f7c6-6898-11eb-22a1-a79a5852d039
function download_county_shapes()
	url = "https://biogeo.ucdavis.edu/data/gadm3.6/shp/gadm36_USA_shp.zip"
	map_name = "gadm36_USA_2"
	download_zipped_shapes(url, map_name)
end

# ╔═╡ 581548ec-688f-11eb-1ec7-6d591814e201
county_tbl = download_county_shapes()

# ╔═╡ edc5ad6e-6894-11eb-38ed-630d03737612
poly(county_tbl.Geometry, color = rand(size(county_tbl, 1)))

# ╔═╡ b248cc88-67ba-11eb-0f39-ebba26500a36
begin
	tbl = download_country_shapes()
	tbl;
end

# ╔═╡ 0745b4da-67b6-11eb-3fc9-9720efb41634
function extract_shapes_df(shp_table)
	fips = shp_table.FIPS_10_
	population = shp_table.POP_EST
	gdp = shp_table.GDP_MD_EST
	continent = shp_table.CONTINENT
	shape = shp_table.Geometry
	df = DataFrame(; fips, shape, population, gdp, continent)
	filter!(:shape => !ismissing, df)
	disallowmissing!(df)
	
	df
end

# ╔═╡ b002f8c0-67b7-11eb-1bd4-1d541828af62
function get_shapes()
	shp_table = download_country_shapes()
	
	df = extract_shapes_df(shp_table)
end

# ╔═╡ 1c9b86c4-67d0-11eb-383b-9d4b15f7d454
shape_df = get_shapes();

# ╔═╡ 1b81dc28-67b9-11eb-11f2-bfcd1ea0e3e0
let
	shape_df = get_shapes()
	df = transform!(shape_df, :population => (x -> x/1_000_000) => :pop)

	fig = Figure()
	ax = Axis(fig[1,1])
	hidedecorations!(ax)
	hidespines!(ax)
	
	color_variable = log.(df.pop)
	
	attr = (tellwidth = true, width = 30)
	AbstractPlotting.poly!(ax, df.shape, color = color_variable)
	cb = Colorbar(fig[1,2], limits = extrema(color_variable); attr..., label="log(population)")

	fig
end

# ╔═╡ bd517a5c-67d4-11eb-0c39-cd5959c0779b
md"""
## Downloading the SSCI data
"""

# ╔═╡ 5df091ce-2913-11eb-1ca7-f35e88fa08d3
url_country_country = "https://data.humdata.org/dataset/e9988552-74e4-4ff4-943f-c782ac8bca87/resource/7c8f6c93-6272-4d39-9e5d-99cdc0053dfc/download/2020-12-16_country_country.tsv"

# ╔═╡ 845730f0-6887-11eb-1f82-63d3cea5d4e5
url_county = "https://data.humdata.org/dataset/e9988552-74e4-4ff4-943f-c782ac8bca87/resource/3e3a1a7e-b557-4191-80cf-33d8e66c2e51/download/county_county_aug2020.tsv"

# ╔═╡ 3705925e-6887-11eb-0e97-bba659ff4d8f
function csv_from_url(url)
	csv = CSV.File(HTTP.get(url).body)
	df = DataFrame(csv)
end

# ╔═╡ a921e756-6880-11eb-154f-4518b9eed66c
begin
	county_acs_csv = "https://github.com/social-connectedness-index/example-scripts/raw/master/covid19_exploration/_input/ACS_17_5YR_DP05.csv"
	county_acs_df0 = csv_from_url(county_acs_csv)
	
	county_acs_df = select!(county_acs_df0, "GEO.id2"=> :fips, "GEO.display-label" => :label, "HC01_VC03" => :pop)
end

# ╔═╡ f724bee2-6888-11eb-31ab-c11c2be90e58
unique(county_acs_df.fips) |> length

# ╔═╡ 50836d44-67d5-11eb-3613-0944a2286b6c
get_country_sci() = csv_from_url(url_country_country)

# ╔═╡ 01635b40-4fff-11eb-3fef-e3b4a4b2471a
df_sci = get_country_sci()

# ╔═╡ b87edc20-67cf-11eb-226f-57d643f11170
nl_df = filter(:user_loc => ==("NL"), df_sci)

# ╔═╡ e7589dee-67cf-11eb-2b39-c7a9e71748ce
merged = @chain nl_df begin
	leftjoin(iso2c_to_fips, on = :fr_loc => :iso2c)
	dropmissing
	leftjoin(shape_df, on = :fips)
end

# ╔═╡ 769687a2-67d1-11eb-2185-f1c1039769e7
let
	df0 = dropmissing(merged)
	
	the_country = "NL"
	df = filter(:fr_loc => !=(the_country), df0)
	
	#filter!(:fr_loc => !=("FR"), df)	
	#filter!(:continent => ==("Europe"), df)
	
	
	fig = Figure()
	ax = Axis(fig[1,1])
	hidedecorations!(ax)
	hidespines!(ax)
		
	
	color_variable = log.(df.scaled_sci ./ maximum(df.scaled_sci))
	
	attr = (tellwidth = true, width = 30)
	AbstractPlotting.poly!(ax, df.shape, color = color_variable)
	
	cb = Colorbar(fig[1,2], limits = extrema(color_variable); attr..., label="log(scaled sci)")

	AbstractPlotting.poly!(ax, filter(:fr_loc => ==(the_country), df0).shape, color = :red)
	
	#AbstractPlotting.xlims!(ax, -25, 40)
	#AbstractPlotting.ylims!(ax, 32, 70)


	fig
end

# ╔═╡ 2d65eb34-67d0-11eb-3f1f-d78da76f7ee7
filter(:shape => ismissing, merged)

# ╔═╡ 2f19ccfe-6887-11eb-0b60-85212b8492d7
get_county_sci() = csv_from_url(url_county)

# ╔═╡ d92e5196-5032-11eb-2b5c-d9432a997cd2
df_county = get_county_sci() # takes ~40s

# ╔═╡ fb31c764-67d4-11eb-2bcc-35b7aa3f58d1
md"""
## Constructing an SSCI network
"""

# ╔═╡ c233cbb0-66e4-11eb-320e-9f36dd0acf35
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

# ╔═╡ 89f72154-66e5-11eb-2f80-936e65b2da9b
node_names, wgts = make_sci_graph(df_sci);

# ╔═╡ dc1702c6-66e5-11eb-2014-c949f1c3aee9
begin
	g = SimpleWeightedGraph(wgts)
	gg = DenseWeightedGraph0(wgts)
end;

# ╔═╡ 92ccd81a-66ff-11eb-3f32-1bb0b4a2dc83
begin
	@assert eigenvector_centrality(g) ≈ eigenvector_centrality(gg)
	@assert katz_centrality(g) ≈ katz_centrality(gg)
end

# ╔═╡ a717fbd6-501d-11eb-2d98-efa84241c837
nodes_df0 = let
	df_nodes0 = DataFrame(name = node_names)
	#df_nodes0[:, :sci] = katz_centrality(gg)
	#transform!(df_nodes0, :sci => ByRow(log))

	missings = DataFrame([
			(iso2c = "XK", country = "Kosovo", continent = "EU"),
			(iso2c = "TW", country = "Taiwan", continent = "AS")
			])


	df_nodes = @chain df_countries begin
		select("official_name_en" => :country,
			   "ISO3166-1-Alpha-2" => :iso2c,
			   "Continent" => :continent)
		filter(:country => !ismissing, _)
		filter(:iso2c => !ismissing, _)
		[_; missings]
		leftjoin(df_nodes0, _, on=:name => :iso2c)
		disallowmissing
		transform!(:continent => ByRow(x -> x in(["AF", "AS", "EU"]) ? "1" : "2") => :Y_GRP)
	    transform!(:continent => ByRow(x -> x in(["AF", "NA"]) ? "1" : x in(["AS", "OC"]) ? "2" : "3") => :X_GRP)
	end
	
	df_nodes
	
end

# ╔═╡ 92d5a042-6710-11eb-32f5-c3f82f09443d
filter(:name => in(["XK", "TW"]), nodes_df0)

# ╔═╡ 92b9356a-6701-11eb-2bb0-a993dc765624
nodes_df = @chain begin
		wdi("SP.POP.TOTL", "all", 2019, 2019) 
		select(:iso2c, 
			   :SP_POP_TOTL => ByRow(x->x/1_000_000) => :population
			   )
		leftjoin(nodes_df0, _, on = :name => :iso2c)
		transform(:population => x -> disallowmissing(coalesce.(x, 0.0)), renamecols = false)
end

# ╔═╡ 4ace0b14-6700-11eb-23d6-4b486113ca4b
begin
	df = nodes_df
	df.katz_c = katz_centrality(g)
	df.eigv_c = eigenvector_centrality(g)
	df.w_katz = katz_centrality(g, node_weights = df.population)
	df
	
	merged2 = @chain nodes_df begin
		leftjoin(iso2c_to_fips, on = :name => :iso2c, makeunique=true)
		dropmissing
		leftjoin(shape_df, on = :fips, makeunique=true)
	end
	
	sort(df, :w_katz, rev= true)
end

# ╔═╡ 8b0570ca-670d-11eb-3c79-d3d635eb548b
color_dict = let
	grps = unique(df.continent)
	colors = distinguishable_colors(length(grps))
#	colors = cgrad(:viridis, length(grps), categorical=true)
	
	Dict(a => b for (a,b) in (zip(grps, colors)))
end

# ╔═╡ 5744288e-6709-11eb-1e3c-bbabcdc8a505
begin
	fig = Figure()
	ax = Axis(fig[1,1], xlabel = "log(population)", ylabel = "log(centrality)")
	
	@chain df begin
	#	filter(:population => <(500), _)
		filter(:population => !ismissing, _)
		groupby(:continent)
		combine(_) do sdf
			grp = only(unique(sdf.continent))
			AbstractPlotting.scatter!(ax, log.(sdf.population), log.(sdf.eigv_c), label= string(grp), color = color_dict[grp] )
		end
	end
	Legend(fig[1,2], ax)
	fig
end

# ╔═╡ 7c292744-67d6-11eb-3506-db73fca04a36
let
	df = dropmissing(merged2)
	
	#the_country = "NL"
	#df = filter(:fr_loc => !=(the_country), df0)
	
	#filter!(:fr_loc => !=("FR"), df)	
	#filter!(:continent => ==("Europe"), df)
	
	
	fig = Figure()
	ax = Axis(fig[1,1])
	hidedecorations!(ax)
	hidespines!(ax)
		
	
	color_variable = log.(df.eigv_c ./ maximum(df.eigv_c))
	
	attr = (tellwidth = true, width = 30)
	AbstractPlotting.poly!(ax, df.shape, color = color_variable)
	
	cb = Colorbar(fig[1,2], limits = extrema(color_variable); attr..., label="log(centrality)")

	#AbstractPlotting.poly!(ax, filter(:fr_loc => ==(the_country), df0).shape, color = :red)
	
	#AbstractPlotting.xlims!(ax, -25, 40)
	#AbstractPlotting.ylims!(ax, 32, 70)


	fig
end

# ╔═╡ 841e2886-670a-11eb-1370-9b58d5a21b4b
AbstractPlotting.scatter(nodes_df.population, katz_centrality(g))

# ╔═╡ 7e53ed56-6862-11eb-3f2a-c3d0c1f9b071
county_names, weights = make_sci_graph(df_county);

# ╔═╡ 9a448f2a-6862-11eb-0da2-07147ec80318
let
	fig = Figure()
	ax = Axis(fig[1,1], title = "Social connectedness between US counties")
	
	image!(ax, RGBA.(0,0,0, min.(1.0, weights .* 10_000)))
	
	fig
end

# ╔═╡ 39e40060-686b-11eb-34d5-8f8282af90c7
begin
	altwgts = ifelse.(weights .> 0, sqrt.(weights), weights)
	rowsums = sum(altwgts, dims = 2)
	altwgts = altwgts ./ maximum(rowsums)
end

# ╔═╡ 91ee15f4-686b-11eb-1df3-470f951b43da
all(altwgts .>= 0)

# ╔═╡ 0a2c6b02-6627-11eb-3630-2575e5bea391
md"""
## Setting up the package environment
"""

# ╔═╡ da8bb910-66ef-11eb-2c40-b34e9559d9ee
md"""
## Patch 1: Weights and Centralities
"""

# ╔═╡ b0a7b9fa-66fe-11eb-3314-adfcbc90ced0
md"""
## Patch 2: Dense Graphs
"""

# ╔═╡ 6769a26a-66e9-11eb-39be-d71128012f64
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

# ╔═╡ ad226e8a-6864-11eb-296c-0b30a61d1c0c
begin
	county_graph0 = SimpleWeightedGraph(altwgts)
	county_graph = DenseWeightedGraph(altwgts)
	nothing
end

# ╔═╡ bc8b6ca0-6864-11eb-399f-b5a02e86171f
eigenvector_centrality(county_graph0)

# ╔═╡ f951a6b8-6864-11eb-2b26-578f4dcd1ddb
eigenvector_centrality(county_graph)

# ╔═╡ 7bf7f414-6865-11eb-293e-95fcd8e23dac
katz_centrality(county_graph0)

# ╔═╡ 8850b5fc-6865-11eb-2866-0b4b60f51012
katz_centrality(county_graph)

# ╔═╡ 1520ba84-686a-11eb-33af-5f38e964127c
pagerank(county_graph0)

# ╔═╡ 8a7f16c8-5034-11eb-0314-d52737495ea5
begin
	df_county0 = DataFrame(name = county_names)
	df_county0.katz_c = katz_centrality(county_graph)
	df_county0.eigv_c = eigenvector_centrality(county_graph)
	
	df_county0 = leftjoin(df_county0, pop_df, on=:name => :county_fips)
	
	pop_wgt =  disallowmissing(coalesce.(df_county0.total_votes, 0))
	df_county0[:, :pop_wgt] = pop_wgt ./ sum(pop_wgt)
	
	df_county0
	#df_county0[:,:sci] = adj_county ./ maximum(adj_county) * df_county0.pop_wgt
	#dropdims(sum(adj_county, dims=2), dims=2)
end

# ╔═╡ 1b62c65c-502c-11eb-22ae-838e9f116590
begin	
	elect_df = leftjoin(elect_df0, df_county0, on=:county_fips => :name, makeunique=true)
	
	filter!(:katz_c => !ismissing, elect_df)
	disallowmissing!(elect_df, :katz_c)
	disallowmissing!(elect_df, :eigv_c)
	
	#filter!(:sci => !ismissing, elect_df)
	#transform!(elect_df, :sci => (x -> x/maximum(x)) => :sci)
	#transform!(elect_df, :sci => ByRow(log))
	transform!(elect_df, :total_votes => (x -> 100 .* x ./ maximum(x)) => :weight)
	
	disallowmissing!(elect_df, :per_gop)
	
	#filter!(:total_votes => x -> 200_000 < x < 100_000_000, elect_df)
end

# ╔═╡ 8ba3fbd4-6869-11eb-345f-bd8372c61c33

AbstractPlotting.scatter(elect_df.katz_c, log.(elect_df.total_votes), axis=(xlabel = "log(Katz centrality)", ylabel = "log(population)"))

# ╔═╡ ea061b7c-6868-11eb-3097-f9431da0368e
AbstractPlotting.scatter(log.(elect_df.eigv_c), elect_df.per_gop)

# ╔═╡ 1f08ff98-5035-11eb-33d2-7982e6f96305
data(elect_df) * mapping(:eigv_c => (x -> log.(x)), :per_gop) * (visual(Scatter, color = (:blue, 0.7)) * mapping(markersize = :weight)
	+ AlgebraOfGraphics.linear * mapping(wts = :weight) + AlgebraOfGraphics.linear) |> draw

# ╔═╡ Cell order:
# ╟─ae5b5f84-6628-11eb-198b-7780f2f1df0c
# ╟─b6ec0220-6628-11eb-29ee-75ac6cf45e88
# ╟─d00377a2-6628-11eb-049a-e3e603d25976
# ╟─5d87bd26-290d-11eb-2bfb-11b14ce73461
# ╟─16ba7b92-2910-11eb-1d12-6f077e13e822
# ╟─96a5beea-67cf-11eb-134a-cfa3c863dc35
# ╠═769687a2-67d1-11eb-2185-f1c1039769e7
# ╠═b87edc20-67cf-11eb-226f-57d643f11170
# ╠═1c9b86c4-67d0-11eb-383b-9d4b15f7d454
# ╠═e7589dee-67cf-11eb-2b39-c7a9e71748ce
# ╠═2d65eb34-67d0-11eb-3f1f-d78da76f7ee7
# ╟─1ec06cb2-5029-11eb-013a-3975374db0c1
# ╠═01635b40-4fff-11eb-3fef-e3b4a4b2471a
# ╠═89f72154-66e5-11eb-2f80-936e65b2da9b
# ╠═dc1702c6-66e5-11eb-2014-c949f1c3aee9
# ╠═92ccd81a-66ff-11eb-3f32-1bb0b4a2dc83
# ╠═4ace0b14-6700-11eb-23d6-4b486113ca4b
# ╠═8b0570ca-670d-11eb-3c79-d3d635eb548b
# ╠═5744288e-6709-11eb-1e3c-bbabcdc8a505
# ╟─7c292744-67d6-11eb-3506-db73fca04a36
# ╠═a717fbd6-501d-11eb-2d98-efa84241c837
# ╠═92d5a042-6710-11eb-32f5-c3f82f09443d
# ╠═92b9356a-6701-11eb-2bb0-a993dc765624
# ╠═841e2886-670a-11eb-1370-9b58d5a21b4b
# ╠═171f03d8-686b-11eb-311e-23e332e76331
# ╟─edd12b54-2928-11eb-1b5a-0551391e58b1
# ╟─e7e8fcb6-4ffd-11eb-3858-5b996fc3d669
# ╠═d92e5196-5032-11eb-2b5c-d9432a997cd2
# ╠═7e53ed56-6862-11eb-3f2a-c3d0c1f9b071
# ╟─f6344148-6887-11eb-35e4-0fb1703301c6
# ╠═9a448f2a-6862-11eb-0da2-07147ec80318
# ╠═39e40060-686b-11eb-34d5-8f8282af90c7
# ╠═91ee15f4-686b-11eb-1df3-470f951b43da
# ╠═ad226e8a-6864-11eb-296c-0b30a61d1c0c
# ╠═bc8b6ca0-6864-11eb-399f-b5a02e86171f
# ╠═f951a6b8-6864-11eb-2b26-578f4dcd1ddb
# ╠═7bf7f414-6865-11eb-293e-95fcd8e23dac
# ╠═8850b5fc-6865-11eb-2866-0b4b60f51012
# ╠═1520ba84-686a-11eb-33af-5f38e964127c
# ╠═8a7f16c8-5034-11eb-0314-d52737495ea5
# ╟─469ad5ee-502c-11eb-1322-f506ad275a0c
# ╠═e7ab8dea-4ffd-11eb-2be0-d17e9e57e3b8
# ╠═0c5176ea-502c-11eb-00dd-591685ca23f5
# ╠═e1ffd48e-503a-11eb-0502-371d5b6bb750
# ╠═f43f6c1a-503a-11eb-22f2-f387b285320a
# ╠═1b62c65c-502c-11eb-22ae-838e9f116590
# ╠═8ba3fbd4-6869-11eb-345f-bd8372c61c33
# ╠═ea061b7c-6868-11eb-3097-f9431da0368e
# ╠═1f08ff98-5035-11eb-33d2-7982e6f96305
# ╟─bd00d952-687f-11eb-1855-d3aeaf9be425
# ╠═7bfa23bc-6881-11eb-221a-a3a955ee1c81
# ╠═a921e756-6880-11eb-154f-4518b9eed66c
# ╠═f724bee2-6888-11eb-31ab-c11c2be90e58
# ╠═20656098-6889-11eb-3d43-23f5409ac77b
# ╠═b7ce7d40-6889-11eb-131b-337d96477cf9
# ╟─6c5d25b4-5038-11eb-35b2-835c7c9fcf71
# ╟─7ca3cee8-5031-11eb-36c8-dfb8f18fee2c
# ╠═650cbc3e-502e-11eb-0373-ef5d9a5d8da8
# ╟─b54c75ce-67d3-11eb-0c15-7b7a3c1c36a9
# ╠═4ad5626c-67d0-11eb-33f9-b95056de3d3f
# ╠═af2f97b6-2921-11eb-3e75-edbe4ed3b6f2
# ╠═6f526d02-67d4-11eb-2580-af247f14d669
# ╟─8b2a68e0-678e-11eb-0db1-eb7f9c91f52f
# ╠═b002f8c0-67b7-11eb-1bd4-1d541828af62
# ╠═954f2bb2-678e-11eb-3572-23d7b93ee43e
# ╠═0990f7c6-6898-11eb-22a1-a79a5852d039
# ╠═90693a54-688b-11eb-3caf-cf814d76a8de
# ╠═581548ec-688f-11eb-1ec7-6d591814e201
# ╠═edc5ad6e-6894-11eb-38ed-630d03737612
# ╠═b248cc88-67ba-11eb-0f39-ebba26500a36
# ╠═0745b4da-67b6-11eb-3fc9-9720efb41634
# ╠═1b81dc28-67b9-11eb-11f2-bfcd1ea0e3e0
# ╟─bd517a5c-67d4-11eb-0c39-cd5959c0779b
# ╠═5df091ce-2913-11eb-1ca7-f35e88fa08d3
# ╠═845730f0-6887-11eb-1f82-63d3cea5d4e5
# ╠═3705925e-6887-11eb-0e97-bba659ff4d8f
# ╠═50836d44-67d5-11eb-3613-0944a2286b6c
# ╠═2f19ccfe-6887-11eb-0b60-85212b8492d7
# ╟─fb31c764-67d4-11eb-2bcc-35b7aa3f58d1
# ╠═c233cbb0-66e4-11eb-320e-9f36dd0acf35
# ╟─0a2c6b02-6627-11eb-3630-2575e5bea391
# ╠═3f6c816c-6627-11eb-2bfb-b1b99f569133
# ╠═4e132d0e-6627-11eb-2012-59da6190e583
# ╠═686939ac-6627-11eb-2d3a-0f49463c1e80
# ╟─da8bb910-66ef-11eb-2c40-b34e9559d9ee
# ╠═33c4be58-685c-11eb-1ec2-551b92d6b275
# ╟─b0a7b9fa-66fe-11eb-3314-adfcbc90ced0
# ╠═6769a26a-66e9-11eb-39be-d71128012f64
