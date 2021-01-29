### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 0d416c6a-6218-11eb-2f4b-594b9e7bf8a6
begin
	import Pkg
	Pkg.activate(temp = true)
	
	Pkg.add("CairoMakie")
	#Pkg.add(["WGLMakie", "JSServe"])
	Pkg.add(["GeometryBasics", "NetworkLayout"])
	#using WGLMakie, JSServe
	using CairoMakie
	using GeometryBasics, NetworkLayout
	CairoMakie.activate!(type = "png")
	#Page(exportable = true)
	
	_a_ = 1 # make sure this is run as cell #1
end

# ╔═╡ 0f429ed0-6218-11eb-1486-d508f430df6e
begin
	Pkg.add("PlutoUI")
	Pkg.add(["XLSX", "DataFrames", "LightGraphs", "Plots", "Underscores", "NamedArrays", "MetaGraphs", "SimpleWeightedGraphs", "GraphPlot", "Colors"])
	Pkg.add("GraphDataFrameBridge")

	# Working with tabular data
	using DataFrames, NamedArrays
	using Underscores # piping
	# Working with graphs
	using LightGraphs, MetaGraphs, GraphDataFrameBridge, SimpleWeightedGraphs
	# Visualization
	using GraphPlot, Colors#, Plots
	# Reading Excel-Files
	using XLSX
	using SparseArrays
	using PlutoUI
	using PlutoUI: Slider
	
	#using PooledArrays
	# using TabularMakie
	
	_a_ # make sure this is run as cell #2
end

# ╔═╡ 73521002-2b1f-11eb-14fa-8f445d00fd91
using Downloads

# ╔═╡ 35389b9e-6213-11eb-3886-01ddddc5ade2
md"""
# Production Networks: Overview

We will spend two lectures and one tutorial (Assignment 4) on production networks. Here is what we will be covering.

1. Input-Output Networks
    - Depicting an economy in one picture
    - Finding the central industries of an economy

2. Propagation of Shocks
    - Simulating the dynamic model of Long & Plosser (198X)
    - Deriving some analytical results of Acemoglu et al (201X)
"""

# ╔═╡ c1e9325a-616f-11eb-1bc2-991abde9ff86
md"""
## The Economy at a Glance: The Input-Output-Network
"""

# ╔═╡ ce86b610-6237-11eb-3977-07c18c2dd4a9
5

# ╔═╡ 0fab2ff8-6241-11eb-37ab-eb45c9977781


# ╔═╡ f53bd8ee-6212-11eb-160b-83d1bdef6bfc
#gplot(swg, nodesize = nodes_df1.centrality)

# ╔═╡ c85b82c6-623e-11eb-28d1-456c1d45504d
function edges_as_points(edges, node_positions;
			    		 weights = missing, min_wgt = -Inf, max_wgt = Inf)
	edges_as_pts = Point2f0[]

	for e in edges
		if ismissing(weights) || (min_wgt < weights[e.src, e.dst] < max_wgt)
			push!(edges_as_pts, node_positions[e.src])
    	    push!(edges_as_pts, node_positions[e.dst])
        	push!(edges_as_pts, Point2f0(NaN, NaN))
		end
    end
	
	edges_as_pts
end

# ╔═╡ 11a5c61a-6219-11eb-0ce4-0f0d2812cb0e
function nodes_edges(matrix, edges, node_positions = NetworkLayout.Spectral.layout(matrix); kwargs...)
	
	# generate a list of points that can be used to plot the graph
	edges_as_pts = edges_as_points(edges, node_positions; kwargs...)
	
	(; node_positions, edges_as_pts)
end

# ╔═╡ 68d455ce-623b-11eb-0ddf-cfa57c60851d
adj_nodes_edges(graph; kwargs...) = nodes_edges(adjacency_matrix(graph), edges(graph); kwargs...)

# ╔═╡ 473b706e-6213-11eb-02c8-97cfa38d0347
md"""
## A Recession Emerges: Propagation of Shocks
"""

# ╔═╡ 2b22880e-6213-11eb-274e-0b917e59c77d


