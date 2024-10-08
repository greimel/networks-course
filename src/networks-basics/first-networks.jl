### A Pluto.jl notebook ###
# v0.19.46

#> [frontmatter]
#> chapter = 2
#> section = 1
#> order = 1
#> title = "First networks (incl Assignment 1)"
#> layout = "layout.jlhtml"
#> tags = ["networks-basics"]
#> description = ""

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 97676f28-4ae3-446b-97ef-2b715f90d8fa
using DataFrames

# ╔═╡ 915ca82e-f358-4515-889a-5a226539223d
using Colors: @colorant_str

# ╔═╡ de6c3f24-618b-44a1-a9ef-b56bd35b4b87
using Graphs # for analyzing networks

# ╔═╡ 48442831-b63d-454f-8129-cff796aba54b
using SimpleWeightedGraphs # for handling weighted graphs

# ╔═╡ da797bdb-b027-4139-8446-91df190cb509
using MetaGraphs

# ╔═╡ 2ff77ccf-9f74-42a4-af0e-188c00dd9852
using SNAPDatasets # cool datasets of *big* networks

# ╔═╡ 48a5a2db-637a-4f8e-9994-ae6c1850ed70
using GraphMakie # for plotting networks

# ╔═╡ 7f248ca3-825f-4698-8ead-f7bd30e0d5c5
using NetworkLayout# layout algorithms

# ╔═╡ 30fa9b9e-8e78-43b8-8405-1e70087b7c63
using CairoMakie# hist

# ╔═╡ 6998ffab-2cf1-410f-b09c-5e70f2da0438
using Statistics: mean, std

# ╔═╡ 40358272-eca0-4a98-be8a-66fb23573d32
using FreqTables

# ╔═╡ 431229ad-a4f5-415c-8946-9888dc335857
using StatsBase: ecdf

# ╔═╡ 2ecf4ffd-d41d-494c-9fec-d681a176a8ba
using PlutoUI: TableOfContents, Slider

# ╔═╡ b4cec279-9bd4-46c5-8dc3-13003730916f
using PlutoUI

# ╔═╡ 2068d1e1-7c8a-4319-a440-8ef5ddc74369
using MarkdownLiteral: @markdown

# ╔═╡ eb6a3510-6477-11eb-0e4e-33557d794e45
md"""
`first-networks.jl` | **Version 1.7** | *last updated: October 7, 2024*
"""

# ╔═╡ 6009f070-5ef8-11eb-340a-d9780be085ad
md"""
# First networks in Julia

In this section we show you how to create networks in Julia and how to visualize them.

1. special named graphs
2. do it yourself
"""

# ╔═╡ df4d9fab-13da-4df7-b51e-0689112f65fe
md"""
## Networks with names

Let us plot our first networks. Below you see *star network* (can you imagine why it is called that way?). You can specify it by
"""

# ╔═╡ bdd75f9a-17e1-4b80-aa88-8a1477032441
n_nodes = 10

# ╔═╡ 6b1af27c-5d0a-43a2-b3a5-b02770aeb841
simple_network = StarGraph(n_nodes)

# ╔═╡ 165ba943-b546-42d0-84b2-00391572ff8e
f1 = graphplot(
	simple_network,
	# ilabels = vertices(simple_network)
)

# ╔═╡ 0f0dc575-7660-4b32-b158-95a9a0ab31e8
md"
Play around with this code. You can change the number of nodes and see you the plot will update automatically. 

You can also look at different *special* graphs

* wheel network (`WheelGraph`)
* circle network (`CycleGraph`)
* complete network (`CompleteGraph`)
* path network (`PathGraph`)

Try it and visualize a few graphs!
"

# ╔═╡ 04a1b174-0eb6-4116-81fc-9355a21dac5e
md"""
### Task 0 (3 points)

👉 Download and run Julia and Pluto. (If you submit this notebook you'll receive the points)

"""

# ╔═╡ e5f39c68-9a15-4c99-bdf1-2da05495bdd4
md"""
### Task 1 (1 point)

👉 Plot a complete network with 6 nodes. _(Adjust the code above.)_
"""

# ╔═╡ 7ca8de90-04bc-4e79-9905-59ffbdfae6af
f1

# ╔═╡ a0ea3f82-91a1-46c1-bb80-4ac050561f16
md"""
### Task 2 (2 points)

👉 Comparing a `StarGraph`, a `WheelGraph`, a `CycleGraph`, a `CompleteGraph` and a `PathGraph` with ``n = 6`` nodes. Which network has the most edges?
"""

# ╔═╡ 8a56d6d9-91e0-4f6d-8f7d-3cf62717b75c
Gs = [StarGraph, WheelGraph, CycleGraph, CompleteGraph, PathGraph]

# ╔═╡ 265e89b7-07e2-4102-b697-a8adaac042ff
graphs = [G(6) for G ∈ Gs]

# ╔═╡ 59dafdda-1e42-44f2-b0b9-6859dcdf8671
named_graphs = DataFrame(graph = graphs, name = string.(Symbol.(Gs)))

# ╔═╡ 31f06624-9fa0-4b7a-a869-aa2ede238854
let
	fig = Figure(size = (600, 350))
	for (i, (; name, graph)) ∈ enumerate(eachrow(named_graphs))

		ax = Axis(fig[fldmod1.(i, 3)...], title = name)
		hidedecorations!(ax)
		graphplot!(ax, graph)
	end

	fig
end
	

# ╔═╡ d6d7256c-1e1a-401a-a925-0a8fb8561138
let
	what_graph = []
	info = []
	
	for G ∈ Gs
		graph = G(6)
		push!(what_graph, G)
		push!(info, nv(graph))
	end

	what_graph, info
end

# ╔═╡ ff7668e2-43af-4b0c-8e06-ac6d3e1fce73
# goes

# ╔═╡ 5101887d-ed0d-46af-86b3-2412de936f5a
# here

# ╔═╡ 10b252de-4c0c-48ab-b579-2c9450e8f084
md"""
Your **answer** goes here
"""

# ╔═╡ b01cef89-6258-4050-9d35-7628eaf54010
begin
	my_network = SimpleDiGraph(7)
	add_edge!(my_network, 3, 4)
	add_edge!(my_network, 2, 3)
end

# ╔═╡ 5f1e3589-48fe-418a-958b-74b5dc0d7eff
md"""
## Building a network from scratch

Below you find a template of building a network from scratch. Play with it make it your own! (you can set the number of nodes (currently $(nv(my_network))) and add a few edges (there are currently $(ne(my_network))).

(Can you rebuild one of the named networks from above?)
"""

