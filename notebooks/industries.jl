### A Pluto.jl notebook ###
# v0.12.19

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

# ╔═╡ 2a132386-2b1f-11eb-1853-e3c32009e50c
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.add("PlutoUI")
	
	Pkg.add(["XLSX", "DataFrames", "LightGraphs", "Plots", "Underscores", "NamedArrays", "MetaGraphs", "SimpleWeightedGraphs", "GraphPlot"])
	Pkg.add("GraphDataFrameBridge")

	# Working with tabular data
	using DataFrames, NamedArrays
	using Underscores # piping
	# Working with graphs
	using LightGraphs, MetaGraphs, GraphDataFrameBridge#, SimpleWeightedGraphs
	# Visualization
	using Plots, GraphPlot
	# Reading Excel-Files
	using XLSX
	using SparseArrays
	using PlutoUI
end

# ╔═╡ 73521002-2b1f-11eb-14fa-8f445d00fd91
using Downloads

# ╔═╡ a29f0d46-614b-11eb-2d1b-717ef1c9dcff
TableOfContents()

# ╔═╡ c1e9325a-616f-11eb-1bc2-991abde9ff86


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

# ╔═╡ be66082e-2b28-11eb-37b2-b5261b9413b2
md"""
# Appendix
"""

# ╔═╡ 348e2384-614c-11eb-310b-5928a0e9b5b0
md"""
## Setting up the package environment
"""

# ╔═╡ 42fa0922-614c-11eb-1a00-c1cff7b8bcf4


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
W = adjacency_matrix(graph_ana)

# ╔═╡ 630bee26-2b4b-11eb-1506-652b4ae431a6
nnz(W) / prod(size(W))

# ╔═╡ 52821b38-2b4e-11eb-0258-672b1e609ac0
list_nodes(graph) = [(i = i, node_name = props(graph, i)[:name]) for i in 1:nv(graph)] |> DataFrame

# ╔═╡ 5a4e8994-2b4e-11eb-0ea8-c9d4ff48e57d
nodes_df = leftjoin(list_nodes(graph_ana), df_all, on = :node_name => :code);

# ╔═╡ 71720af4-2b4b-11eb-3c36-377f4dda5905
begin
	nodes_df1 = deepcopy(nodes_df)
	nodes_df1[!,:centrality] = eigenvector_centrality(graph_ana)
end;

# ╔═╡ 96a16f86-2b4b-11eb-33d4-c548ec069343
Plots.histogram(nodes_df1.centrality)

# ╔═╡ 8d00e92a-2b4b-11eb-06f5-fdcb9b0c5d12
sort(nodes_df1, :centrality, rev=true)

# ╔═╡ d4ba17ca-2b44-11eb-1501-3b03b4859c57
#gplot(graph, nodesize = nodes_df1.centrality)

# ╔═╡ d63ee986-2b44-11eb-1efe-f54faea6dbca
#gplot(graph, nodefillc = [RGBA(1,0,0,min(0.1 + 5 * c, 1.0)) for c in nodes_df1.centrality])

# ╔═╡ 0d2ec2cc-2b45-11eb-2b8a-c30d8b769089
#gplot(graph, nodefillc = [RGBA(1,0,0,min(0.1 + 5 * c, 1.0)) for c in nodes_df1.centrality])

# ╔═╡ Cell order:
# ╠═a29f0d46-614b-11eb-2d1b-717ef1c9dcff
# ╠═2a132386-2b1f-11eb-1853-e3c32009e50c
# ╠═c1e9325a-616f-11eb-1bc2-991abde9ff86
# ╟─321055b6-2b49-11eb-2ee6-d15ddc531d8e
# ╠═80751dbe-2b4d-11eb-0b68-f55bb8b677cb
# ╠═57c040be-2b4c-11eb-02ca-a78d0ba2d886
# ╠═6f7ae560-2b49-11eb-087d-c3fbe2313038
# ╟─013fccc8-2b4e-11eb-2ae7-6d9029db39f4
# ╠═b0f69646-2b4c-11eb-0220-050432bc8118
# ╠═58226916-2b34-11eb-1788-3da0d8047aab
# ╟─b074a7f4-2b4e-11eb-2dcf-0f23b99b1dbd
# ╟─26203d20-2b4e-11eb-2c8a-0f7b0394730e
# ╠═c451acc8-2b4d-11eb-3d90-29b2c2da2a44
# ╠═5a4e8994-2b4e-11eb-0ea8-c9d4ff48e57d
# ╠═d8866898-2b3a-11eb-2654-e3599b73a296
# ╠═630bee26-2b4b-11eb-1506-652b4ae431a6
# ╟─6881cac8-2b4f-11eb-376a-b746b0741df6
# ╠═71720af4-2b4b-11eb-3c36-377f4dda5905
# ╟─c2938920-2b4f-11eb-31f9-8d892db28f88
# ╠═96a16f86-2b4b-11eb-33d4-c548ec069343
# ╠═8d00e92a-2b4b-11eb-06f5-fdcb9b0c5d12
# ╟─be66082e-2b28-11eb-37b2-b5261b9413b2
# ╟─348e2384-614c-11eb-310b-5928a0e9b5b0
# ╠═42fa0922-614c-11eb-1a00-c1cff7b8bcf4
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
# ╠═d4ba17ca-2b44-11eb-1501-3b03b4859c57
# ╠═d63ee986-2b44-11eb-1efe-f54faea6dbca
# ╠═0d2ec2cc-2b45-11eb-2b8a-c30d8b769089