# ╔═╡ 321055b6-2b49-11eb-2ee6-d15ddc531d8e
md"""
# The US Input-Output table as a network

Here is the list of edges.
"""

# ╔═╡ 80751dbe-2b4d-11eb-0b68-f55bb8b677cb
md" **Note to self: Use reduced form with ~70 industries first**"

# ╔═╡ 013fccc8-2b4e-11eb-2ae7-6d9029db39f4
md"""
## Visualization 1: Hard to see anything

Choose the cutoff to reduce number of edges: $(@bind cutoff Slider(0.005:0.0025:0.05, default = 0.01, show_value=true))
"""

# ╔═╡ 26203d20-2b4e-11eb-2c8a-0f7b0394730e
md"""
## Analyzing the network
"""

# ╔═╡ 6881cac8-2b4f-11eb-376a-b746b0741df6
md"""
## Finding the most central industries
"""

# ╔═╡ c2938920-2b4f-11eb-31f9-8d892db28f88
md"The distribution of centralities looks bell-shaped."

# ╔═╡ 206c0ab4-6215-11eb-3bf1-6338a3f9877f
md"""
# Propagation of Shocks: Simulating a dynamic multi-sector model
"""

# ╔═╡ 6a738b14-6215-11eb-0821-11a7a78a9d59


# ╔═╡ be66082e-2b28-11eb-37b2-b5261b9413b2
md"""
# Appendix
"""

# ╔═╡ 348e2384-614c-11eb-310b-5928a0e9b5b0
md"""
## Setting up the package environment
"""

# ╔═╡ 254c8fd2-614c-11eb-0698-51291ee0533d
md"""
## Downloading the Input-Output table
"""

# ╔═╡ b8da4972-2b1e-11eb-0227-67843f0cb6ac
url = "https://apps.bea.gov/industry/xls/io-annual/CxI_DR_2007_2012_DOM_DET.xlsx"

# ╔═╡ 740854ca-2b1f-11eb-28f3-73aa6501e930
file = Downloads.download(url)

# ╔═╡ 2251ea14-2b20-11eb-0227-4d7316d4060c
begin
	f = XLSX.readxlsx(file)
	sh = f["2007"]
end
	

# ╔═╡ e95fce70-2b28-11eb-19e2-a56ec4558c56
md"""
## A first look at the data

Data is usually messy. Here is some evidence.
"""

# ╔═╡ edb5a552-2b24-11eb-15e0-751e46577d09
begin
	code_column = sh["A6:A410"] |> vec .|> string # output == row
	name_column = sh["B6:B410"] |> vec .|> string
	code_row    = sh["C5:OQ5"]  |> vec .|> string  # input == column
	name_row    = sh["C4:OQ4"]  |> vec .|> string
	io_matrix   = sh["C6:OQ410"] .|> float
	
	df_in = DataFrame(
		:code => vec(code_row),
		:name => vec(name_row)		
	)
	df_out = DataFrame(
		:code => vec(code_column),
		:name => vec(name_column),
	)
end

# ╔═╡ df4894c8-2b30-11eb-2321-91860373eae2
io1 = NamedArray(io_matrix, (code_row, code_column), (:output, :input))

# ╔═╡ 7b844a74-2b29-11eb-330f-055645a9e1bb
md"**The vector of input industries is not the vector of output industries.**"

# ╔═╡ dbc69e56-2b28-11eb-1789-df192359f819
all(code_column .== code_row)

# ╔═╡ 3cea1a9a-2b2a-11eb-126b-7d5cc89e428b
md"""
Here are the industries that are *only outputs*.
"""

# ╔═╡ 93882850-2b1f-11eb-35cd-c35c1f1a554e
out_not_in = @_ df_out |>
	filter(!(_.code in(df_in.code)), __) |>
    select(__, [:code, :name])

# ╔═╡ 6150df66-2b2a-11eb-34c4-112889b9e4fd
md"""
Here are the industries that are *only inputs*.
"""