# ╔═╡ 67a2e792-647a-11eb-208e-4df018d00425
md"""
Note, that you can build directed graphs using `SimpleDiGraph`. Replace `SimpleDiGraph` by `SimpleGraph` to get an undirected graph.
"""

# ╔═╡ d3feb786-2c69-416f-8fda-e2b4da0c0c1c
graphplot(my_network, 
	layout=Shell(), 
	#arrow_size=20, 
	#node_color="orange",
	ilabels = vertices(my_network))

# ╔═╡ 2a46c00e-c740-4c67-9055-19d28dd09402
md"""
### Task 3 (2 points)

👉 Build a `WheelGraph` with ``n = 6`` from scratch.
"""

# ╔═╡ 4085f4f4-2e4f-4ddb-85b7-55b4c5ee5d29
task3_graph = let
	graph = SimpleGraph(5)

	# add your code here, e.g.
	add_edge!(graph, 1, 2)

	graph
end

# ╔═╡ 40defc1b-f9a7-4653-a52f-3d217a424ee5
let
	fig = Figure(size = (600, 250))
	n = 6
	task_comparison = WheelGraph(n)

	layout = Shell(; nlist = [[1]])
	a1, _ = graphplot(
		fig[1,1], task3_graph; layout, ilabels = vertices(task3_graph),
		axis = (; title = "Your attempt")
	)
	a2, _ = graphplot(
		fig[1,2], task_comparison; layout, ilabels = vertices(task_comparison),
		axis = (; title = "Your goal")
	)

	hidedecorations!(a1)
	hidedecorations!(a2)
	
	fig
end

# ╔═╡ 60bca082-5be8-46b9-acbf-2dbbcfa984ea
md"""
### Task 4 (2 points)

👉 Build a `StarGraph` with ``n = 25`` from scratch. **Add fewer than 20 lines of code!** (That is, use something more sophisticated than copy-paste. E.g., a `for` loop, vectorization, ...)
"""

# ╔═╡ 7f8a85ee-4476-4728-ba39-9f40c5da5161
(; task4_graph) = let
	graph = SimpleGraph(5)

	# add your code here, e.g.
	add_edge!(graph, 1, 3)
	
	(; task4_graph = graph)
end

# ╔═╡ 30ce82be-d68f-424d-8a4c-cb6272268251
let
	fig = Figure(size = (600, 250))
	task_comparison = StarGraph(25)

	layout = Shell(; nlist = [[1]])
	a1, _ = graphplot(
		fig[1,1], task4_graph; layout, ilabels = vertices(task4_graph),
		axis = (; title = "Your attempt")
	)
	a2, _ = graphplot(
		fig[1,2], task_comparison; layout, ilabels = vertices(task_comparison),
		axis = (; title = "Your goal")
	)

	hidedecorations!(a1)
	hidedecorations!(a2)
	
	fig
end

# ╔═╡ 0f454038-cb1d-457c-9a5e-bdf8deccface
md"""
# [End of Assignment]

Have a look at the rest of the material. It might be helpful for Assignment 2!
"""

# ╔═╡ 7057b8a6-91a9-495f-ac29-669d5652c8d0
md"""
# Building networks from real-world data

There are plenty of network datasets out there. You can check out the *Stanford Large Network Dataset Collection* [[link]](https://snap.stanford.edu/data/index.html). A very small subset of these datasets can be downloaded directly from Julia using the package *SNAPDatasets.jl* [[link]](https://github.com/JuliaGraphs/SNAPDatasets.jl).

Let us have a look at the Facebook dataset, with 4039 nodes and 88234 edges. [[link to description]](https://snap.stanford.edu/data/ego-Facebook.html)
"""

# ╔═╡ c28b2d55-63dc-4794-bfcd-a03172cb7f25
big_network = loadsnap(:facebook_combined)

# ╔═╡ c3946663-eddf-4bc1-bb52-9c82c8f7258c
md"Even though the dataset is rather small compared to others from this collection, we already run into problems when we want to visualize the network. 

The time it takes to plot a big network is mainly driven by the layout algorithm. That's why I choose the *boring* Shell algorithm, where all nodes are placed on a circle. This is very fast.

If you want, you can try to plot this with the default layout algorithm. (On my recent MacBook Pro, this took more than two minutes -- then I interrupted the execution of the cell.)
"

# ╔═╡ 07f7ed69-3e9a-4a6b-a10f-de8d09aa0db5
graphplot(big_network,
	layout = Shell(),
#	layout=SquareGrid(),
	node_size = 2,
	edge_width = 1,
	node_color = :blue,
	edge_color = (:orange, 0.01)
)

# ╔═╡ 3956c45f-23a9-4ec2-846f-d33706373d72
md"""
# Language for network analysis

We will discuss some useful concepts for analyzing networks. We will divide them into four groups.

**NOTE** The concepts of this section are introduced in the first lectures of the course. Have a look if you're curious. But it is rather meant as a references for your assignments.

If you cannot find what you need in this notebook, check out the excellent [documentation of Graphs.jl](https://juliagraphs.org/Graphs.jl/dev/).

#### Counting friends
* neighborhood
* degree (in/out)
* degree distribution, average degree

#### Are my friends friends themselves?
* clustering (average, total)

#### Friends of friends of friends ...
* walk
* path
* connected pair
* distance
* diameter
* connected network
* components

#### Cool kids

* centralities
"""

# ╔═╡ d25c59f6-8f99-4a83-8750-10518a13f6ae
network = big_network[∪(([k; neighbors(big_network, k)] for k ∈ [5, 50, 101, 500])...)]

# ╔═╡ 63fff52b-d485-4fb3-be2c-80039e6ebc2a
nodes = rand(1:nv(big_network), 10) |> unique

# ╔═╡ edbb8f3b-f133-481b-8972-fdcd87b5acef
md"""
## Neighborhood and degree of a node _(Counting friends)_

The **neighborhood of a node ``i``** is the set of friends of (_nodes that are connected to_) ``i``.

Let ``i = ``$(@bind i Slider(1:nv(network), default = 1, show_value=true)), then the neighborhood of ``i`` is shown below.

The **degree of a node ``i``** is number of friends (_connected nodes_) of ``i``. (Show degree $(@bind show_degree CheckBox(default = false)))
"""

# ╔═╡ 75194951-3f88-4855-98d4-a987430f5b00
md"""
The **degree distribution** is the distribution of the number of friends. We can  compute statistics of the distribution (e.g. the **average degree**: $(round(mean(degree(network)), digits=2))). Or we can visualize the full distribution in a histogram.
"""

