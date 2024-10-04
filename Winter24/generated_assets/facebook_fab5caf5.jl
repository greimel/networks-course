### A Pluto.jl notebook ###
# v0.19.38

#> [frontmatter]
#> chapter = 4
#> section = 1
#> order = 1
#> title = "Social connectedness"
#> layout = "layout.jlhtml"
#> tags = ["social-networks"]
#> description = ""

using Markdown
using InteractiveUtils

# ╔═╡ 0c42d965-decc-42c5-9064-286aa2ea1a9a
using AoGExtensions

# ╔═╡ 11fb9a53-01a3-4646-9498-3d3b6624e82c
using GADM

# ╔═╡ 393969b9-6447-4493-8af0-231811611c22
using AlgebraOfGraphics

# ╔═╡ 0baf1637-46b7-446c-8737-9ef25436ec83
using AlgebraOfGraphics: to_geometry, trivialtransformation

# ╔═╡ d5139528-6dae-4e76-9b3a-c378219ea965
using Makie:
		Scatter, Poly, Lines,
		Legend, Figure, Axis, Colorbar,
		lines!, scatter, scatter!, poly!, vlines!, hlines!, image!,
		hidedecorations!, hidespines!

# ╔═╡ d9dc06a2-74b6-4c3a-adc0-b80f883456e4
using Makie: Label, Bottom, linkaxes!

# ╔═╡ 651fdd27-f145-48b3-b637-85bd0a031f9d
using Makie: @L_str, colgap!

# ╔═╡ 13f8193c-57a7-495f-b52b-511adf792903
using Colors: RGBA

# ╔═╡ bbf69c13-4757-4829-8690-16b1f201c24f
using DataFrameMacros

# ╔═╡ 7b1f3d74-e132-4f29-aa81-219bc78f7aaa
using Chain: @chain

# ╔═╡ 33f6e5f3-4c18-4c34-b78f-87cce2d5985e
using DataFrames: DataFrames, DataFrame,
		select, select!, transform, transform!, combine,
		leftjoin, innerjoin, rightjoin,
		groupby, ByRow, Not,
		disallowmissing!, dropmissing!, disallowmissing,
		stack, rename

# ╔═╡ 61986f4e-7386-478c-898a-aa2109e794e0
using CategoricalArrays: cut

# ╔═╡ 410d8606-c8ba-4fda-9bed-f6dff4384f14
using Statistics: mean

# ╔═╡ 39710fee-db54-4cf6-a939-5580b4b9c722
using SparseArrays: sparse

# ╔═╡ 03392660-b832-424a-88f5-aa341aad680e
using LinearAlgebra: I, dot, diag, Diagonal, norm

# ╔═╡ 3df898af-cf6d-4c8a-a09f-9ac0752525e6
using StatsBase: quantile, Weights, weights

# ╔═╡ 2baf0377-29ad-4ac1-8f2a-02d26cf9acae
using PlutoUI: TableOfContents

# ╔═╡ 1f7e15e2-6cbb-11eb-1e92-9f37d4f3df40
begin
	using Graphs
	using SimpleWeightedGraphs: SimpleWeightedGraph
	const LG = Graphs
	
	weighted_adjacency_matrix(graph::AbstractGraph) = LG.weights(graph) .* adjacency_matrix(graph)
	
	LG.adjacency_matrix(graph::SimpleWeightedGraph) = LG.weights(graph) .> 0
	
	function LG.katz_centrality(graph::AbstractGraph, α::Real=0.3; node_weights = ones(nv(graph)))
		v = node_weights

	    A = weighted_adjacency_matrix(graph)
    	v = (I - α * A) \ v
    	v /=  norm(v)
	end
	
	function LG.eigenvector_centrality(graph::AbstractGraph)
		A = weighted_adjacency_matrix(graph)
		eig = LG.eigs(A, which=LG.LM(), nev=1)
		eigenvector = eig[2]
	
		centrality = abs.(vec(eigenvector))
	end

	LG.outdegree(G::AbstractGraph) = vec(
		sum(weighted_adjacency_matrix(G), dims=2)
	)

	LG.indegree(G::AbstractGraph) = vec(
		sum(weighted_adjacency_matrix(G), dims=1)
	)	
end

# ╔═╡ 47594b98-6c72-11eb-264f-e5416a8faa32
md"""
`facebook.jl` | **Version 1.9** | *last updated: Feb 22, 2024*
"""

# ╔═╡ 7f8a57f0-6c72-11eb-27dd-2dae50f00232
md"""
# Social Connectedness: What Friendships on Facebook Tell Us About the World

Here is what we will cover.

#### Lecture Notes

1. Define the Social Connectedness Index, discuss its limitations
2. Measuring concentration of Social Networks
3. Approximating friends' characteristics

#### Pluto Notebook

4. Visualize social connectedness of a region
5. Regard the social connectedness index as the weights of network of regions. 
6. Compute the network concentration of US counties
7. Analyze the US presidential election 2020 using these concepts
"""

# ╔═╡ 547d93f4-6c74-11eb-28fe-c5be4dc7aaa6
md"""
# Visualizing Social Connectedness

There at least two ways to visualize social connectedness.

1. [Choropleth maps](https://en.wikipedia.org/wiki/Choropleth_map) allow visualizing the social connectedness of one region with other regions.

2. Heatmaps allow visualizing social connectedness of the full network.
"""

# ╔═╡ 710d5dfe-6cb2-11eb-2de6-3593e0bd4aba
country = "NL"

# ╔═╡ 8bee74ea-7140-11eb-3441-330ab08a9f38
md"""
## Visualizing the full network with a Heatmap
"""

# ╔═╡ e90eb932-6c74-11eb-3338-618a4ea9c211
md"""
# Social Connectedness as Weights of a Network of Regions
"""

# ╔═╡ d127df3e-710d-11eb-391a-89f3aeb8c219
md"""
# US Counties and US elections
"""

# ╔═╡ edf0f1e5-29eb-4bc9-88ca-2c1e0fbae7aa
#county_name = "Cook"; state = "Illinois"
county_name = "Los Angeles"; state = ""
# county_name = "New York"; state = ""

# ╔═╡ e0d17116-710d-11eb-1719-e18f188a6229
md"""
# Network Concentration
"""

# ╔═╡ 30350a46-712a-11eb-1d4b-81de61879835
add0_infty(from, to, dist) = from == to ? 0.0 : ismissing(dist) ? Inf : dist

# ╔═╡ 6f0b7a68-e830-4d37-a2bb-353205adb65f
distance = 150

# ╔═╡ cbed5f29-b55a-47a8-8986-0e98d4aed34b
format(a, b, i; kwargs...) = "$i"

# ╔═╡ f3b6d9be-712e-11eb-2f2d-af92e85304b5
md"""
# US Presidential Elections 2020
"""

# ╔═╡ 1f1f37a9-4c42-414f-8cb3-d9bfe57ddb3e
md"""
## Network concentration and election outcomes
"""

# ╔═╡ a3c5e85b-7bf1-4456-a3a3-02816f530239
md"""
## Partisan exposure and election outcomes

*(see Assignment)*
"""

# ╔═╡ 1600f95e-8b98-47fe-be7d-b1983c6a07b0
md"""
# Assignment 3: The Social Connectedness Index
"""

# ╔═╡ 96e4482c-6f9a-11eb-0e47-c568006368b6
md"""
### Task 1: Social connectedness is not distance (2 points)

The social connectedness is strongly correlated with distance. The closest geographical regions often have the highest social connectedness index.

👉 Think about a country for which you expect high social connectedness with a country far away. Replace the variable `country` (now *$(country)*) with the two-letter abbreviation of the country of your choice.

👉 Explain in <200 words why you would expect high social connectedness with this distant country. (Common) history? A stereotype?
"""

# ╔═╡ 6114ed16-6f9d-11eb-1bd4-1d1710b7f9df
answer1 = md"""
Your answer goes here ...
"""

# ╔═╡ 2338f91c-6f9e-11eb-0fb5-33421b7ae810
md"""
### Task 2: Measuring centrality in the network of regions (4 points)

Take another look at the list of *most central countries* according to the social connectedness index. *(Shown below.)*
"""

# ╔═╡ da7f397a-6fa6-11eb-19d5-972c93f11f91
md"""
Are you surprised by this list? Would you have expected some other countries at the top? There are two possibilities.

1. Our prior beliefs are wrong.

2. We don't measure what we want to measure.

Before we update our beliefs, let us think a bit about measuring centrality.

👉 (2.1 | 1 points) Discuss what problems you see with our measure of centrality. ( <200 words)
"""


# ╔═╡ d5c448e6-713c-11eb-1b3b-9b8e4af8ae5f
answer21 = md"""
Your answer goes here ...
"""

# ╔═╡ 55ab86e6-6fa8-11eb-2ac4-9f0548598014
md"""
👉 (2.2 | 2 points) Suggest an improved measure of centrality. Explain which of the problems you identified above are mitigated and how. (<200 words)
"""

# ╔═╡ dcb2cd6c-713c-11eb-1f3d-2de066d25c6f
answer22 = md"""
Your answer goes here ...
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
Your answer goes here ...
"""

# ╔═╡ e4a28c46-6fa8-11eb-0b80-658ffbab932b
md"""
### Task 3: Partisan exposure and election outcomes (4 points)

In the figure below you find the partisan exposure measure (which approximates the fraction of friends that votes Republican) against the outcome of the election. Each dot corresponds to one county.
"""

# ╔═╡ 39ea6d9a-6fab-11eb-2b00-f3eda1cd2677
md"""
There is a pretty strong correlation between these two measures. To some extent, this strong correlation is purely by construction. 

👉 (3.1 | 1.5 points) Why is that? Explain what's going on. (< 100 words)
"""

# ╔═╡ 2816c75e-713d-11eb-11ec-5391cb16ecc3
answer31 = md"""
Your answer goes here ...
"""

# ╔═╡ 07fd582c-223d-4b9c-805b-1ed396cde5bc
threshold = 300

# ╔═╡ 272f7770-6fab-11eb-32b9-01af616ae967
md"""
One way to remedy this sitation is to comment out line 6. Still, let us be cautious in interpreting this correlation causally.

One concern is, that this correlation is driven by *spatial autocorrelation*. That is, regions that are close are similar in many dimensions.

👉 (3.2 | 1.5 points) Why can't we interpret the correlation causally if there is spatial autocorrelation? Why is the problem alleviated (a bit) by commenting out line 7. What changes if you increase the threshold (currently $threshold)? (< 200 words)
"""