# ╔═╡ 006f8a84-2b2a-11eb-1cf8-1bf8a4ce3c31
in_not_out = @_ df_in |>
	filter(!(_.code in(df_out.code)), __) |>
    select(__, [:code, :name])

# ╔═╡ b5009b6c-2b2f-11eb-0b55-6b25489174ae
md"""
## Cleaning the data and constructing the list of edges
"""

# ╔═╡ d8621d0c-2b2e-11eb-2b6f-03636a7589d9
md"Combine all the industries and check that there are no duplicates. This could occur if the `(code, name)` pairs are not consistent between input and output industries."

# ╔═╡ fe01eb4c-2b2d-11eb-20a4-c57284b370e1
begin
	df_all = outerjoin(df_in, df_out, on = [:code, :name])
	n_rows = size(df_all, 1)
	
	@assert length(unique(df_all.code)) == n_rows
	@assert length(unique(df_all.name)) == n_rows
	
	
end

# ╔═╡ 608e5718-2b34-11eb-2c77-1bc36c400775
df000 = DataFrame(io_matrix, code_column)

# ╔═╡ 887882f6-2b34-11eb-1181-a77586ca14fd
df000[!,:output] = code_row

# ╔═╡ 0723e2c8-2b49-11eb-11ca-f10351d92f45
md"Here is the list of edges :-)"

# ╔═╡ b5c00db6-2b49-11eb-35e9-bd811fbe2a3f
begin
	io_edges0 = DataFrames.stack(df000, Not("output"), variable_name = "input")
	filter!(:value => >(0), io_edges0)
end

# ╔═╡ 57c040be-2b4c-11eb-02ca-a78d0ba2d886
sorted_edges = sort(io_edges0.value, rev=true)

# ╔═╡ b0f69646-2b4c-11eb-0220-050432bc8118
begin
	n_edges_to_keep = findfirst(sorted_edges .< cutoff)
	pc_dropped = round(100 * (1 - n_edges_to_keep / size(sorted_edges, 1)), digits = 3)
	md"With cutoff $cutoff we keep $n_edges_to_keep edges. That is, we dropped $(pc_dropped) % of edges."
end

# ╔═╡ 6f7ae560-2b49-11eb-087d-c3fbe2313038
io_edges(cutoff=0.0) = filter(:value => x -> x > cutoff, io_edges0)

# ╔═╡ 58226916-2b34-11eb-1788-3da0d8047aab
begin
	graph_viz = MetaGraph(io_edges(cutoff), :input, :output,
                       weight=:value)
	W_viz = adjacency_matrix(graph_viz)
	gplot(graph_viz, nodefillc = RGBA(1,0,0,0.3), arrowlengthfrac = 0.025)
end

# ╔═╡ b074a7f4-2b4e-11eb-2dcf-0f23b99b1dbd
W_viz

# ╔═╡ c451acc8-2b4d-11eb-3d90-29b2c2da2a44
graph_ana = MetaDiGraph(io_edges(0.0), :input, :output,
                       weight=:value)

# ╔═╡ d8866898-2b3a-11eb-2654-e3599b73a296
W = adjacency_matrix(graph_ana) .* weights(graph_ana)

# ╔═╡ a3bacef0-6215-11eb-1869-b375caf7c8e4
swg = SimpleWeightedDiGraph(W)

# ╔═╡ 022ed772-623e-11eb-2bc1-45fbdbccdb3d
let
	fig = Figure()
	ax = Axis(fig[1,1], title = "The Distribution of Input-Output Links")
	
	hist!(ax, log10.(filter(!=(0), weights(swg))), color = :lightblue)
	
	ax.xtickformat[] = "10^{:.1f}"
	
	fig
end

# ╔═╡ 3a7e6cf2-623e-11eb-16e8-0555386fccc0
nnz(parent(weights(swg)))

# ╔═╡ 6d8a3cbe-6245-11eb-1ee0-c52defc3c9f7
extrema(weights(swg))

# ╔═╡ 22069258-6216-11eb-3e83-7154e6e5e09b
eigenvector_centrality(swg)