# ╔═╡ 4b0dc2b4-a56d-45e3-8d58-a53978c4ff7f
hist(degree(network), bins=1:25, normalization=:probability, axis=(title = "The degree distribution (The distribution of the number of friends)", ylabel = "relative frequency", xlabel="degree (number of friends)"))

# ╔═╡ 609dfa37-2208-40b7-bc47-60d0c9ec54c8
md"""
## Clustering _(Are my friends friends themselves?)_

This time we look at node ``j = ``$(@bind j Slider(1:nv(network), default = 12, show_value=true)).
"""

# ╔═╡ ac1291c8-e560-4457-ad58-47c70ade7dca
degree_of_j = degree(network, j)

# ╔═╡ 228237f5-4884-4575-9dc4-a5c33b9afdae
actual_links, possible_links = local_clustering(network, j)

# ╔═╡ 0cd4e0a0-fa38-4b05-8688-6396093d2652
md"""
We see that the node has $degree_of_j friends. These $degree_of_j friends can form at most $degree_of_j ⋅ $(degree_of_j - 1) / 2 = $possible_links friendships. We see that there are $actual_links friendships _(red edges)_. The clustering coefficient of node $j is ``\frac{\text{actual}}{\text{possible}} =`` $(round(local_clustering_coefficient(network, j), digits=2)). (Show clustering coefficient $(@bind show_clustering CheckBox(default = false)))
"""

# ╔═╡ 7c9f2f26-329e-46f8-8be9-c95cd680d51d
local_clustering_coefficient(network, j)

# ╔═╡ 7ba0f472-f8a3-497d-8093-6f9275365841
global_clustering_coefficient(network)

# ╔═╡ f2a97e1c-f9d9-45eb-a197-6325da142845
𝒩 = neighbors(network, j)

# ╔═╡ 3d32cc06-db5f-49a1-9510-c129fb064440
md"""
## Distance between nodes _(Friends of friends of friends ...)_
"""

# ╔═╡ 49627e46-c654-49b6-80ee-b664b61a68ac
md"""
* walk
* path
* connected pair
* distance
* diameter
* connected network
* components
"""

# ╔═╡ 2a07742e-4413-4a20-b417-b7dda8cb7c49
from = 13

# ╔═╡ 7b8a732f-a834-488b-9cdf-37d4f0b31eab
to = 23

# ╔═╡ 32dd4b65-15a4-4247-afe7-15a4daec2294
path = a_star(network, from, to)

# ╔═╡ aa91eb44-8cf9-4df4-a926-23dc6cc92cda
length(path)

# ╔═╡ 26fbde25-c520-4ca3-8bfd-22753d9a7a94
function color_nodes(graph, sets_of_nodes)
	default_color = colorant"lightgray"
	colors = [Makie.wong_colors()[1:length(sets_of_nodes)]; default_color]
	
	extended_sets = [sets_of_nodes..., 1:nv(graph)]
	groups = map(1:nv(graph)) do i
		findfirst(set -> i ∈ set, extended_sets)
	end
	colors[groups]
end

# ╔═╡ f26e4c88-fc29-41fe-b932-c136047dabb6
graphplot(network,
	node_size = 19,
	edge_width = 1,
	ilabels = vertices(network),	
	node_color = color_nodes(network, [[from, to]]),
	edge_color = [e ∈ path || reverse(e) ∈ path ? :red : :gray
	 for e ∈ edges(network)]
)

# ╔═╡ 4a5319ed-14f6-4635-8f58-a387de0cd8ad
function highlight_neighbors(graph, i)
	color_nodes(graph, [[i], neighbors(graph, i)])
end

# ╔═╡ 77cc233a-d916-4959-a73c-7138cfdd03af
graphplot(network,
	edge_width = 1,
	ilabels = vertices(network),
	node_size = 20,
	nlabels =
		!show_degree ? 
			nothing : 
			"deg: " .* string.(degree(network)),
	nlabels_offset = Point2f(0.1, 0.0),
	node_color = highlight_neighbors(network, i),
	edge_color = (:black, 0.5)
)

# ╔═╡ 9b3ede7b-6e55-4d98-8f8f-6b18382fcb43
graphplot(network,
	node_size = 19,
	edge_width = 1,
	ilabels = vertices(network),
	nlabels =
		!show_clustering ? 
			nothing :
			"cl: " .* string.(round.(local_clustering_coefficient(network), digits=2)),
		#string.(1:nv(network)) .* " (clust.: " .* string.(round.(local_clustering_coefficient(network), digits=2)) .* ")",
	
	node_color = highlight_neighbors(network, j),
	edge_color = [src(e) ∈ 𝒩 && dst(e) ∈ 𝒩 ? :red : :gray
	 for e ∈ edges(network)]
)

# ╔═╡ 5d7adf23-4fef-4597-a3ac-18adbef08d8e
md"""
## Components, path length and diameter

"""

# ╔═╡ 383c5cca-2301-4f9e-9610-9e5b7fdb13b5
components = connected_components(network)

# ╔═╡ 56ffb909-1dce-49c4-90a5-b45ede78e624
subnetwork = network[components[1]]

# ╔═╡ 7784fe91-ceb0-4756-8571-65efa217a065
diameter(subnetwork)

# ╔═╡ 9f083058-6a12-41cc-bb65-ad81e5d79aea
diameter(network)

# ╔═╡ a22c9ec0-647b-11eb-2141-974fa4223428
md"""
To get the length of shortest path from node `i` to node `j` use `gdistances(graph, i)[j]`.
"""

# ╔═╡ 257c32c8-647b-11eb-1244-e1d2baa5c58d
distances_from_1 = gdistances(network, 1)

# ╔═╡ d9428a14-647b-11eb-336d-778226dd13e1
dist_from_1_to_5 = distances_from_1[5]

# ╔═╡ 9c3d3a6a-4ad5-4c45-bb07-8e75b4380290
function giant_component(graph)
	components = connected_components(graph)
	
	# compute the size (# of nodes) of each component
	size_of_components = length.(components)
	# find the component with maximal number of nodes
	(n_nodes, ind) = findmax(size_of_components)
	
	# return the giant_component
	giant_component = components[ind]
end

# ╔═╡ 2ec96593-85fa-4f45-aceb-f3869717884e
giant_component(my_network)

# ╔═╡ 7f457cac-c153-44a8-a13c-af03ffd6eef1
subgraph, node_list = induced_subgraph(network, giant_component(network))