# ╔═╡ 2a61d17a-713d-11eb-2457-11e5c4dd792f
answer32 = md"""
Your answer goes here ...
"""

# ╔═╡ e0b9ac6c-a648-4b08-85cc-a0a040408f9d
md"""
👉 (3.3 | 1 points) Are there other reasons to believe that the correlation is not causal? Explain. (< 200 words)
"""

# ╔═╡ ec3a1a46-b1de-4a1d-939c-bf12ee55b658
answer33 = md"""
Your answer goes here ...
"""

# ╔═╡ e5f7cdab-c496-4309-bd9d-e0cf6f1d40d1
md"""
### Before you submit ...

👉 Make sure you have added your names and your group number in the cells below.

👉 Make sure that that **all group members proofread** your submission (especially your little essay).

👉 Make sure that you are **within the word limit**. Short and concise answers are appreciated. Answers longer than the word limit will lead to deductions.

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. (The source code is embedded in the html file.)
"""

# ╔═╡ 378c8a92-7129-4655-ac0b-f6aa02c600c6
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ f5882ac7-b1f2-4285-9bab-8abdd975afd1
group_number = 99

# ╔═╡ a3176884-6f9a-11eb-1831-41486221dedb
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the randomly generated names above by the names of your group and put the right group number in [this cell](#378c8a92-7129-4655-ac0b-f6aa02c600c6) and [this cell](#f5882ac7-b1f2-4285-9bab-8abdd975afd1)
	"""
end

# ╔═╡ 529053c2-4e8d-47c7-b135-0468f34b6ced
md"""
### Appendix to Task 3 
"""

# ╔═╡ 3062715a-6c75-11eb-30ef-2953bc64adb8
md"""
# Appendix
"""

# ╔═╡ 59047492-3f1d-48de-9f8c-e1dd8a90c89c
minimalaxis(; args...) = (; xticksvisible = false, yticksvisible = false, topspinevisible=false, bottomspinevisible=false, leftspinevisible=false, rightspinevisible=false, xgridvisible=false, ygridvisible=false, xticklabelsvisible=false, yticklabelsvisible=false, args...)

# ╔═╡ 0e556b16-5909-4853-9f78-76a071916f8d
md"""
## Specifying data deps
"""

# ╔═╡ ea4d4bba-5f8b-48ee-a171-7e7b90c2b062
dist_urls = [
	"500mi" => "https://nber.org/distance/2010/sf1/county/sf12010countydistance500miles.csv.zip",
	"100mi" => "https://data.nber.org/distance/2010/sf1/county/sf12010countydistance100miles.csv.zip"]

# ╔═╡ b0fc1027-4a33-49c6-b0ac-bb4e4bfb9414
sci_url_pre = "https://data.humdata.org/dataset/e9988552-74e4-4ff4-943f-c782ac8bca87/resource/"

# ╔═╡ b6d47ef5-5a9a-4e36-9bb4-d0d8fa4bcb38
sci_urls = [
	:countries =>
		"35ca6ade-a5bd-4782-b266-797169dca74b/download/countries-countries-fb-social-connectedness-index-october-2021.tsv",
	:US_counties =>
		"c59fd5ac-0458-4e83-b6be-5334f0ea9a69/download/us-counties-us-counties-fb-social-connectedness-index-october-2021.zip",
	:US_counties__countries => 
		"868a2fdb-f5c8-4a98-af7c-cfc8bf0daeb3/download/us-counties-countries-fb-social-connectedness-index-october-2021.tsv",
	:GADM_NUTS2 =>
		"cc5b6046-c417-4e25-930a-3d31538dffc5/download/gadm1_nuts2-gadm1_nuts2-fb-social-connectedness-index-october-2021.zip",
	:GADM_NUTS3_counties =>
		"18bf46fe-7f84-47b7-9d7e-b79a9c491f52/download/gadm1_nuts3_counties-gadm1_nuts3_counties-fb-social-connectedness-index-october-2021.zip"
	]

# ╔═╡ f5fdbf36-36e0-4714-9f35-ec538d3d447a
sci_checksums = Dict(
	:US_counties =>
		"023cf8a522a4e15ca321113adf9dcda85b7796fee3a5688f825ffc71a0eeaa1f",
	:countries =>
		"bc6269eb10da945e2327beb725e3ef4fa955fd430535b0357cc118a0b3c7cfd6",
	:US_counties__countries => nothing,
	:GADM_NUTS2 => nothing,
	:GADM_NUTS3_counties => nothing
	)

# ╔═╡ 5b4444ad-1156-4b8c-bf84-b6f993d9f52b
begin
	using DataDeps
	ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"
	
	for (id, url) in sci_urls
		register(DataDep(
    		"SCI_$id",
    		"""
	
			""",
    		sci_url_pre * url,
	    	sci_checksums[id],
		 	post_fetch_method = id ∉ [:US_counties__countries, :countries] ? unpack : identity 
		))
	end
	
	for (id, url) in dist_urls
		register(DataDep(
    		"county_dist_$id",
    		"""
	
			""",
    		url,
	    	#sci_checksums[id],
		 	post_fetch_method = unpack
		))
	end
	
	register(DataDep(
		"NaturalEarth",
		"""
			
		""",
"https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_countries.zip?version=4.0.0",
		"7ff25c5b1cca58ac85bc951fbdc660dc506889d952bae5eadb2567346ccadbb3",
		post_fetch_method = unpack
	))
	
	register(DataDep(
    	"US-Elections",
    	"""
	
		""",
    	[
				"https://raw.githubusercontent.com/tonmcg/US_County_Level_Election_Results_08-20/master/2016_US_County_Level_Presidential_Results.csv",
					"https://raw.githubusercontent.com/tonmcg/US_County_Level_Election_Results_08-20/master/2020_US_County_Level_Presidential_Results.csv"
		],
		"5e31e327837c1c6459e4d65ad248913b7503c47ac17f777a4c3659c1fa30cfa4"
	))
end

# ╔═╡ 19528ac3-4dcd-49cd-934d-fb0392394b59
function urls_to_files(urls)
	map(urls) do (id, url)
		file = split(url, "/") |> last |> string
		id => replace(file, ".zip" => "")
	end |> Dict
end

# ╔═╡ 765fa3eb-2ffe-4b7d-8dbd-191f21ec0302
#sci_files = urls_to_files(sci_urls)

# ╔═╡ 186246ce-6c80-11eb-016f-1b1abb9039bd
md"""
## Downloading the SCI Data
"""

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

# ╔═╡ 713ce11e-6c85-11eb-12f7-d7fac18801fd
function extract_shapes_df(shp_table)
	@chain shp_table begin
		DataFrame
		@select begin
			:shape = to_geometry(trivialtransformation, :geometry)
			:population = :POP_EST
			:gdp = :GDP_MD_EST
			:iso3c = :ADM0_A3
			:country = :ADMIN
		end
		@subset(!ismissing(:shape))
		disallowmissing
	end
end

# ╔═╡ 8575cb62-6c82-11eb-2a76-f9c1af6aab50
md"""
## Translating Country Codes
"""

# ╔═╡ a91896c6-6c82-11eb-018e-e514ca265b1a
url_country_codes = "https://raw.githubusercontent.com/datasets/country-codes/master/data/country-codes.csv"

# ╔═╡ 15139994-6c82-11eb-147c-59013c36a518
md"""
## Matching SCI and Map Shapes
"""

# ╔═╡ d4b337f4-7124-11eb-0437-e1e4ec1a61c9
md"""
## Preparations County level analysis
"""

# ╔═╡ fe752700-711a-11eb-1c13-3303010dfa48
md"""
### Matching County Names
"""

# ╔═╡ 3ec51950-711b-11eb-08fd-0d6ea3ee31ea
#node_county_ids

# ╔═╡ 278f55b0-711c-11eb-36d9-05fff7161d82
md"""
The SCI data contain data on county-equivalent entities from U.S. protectorates and freely associated states (e.g. American Samoa, Puerto Rico, Guam). For these entities the don't have additional data, so we drop them.
"""

# ╔═╡ 754db298-711b-11eb-3b0f-07e1d984dbe0
#filter(!in(county_acs_df.fips), node_county_ids)

# ╔═╡ a6b7545a-711c-11eb-13b4-6baf343485a0
md"""
Unfortunately, the map data don't contain FIPS codes, but county names. These are not in the same format as the names in `county_acs_df`.

* We need to remove identifiers like "County", "Parish", etc from the name.
* We need to handle capitalization and spaces in spanish names
* We need to handle the use of "St." vs "Saint"
"""

# ╔═╡ da19832e-710b-11eb-0e66-01111d3070b5
# filter out Alaska and Hawaii for plotting
#county_shapes_df = filter(:state => !in(["Hawaii", "Alaska"]), county_dict_shapes);

# ╔═╡ f048378e-11cb-4df6-968b-0f825ff2a7eb
function clean_county_name_for_matching(county)
	county_match = county
	
	repl = [
		" County"      => "",
		" Parish"      => "",
		" City"        => "", " city"    => "",
		" and Borough" => "", " Borough" => "",
		" Census Area" => "",
		" Municipality"=> "",
		"\xf1"         => "n", # ñ => n
		"St."          => "Saint",
		"Ste."         => "Sainte",
		"Oglala Lakota"=> "Shannon",
		" " => ""
	]
		
	for r in repl
		county_match = replace(county_match, r)
	end
		
	county_match = lowercase(county_match)
end

# ╔═╡ d7ebb76c-3b2b-465c-833e-a67c48506067
md"""
### Population data
"""

# ╔═╡ 15891beb-d614-4af4-81f7-8df5dc4dd6ba
pop_url = "https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/co-est2019-alldata.csv"

# ╔═╡ 945a9e42-974e-4be0-9d00-192b7f983f87
md"""
### Shapes
"""

# ╔═╡ 581b8793-808e-469a-9a4a-27e5ccce85ea
function get_county_shapes()
	country_code = "USA"
	lev2 = GADM.get(country_code, depth = 2)
	
	@chain lev2 begin
		DataFrame
		@select!(:state = :NAME_1, :county = :NAME_2, :shape = to_geometry(trivialtransformation, :geom))
		@transform!(:county_match = clean_county_name_for_matching(:county))
	end
end

# ╔═╡ 39d717a4-6c75-11eb-15f0-d537959a41b8
md"""
## Package Environment
"""

# ╔═╡ 7d28c5fa-4fe8-498a-97ca-095fa9d2d994
md"""
### Plotting
"""

# ╔═╡ 5191b535-3f4a-4b83-86ff-bd8085ff5615
import CairoMakie

# ╔═╡ 156b04d4-4e34-4128-a9b0-4e7b72c44623
md"""
### Data
"""

# ╔═╡ e21cd664-572f-4c89-b519-cdf5cfa21203
import CSV, HTTP, ZipFile

# ╔═╡ 0a47261d-1061-4c3d-bda8-7e0106c4a1df
function county_dist_data(id)
	urls = dist_urls
	id = string(id)
	files = urls_to_files(urls)
	valid_ids = first.(urls)
	if id ∉ valid_ids
		ArgumentError("provide one of $valid_ids") |> throw
	end
	path = joinpath(@datadep_str("county_dist_$id"), files[id])
	
	CSV.File(path) |> DataFrame
end

# ╔═╡ aab55326-7127-11eb-2f03-e9d3f30d1947
dff = county_dist_data("500mi")

# ╔═╡ 4ffaca67-8600-4f2c-a360-05c48a960cf2
function SCI_data(id)
	urls = sci_urls
	id = Symbol(id)
	files = urls_to_files(urls)
	valid_ids = first.(urls)
	if id ∉ valid_ids
		ArgumentError("provide one of $valid_ids") |> throw
	end
	if id == :US_counties
		path = joinpath(@datadep_str("SCI_$id"), "county_county.tsv")
	else
		path = joinpath(@datadep_str("SCI_$id"), files[id])
	end
	
	CSV.File(path) |> DataFrame
end

# ╔═╡ b20ab98c-710d-11eb-0a6a-7de2477acf35
county_df = SCI_data(:US_counties)

# ╔═╡ e1c5a635-c008-4ead-b170-6f2353693e20
begin
	node_county_ids, wgts2 = make_sci_graph(county_df)
	g_county = SimpleWeightedGraph(wgts2)
end

# ╔═╡ 759dd2da-f043-468f-891c-4fd17d701045
county_centrality_df = DataFrame(
	fips = node_county_ids,
	eigv_c = eigenvector_centrality(g_county)
	);

# ╔═╡ 575ea397-6ce1-4424-aa49-fca631c89570
let
	fig = Figure()
	ax = Axis(fig[1,1], title = "Social connectedness between US counties")
	
	image!(ax, RGBA.(0,0,0, min.(1.0, wgts2 .* 10_000)))
	
	fig
end

# ╔═╡ be47304a-6c80-11eb-18ad-974bb077e53f
get_county_sci() = SCI_data(:US_counties)

# ╔═╡ 3dc97a66-6c82-11eb-20a5-635ac0b6bac1
country_df = SCI_data(:countries)

# ╔═╡ aa423d14-6cb3-11eb-0f1c-65ebbf99d539
(; node_names, wgts) = make_sci_graph(country_df);

# ╔═╡ 29479030-6c75-11eb-1b96-9fd35f6d0840
g = SimpleWeightedGraph(wgts)

# ╔═╡ f02674bc-ad32-4f03-b511-01627e927c52
function elections_data(year)
	path = joinpath(
		datadep"US-Elections",
		"$(year)_US_County_Level_Presidential_Results.csv"
	)
	
	CSV.File(path) |> DataFrame
end

# ╔═╡ 1d8c5db6-712f-11eb-07dd-f1a3cf9a5208
df_elect0 = elections_data(2020)

# ╔═╡ 5a0d2490-6c80-11eb-0985-9de4f34412f1
function csv_from_url(url, args...; kwargs...)
	csv = CSV.File(HTTP.get(url).body, args...; kwargs...)
	df = DataFrame(csv)
end

# ╔═╡ 09109488-6c87-11eb-2d64-43fc9df7d8c8
codes_df = csv_from_url(url_country_codes)

# ╔═╡ c8d9234a-6c82-11eb-0f81-c17abae3e1c7
iso2c_to_fips = begin
	df = @chain codes_df begin
		@select(:iso2c = {"ISO3166-1-Alpha-2"},
				 :iso3c = {"ISO3166-1-Alpha-3"},
				 :fips = :FIPS,
				 :country = :official_name_en,
				 :continent = :Continent)
		dropmissing!
	end
	
	missing_countries = DataFrame([
			(iso2c = "XK", iso3c = "KOS", country = "Kosovo", fips = "KV", continent = "EU"),
			(iso2c = "TW", iso3c = "TWN", country = "Taiwan", fips = "TW", continent = "AS")
			])
	
	[df; missing_countries]
end

# ╔═╡ ce3486cf-8b42-4a7f-8cb5-04a27ad013d1
iso2c_to_fips

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

# ╔═╡ 05dcc1a2-6c83-11eb-3b62-2339a8e8863e
all(in(iso2c_to_fips.iso2c), node_names)

# ╔═╡ d8ea51ed-98da-4092-b464-9b269c7b7b56
pop_df = @chain pop_url begin
	csv_from_url(select = [:REGION, :DIVISION, :STATE, :COUNTY, :STNAME, :CTYNAME, :CENSUS2010POP])
	@transform(:fips_str = string(:STATE) * lpad(string(:COUNTY), 3, '0'))
	@select(
		:fips = Meta.parse(:fips_str),
		:state = :STNAME, :county = :CTYNAME,
		:population = :CENSUS2010POP,
	#	#:divisor = :STNAME * " " * :CTYNAME
	)
	@transform(:county_match = clean_county_name_for_matching(:county))
	@subset(:state != :county)
end

# ╔═╡ b9c0be22-7128-11eb-3da8-bb3a49e95fd7
df_c = @chain county_df begin		
	# add distances
	leftjoin(_, dff, on=[:user_loc => :county1, :fr_loc => :county2])
	# set distance to infinity if there are no data
	@transform!(:distance = add0_infty(:user_loc, :fr_loc, :mi_to_county))
	# add population
	leftjoin(_, pop_df, on = :fr_loc => :fips)
	@subset!(!ismissing(:population))
	disallowmissing!(:population)
end

# ╔═╡ afef1939-e7e8-4432-85c9-734d5c5c64ba
concentration_df0 = combine(groupby(df_c, :user_loc)) do all
		close = @subset(all, :distance < distance)
		
		concentration = dot(close.scaled_sci, close.population) / dot(all.scaled_sci, all.population)
		
		(; concentration)
end

# ╔═╡ d47df7ce-4be0-41b9-8f7f-28a4abd54518
extrema(skipmissing(df_c.mi_to_county))

# ╔═╡ b281826c-5092-4de5-8f6e-5cf95273e1cf
sci_with_distance = @chain df_c begin
	@select(:user_loc, :fr_loc, :scaled_sci, :distance)
end

# ╔═╡ 281198fa-712f-11eb-02ae-99a2d48099eb
df_elect = innerjoin(df_elect0, pop_df, on = :county_fips => :fips)

# ╔═╡ 22372514-1708-4a13-af50-bc7c45a43c52
exposure_df = @chain sci_with_distance begin
	groupby(:user_loc)
	combine(_) do gdf
		@chain gdf begin
			# @subset(:user_loc == :fr_loc)
			# @subset(:user_loc ≠ :fr_loc)
			# @subset(:distance > threshold)
			innerjoin(_, df_elect, on = :fr_loc => :county_fips)
			@aside wgts = _.scaled_sci .* _.population
			(; 
				rep_exp = mean(_.per_gop, weights(wgts)),
				dem_exp = mean(_.per_dem, weights(wgts)),
				vot_exp = dot(_.scaled_sci, _.total_votes) / sum(wgts)
			)
		end
	end
	rename(:user_loc => :fips)
end

# ╔═╡ 2bbeebe4-cf24-42b3-8696-3f3b70633b5b
df_elect_exposure = @chain df_elect begin
	@select(:fips = :county_fips, :per_gop, :per_dem, :turnout = :total_votes / :population)
	innerjoin(exposure_df, on = :fips)
end

# ╔═╡ 99c795b5-f7e9-4edf-8ae8-576753acdc2a
@chain df_elect_exposure begin
	data(_) * mapping(
		:rep_exp => "approximate share of Republican friends",
		:per_gop => "Republican vote share 2020"
	) * visual(Scatter, color = (:black, 0.3), markersize=5)
	draw(; figure = (; size = (300, 250)))
end

# ╔═╡ 2759d19a-a5bf-4c8a-ba95-f91c36c9a167
function get_county_shapes_info_df()
	shapes_df = get_county_shapes()
	@chain pop_df begin
		# join population with shapes
		leftjoin(_, shapes_df, on = [:state, :county_match], makeunique=true)
		# drop counties for which there is no shape (mostly Alaska)
		@aside begin
			not_matched = @subset(_, any(ismissing.([:county_1, :fips])))
#			not_matched = filter([:county_1, :fips] => (x,y) -> any(ismissing.([x,y])), _)
		end
		@subset!(!ismissing(:shape))
		# drop Alaska and Hawaii (for better plotting)
		@subset!(:state ∉ ["Alaska", "Hawaii"])
		select!(:county_1 => :county, Not([:county_1, :county_match]))
		disallowmissing!
	end
end

# ╔═╡ 3e01f0b2-0d1a-4fff-94c2-b3eb959fd08a
county_shapes_df = get_county_shapes_info_df()

# ╔═╡ 57368fa0-8f46-4711-9e76-bd7cc088efcb
fips, _df_ = let
	_df_ = @subset(county_shapes_df, contains(county_name)(:county))
	
	if size(_df_, 1) == 1
		fips = only(_df_.fips)
	else
		@subset!(_df_, :state == state)
		if size(_df_, 1) == 1
			fips = only(_df_.fips)
		else
			_df_
		end
	end
	fips, _df_
end

# ╔═╡ c7bddeb3-943a-458e-83d0-8d6371b59529
let
	df = @chain county_df begin
		@subset(:user_loc == fips)
		@select!(:fips = :fr_loc, :scaled_sci)
		innerjoin(county_shapes_df, _, on=:fips)
	end

	plt = data(df) * visual(Poly) * mapping(:shape, color = :scaled_sci => log)

	# define plot attributes
	figure = (; figure_padding = 3, size = (450, 300))
	axis = minimalaxis(
		title = "Social Connectedness with $county_name",
		aspect = 1.5, titlefont=:regular
	)
	
	draw(plt; axis, figure)
end

# ╔═╡ c20c6133-73a3-4742-bf22-35a479a99a9b
concentration_df = let
	df = innerjoin(county_shapes_df, concentration_df0, on=:fips => :user_loc)
	
	n = 20
	q = quantile(df.concentration, weights(df.population), 0:1/n:1)

	@chain df begin
		@transform!(:conc_grp = @bycol cut(:concentration, q, extend = true, labels = format))
		@transform!(:conc_grp_alt = parse(Int, string(:conc_grp)) % 2)
	end

	df
end;

# ╔═╡ c4c63797-1946-4a10-a03f-4c578ec5ae13
let
	@chain concentration_df begin
		@groupby(:conc_grp)
		@combine(
			:population    = mean(:population,    weights(:population)),
			:concentration = mean(:concentration, weights(:population))
		)
		#@aside @info scatter(_.concentration, log.(_.population), figure = (; size = (350, 250)))
	end
	
	@chain concentration_df begin
		@transform(:log_pop = log(:population))
		data(_) * mapping(
			:concentration, 
			:log_pop => "log(population)",
			weights=:population
		) * (
			visual(Scatter, markersize = 4) * mapping(color=:conc_grp_alt) +
			binscatter() * visual(color = :red)
		)
		draw(; figure = (; size = (600, 250), figure_padding = 3))
	end
end

# ╔═╡ 147cfa50-9a8b-432e-881c-5b16a6711d5c
let	
	plt = data(concentration_df) * visual(Poly) * mapping(:shape, color = :concentration)

	# Set plot attributes
	figure = (; figure_padding = 3, size = (450, 300))
	axis = minimalaxis(title = L"Network Concentration (% of friends $≤ %$distance \text{mi}$)", aspect = 1.5)
	
	draw(plt; axis, figure)
end

# ╔═╡ d1afd7c6-16ba-4961-8184-a05490d4ccac
df_conc_elect = innerjoin(
	select(concentration_df, :fips, :concentration),
	select(df_elect, :county_fips, :per_gop, :total_votes),
	on = :fips => :county_fips
)

# ╔═╡ be92efd8-7154-4663-bd88-fad7df34c7dc
@chain df_conc_elect begin
	data(_) * mapping(
			:concentration => "concentration",
			:per_gop => "Republican vote share", weights=:total_votes
		) * (
		#visual(Scatter, color = (:blue, 0.1)) +
		binscatter()
	)
	draw(; figure = (; size = (300, 250)))
end

# ╔═╡ 86d4b686-f0d0-4999-91d3-e7bf040df013
import Shapefile

# ╔═╡ b463d10f-d944-42c8-aa00-1b99d4f8b51e
function read_country_shapes()
	map_name = "ne_110m_admin_0_countries"
	Shapefile.Table(joinpath(datadep"NaturalEarth", map_name))
end

# ╔═╡ 60e9f650-6c83-11eb-270a-fb57f2449762
begin
	shapes_df = @chain begin
		read_country_shapes()
		extract_shapes_df
		leftjoin(iso2c_to_fips, on = :iso3c, makeunique = true)
	end
	
	function sci(country)
		@chain SCI_data(:countries) begin
			@subset(:user_loc == country)
			select!(Not(:user_loc))
			leftjoin(_, iso2c_to_fips, on = :fr_loc => :iso2c)
			leftjoin(_, shapes_df, on = :iso3c, makeunique = true)
			@subset!(!ismissing(:shape))
			@subset!(:fr_loc != country)
			disallowmissing!
		end
	end
end

# ╔═╡ 4f14a79c-6cb3-11eb-3335-2bbb61da25d9
sort(sci(country), :scaled_sci, rev=true)

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
	fig = Figure(size = (350, 350), figure_padding=3)
	ax = Axis(fig[1,1], title = "Social Connectedness Between Countries", xgridvisible = false, ygridvisible = false, aspect = 1)
	
	vlines!(ax, labels.start, color = :gray80)
	hlines!(ax, labels.start, color = :gray80)
	
	ax.xticks = (labels.mid, labels.continent)
	ax.yticks = (labels.mid, labels.continent)
	
	image!(ax, RGBA.(0,0,0, min.(1.0, wgts[df_nodes.id, df_nodes.id] .* 100)), interpolate=false)
	
	fig
end

# ╔═╡ b5464c40-6cbb-11eb-233a-b1557763e8d6
sort(df_nodes, :eigv_c, rev = true)

# ╔═╡ d1fd17dc-6fa6-11eb-245d-8bc905079f2f
df_nodes1; sort(df_nodes, :eigv_c, rev = true)

# ╔═╡ 64b321e8-6c84-11eb-35d4-b16736c24cea
no_data = @chain iso2c_to_fips begin
	@subset(:iso2c ∉ node_names)
	leftjoin(shapes_df, on = :iso3c, makeunique=true)
	@subset(!ismissing(:shape))	
	disallowmissing!
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
	fig = Figure(figure_padding = 3, size=(450, 400))
	ax = Axis(fig[1,1], title = "Centrality According to Facebook", aspect=1)
	hidedecorations!(ax)
	hidespines!(ax)
	
	color_variable = log.(df_nodes1.eigv_c)
	
	attr = (tellwidth = true, width = 15)
	
	# Plot the countries for which there is no SCI data
	poly!(ax, no_data.shape, color = :gray95)
	# Plot the countries with sci data
	poly!(ax, df_nodes1.shape, color = color_variable)
	
	cb = Colorbar(fig[1,2], limits = extrema(color_variable); attr..., label="log(centrality)")

	colgap!(fig.layout, 2)
	fig
	
end

# ╔═╡ 4da91cd0-6c86-11eb-31fd-2fe037228a52
@subset(shapes_df, ismissing(:continent))

# ╔═╡ fdc229f8-6c84-11eb-1ae9-d133fc05035e
nomatch = @chain shapes_df begin
	@subset(!ismissing(:iso2c))
	filter(∉(_.iso2c), node_names)
end

# ╔═╡ 34b2982a-6c89-11eb-2ae6-77e735c49966
@subset(iso2c_to_fips, :iso2c ∈ nomatch) # too small

# ╔═╡ 8a5dd546-a59e-42ae-9bf6-0a97982906cc
#using WorldBankData

# ╔═╡ 08e65ea4-952b-4c4c-83f0-05964f2f4f07
md"""
### Other
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
	# note LG == Graphs
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

# ╔═╡ 7b7005e6-72d8-4cf2-9d1b-1a124b57bdad
md"""
## Assignment infrastructure
"""

# ╔═╡ e33b5bb4-0a97-4fb7-9b2a-5a0bc0aab268
members = let
	names = map(group_members) do (; firstname, lastname)
		firstname * " " * lastname
	end
	join(names, ", ", " & ")
end

# ╔═╡ 44ef5554-713f-11eb-35fc-1b93349ca7fa
md"*Assignment submitted by* **$members** (*group $(group_number)*)"

# ╔═╡ 50e332de-6f9a-11eb-3888-d15d986aca8e
md"""
*submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ 0f762e98-e30d-4831-8b0d-14d0ae3f617b
function wordcount(text)
	stripped_text = strip(replace(string(text), r"\s" => " "))
   	words = split(stripped_text, (' ','-','.',',',':','_','"',';','!'))
   	length(words)
end

# ╔═╡ 68729271-a9d1-4308-89e0-efde5a3e481b
show_words(answer) = md"_approximately $(wordcount(answer)) words_"

# ╔═╡ c9de87e2-6f9a-11eb-06cf-d778ae009fb6
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
end

# ╔═╡ 52b29c95-35f7-44f7-b0f2-e2fb2231f7d5
hint(md"Uncomment line 5 in the cell below.")

# ╔═╡ 86d213e8-95ea-456c-b27b-a428ecd97348
function show_words_limit(answer, limit)
	count = wordcount(answer)
	if count < 1.02 * limit
		return show_words(answer)
	else
		return almost(md"You are at $count words. Please shorten your text a bit, to get **below $limit words**.")
	end
end

# ╔═╡ b0f46e9c-6f9d-11eb-1ed0-0fddd637fb6c
show_words_limit(answer1, 200)

# ╔═╡ 477b9a84-713d-11eb-2b48-0553087b0735
show_words_limit(answer21, 200)

# ╔═╡ 3e69678e-713d-11eb-3591-ff5c3563d0eb
show_words_limit(answer22, 200)

# ╔═╡ 4dd44354-713d-11eb-164b-0d143e507815
show_words_limit(answer31, 100)

# ╔═╡ 54291450-713d-11eb-37d2-0db48a0e8a85
show_words_limit(answer32, 200)

# ╔═╡ a6816468-0d3f-4050-80e1-29df52e471c1
show_words_limit(answer33, 200)

# ╔═╡ c069fd72-6f9a-11eb-000c-1fa67ae5bed4
md"""
## Other stuff
"""

# ╔═╡ 6bec11fe-6c75-11eb-2494-25e57c4c84c8
TableOfContents()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AlgebraOfGraphics = "cbdf2221-f076-402e-a563-3d30da359d67"
AoGExtensions = "7df18d33-496e-4cfd-8564-72cba2c0b329"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
CategoricalArrays = "324d7699-5711-5eae-9e2f-1d82baa6b597"
Chain = "8be319e6-bccf-4806-a6f7-6fae938471bc"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
DataDeps = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
DataFrameMacros = "75880514-38bc-4a95-a458-c2aea5a3a702"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
GADM = "a8dd9ffe-31dc-4cf5-a379-ea69100a8233"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Shapefile = "8e980c4a-a4fe-5da2-b3a7-4b4b0353a2f4"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
ZipFile = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"

[compat]
AlgebraOfGraphics = "~0.6.18"
AoGExtensions = "~0.1.12"
CSV = "~0.10.12"
CairoMakie = "~0.11.8"
CategoricalArrays = "~0.10.8"
Chain = "~0.5.0"
Colors = "~0.12.10"
DataDeps = "~0.7.12"
DataFrameMacros = "~0.4.1"
DataFrames = "~1.6.1"
GADM = "~1.1.0"
Graphs = "~1.9.0"
HTTP = "~1.10.1"
Makie = "~0.20.7"
PlutoUI = "~0.7.55"
Shapefile = "~0.12.0"
SimpleWeightedGraphs = "~1.4.0"
StatsBase = "~0.34.2"
ZipFile = "~0.10.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0"
manifest_format = "2.0"
project_hash = "2c2b6eb79ab11365cadf20035f5f2419c068bb94"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractLattices]]
git-tree-sha1 = "222ee9e50b98f51b5d78feb93dd928880df35f06"
uuid = "398f06c4-4d28-53ec-89ca-5b2656b7603d"
version = "0.3.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "c278dfab760520b8bb7e9511b968bf4ba38b7acc"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.3"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "0fb305e0253fd4e833d486914367a2ee2c2e78d0"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.1"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AlgebraOfGraphics]]
deps = ["Colors", "Dates", "Dictionaries", "FileIO", "GLM", "GeoInterface", "GeometryBasics", "GridLayoutBase", "KernelDensity", "Loess", "Makie", "PlotUtils", "PooledArrays", "PrecompileTools", "RelocatableFolders", "StatsBase", "StructArrays", "Tables"]
git-tree-sha1 = "3fbdee81b0cdc2b106b681dd2b9d4bdc60ca35a2"
uuid = "cbdf2221-f076-402e-a563-3d30da359d67"
version = "0.6.18"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.AoGExtensions]]
deps = ["AlgebraOfGraphics", "CategoricalArrays", "Chain", "DataFrameMacros", "DataFrames", "InteractiveUtils", "Markdown", "NamedDims", "Statistics", "StatsBase"]
git-tree-sha1 = "cd5770c09e0537d34b8519bceb1d91e1f8b23f71"
uuid = "7df18d33-496e-4cfd-8564-72cba2c0b329"
version = "0.1.12"

[[deps.ArchGDAL]]
deps = ["CEnum", "ColorTypes", "Dates", "DiskArrays", "Extents", "GDAL", "GeoFormatTypes", "GeoInterface", "GeoInterfaceRecipes", "ImageCore", "Tables"]
git-tree-sha1 = "8168d1cea4d02ae2a36022d8d681d94cbcd69b47"
uuid = "c9ce4bd3-c3d5-55b8-8973-c0e20141b8c3"
version = "0.10.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "bbec08a37f8722786d87bedf84eae19c020c4efa"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.7.0"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Arrow_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Lz4_jll", "Pkg", "Thrift_jll", "Zlib_jll", "boost_jll", "snappy_jll"]
git-tree-sha1 = "d64cb60c0e6a138fbe5ea65bcbeea47813a9a700"
uuid = "8ce61222-c28f-5041-a97a-c2198fb817bf"
version = "10.0.0+1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["PrecompileTools", "TranscodingStreams"]
git-tree-sha1 = "588e0d680ad1d7201d4c6a804dcb1cd9cba79fbb"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "1.0.3"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1f03a9fa24271160ed7e73051fba3c1a759b53f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.4.0"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.Blosc_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Lz4_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "19b98ee7e3db3b4eff74c5c9c72bf32144e24f10"
uuid = "0b7ba130-8d10-5ba8-a3d6-c5182647fed9"
version = "1.21.5+0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9e2a6b69137e6969bab0152632dcb3bc108c8bdd"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+1"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"

[[deps.CRlibm]]
deps = ["CRlibm_jll"]
git-tree-sha1 = "32abd86e3c2025db5172aa182b982debed519834"
uuid = "96374032-68de-5a5b-8d9e-752f78720389"
version = "1.0.1"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "679e69c611fff422038e9e21e270c4197d49d918"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.12"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["CRC32c", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "PrecompileTools"]
git-tree-sha1 = "a80d49ed3333f5f78df8ffe76d07e88cc35e9172"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.11.8"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "1568b28f91293458345dabba6a5ea3f183250a61"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.8"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.Chain]]
git-tree-sha1 = "8c4920235f6c561e401dfe569beb8b924adad003"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.5.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "ab79d1f9754a3988a7792caec43bfdc03996020f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.21.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "9b1ca1aa6ce3f71b3d1840c538a8210a043625eb"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.8.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "59939d8a997469ee05c4b4944560a820f9ba0d73"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.4"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "75bd5b6fc5089df449b5d35fa501c846c9b6549b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.12.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+1"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "8cfa272e8bdedfa88b6aefbbca7c19f1befac519"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"
weakdeps = ["IntervalSets", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.CovarianceEstimation]]
deps = ["LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "9a44ddc9e60ee398934b73a5168f5806989e6792"
uuid = "587fd27a-f159-11e8-2dae-1979310e6154"
version = "0.2.11"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBFTables]]
deps = ["Dates", "Printf", "Tables", "WeakRefStrings"]
git-tree-sha1 = "971a159c2ad2624dd86fff9ec39eea6d602170cd"
uuid = "75c7ada1-017a-5fb6-b8c7-2125ff2d6c93"
version = "1.2.4"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataDeps]]
deps = ["HTTP", "Libdl", "Reexport", "SHA", "Scratch", "p7zip_jll"]
git-tree-sha1 = "d481f6419c262edcb7294179bd63249d123eb081"
uuid = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
version = "0.7.12"

[[deps.DataFrameMacros]]
deps = ["DataFrames", "MacroTools"]
git-tree-sha1 = "5275530d05af21f7778e3ef8f167fb493999eea1"
uuid = "75880514-38bc-4a95-a458-c2aea5a3a702"
version = "0.4.1"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "ac67408d9ddf207de5cfa9a97e114352430f01ed"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.16"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelaunayTriangulation]]
deps = ["DataStructures", "EnumX", "ExactPredicates", "Random", "SimpleGraphs"]
git-tree-sha1 = "d4e9dc4c6106b8d44e40cd4faf8261a678552c7c"
uuid = "927a84f5-c5f4-47a5-9785-b46e178433df"
version = "0.8.12"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "1f3b7b0d321641c1f2e519f7aed77f8e1f6cb133"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.29"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.DiskArrays]]
deps = ["LRUCache", "OffsetArrays"]
git-tree-sha1 = "ef25c513cad08d7ebbed158c91768ae32f308336"
uuid = "3c3547ce-8d99-4f5e-a174-61eb10b00ae3"
version = "0.3.23"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "66c4c81f259586e8f002eacebc177e1fb06363b0"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.11"
weakdeps = ["ChainRulesCore", "SparseArrays"]

    [deps.Distances.extensions]
    DistancesChainRulesCoreExt = "ChainRulesCore"
    DistancesSparseArraysExt = "SparseArrays"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "7c302d7a5fec5214eb8a5a4c466dcf7a51fcf169"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.107"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.ExactPredicates]]
deps = ["IntervalArithmetic", "Random", "StaticArrays"]
git-tree-sha1 = "b3f2ff58735b5f024c392fde763f29b057e4b025"
uuid = "429591f6-91af-11e9-00e2-59fbe8cec110"
version = "2.2.8"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.Extents]]
git-tree-sha1 = "2140cd04483da90b2da7f99b2add0750504fc39c"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "4820348781ae578893311153d69049a93d05f39d"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.8.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "c5c28c245101bd59154f649e19b038d15901b5dc"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.2"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "5b93957f6dcd33fc343044af3d48c215be2562f1"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.9.3"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "Setfield", "SparseArrays"]
git-tree-sha1 = "73d1214fec245096717847c62d389a5d2ac86504"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.22.0"

    [deps.FiniteDiff.extensions]
    FiniteDiffBandedMatricesExt = "BandedMatrices"
    FiniteDiffBlockBandedMatricesExt = "BlockBandedMatrices"
    FiniteDiffStaticArraysExt = "StaticArrays"

    [deps.FiniteDiff.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "907369da0f8e80728ab49c1c7e09327bf0d6d999"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.1.1"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d8db6a5a2fe1381c1ea4ef2cab7c69c2de7f9ea0"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.1+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "055626e1a35f6771fe99060e835b72ca61a52621"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GADM]]
deps = ["ArchGDAL", "DataDeps", "Tables"]
git-tree-sha1 = "87e48061ace66c3e55d5e82bfe4094a2d04b8bed"
uuid = "a8dd9ffe-31dc-4cf5-a379-ea69100a8233"
version = "1.1.0"

[[deps.GDAL]]
deps = ["CEnum", "GDAL_jll", "NetworkOptions", "PROJ_jll"]
git-tree-sha1 = "50bfa3f63b47ed1873c35f7fea19893a288f6785"
uuid = "add2ef01-049f-52c4-9ee2-e494f65e021a"
version = "1.7.1"

[[deps.GDAL_jll]]
deps = ["Arrow_jll", "Artifacts", "Expat_jll", "GEOS_jll", "HDF5_jll", "JLLWrappers", "LibCURL_jll", "LibPQ_jll", "Libdl", "Libtiff_jll", "NetCDF_jll", "OpenJpeg_jll", "PROJ_jll", "SQLite_jll", "Zlib_jll", "Zstd_jll", "libgeotiff_jll"]
git-tree-sha1 = "f0d160a50c63520db7b8775e26365f1057381235"
uuid = "a7073274-a066-55f0-b90d-d619367d196c"
version = "301.800.300+0"

[[deps.GEOS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e143352a8a1b1c7236d05bc9e0982420099c46af"
uuid = "d604d12d-fa86-5845-992e-78dc15976526"
version = "3.12.0+0"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "273bd1cd30768a2fddfa3fd63bbc746ed7249e5f"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.9.0"

[[deps.GMP_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "781609d7-10c4-51f6-84f2-b8444358ff6d"
version = "6.2.1+6"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "ec632f177c0d990e64d955ccc1b8c04c485a0950"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.6"

[[deps.GeoFormatTypes]]
git-tree-sha1 = "59107c179a586f0fe667024c5eb7033e81333271"
uuid = "68eda718-8dee-11e9-39e7-89f7f65f511f"
version = "0.4.2"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "d4f85701f569584f2cff7ba67a137d03f0cfb7d0"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.3"

[[deps.GeoInterfaceMakie]]
deps = ["GeoInterface", "GeometryBasics", "MakieCore"]
git-tree-sha1 = "c15f793d501789ffa1cd171103406573d00f71cc"
uuid = "0edc0954-3250-4c18-859d-ec71c1660c08"
version = "0.1.5"

[[deps.GeoInterfaceRecipes]]
deps = ["GeoInterface", "RecipesBase"]
git-tree-sha1 = "fb1156076f24f1dfee45b3feadb31d05730a49ac"
uuid = "0329782f-3d07-4b52-b9f6-d3137cf03c7a"
version = "1.0.2"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "Extents", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "5694b56ccf9d15addedc35e9a4ba9c317721b788"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.10"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "e94c92c7bf4819685eb80186d51c43e71d4afa17"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.76.5+0"

[[deps.GnuTLS_jll]]
deps = ["Artifacts", "GMP_jll", "JLLWrappers", "Libdl", "Nettle_jll", "P11Kit_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "266fe9b2335527cbf569ba4fd0979e3d8c6fd491"
uuid = "0951126a-58fd-58f1-b5b3-b08c7c4a876d"
version = "3.7.8+1"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "899050ace26649433ef1af25bc17a815b3db52b7"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.9.0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "af13a277efd8a6e716d79ef635d5342ccb75be61"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.10.0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HDF5_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "LibCURL_jll", "Libdl", "MPICH_jll", "MPIPreferences", "MPItrampoline_jll", "MicrosoftMPI_jll", "OpenMPI_jll", "OpenSSL_jll", "TOML", "Zlib_jll", "libaec_jll"]
git-tree-sha1 = "e4591176488495bf44d7456bd73179d87d5e6eab"
uuid = "0234f1f7-429e-5d53-9886-15a909be8d59"
version = "1.14.3+1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "abbbb9ec3afd783a7cbd82ef01dcd088ea051398"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.1"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "f218fe3736ddf977e0e772bc9a586b2383da2685"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.23"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.ICU_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "20b6765a3016e1fca0c9c93c80d50061b94218b7"
uuid = "a51ab1cf-af8e-5615-a023-bc2c838bba6b"
version = "69.1.0+0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "2e4520d67b0cef90865b3ef727594d2a58e0e1f8"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.11"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "b2a7eaa169c13f5bcae8131a83bc30eff8f71be0"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.2"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "bca20b2f5d00c4fbc192c3212da8fa79f4688009"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.7"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "355e2b974f2e3212a75dfb60519de21361ad3cb7"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.9"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3d09a9f60edf77f8a4d99f9e015e8fbf9989605d"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.7+0"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "ea8031dea4aff6bd41f1df8f2fdfb25b33626381"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.4"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "b8ffb903da9f7b8cf695a8bead8e01814aa24b30"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.2"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5fdf2fe6724d8caabf43b557b84ce53f3b7e2f6b"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2024.0.2+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "88a101217d7cb38a7b481ccd50d21876e1d1b0e0"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.15.1"

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

    [deps.Interpolations.weakdeps]
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.IntervalArithmetic]]
deps = ["CRlibm", "RoundingEmulator"]
git-tree-sha1 = "c274ec586ea58eb7b42afd0c5d67e50ff50229b5"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "0.22.5"
weakdeps = ["DiffRules", "RecipesBase"]

    [deps.IntervalArithmetic.extensions]
    IntervalArithmeticDiffRulesExt = "DiffRules"
    IntervalArithmeticRecipesBaseExt = "RecipesBase"

[[deps.IntervalSets]]
git-tree-sha1 = "581191b15bcb56a2aa257e9c160085d0f128a380"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.9"
weakdeps = ["Random", "Statistics"]

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsStatisticsExt = "Statistics"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "fa6d0bcff8583bac20f1ffa708c3913ca605c611"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.5"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "60b1194df0a3298f460063de985eae7b01bc011a"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.1+0"

[[deps.Kerberos_krb5_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "60274b4ab38e8d1248216fe6b6ace75ae09b0502"
uuid = "b39eb1a6-c29a-53d7-8c32-632cd16f18da"
version = "1.19.3+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "fee018a29b60733876eb557804b5b109dd3dd8a7"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.8"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d986ce2d884d49126836ea94ed5bfb0f12679713"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.7+0"

[[deps.LRUCache]]
git-tree-sha1 = "b3cc6698599b10e652832c2f23db3cab99d51b59"
uuid = "8ac3fa9e-de4c-5943-b1dc-09c6b5f20637"
version = "1.6.1"
weakdeps = ["Serialization"]

    [deps.LRUCache.extensions]
    SerializationExt = ["Serialization"]

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibPQ_jll]]
deps = ["Artifacts", "ICU_jll", "JLLWrappers", "Kerberos_krb5_jll", "Libdl", "OpenSSL_jll", "Zstd_jll"]
git-tree-sha1 = "09163f837936c8cc44f4691cb41d805eb1769642"
uuid = "08be9ffa-1c94-5ee5-a977-46a84ec9b350"
version = "16.0.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "2da088d113af58221c52828a80378e16be7d037a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.5.1+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LightXML]]
deps = ["Libdl", "XML2_jll"]
git-tree-sha1 = "3a994404d3f6709610701c7dabfc03fed87a81f8"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.9.1"

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "7bbea35cec17305fc70a0e5b4641477dc0789d9d"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.2.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LinearAlgebraX]]
deps = ["LinearAlgebra", "Mods", "Primes", "SimplePolynomials"]
git-tree-sha1 = "d76cec8007ec123c2b681269d40f94b053473fcf"
uuid = "9b3f67b0-2d00-526e-9884-9e4938f8fb88"
version = "0.2.7"

[[deps.LittleCMS_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll"]
git-tree-sha1 = "08ed30575ffc5651a50d3291beaf94c3e7996e55"
uuid = "d3a379c0-f9a3-5b72-a4c0-6bf4d2e8af0f"
version = "2.15.0+0"

[[deps.Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "a113a8be4c6d0c64e217b472fb6e61c760eb4022"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.6.3"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.Lz4_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6c26c5e8a4203d43b5497be3ec5d4e0c3cde240a"
uuid = "5ced341a-0733-55b8-9ab6-a4889d929147"
version = "1.9.4+0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "72dc3cf284559eb8f53aa593fe62cb33f83ed0c0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2024.0.0+0"

[[deps.MPICH_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "MPIPreferences", "TOML"]
git-tree-sha1 = "2ee75365ca243c1a39d467e35ffd3d4d32eef11e"
uuid = "7cb0a576-ebde-5e09-9194-50597f1243b4"
version = "4.1.2+1"

[[deps.MPIPreferences]]
deps = ["Libdl", "Preferences"]
git-tree-sha1 = "8f6af051b9e8ec597fa09d8885ed79fd582f33c9"
uuid = "3da0fdf6-3ccc-4f1b-acd9-58baa6c99267"
version = "0.1.10"

[[deps.MPItrampoline_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "MPIPreferences", "TOML"]
git-tree-sha1 = "8eeb3c73bbc0ca203d0dc8dad4008350bbe5797b"
uuid = "f1f71cc9-e9ae-5b93-9b94-4fe0e1ad3748"
version = "5.3.1+1"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Makie]]
deps = ["Animations", "Base64", "CRC32c", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "DelaunayTriangulation", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG_jll", "FileIO", "FilePaths", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "InteractiveUtils", "IntervalArithmetic", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MacroTools", "MakieCore", "Markdown", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "PrecompileTools", "Printf", "REPL", "Random", "RelocatableFolders", "Scratch", "ShaderAbstractions", "Showoff", "SignedDistanceFields", "SparseArrays", "StableHashTraits", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun"]
git-tree-sha1 = "40c5dfbb99c91835171536cd571fe6f1ba18ff97"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.20.7"

[[deps.MakieCore]]
deps = ["Observables", "REPL"]
git-tree-sha1 = "248b7a4be0f92b497f7a331aed02c1e9a878f46b"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.7.3"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MutableArithmetics", "NaNMath", "OrderedCollections", "PrecompileTools", "Printf", "SparseArrays", "SpecialFunctions", "Test", "Unicode"]
git-tree-sha1 = "8b40681684df46785a0012d352982e22ac3be59e"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "1.25.2"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "UnicodeFun"]
git-tree-sha1 = "96ca8a313eb6437db5ffe946c457a401bbb8ce1d"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.5.7"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.MicrosoftMPI_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b01beb91d20b0d1312a9471a36017b5b339d26de"
uuid = "9237b28f-5490-5468-be7b-bb81f5f5e6cf"
version = "10.1.4+1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.Mods]]
git-tree-sha1 = "924f962b524a71eef7a21dae1e6853817f9b658f"
uuid = "7475f97c-0381-53b1-977b-4c60186c8d62"
version = "2.2.4"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.Multisets]]
git-tree-sha1 = "8d852646862c96e226367ad10c8af56099b4047e"
uuid = "3b2b4ff1-bcff-5658-a3ee-dbcf1ce5ac09"
version = "0.4.4"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "806eea990fb41f9b36f1253e5697aa645bf6a9f8"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.4.0"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NamedDims]]
deps = ["AbstractFFTs", "ChainRulesCore", "CovarianceEstimation", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "dc9144f80a79b302b48c282ad29b1dc2f10a9792"
uuid = "356022a1-0364-5f58-8944-0da4b18d706f"
version = "1.2.1"

[[deps.NetCDF_jll]]
deps = ["Artifacts", "Blosc_jll", "Bzip2_jll", "HDF5_jll", "JLLWrappers", "LibCURL_jll", "Libdl", "OpenMPI_jll", "XML2_jll", "Zlib_jll", "Zstd_jll", "libzip_jll"]
git-tree-sha1 = "a8af1798e4eb9ff768ce7fdefc0e957097793f15"
uuid = "7243133f-43d8-5620-bbf4-c2c921802cf3"
version = "400.902.209+0"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.Nettle_jll]]
deps = ["Artifacts", "GMP_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "eca63e3847dad608cfa6a3329b95ef674c7160b4"
uuid = "4c82536e-c426-54e4-b420-14f461c4ed8b"
version = "3.7.2+0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "6a731f2b5c03157418a20c12195eb4b74c8f8621"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.13.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+2"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "a4ca623df1ae99d09bc9868b008262d0c0ac1e4f"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.4+0"

[[deps.OpenJpeg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libtiff_jll", "LittleCMS_jll", "libpng_jll"]
git-tree-sha1 = "8d4c87ffaf09dbdd82bcf8c939843e94dd424df2"
uuid = "643b3616-a352-519d-856d-80112ee9badc"
version = "2.5.0+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenMPI_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "MPIPreferences", "TOML"]
git-tree-sha1 = "e25c1778a98e34219a00455d6e4384e017ea9762"
uuid = "fe0851c0-eecd-5654-98d4-656369965a5c"
version = "4.1.6+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "60e3045590bd104a16fefb12836c00c0ef8c7f8c"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.13+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Optim]]
deps = ["Compat", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "MathOptInterface", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "d024bfb56144d947d4fafcd9cb5cafbe3410b133"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.9.2"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.P11Kit_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "2cd396108e178f3ae8dedbd8e938a18726ab2fbf"
uuid = "c2071276-7c44-58a7-b746-946036e04d0a"
version = "0.24.1+0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "67186a2bc9a90f9f85ff3cc8277868961fb57cbd"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.3"

[[deps.PROJ_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "Libtiff_jll", "SQLite_jll"]
git-tree-sha1 = "f3e45027ea0f44a2725fbedfdb7ed118d5deec8d"
uuid = "58948b4f-47e0-5654-a9ad-f609743f8632"
version = "901.300.0+0"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "ec3edfe723df33528e085e632414499f26650501"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.5.0"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4745216e94f71cb768d58330b059c9b76f32cb66"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.14+0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Permutations]]
deps = ["Combinatorics", "LinearAlgebra", "Random"]
git-tree-sha1 = "eb3f9df2457819bf0a9019bd93cc451697a0751e"
uuid = "2ae35dd2-176d-5d53-8349-f30d82d94d4f"
version = "0.4.20"

[[deps.PikaParser]]
deps = ["DocStringExtensions"]
git-tree-sha1 = "d6ff87de27ff3082131f31a714d25ab6d0a88abf"
uuid = "3bbf5609-3e7b-44cd-8549-7c69f321e792"
version = "0.6.1"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "862942baf5663da528f66d24996eb6da85218e76"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "68723afdb616445c6caaef6255067a8339f91325"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.55"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.Polynomials]]
deps = ["LinearAlgebra", "RecipesBase", "Setfield", "SparseArrays"]
git-tree-sha1 = "a9c7a523d5ed375be3983db190f6a5874ae9286d"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "4.0.6"
weakdeps = ["ChainRulesCore", "FFTW", "MakieCore", "MutableArithmetics"]

    [deps.Polynomials.extensions]
    PolynomialsChainRulesCoreExt = "ChainRulesCore"
    PolynomialsFFTWExt = "FFTW"
    PolynomialsMakieCoreExt = "MakieCore"
    PolynomialsMutableArithmeticsExt = "MutableArithmetics"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "88b895d13d53b5577fd53379d913b9ab9ac82660"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.1"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "1d05623b5952aed1307bf8b43bec8b8d1ef94b6e"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.5"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "00099623ffee15972c16111bcf84c58a0051257c"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.9.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9b23c31e76e333e6fb4c1595ae6afa74966a729e"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.9.4"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.RingLists]]
deps = ["Random"]
git-tree-sha1 = "f39da63aa6d2d88e0c1bd20ed6a3ff9ea7171ada"
uuid = "286e9d63-9694-5540-9e3c-4e6708fa07b2"
version = "0.2.8"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SQLite_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "75e28667a36b5650b5cc4baa266c5760c3672275"
uuid = "76ed43ae-9a5d-5a62-8c75-30186b810ce8"
version = "3.45.0+0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "0e7508ff27ba32f26cd459474ca2ede1bc10991f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "79123bc60c5507f035e6d1d9e563bb2971954ec8"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.4.1"

[[deps.Shapefile]]
deps = ["DBFTables", "Extents", "GeoFormatTypes", "GeoInterface", "GeoInterfaceMakie", "GeoInterfaceRecipes", "OrderedCollections", "RecipesBase", "Tables"]
git-tree-sha1 = "efc2b1829c272bffbde1282ff2a076cdfa31fae6"
uuid = "8e980c4a-a4fe-5da2-b3a7-4b4b0353a2f4"
version = "0.12.0"
weakdeps = ["Makie"]

    [deps.Shapefile.extensions]
    ShapefileMakieExt = "Makie"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.ShiftedArrays]]
git-tree-sha1 = "503688b59397b3307443af35cd953a13e8005c16"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "2.0.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleGraphs]]
deps = ["AbstractLattices", "Combinatorics", "DataStructures", "IterTools", "LightXML", "LinearAlgebra", "LinearAlgebraX", "Optim", "Primes", "Random", "RingLists", "SimplePartitions", "SimplePolynomials", "SimpleRandom", "SparseArrays", "Statistics"]
git-tree-sha1 = "f65caa24a622f985cc341de81d3f9744435d0d0f"
uuid = "55797a34-41de-5266-9ec1-32ac4eb504d3"
version = "0.8.6"

[[deps.SimplePartitions]]
deps = ["AbstractLattices", "DataStructures", "Permutations"]
git-tree-sha1 = "e9330391d04241eafdc358713b48396619c83bcb"
uuid = "ec83eff0-a5b5-5643-ae32-5cbf6eedec9d"
version = "0.3.1"

[[deps.SimplePolynomials]]
deps = ["Mods", "Multisets", "Polynomials", "Primes"]
git-tree-sha1 = "7063828369cafa93f3187b3d0159f05582011405"
uuid = "cc47b68c-3164-5771-a705-2bc0097375a0"
version = "0.2.17"

[[deps.SimpleRandom]]
deps = ["Distributions", "LinearAlgebra", "Random"]
git-tree-sha1 = "3a6fb395e37afab81aeea85bae48a4db5cd7244a"
uuid = "a6525b86-64cd-54fa-8f65-62fc48bdc0e8"
version = "0.3.1"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays"]
git-tree-sha1 = "4b33e0e081a825dbfaf314decf58fa47e53d6acb"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.4.0"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2da10356e31327c7096832eb9cd86307a50b1eb6"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StableHashTraits]]
deps = ["Compat", "PikaParser", "SHA", "Tables", "TupleTools"]
git-tree-sha1 = "662f56ffe22b3985f3be7474f0aecbaf214ecf0f"
uuid = "c5dd0088-6c3f-4803-b00e-f31a60c170fa"
version = "1.1.6"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "7b0e9c14c624e435076d19aea1e5cbdec2b9ca37"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.2"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsAPI", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "5cf6c4583533ee38639f73b880f35fc85f2941e0"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.7.3"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.StructArrays]]
deps = ["Adapt", "ConstructionBase", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "1b0b1205a56dc288b71b1961d48e351520702e24"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.17"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Thrift_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "boost_jll"]
git-tree-sha1 = "fd7da49fae680c18aa59f421f0ba468e658a2d7a"
uuid = "e0b8ae26-5307-5830-91fd-398402328850"
version = "0.16.0+0"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "34cc045dd0aaa59b8bbe86c644679bc57f1d5bd0"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.8"

[[deps.TranscodingStreams]]
git-tree-sha1 = "54194d92959d8ebaa8e26227dbe3cdefcdcd594f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.3"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.TupleTools]]
git-tree-sha1 = "155515ed4c4236db30049ac1495e2969cc06be9d"
uuid = "9d95972d-f1c8-5527-a6e0-b4b365fa01f6"
version = "1.4.3"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c1a7aa6219628fcd757dede0ca95e245c5cd9511"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.0.0"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "801cbe47eae69adc50f36c3caec4758d2650741b"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.12.2+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "522b8414d40c4cbbab8dee346ac3a09f9768f25d"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.4.5+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "b4bfde5d5b652e22b9c790ad00af08b6d042b97d"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.15.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "f492b7fe1698e623024e873244f10d89c95c340a"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.10.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.boost_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7a89efe0137720ca82f99e8daa526d23120d0d37"
uuid = "28df3c45-c428-5900-9ff8-a3135698ca75"
version = "1.76.0+1"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaec_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eddd19a8dea6b139ea97bdc8a0e2667d4b661720"
uuid = "477f73a3-ac25-53e9-8cc3-50b2fa2566f0"
version = "1.0.6+1"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libgeotiff_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "Libtiff_jll", "PROJ_jll"]
git-tree-sha1 = "b1df2e0dd651ef0d2e9f4bdf9f2c4b121f79b345"
uuid = "06c338fa-64ff-565b-ac2f-249532af990e"
version = "100.701.100+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "93284c28274d9e75218a416c65ec49d0e0fcdf3d"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.40+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.libzip_jll]]
deps = ["Artifacts", "Bzip2_jll", "GnuTLS_jll", "JLLWrappers", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "9a6ac803f3c17fe7cf66430a8bfc7186800f08a4"
uuid = "337d8026-41b4-5cde-a456-74a10e5b31d1"
version = "1.9.2+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.snappy_jll]]
deps = ["Artifacts", "JLLWrappers", "LZO_jll", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "985c1da710b0e43f7c52f037441021dfd0e3be14"
uuid = "fe1e1685-f7be-5f59-ac9f-4ca204017dfd"
version = "1.1.9+1"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"
"""

# ╔═╡ Cell order:
# ╟─44ef5554-713f-11eb-35fc-1b93349ca7fa
# ╟─a3176884-6f9a-11eb-1831-41486221dedb
# ╟─47594b98-6c72-11eb-264f-e5416a8faa32
# ╟─7f8a57f0-6c72-11eb-27dd-2dae50f00232
# ╟─547d93f4-6c74-11eb-28fe-c5be4dc7aaa6
# ╠═710d5dfe-6cb2-11eb-2de6-3593e0bd4aba
# ╟─6d30c04a-6cb2-11eb-220b-998e7d5cc469
# ╠═4f14a79c-6cb3-11eb-3335-2bbb61da25d9
# ╠═aa423d14-6cb3-11eb-0f1c-65ebbf99d539
# ╟─8bee74ea-7140-11eb-3441-330ab08a9f38
# ╟─f25cf8be-6cb3-11eb-0c9c-f9ed04ded513
# ╠═ce3486cf-8b42-4a7f-8cb5-04a27ad013d1
# ╠═baecfe58-6cb6-11eb-3a4e-31bbb8da02ae
# ╠═cd3fd39a-6cb7-11eb-1d7f-459f25a393e4
# ╟─e90eb932-6c74-11eb-3338-618a4ea9c211
# ╠═29479030-6c75-11eb-1b96-9fd35f6d0840
# ╠═96cd1698-6cbb-11eb-0843-f9edd8f58c80
# ╠═b5464c40-6cbb-11eb-233a-b1557763e8d6
# ╠═d38c51d4-6cbb-11eb-09dc-a92080dea6c7
# ╟─d127df3e-710d-11eb-391a-89f3aeb8c219
# ╠═b20ab98c-710d-11eb-0a6a-7de2477acf35
# ╠═e1c5a635-c008-4ead-b170-6f2353693e20
# ╠═759dd2da-f043-468f-891c-4fd17d701045
# ╟─575ea397-6ce1-4424-aa49-fca631c89570
# ╠═3e01f0b2-0d1a-4fff-94c2-b3eb959fd08a
# ╠═57368fa0-8f46-4711-9e76-bd7cc088efcb
# ╠═edf0f1e5-29eb-4bc9-88ca-2c1e0fbae7aa
# ╟─c7bddeb3-943a-458e-83d0-8d6371b59529
# ╟─e0d17116-710d-11eb-1719-e18f188a6229
# ╠═aab55326-7127-11eb-2f03-e9d3f30d1947
# ╠═30350a46-712a-11eb-1d4b-81de61879835
# ╠═b9c0be22-7128-11eb-3da8-bb3a49e95fd7
# ╠═6f0b7a68-e830-4d37-a2bb-353205adb65f
# ╠═afef1939-e7e8-4432-85c9-734d5c5c64ba
# ╠═c20c6133-73a3-4742-bf22-35a479a99a9b
# ╠═cbed5f29-b55a-47a8-8986-0e98d4aed34b
# ╟─c4c63797-1946-4a10-a03f-4c578ec5ae13
# ╠═d47df7ce-4be0-41b9-8f7f-28a4abd54518
# ╟─147cfa50-9a8b-432e-881c-5b16a6711d5c
# ╟─f3b6d9be-712e-11eb-2f2d-af92e85304b5
# ╠═1d8c5db6-712f-11eb-07dd-f1a3cf9a5208
# ╠═281198fa-712f-11eb-02ae-99a2d48099eb
# ╟─1f1f37a9-4c42-414f-8cb3-d9bfe57ddb3e
# ╟─be92efd8-7154-4663-bd88-fad7df34c7dc
# ╟─d1afd7c6-16ba-4961-8184-a05490d4ccac
# ╟─a3c5e85b-7bf1-4456-a3a3-02816f530239
# ╟─1600f95e-8b98-47fe-be7d-b1983c6a07b0
# ╟─50e332de-6f9a-11eb-3888-d15d986aca8e
# ╟─96e4482c-6f9a-11eb-0e47-c568006368b6
# ╟─ac0bbc28-6f9b-11eb-1467-6dbd9d2b763a
# ╠═6114ed16-6f9d-11eb-1bd4-1d1710b7f9df
# ╟─b0f46e9c-6f9d-11eb-1ed0-0fddd637fb6c
# ╟─2338f91c-6f9e-11eb-0fb5-33421b7ae810
# ╠═d1fd17dc-6fa6-11eb-245d-8bc905079f2f
# ╟─da7f397a-6fa6-11eb-19d5-972c93f11f91
# ╠═d5c448e6-713c-11eb-1b3b-9b8e4af8ae5f
# ╟─477b9a84-713d-11eb-2b48-0553087b0735
# ╟─55ab86e6-6fa8-11eb-2ac4-9f0548598014
# ╠═dcb2cd6c-713c-11eb-1f3d-2de066d25c6f
# ╟─3e69678e-713d-11eb-3591-ff5c3563d0eb
# ╟─74c2e86c-6fa8-11eb-32f7-a97c939225ef
# ╠═778053a0-713d-11eb-10d9-0be586250eb1
# ╠═7b89e48e-713d-11eb-3838-a5de7e13f72b
# ╠═7f2a8d46-713d-11eb-08f1-3b310beea91c
# ╠═840a7d80-713d-11eb-19d5-594bcbb61ec0
# ╠═df16a43e-713c-11eb-15db-cdcdb1756588
# ╟─e4a28c46-6fa8-11eb-0b80-658ffbab932b
# ╟─99c795b5-f7e9-4edf-8ae8-576753acdc2a
# ╟─39ea6d9a-6fab-11eb-2b00-f3eda1cd2677
# ╠═2816c75e-713d-11eb-11ec-5391cb16ecc3
# ╟─4dd44354-713d-11eb-164b-0d143e507815
# ╟─52b29c95-35f7-44f7-b0f2-e2fb2231f7d5
# ╠═22372514-1708-4a13-af50-bc7c45a43c52
# ╠═07fd582c-223d-4b9c-805b-1ed396cde5bc
# ╟─272f7770-6fab-11eb-32b9-01af616ae967
# ╠═2a61d17a-713d-11eb-2457-11e5c4dd792f
# ╟─54291450-713d-11eb-37d2-0db48a0e8a85
# ╟─e0b9ac6c-a648-4b08-85cc-a0a040408f9d
# ╠═ec3a1a46-b1de-4a1d-939c-bf12ee55b658
# ╟─a6816468-0d3f-4050-80e1-29df52e471c1
# ╟─e5f7cdab-c496-4309-bd9d-e0cf6f1d40d1
# ╠═378c8a92-7129-4655-ac0b-f6aa02c600c6
# ╠═f5882ac7-b1f2-4285-9bab-8abdd975afd1
# ╟─529053c2-4e8d-47c7-b135-0468f34b6ced
# ╠═b281826c-5092-4de5-8f6e-5cf95273e1cf
# ╠═2bbeebe4-cf24-42b3-8696-3f3b70633b5b
# ╟─3062715a-6c75-11eb-30ef-2953bc64adb8
# ╠═59047492-3f1d-48de-9f8c-e1dd8a90c89c
# ╠═0c42d965-decc-42c5-9064-286aa2ea1a9a
# ╟─0e556b16-5909-4853-9f78-76a071916f8d
# ╠═ea4d4bba-5f8b-48ee-a171-7e7b90c2b062
# ╠═0a47261d-1061-4c3d-bda8-7e0106c4a1df
# ╠═b0fc1027-4a33-49c6-b0ac-bb4e4bfb9414
# ╠═b6d47ef5-5a9a-4e36-9bb4-d0d8fa4bcb38
# ╠═f5fdbf36-36e0-4714-9f35-ec538d3d447a
# ╠═19528ac3-4dcd-49cd-934d-fb0392394b59
# ╠═765fa3eb-2ffe-4b7d-8dbd-191f21ec0302
# ╠═4ffaca67-8600-4f2c-a360-05c48a960cf2
# ╠═5b4444ad-1156-4b8c-bf84-b6f993d9f52b
# ╠═f02674bc-ad32-4f03-b511-01627e927c52
# ╟─186246ce-6c80-11eb-016f-1b1abb9039bd
# ╠═5a0d2490-6c80-11eb-0985-9de4f34412f1
# ╠═be47304a-6c80-11eb-18ad-974bb077e53f
# ╟─a6939ede-6c80-11eb-21ce-bdda8fe67acc
# ╠═ca92332e-6c80-11eb-3b62-41f0301d6330
# ╟─72619534-6c81-11eb-07f1-67f833293077
# ╠═b463d10f-d944-42c8-aa00-1b99d4f8b51e
# ╠═713ce11e-6c85-11eb-12f7-d7fac18801fd
# ╟─8575cb62-6c82-11eb-2a76-f9c1af6aab50
# ╠═a91896c6-6c82-11eb-018e-e514ca265b1a
# ╠═09109488-6c87-11eb-2d64-43fc9df7d8c8
# ╠═c8d9234a-6c82-11eb-0f81-c17abae3e1c7
# ╟─15139994-6c82-11eb-147c-59013c36a518
# ╠═3dc97a66-6c82-11eb-20a5-635ac0b6bac1
# ╠═60e9f650-6c83-11eb-270a-fb57f2449762
# ╠═64b321e8-6c84-11eb-35d4-b16736c24cea
# ╠═05dcc1a2-6c83-11eb-3b62-2339a8e8863e
# ╠═4da91cd0-6c86-11eb-31fd-2fe037228a52
# ╠═fdc229f8-6c84-11eb-1ae9-d133fc05035e
# ╠═34b2982a-6c89-11eb-2ae6-77e735c49966
# ╟─d4b337f4-7124-11eb-0437-e1e4ec1a61c9
# ╟─fe752700-711a-11eb-1c13-3303010dfa48
# ╠═3ec51950-711b-11eb-08fd-0d6ea3ee31ea
# ╟─278f55b0-711c-11eb-36d9-05fff7161d82
# ╠═754db298-711b-11eb-3b0f-07e1d984dbe0
# ╟─a6b7545a-711c-11eb-13b4-6baf343485a0
# ╠═da19832e-710b-11eb-0e66-01111d3070b5
# ╠═f048378e-11cb-4df6-968b-0f825ff2a7eb
# ╟─d7ebb76c-3b2b-465c-833e-a67c48506067
# ╠═15891beb-d614-4af4-81f7-8df5dc4dd6ba
# ╠═d8ea51ed-98da-4092-b464-9b269c7b7b56
# ╟─945a9e42-974e-4be0-9d00-192b7f983f87
# ╠═11fb9a53-01a3-4646-9498-3d3b6624e82c
# ╠═581b8793-808e-469a-9a4a-27e5ccce85ea
# ╠═2759d19a-a5bf-4c8a-ba95-f91c36c9a167
# ╟─39d717a4-6c75-11eb-15f0-d537959a41b8
# ╟─7d28c5fa-4fe8-498a-97ca-095fa9d2d994
# ╠═5191b535-3f4a-4b83-86ff-bd8085ff5615
# ╠═393969b9-6447-4493-8af0-231811611c22
# ╠═0baf1637-46b7-446c-8737-9ef25436ec83
# ╠═d5139528-6dae-4e76-9b3a-c378219ea965
# ╠═d9dc06a2-74b6-4c3a-adc0-b80f883456e4
# ╠═651fdd27-f145-48b3-b637-85bd0a031f9d
# ╠═13f8193c-57a7-495f-b52b-511adf792903
# ╟─156b04d4-4e34-4128-a9b0-4e7b72c44623
# ╠═bbf69c13-4757-4829-8690-16b1f201c24f
# ╠═7b1f3d74-e132-4f29-aa81-219bc78f7aaa
# ╠═33f6e5f3-4c18-4c34-b78f-87cce2d5985e
# ╠═e21cd664-572f-4c89-b519-cdf5cfa21203
# ╠═86d4b686-f0d0-4999-91d3-e7bf040df013
# ╠═61986f4e-7386-478c-898a-aa2109e794e0
# ╠═8a5dd546-a59e-42ae-9bf6-0a97982906cc
# ╟─08e65ea4-952b-4c4c-83f0-05964f2f4f07
# ╠═410d8606-c8ba-4fda-9bed-f6dff4384f14
# ╠═39710fee-db54-4cf6-a939-5580b4b9c722
# ╠═03392660-b832-424a-88f5-aa341aad680e
# ╠═3df898af-cf6d-4c8a-a09f-9ac0752525e6
# ╠═2baf0377-29ad-4ac1-8f2a-02d26cf9acae
# ╟─3399e1f8-6cbb-11eb-329c-811efb68179f
# ╠═1f7e15e2-6cbb-11eb-1e92-9f37d4f3df40
# ╟─3bdf7df2-6cbb-11eb-2ea4-f5e465bd0e63
# ╠═2aa908f0-6cbb-11eb-1ee5-3399373632a5
# ╟─7b7005e6-72d8-4cf2-9d1b-1a124b57bdad
# ╠═e33b5bb4-0a97-4fb7-9b2a-5a0bc0aab268
# ╠═0f762e98-e30d-4831-8b0d-14d0ae3f617b
# ╠═68729271-a9d1-4308-89e0-efde5a3e481b
# ╠═86d213e8-95ea-456c-b27b-a428ecd97348
# ╠═c9de87e2-6f9a-11eb-06cf-d778ae009fb6
# ╟─c069fd72-6f9a-11eb-000c-1fa67ae5bed4
# ╠═6bec11fe-6c75-11eb-2494-25e57c4c84c8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