# ╔═╡ 52821b38-2b4e-11eb-0258-672b1e609ac0
list_nodes(graph) = [(i = i, node_name = props(graph, i)[:name]) for i in 1:nv(graph)] |> DataFrame

# ╔═╡ 5a4e8994-2b4e-11eb-0ea8-c9d4ff48e57d
nodes_df = leftjoin(list_nodes(graph_ana), df_all, on = :node_name => :code);

# ╔═╡ 71720af4-2b4b-11eb-3c36-377f4dda5905
begin
	nodes_df1 = deepcopy(nodes_df)
	nodes_df1[!,:centrality] = eigenvector_centrality(swg)
end;

# ╔═╡ 7ac0e4c2-623c-11eb-1097-635550667caa
begin
	wgt = Matrix(weights(swg))
	
	#lwgt = [w == 0 ? 0.0 : log(w) .- log(minimum(filter(>(0), wgt))) for w in wgt]
	
	# the Stress layout also works
	
	node_positions = NetworkLayout.Spectral.layout(wgt, node_weights = nodes_df1.centrality .* 100)
	
	#node_positions = NetworkLayout.Stress.layout(wgt)
		
	cutoffs = [0.001,0.01,0.05,0.15,0.4,1.0]
	
	minmax = zip(cutoffs[1:end-1], cutoffs[2:end])
	#node_positions = NetworkLayout.Stress.layout(wgt + wgt')
	xane = map(minmax) do (min, max) 
		x = min + max
		
		ane = nodes_edges(wgt,
					  edges(SimpleGraph(wgt .+ wgt')),
					  node_positions, weights=wgt, min_wgt = min, max_wgt = max)
		
		(; x, ane)
	end
	
	ane = (; node_positions, xane)
end

# ╔═╡ d6c78332-621b-11eb-372d-9d322b577cd0
begin
	fig = Figure()
	
	ax = Axis(fig[1,1], spinewidth = 0, title = "The US Input-Output Network")
	
	hidedecorations!(ax)
	#edges_as_points(swg)


	for (x, ane) in ane.xane
		x > 0.0 && lines!(ax, ane.edges_as_pts, color = (:blue, min(1, 2 * √x)), linewidth = 0.05)
	end
	scatter!(ax, ane.node_positions, markersize = 100 .* nodes_df1.centrality)
	#weights(swg)
	fig
	
end

# ╔═╡ 96a16f86-2b4b-11eb-33d4-c548ec069343
Plots.histogram(nodes_df1.centrality)

# ╔═╡ 8d00e92a-2b4b-11eb-06f5-fdcb9b0c5d12
sort(nodes_df1, :centrality, rev=true)

# ╔═╡ d370caa2-6218-11eb-02b4-5da6bc763265
md"""
## Utilities for plotting graphs with Makie.jl
"""

# ╔═╡ a29f0d46-614b-11eb-2d1b-717ef1c9dcff
TableOfContents()

# ╔═╡ Cell order:
# ╟─35389b9e-6213-11eb-3886-01ddddc5ade2
# ╟─c1e9325a-616f-11eb-1bc2-991abde9ff86
# ╠═ce86b610-6237-11eb-3977-07c18c2dd4a9
# ╠═0fab2ff8-6241-11eb-37ab-eb45c9977781
# ╠═7ac0e4c2-623c-11eb-1097-635550667caa
# ╠═022ed772-623e-11eb-2bc1-45fbdbccdb3d
# ╠═3a7e6cf2-623e-11eb-16e8-0555386fccc0
# ╠═6d8a3cbe-6245-11eb-1ee0-c52defc3c9f7
# ╠═d6c78332-621b-11eb-372d-9d322b577cd0
# ╠═68d455ce-623b-11eb-0ddf-cfa57c60851d
# ╠═11a5c61a-6219-11eb-0ce4-0f0d2812cb0e
# ╠═f53bd8ee-6212-11eb-160b-83d1bdef6bfc
# ╠═c85b82c6-623e-11eb-28d1-456c1d45504d
# ╟─473b706e-6213-11eb-02c8-97cfa38d0347
# ╠═2b22880e-6213-11eb-274e-0b917e59c77d
# ╟─321055b6-2b49-11eb-2ee6-d15ddc531d8e
# ╠═80751dbe-2b4d-11eb-0b68-f55bb8b677cb
# ╠═57c040be-2b4c-11eb-02ca-a78d0ba2d886
# ╠═6f7ae560-2b49-11eb-087d-c3fbe2313038
# ╟─013fccc8-2b4e-11eb-2ae7-6d9029db39f4
# ╠═b0f69646-2b4c-11eb-0220-050432bc8118
# ╠═58226916-2b34-11eb-1788-3da0d8047aab
# ╟─b074a7f4-2b4e-11eb-2dcf-0f23b99b1dbd
# ╠═26203d20-2b4e-11eb-2c8a-0f7b0394730e
# ╠═c451acc8-2b4d-11eb-3d90-29b2c2da2a44
# ╠═5a4e8994-2b4e-11eb-0ea8-c9d4ff48e57d
# ╠═d8866898-2b3a-11eb-2654-e3599b73a296
# ╠═a3bacef0-6215-11eb-1869-b375caf7c8e4
# ╠═22069258-6216-11eb-3e83-7154e6e5e09b
# ╟─6881cac8-2b4f-11eb-376a-b746b0741df6
# ╠═71720af4-2b4b-11eb-3c36-377f4dda5905
# ╟─c2938920-2b4f-11eb-31f9-8d892db28f88
# ╠═96a16f86-2b4b-11eb-33d4-c548ec069343
# ╠═8d00e92a-2b4b-11eb-06f5-fdcb9b0c5d12
# ╟─206c0ab4-6215-11eb-3bf1-6338a3f9877f
# ╠═6a738b14-6215-11eb-0821-11a7a78a9d59
# ╟─be66082e-2b28-11eb-37b2-b5261b9413b2
# ╟─348e2384-614c-11eb-310b-5928a0e9b5b0
# ╠═0d416c6a-6218-11eb-2f4b-594b9e7bf8a6
# ╠═0f429ed0-6218-11eb-1486-d508f430df6e
# ╟─254c8fd2-614c-11eb-0698-51291ee0533d
# ╠═73521002-2b1f-11eb-14fa-8f445d00fd91
# ╠═b8da4972-2b1e-11eb-0227-67843f0cb6ac
# ╠═740854ca-2b1f-11eb-28f3-73aa6501e930
# ╠═2251ea14-2b20-11eb-0227-4d7316d4060c
# ╟─e95fce70-2b28-11eb-19e2-a56ec4558c56
# ╠═edb5a552-2b24-11eb-15e0-751e46577d09
# ╠═df4894c8-2b30-11eb-2321-91860373eae2
# ╟─7b844a74-2b29-11eb-330f-055645a9e1bb
# ╠═dbc69e56-2b28-11eb-1789-df192359f819
# ╟─3cea1a9a-2b2a-11eb-126b-7d5cc89e428b
# ╟─93882850-2b1f-11eb-35cd-c35c1f1a554e
# ╟─6150df66-2b2a-11eb-34c4-112889b9e4fd
# ╟─006f8a84-2b2a-11eb-1cf8-1bf8a4ce3c31
# ╟─b5009b6c-2b2f-11eb-0b55-6b25489174ae
# ╟─d8621d0c-2b2e-11eb-2b6f-03636a7589d9
# ╠═fe01eb4c-2b2d-11eb-20a4-c57284b370e1
# ╠═608e5718-2b34-11eb-2c77-1bc36c400775
# ╠═887882f6-2b34-11eb-1181-a77586ca14fd
# ╟─0723e2c8-2b49-11eb-11ca-f10351d92f45
# ╠═b5c00db6-2b49-11eb-35e9-bd811fbe2a3f
# ╠═52821b38-2b4e-11eb-0258-672b1e609ac0
# ╟─d370caa2-6218-11eb-02b4-5da6bc763265
# ╠═a29f0d46-614b-11eb-2d1b-717ef1c9dcff