# ╔═╡ ba4ddf01-d02e-4d9f-beb7-15467a03b08a
graphplot(subgraph, node_size=20, arrow_size=20, node_color="orange")

# ╔═╡ ef85efd2-da5c-4197-831e-110aebe5a1d7
let
	f(x) = log(1 - ecdf(degree(network))(x))
	x_vec = exp.(0:0.01:6)

	lines(x_vec, f.(x_vec))
end

# ╔═╡ 62063f20-4041-454d-964b-e2e89a8634f0
diameter(big_network)

# ╔═╡ 2e02bf8a-b9f2-4aaf-8e58-e5d17e3d193c
is_connected(big_network)

# ╔═╡ 0f3c851f-78ea-4d0f-bfcf-7a6f1df9c152
# Todo: check if this needs to be transposed
function distance_matrix(graph)
	n = nv(graph) # number of vertices
	
	distance_matrix = zeros(Int, n, n)
	
	for (i, node) in enumerate(vertices(graph))
		distance_matrix[i, :] .= gdistances(graph, node)
	end
	
	distance_matrix
end

# ╔═╡ 7c308142-d5b5-47c0-be74-083709e43ac5
distance_matrix(simple_network)

# ╔═╡ f609d59f-25ce-4075-a824-c96bc4e9bbe3
md"
## Centralities
"

# ╔═╡ 12cfd4cd-3448-405a-b8bb-ad1d73c23150
katz_centrality(big_network)
# katz_centrality(big_network, 0.3)

# ╔═╡ ec57d7c7-0a96-40a4-942f-73723460a5fe
betweenness_centrality(simple_network)

# ╔═╡ 0d659ab1-88ce-48ce-8ee0-83185fd865aa
eigenvector_centrality(simple_network)

# ╔═╡ 7883f729-f34d-4a1c-a684-6d78700d2a45
closeness_centrality(simple_network)

# ╔═╡ 1df2ac74-6478-11eb-1266-7381e24cab9d
md"""
# Weighted graphs

You can work with weighted networks using the package `SimpleWeightedGraphs`.

It offers the types `SimpleWeightedGraph` and `SimpleWeightedDiGraph`.

Let's construct a weighted directed network.
"""

# ╔═╡ 89ce79c8-6478-11eb-18ae-ff6ec414e65b
begin
	weighted_network = SimpleWeightedDiGraph(3)
	add_edge!(weighted_network, 1, 2, 0.5)
	add_edge!(weighted_network, 2, 3, 0.8)
	add_edge!(weighted_network, 1, 3, 2.0)
end

# ╔═╡ 9c51f3fe-6478-11eb-2e87-69a72bb28e6d
adjacency_matrix(weighted_network)

# ╔═╡ 3cc59dcc-6479-11eb-1722-11883fbbd5a7
edge_weights = (e.weight for e in edges(weighted_network))

# ╔═╡ b6c85692-6478-11eb-310a-3ddc517ccdb0
graphplot(
	weighted_network,
	elabels = string.(edge_weights),
	ilabels = vertices(weighted_network)
)

# ╔═╡ 99fb9532-6479-11eb-1c7b-1d385d3a5441
indegree(weighted_network)

# ╔═╡ b0beccf8-6479-11eb-0ca8-e125c7183758
outdegree(weighted_network)

# ╔═╡ c706e9dc-6479-11eb-16ef-dbddc09a2612
degree(weighted_network)

# ╔═╡ 56f44286-647c-11eb-11ca-23a5342611b4
md"""
## Issue with weighted graphs (advanced)

There is a second way of constructing weighted graphs.
"""

# ╔═╡ 6e4afa92-647c-11eb-2165-73b6b8494c70
begin
	meta_graph = MetaDiGraph(3)
	add_edge!(meta_graph, 1, 2)
	add_edge!(meta_graph, 2, 3)
	add_edge!(meta_graph, 1, 3)
	set_prop!(meta_graph, 1, 2, :weight, 0.5)
	set_prop!(meta_graph, 2, 3, :weight, 0.8)
	set_prop!(meta_graph, 1, 3, :weight, 2.0)
	
	meta_graph
end

# ╔═╡ 4a6c6e48-647d-11eb-16e2-d3fa799ebe1f
md"""
`MetaGraph`s are convenient to work with because they can store names of nodes and other meta data. However, they behave slightly differently than `SimpleWeightedGraphs`. The `adjacency_matrix` is a matrix of 0 and 1 (not showing the weights).
"""

# ╔═╡ 58cc500f-8bb2-4c2f-bdaf-0cb8a42bf7da
adjacency_matrix(meta_graph) .* weights(meta_graph)

# ╔═╡ 97c76ed6-647d-11eb-3b73-b9fe79d52b4c
md"""
In order to get the matrix representation of the weighted graph use
"""

# ╔═╡ a0a0cc5a-647d-11eb-380a-bb5c0da3d2bd
md"""
This inconsistency will likely be fixed in the future. See [this issue on github](https://github.com/JuliaGraphs/LightGraphs.jl/issues/1519).
"""

# ╔═╡ 1250300d-8bd5-41c3-a36f-b59064e8fbfd
md"""
# Appendix
"""

# ╔═╡ c5cf8e17-9dcc-4f37-ace2-dbc3d92a83d4
TableOfContents()

# ╔═╡ 1ff1315e-154d-4eaa-92ce-4ed1c32bb01f
md"""
## Packages
"""

# ╔═╡ cf21a82b-ff81-4165-afd1-a96475d8b547
md"""
#### Graphs
"""

# ╔═╡ 83fdf8aa-18d5-47b2-8dd9-feb713bc423a
md"""
#### Plotting
"""

# ╔═╡ 4de43ab8-4187-49ea-9c96-779a6d39c757
md"""
#### Statistics
"""

# ╔═╡ f45dfb17-aef7-4540-a790-9148fa921d25
md"""
#### Other
"""

# ╔═╡ e0b98b3b-1a2a-420e-9cf0-b08bfa7b4244
md"""
## Assignment infrastructure
"""

# ╔═╡ 095e3198-eba0-4e33-a966-92c30f9caa7d
cell_id() = "#" * (string(PlutoRunner.currently_running_cell_id[]))

# ╔═╡ 9a7334de-3721-41f2-8297-0f6bb667ea1c
group_number = 99; cell1 = cell_id();

# ╔═╡ 2b00b912-c64c-4128-ae36-a5ad3135a4da
@markdown("""
#### Before you submit ...

👉 Make sure you have added your names and your group number [in the cells below]($cell1).

👉 Make sure that that **all group members proofread** your submission (especially your little essay).

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. (The source code is embedded in the html file.)
""")

# ╔═╡ 32ebdfb4-bc3e-4dfa-8b97-6367104e84ec
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]); cell2 = cell_id();

# ╔═╡ 0edff9fd-b092-4605-988e-c25d2472d852
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	@markdown("""
!!! danger "Note!"
    **Before you submit**, please replace the [randomly generated names in this cell]($cell2) by the names of your group and put the [right group number in the cell above.]($cell1).
	""")
end

# ╔═╡ c1a7ce59-f524-474e-9816-8955aa180bf3
members = let
	names = map(group_members) do (; firstname, lastname)
		firstname * " " * lastname
	end
	join(names, ", ", " & ")
end

# ╔═╡ fa711a36-3d9e-4a0e-9389-e525617dacc1
assignment_cell = cell_id(); md"""
# Assignment 1: First networks in Julia

*submitted by* **$members** (*group $(group_number)*)

In this assignment you get some experience with the *Julia* programming language. You will also **create and visualize simple networks** in Julia.
"""

# ╔═╡ 1ec6ed12-e598-460d-aac2-4b3f1852b4e0
function wordcount(text)
	stripped_text = strip(replace(string(text), r"\s" => " "))
   	words = split(stripped_text, (' ', '-', '.', ',', ':', '_', '"', ';', '!', '\''))
   	length(filter(!=(""), words))
end

# ╔═╡ b9ee323b-ed46-4601-9712-c81519aed7c9
show_words(answer) = md"_approximately $(wordcount(answer)) words_"

# ╔═╡ 9a2b20ce-4b00-4045-8298-d35a28a88fbe
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
end

# ╔═╡ 8636f7de-05d8-457f-95a5-5cb5cecfaf94
function show_words_limit(answer, limit)
	count = wordcount(answer)
	if count < 1.02 * limit
		return show_words(answer)
	else
		return almost(md"You are at $count words. Please shorten your text a bit, to get **below $limit words**.")
	end
end

# ╔═╡ bc2144ce-a9f7-4363-895c-6622d1687cb2
note(text; title="FYI") = Markdown.MD(Markdown.Admonition("note", title, [text]))

# ╔═╡ f32bd589-19f7-4b7c-901c-62a2999916a0
note(@markdown("The assignment starts [here (link)]($assignment_cell)"))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
FreqTables = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
GraphMakie = "1ecd5474-83a3-4783-bb4f-06765db800d2"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
MetaGraphs = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
NetworkLayout = "46757867-2c16-5918-afeb-47bfcb05e46a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SNAPDatasets = "fc66bc1b-447b-53fc-8f09-bc9cfb0b0c10"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
CairoMakie = "~0.12.12"
Colors = "~0.12.11"
DataFrames = "~1.7.0"
FreqTables = "~0.4.6"
GraphMakie = "~0.5.12"
Graphs = "~1.12.0"
MarkdownLiteral = "~0.1.1"
MetaGraphs = "~0.7.2"
NetworkLayout = "~0.4.6"
PlutoUI = "~0.7.60"
SNAPDatasets = "~0.2.0"
SimpleWeightedGraphs = "~1.4.0"
StatsBase = "~0.34.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.5"
manifest_format = "2.0"
project_hash = "3c45333740acbd54acf4f44d01435d7c583a979b"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "6a55b747d1812e699320963ffde36f1ebdda4099"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.4"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AdaptivePredicates]]
git-tree-sha1 = "7e651ea8d262d2d74ce75fdf47c4d63c07dba7a6"
uuid = "35492f91-a3bd-45ad-95db-fcad7dcfedb7"
version = "1.2.0"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "d57bd3762d308bded22c3b82d033bff85f6195c6"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.4.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["PrecompileTools", "TranscodingStreams"]
git-tree-sha1 = "014bc22d6c400a7703c0f5dc1fdc302440cf88be"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "1.0.4"

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

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "7b6ad8c35f4bc3bca8eb78127c8b99719506a5fb"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.1.0"

[[deps.CairoMakie]]
deps = ["CRC32c", "Cairo", "Cairo_jll", "Colors", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "PrecompileTools"]
git-tree-sha1 = "0852b8edf4da66cc44861b12d7d6c69693fc620f"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.12.12"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "a2f1c8c668c8e3cb4cca4e57a8efdb09067bb3fd"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.0+2"

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

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "3e4b134270b372f2ed4d4d0e936aabaefc1802bc"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b5278586822443594ff615963b0c09755771b3e0"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.26.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

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
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "PrecompileTools", "URIs"]
git-tree-sha1 = "5f4be62ad3811a4073798c41d94ad7560615d715"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.14"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "fb61b4812c49343d7ef0b533ba982c46021938a6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.7.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelaunayTriangulation]]
deps = ["AdaptivePredicates", "EnumX", "ExactPredicates", "PrecompileTools", "Random"]
git-tree-sha1 = "668bb97ea6df5e654e6288d87d2243591fe68665"
uuid = "927a84f5-c5f4-47a5-9785-b46e178433df"
version = "1.6.0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "d7477ecdafb813ddee2ae727afa94e9dcb5f3fb0"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.112"

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

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c6317308b9dc757616f0b5cb379db10494443a7"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.2+0"

[[deps.Extents]]
git-tree-sha1 = "81023caa0021a41712685887db1fc03db26f41f5"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.4"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "8cc47f299902e13f90405ddb5bf87e5d474c0d38"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "6.1.2+0"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "4820348781ae578893311153d69049a93d05f39d"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.8.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4d81ed14783ec49ce9f2e168208a12ce1815aa25"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+1"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "82d8afa92ecf4b52d78d869f038ebfb881267322"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.3"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "7878ff7172a8e6beedd1dea14bd27c3c6340d361"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.22"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "db16beca600632c95fc8aca29890d83788dd8b23"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.96+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "907369da0f8e80728ab49c1c7e09327bf0d6d999"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.1.1"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "5c1d8ae0efc6c2e7b1fc502cbe25def8f661b7bc"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.2+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "2493cdfd0740015955a8e46de4ef28f49460d8bc"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.3"

[[deps.FreqTables]]
deps = ["CategoricalArrays", "Missings", "NamedArrays", "Tables"]
git-tree-sha1 = "4693424929b4ec7ad703d68912a6ad6eff103cfe"
uuid = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
version = "0.4.6"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1ed150b39aebcc805c26b93a8d0122c940f64ce2"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.14+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GeoFormatTypes]]
git-tree-sha1 = "59107c179a586f0fe667024c5eb7033e81333271"
uuid = "68eda718-8dee-11e9-39e7-89f7f65f511f"
version = "0.4.2"

[[deps.GeoInterface]]
deps = ["Extents", "GeoFormatTypes"]
git-tree-sha1 = "2f6fce56cdb8373637a6614e14a5768a88450de2"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.7"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "Extents", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "b62f2b2d76cee0d61a2ef2b3118cd2a3215d3134"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.11"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "674ff0db93fffcd11a3573986e550d66cd4fd71f"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.80.5+0"

[[deps.GraphMakie]]
deps = ["DataStructures", "GeometryBasics", "Graphs", "LinearAlgebra", "Makie", "NetworkLayout", "PolynomialRoots", "SimpleTraits", "StaticArrays"]
git-tree-sha1 = "c8c3ece1211905888da48e16f438af85e951ea55"
uuid = "1ecd5474-83a3-4783-bb4f-06765db800d2"
version = "0.5.12"

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
git-tree-sha1 = "1dc470db8b1131cfc7fb4c115de89fe391b9e780"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.12.0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "fc713f007cff99ff9e50accba6373624ddd33588"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.11.0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "401e4f3f30f43af2c8478fc008da50096ea5240f"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.3.1+0"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "7c4195be1649ae622304031ed46a2f4df989f1eb"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.24"

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

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

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
git-tree-sha1 = "437abb322a41d527c197fa800455f79d414f0a3c"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.8"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "355e2b974f2e3212a75dfb60519de21361ad3cb7"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.9"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0936ba688c6d201805a83da835b55c61a180db52"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.11+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InlineStrings]]
git-tree-sha1 = "45521d31238e87ee9f9732561bfee12d4eebd52d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.2"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "10bd689145d2c3b2a9844005d01087cc1194e79e"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2024.2.1+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "88a101217d7cb38a7b481ccd50d21876e1d1b0e0"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.15.1"
weakdeps = ["Unitful"]

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

[[deps.IntervalArithmetic]]
deps = ["CRlibm_jll", "MacroTools", "RoundingEmulator"]
git-tree-sha1 = "8e125d40cae3a9f4276cdfeb4fcdb1828888a4b3"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "0.22.17"

    [deps.IntervalArithmetic.extensions]
    IntervalArithmeticDiffRulesExt = "DiffRules"
    IntervalArithmeticForwardDiffExt = "ForwardDiff"
    IntervalArithmeticIntervalSetsExt = "IntervalSets"
    IntervalArithmeticLinearAlgebraExt = "LinearAlgebra"
    IntervalArithmeticRecipesBaseExt = "RecipesBase"

    [deps.IntervalArithmetic.weakdeps]
    DiffRules = "b552c78f-8df3-52c6-915a-8e097449b14b"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

    [deps.IntervalSets.weakdeps]
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

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

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "PrecompileTools", "Requires", "TranscodingStreams"]
git-tree-sha1 = "a0746c21bdc986d0dc293efa6b1faee112c37c28"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.53"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "f389674c99bfcde17dc57454011aa44d5a260a40"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.0"

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
git-tree-sha1 = "25ee0be4d43d0269027024d75a24c24d6c6e590c"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.4+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "7d703202e65efa1369de1279c162b915e245eed1"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.9"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "854a9c268c43b77b0a27f22d7fab8d33cdb3a731"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.2+1"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "9fd170c4bbfd8b935fdc5f8b7aa33532c991a673"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.11+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fbb1f2bef882392312feb1ede3615ddc1e9b99ed"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.49.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0c4f9c4f1a50d8f35048fa0532dabbadf702f81e"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.1+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5ee6203157c120d79034c748a2acba45b82b8807"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.1+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

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

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "oneTBB_jll"]
git-tree-sha1 = "f046ccd0c6db2832a9f639e2c669c6fe867e5f4f"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2024.2.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Makie]]
deps = ["Animations", "Base64", "CRC32c", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Dates", "DelaunayTriangulation", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG_jll", "FileIO", "FilePaths", "FixedPointNumbers", "Format", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageBase", "ImageIO", "InteractiveUtils", "Interpolations", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MacroTools", "MakieCore", "Markdown", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "PrecompileTools", "Printf", "REPL", "Random", "RelocatableFolders", "Scratch", "ShaderAbstractions", "Showoff", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun", "Unitful"]
git-tree-sha1 = "e08a87ca672b6f26a6f7237000554d2a093d3495"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.21.12"

[[deps.MakieCore]]
deps = ["ColorTypes", "GeometryBasics", "IntervalSets", "Observables"]
git-tree-sha1 = "22fed09860ca73537a36d4e5a9bce0d9e80ee8a8"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.8.8"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MarkdownLiteral]]
deps = ["CommonMark", "HypertextLiteral"]
git-tree-sha1 = "0d3fa2dd374934b62ee16a4721fe68c418b92899"
uuid = "736d6165-7244-6769-4267-6b50796e6954"
version = "0.1.1"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "UnicodeFun"]
git-tree-sha1 = "e1641f32ae592e415e3dbae7f4a188b5316d4b62"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.6.1"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.MetaGraphs]]
deps = ["Graphs", "JLD2", "Random"]
git-tree-sha1 = "1130dbe1d5276cb656f6e1094ce97466ed700e5a"
uuid = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
version = "0.7.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "58e317b3b956b8aaddfd33ff4c3e33199cd8efce"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.10.3"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "StaticArrays"]
git-tree-sha1 = "91bb2fedff8e43793650e7a677ccda6e6e6e166b"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.6"
weakdeps = ["Graphs"]

    [deps.NetworkLayout.extensions]
    NetworkLayoutGraphsExt = "Graphs"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "1a27764e945a152f7ca7efa04de513d473e9542e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.14.1"
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
version = "0.3.23+4"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "8292dd5c8a38257111ada2174000a33745b06d4e"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.2.4+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7493f61f55a6cce7325f197443aa80d32554ba10"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+1"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

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
git-tree-sha1 = "e127b609fb9ecba6f201ba7ab753d5a605d53801"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.54.1+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

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
git-tree-sha1 = "7b1a9df27f072ac4c9c7cbe5efb198489258d1f5"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.1"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PolynomialRoots]]
git-tree-sha1 = "5f807b5345093487f733e520a1b7395ee9324825"
uuid = "3a141323-8675-5d76-9d11-e1df1406c778"
version = "1.0.0"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "1101cd475833706e4d0e7b122218257178f48f34"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "8f6bc219586aef8baf0ff9a5fe16ee9c70cb65e4"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.2"

[[deps.PtrArrays]]
git-tree-sha1 = "77a42d78b6a92df47ab37e177b2deac405e1c88f"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.2.1"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "cda3b045cf9ef07a08ad46731f5a3165e56cf3da"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.1"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

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

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "98ca7c29edd6fc79cd74c61accb7010a4e7aee33"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.6.0"

[[deps.SNAPDatasets]]
deps = ["Graphs"]
git-tree-sha1 = "6c163282a557ac00ce86a37f605b7b8b8fa3124d"
uuid = "fc66bc1b-447b-53fc-8f09-bc9cfb0b0c10"
version = "0.2.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "ff11acffdb082493657550959d4feb4b6149e73a"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.5"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "79123bc60c5507f035e6d1d9e563bb2971954ec8"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.4.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

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
git-tree-sha1 = "2f5d4697f21388cbe1ff299430dd169ef97d7e14"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.4.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "eeafab08ae20c62c44c8399ccb9354a04b80db50"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.7"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

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
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a6b1675a536c5ad1a60e5a5153e1fee12eb146e3"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.0"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "f4dc295e983502292c4c3f951dbb4e985e35b3be"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.18"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = "GPUArraysCore"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

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

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "bc7fd5c91041f44636b2c134041f7e5263ce58ae"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.10.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "e84b3a11b9bece70d14cce63406bbc79ed3464d2"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.2"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "d95fe458f26209c66a187b1114df96fd70839efd"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.21.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c1a7aa6219628fcd757dede0ca95e245c5cd9511"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.0.0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "1165b0443d0eca63ac1e32b8c0eb69ed2f4f8127"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "a54ee957f4c86b526460a720dbc882fa5edcbefc"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.41+0"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d2d1a5c49fae4ba39983f63de6afcbea47194e85"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "47e45cd78224c53109495b3e324df0c37bb61fbe"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+0"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "bcd466676fef0878338c61e655629fa7bbc69d8e"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1827acba325fdcdf1d2647fc8d5301dd9ba43a9d"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.9.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "b70c870239dc3d7bc094eb2d6be9b73d27bef280"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.44+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "7dfa0fd9c783d3d0cc43ea1af53d69ba45c447df"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+1"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.oneTBB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7d0ea0f4895ef2f5cb83645fa689e52cb55cf493"
uuid = "1317d2d5-d96f-522e-a858-c73665f53c3e"
version = "2021.12.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "35976a1216d6c066ea32cba2150c4fa682b276fc"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.0+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "dcc541bb19ed5b0ede95581fb2e41ecf179527d2"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.6.0+0"
"""

# ╔═╡ Cell order:
# ╟─0edff9fd-b092-4605-988e-c25d2472d852
# ╟─eb6a3510-6477-11eb-0e4e-33557d794e45
# ╟─f32bd589-19f7-4b7c-901c-62a2999916a0
# ╟─6009f070-5ef8-11eb-340a-d9780be085ad
# ╟─df4d9fab-13da-4df7-b51e-0689112f65fe
# ╠═bdd75f9a-17e1-4b80-aa88-8a1477032441
# ╠═6b1af27c-5d0a-43a2-b3a5-b02770aeb841
# ╠═165ba943-b546-42d0-84b2-00391572ff8e
# ╟─0f0dc575-7660-4b32-b158-95a9a0ab31e8
# ╟─fa711a36-3d9e-4a0e-9389-e525617dacc1
# ╟─04a1b174-0eb6-4116-81fc-9355a21dac5e
# ╟─e5f39c68-9a15-4c99-bdf1-2da05495bdd4
# ╠═7ca8de90-04bc-4e79-9905-59ffbdfae6af
# ╟─a0ea3f82-91a1-46c1-bb80-4ac050561f16
# ╠═8a56d6d9-91e0-4f6d-8f7d-3cf62717b75c
# ╠═97676f28-4ae3-446b-97ef-2b715f90d8fa
# ╟─31f06624-9fa0-4b7a-a869-aa2ede238854
# ╠═59dafdda-1e42-44f2-b0b9-6859dcdf8671
# ╠═265e89b7-07e2-4102-b697-a8adaac042ff
# ╠═d6d7256c-1e1a-401a-a925-0a8fb8561138
# ╠═ff7668e2-43af-4b0c-8e06-ac6d3e1fce73
# ╠═5101887d-ed0d-46af-86b3-2412de936f5a
# ╠═10b252de-4c0c-48ab-b579-2c9450e8f084
# ╟─5f1e3589-48fe-418a-958b-74b5dc0d7eff
# ╠═b01cef89-6258-4050-9d35-7628eaf54010
# ╟─67a2e792-647a-11eb-208e-4df018d00425
# ╠═d3feb786-2c69-416f-8fda-e2b4da0c0c1c
# ╟─2a46c00e-c740-4c67-9055-19d28dd09402
# ╠═4085f4f4-2e4f-4ddb-85b7-55b4c5ee5d29
# ╟─40defc1b-f9a7-4653-a52f-3d217a424ee5
# ╟─60bca082-5be8-46b9-acbf-2dbbcfa984ea
# ╠═7f8a85ee-4476-4728-ba39-9f40c5da5161
# ╟─30ce82be-d68f-424d-8a4c-cb6272268251
# ╟─2b00b912-c64c-4128-ae36-a5ad3135a4da
# ╠═9a7334de-3721-41f2-8297-0f6bb667ea1c
# ╠═32ebdfb4-bc3e-4dfa-8b97-6367104e84ec
# ╟─0f454038-cb1d-457c-9a5e-bdf8deccface
# ╟─7057b8a6-91a9-495f-ac29-669d5652c8d0
# ╠═c28b2d55-63dc-4794-bfcd-a03172cb7f25
# ╟─c3946663-eddf-4bc1-bb52-9c82c8f7258c
# ╠═07f7ed69-3e9a-4a6b-a10f-de8d09aa0db5
# ╟─3956c45f-23a9-4ec2-846f-d33706373d72
# ╠═d25c59f6-8f99-4a83-8750-10518a13f6ae
# ╠═63fff52b-d485-4fb3-be2c-80039e6ebc2a
# ╟─edbb8f3b-f133-481b-8972-fdcd87b5acef
# ╟─77cc233a-d916-4959-a73c-7138cfdd03af
# ╟─75194951-3f88-4855-98d4-a987430f5b00
# ╟─4b0dc2b4-a56d-45e3-8d58-a53978c4ff7f
# ╟─609dfa37-2208-40b7-bc47-60d0c9ec54c8
# ╟─0cd4e0a0-fa38-4b05-8688-6396093d2652
# ╟─9b3ede7b-6e55-4d98-8f8f-6b18382fcb43
# ╠═ac1291c8-e560-4457-ad58-47c70ade7dca
# ╠═228237f5-4884-4575-9dc4-a5c33b9afdae
# ╠═7c9f2f26-329e-46f8-8be9-c95cd680d51d
# ╠═7ba0f472-f8a3-497d-8093-6f9275365841
# ╠═f2a97e1c-f9d9-45eb-a197-6325da142845
# ╟─3d32cc06-db5f-49a1-9510-c129fb064440
# ╟─49627e46-c654-49b6-80ee-b664b61a68ac
# ╠═2a07742e-4413-4a20-b417-b7dda8cb7c49
# ╠═7b8a732f-a834-488b-9cdf-37d4f0b31eab
# ╟─f26e4c88-fc29-41fe-b932-c136047dabb6
# ╠═32dd4b65-15a4-4247-afe7-15a4daec2294
# ╠═aa91eb44-8cf9-4df4-a926-23dc6cc92cda
# ╠═4a5319ed-14f6-4635-8f58-a387de0cd8ad
# ╠═915ca82e-f358-4515-889a-5a226539223d
# ╠═26fbde25-c520-4ca3-8bfd-22753d9a7a94
# ╟─5d7adf23-4fef-4597-a3ac-18adbef08d8e
# ╠═383c5cca-2301-4f9e-9610-9e5b7fdb13b5
# ╠═56ffb909-1dce-49c4-90a5-b45ede78e624
# ╠═7784fe91-ceb0-4756-8571-65efa217a065
# ╠═9f083058-6a12-41cc-bb65-ad81e5d79aea
# ╟─a22c9ec0-647b-11eb-2141-974fa4223428
# ╠═257c32c8-647b-11eb-1244-e1d2baa5c58d
# ╠═d9428a14-647b-11eb-336d-778226dd13e1
# ╠═9c3d3a6a-4ad5-4c45-bb07-8e75b4380290
# ╠═2ec96593-85fa-4f45-aceb-f3869717884e
# ╠═7f457cac-c153-44a8-a13c-af03ffd6eef1
# ╠═ba4ddf01-d02e-4d9f-beb7-15467a03b08a
# ╠═ef85efd2-da5c-4197-831e-110aebe5a1d7
# ╠═62063f20-4041-454d-964b-e2e89a8634f0
# ╠═2e02bf8a-b9f2-4aaf-8e58-e5d17e3d193c
# ╠═0f3c851f-78ea-4d0f-bfcf-7a6f1df9c152
# ╠═7c308142-d5b5-47c0-be74-083709e43ac5
# ╟─f609d59f-25ce-4075-a824-c96bc4e9bbe3
# ╠═12cfd4cd-3448-405a-b8bb-ad1d73c23150
# ╠═ec57d7c7-0a96-40a4-942f-73723460a5fe
# ╠═0d659ab1-88ce-48ce-8ee0-83185fd865aa
# ╠═7883f729-f34d-4a1c-a684-6d78700d2a45
# ╟─1df2ac74-6478-11eb-1266-7381e24cab9d
# ╠═89ce79c8-6478-11eb-18ae-ff6ec414e65b
# ╠═9c51f3fe-6478-11eb-2e87-69a72bb28e6d
# ╠═b6c85692-6478-11eb-310a-3ddc517ccdb0
# ╠═3cc59dcc-6479-11eb-1722-11883fbbd5a7
# ╠═99fb9532-6479-11eb-1c7b-1d385d3a5441
# ╠═b0beccf8-6479-11eb-0ca8-e125c7183758
# ╠═c706e9dc-6479-11eb-16ef-dbddc09a2612
# ╟─56f44286-647c-11eb-11ca-23a5342611b4
# ╠═6e4afa92-647c-11eb-2165-73b6b8494c70
# ╟─4a6c6e48-647d-11eb-16e2-d3fa799ebe1f
# ╠═58cc500f-8bb2-4c2f-bdaf-0cb8a42bf7da
# ╟─97c76ed6-647d-11eb-3b73-b9fe79d52b4c
# ╟─a0a0cc5a-647d-11eb-380a-bb5c0da3d2bd
# ╟─1250300d-8bd5-41c3-a36f-b59064e8fbfd
# ╠═c5cf8e17-9dcc-4f37-ace2-dbc3d92a83d4
# ╟─1ff1315e-154d-4eaa-92ce-4ed1c32bb01f
# ╟─cf21a82b-ff81-4165-afd1-a96475d8b547
# ╠═de6c3f24-618b-44a1-a9ef-b56bd35b4b87
# ╠═48442831-b63d-454f-8129-cff796aba54b
# ╠═da797bdb-b027-4139-8446-91df190cb509
# ╠═2ff77ccf-9f74-42a4-af0e-188c00dd9852
# ╟─83fdf8aa-18d5-47b2-8dd9-feb713bc423a
# ╠═48a5a2db-637a-4f8e-9994-ae6c1850ed70
# ╠═7f248ca3-825f-4698-8ead-f7bd30e0d5c5
# ╠═30fa9b9e-8e78-43b8-8405-1e70087b7c63
# ╟─4de43ab8-4187-49ea-9c96-779a6d39c757
# ╠═6998ffab-2cf1-410f-b09c-5e70f2da0438
# ╠═40358272-eca0-4a98-be8a-66fb23573d32
# ╠═431229ad-a4f5-415c-8946-9888dc335857
# ╟─f45dfb17-aef7-4540-a790-9148fa921d25
# ╠═2ecf4ffd-d41d-494c-9fec-d681a176a8ba
# ╠═b4cec279-9bd4-46c5-8dc3-13003730916f
# ╠═2068d1e1-7c8a-4319-a440-8ef5ddc74369
# ╟─e0b98b3b-1a2a-420e-9cf0-b08bfa7b4244
# ╠═095e3198-eba0-4e33-a966-92c30f9caa7d
# ╠═c1a7ce59-f524-474e-9816-8955aa180bf3
# ╠═1ec6ed12-e598-460d-aac2-4b3f1852b4e0
# ╠═b9ee323b-ed46-4601-9712-c81519aed7c9
# ╠═8636f7de-05d8-457f-95a5-5cb5cecfaf94
# ╠═9a2b20ce-4b00-4045-8298-d35a28a88fbe
# ╠═bc2144ce-a9f7-4363-895c-6622d1687cb2
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
