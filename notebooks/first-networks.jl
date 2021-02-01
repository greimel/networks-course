### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 2ecf4ffd-d41d-494c-9fec-d681a176a8ba
let
	using Pkg
	Pkg.activate(temp = true)
	
	Pkg.add(["LightGraphs", "GraphPlot", "Plots", "SNAPDatasets", "FreqTables", "StatsBase", "PlutoUI", "SimpleWeightedGraphs", "MetaGraphs"])
	using PlutoUI: TableOfContents
	
	using LightGraphs # for analyzing networks
	using SimpleWeightedGraphs # for handling weighted graphs
	using MetaGraphs
	using GraphPlot: gplot, random_layout, spring_layout   # for plotting networks
	using SNAPDatasets: loadsnap  # cool datasets of *big* networks
	
	using Plots: histogram, plot
	
	# Basic statistical analysis
	using Statistics: mean, std
	using FreqTables    
	using StatsBase: ecdf
end

# ╔═╡ eb6a3510-6477-11eb-0e4e-33557d794e45
md"""
*Last updated: Feb 1*
"""

# ╔═╡ 6009f070-5ef8-11eb-340a-d9780be085ad
md"""
# First networks in Julia

In this section we show you how to create networks in Julia and how to visualize them.

1. special named graphs
2. do it yourself
3. from a dataset
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
gplot(simple_network)

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
gplot(my_network, layout = random_layout)

# ╔═╡ 51528bcb-0dac-4e32-8b8a-772fa964cbd8
md"""
You will probably realize that many graph drawing algorithms are not deterministic. The plot may look different if you re-execute it.

I've chosen the `random_layout` because the default options sometimes "hides" the links of the network when there are very few nodes and links.
"""

# ╔═╡ 99c5a7ee-9d4b-4bbf-9ddb-29f5778438d9
gplot(my_network,
	layout = spring_layout,
	NODESIZE = 0.05,
)

# ╔═╡ 7057b8a6-91a9-495f-ac29-669d5652c8d0
md"""
## Building networks from real-world data

There are plenty of network datasets out there. You can check out the *Stanford Large Network Dataset Collection* [[link]](https://snap.stanford.edu/data/index.html). A very small subset of these datasets can be downloaded directly from Julia using the package *SNAPDatasets.jl* [[link]](https://github.com/JuliaGraphs/SNAPDatasets.jl).

Let us have a look at the Facebook dataset, with 4039 nodes and 88234 edges. [[link to description]](https://snap.stanford.edu/data/ego-Facebook.html)
"""

# ╔═╡ c28b2d55-63dc-4794-bfcd-a03172cb7f25
big_network = loadsnap(:facebook_combined)

# ╔═╡ c3946663-eddf-4bc1-bb52-9c82c8f7258c
md"Even though the dataset is rather small compared to others from this collection, we already run into problems when we want to visualize the network. 

Don't run the following cell on an old computer. The plot takes around 1 minute on my recent MacBook Pro.

**NOTE** `gplot` creates vector graphics (svg), which is not recommended for plots with many components (here: 88234 lines). That is why your browser might get stuck when you run this command.
"

# ╔═╡ 07f7ed69-3e9a-4a6b-a10f-de8d09aa0db5
#gplot(big_network)

# ╔═╡ 541303e2-02b3-4537-ab92-e3947652f6f6
md"""
# Analyzing networks with LightGraphs.jl

**NOTE** The concepts of this section are introduced in the first lectures of the course. Have a look if you're curious. But it is rather meant as a references for your assignments.

If you cannot find what you need in this notebook, check out the excellent [documentation of LightGraphs.jl](https://juliagraphs.org/LightGraphs.jl/stable).
"""

# ╔═╡ 7e163209-7c52-4116-bcc2-572060b90fde
md"""
## Counting the number of neighbors: The degree of a node

Let's count the number of neighbors for each node. That is, how many links does each node have?

For illustration, let's plot the degree of each node for the `simple_network` from above.
"""

# ╔═╡ b34c0187-86dd-482c-a1dd-11a461bc0be2
gplot(simple_network, nodelabel = degree(simple_network))

# ╔═╡ 7dead69c-36c1-4676-a072-3442d20ba899
md"
Now, let's compute it for the big network.
"

# ╔═╡ 97d36935-3d2d-4079-a141-1bd030196328
degrees = degree(big_network)

# ╔═╡ b1d74829-82fd-48b0-a0d9-3d2ae2b802b0
(deg, node) = findmax(degrees)

# ╔═╡ 3e0e847a-cc7f-4bda-a321-0f8dcfc75bd7
md"""
The first node has $(degrees[1]) neighbors ("friends"), the second node has $(degrees[2]), and so on.

We can look for the nodes with the most neighbors. Node $node has $deg neighbours.
"""

# ╔═╡ afb8492d-a95e-40ae-9c34-a8fc9ce8a25e
md"
Can you guess how to find the node with the least neighbors?
"

# ╔═╡ 313359ed-a84c-4eb8-86da-3da41cf475d4
md"""
We can have a look at the full degree distribution by plotting a histogram.
"""

# ╔═╡ a1fe05e9-b3e3-4055-831c-ca6289086fbe
histogram(degrees)

# ╔═╡ a5a085cf-b4dd-48c0-a3c2-967abc1445c2
mean(degrees)

# ╔═╡ b0ab1ac5-8433-4818-8579-f2c36d0dee30
std(degrees)

# ╔═╡ 5d7adf23-4fef-4597-a3ac-18adbef08d8e
md"""
## Components, path length and diameter

"""

# ╔═╡ 7ba0f472-f8a3-497d-8093-6f9275365841
global_clustering_coefficient(big_network)

# ╔═╡ 9f083058-6a12-41cc-bb65-ad81e5d79aea
diameter(big_network)

# ╔═╡ a22c9ec0-647b-11eb-2141-974fa4223428
md"""
To get the length of shortest path from node `i` to node `j` use `gdistances(graph, i)[j]`.
"""

# ╔═╡ 257c32c8-647b-11eb-1244-e1d2baa5c58d
distances_from_1 = gdistances(simple_network, 1)

# ╔═╡ d9428a14-647b-11eb-336d-778226dd13e1
dist_from_1_to_5 = distances_from_1[5]

# ╔═╡ 2c703f99-5d25-44db-8651-92dd6427a605
diameter(simple_network)

# ╔═╡ 7381cca1-5f12-48d3-8a33-4642e8f80072
components = connected_components(my_network)

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
subgraph, node_list = induced_subgraph(my_network, giant_component(my_network))

# ╔═╡ ba4ddf01-d02e-4d9f-beb7-15467a03b08a
gplot(subgraph)

# ╔═╡ ef85efd2-da5c-4197-831e-110aebe5a1d7
plot(x -> log(1 - ecdf(degrees)(x)), 1, 250)

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
gplot(weighted_network, edgelabel = edge_weights, nodelabel = 1:3)

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

# ╔═╡ fb7a80ae-647c-11eb-2909-9164e5a3676a
adjacency_matrix(meta_graph)

# ╔═╡ 97c76ed6-647d-11eb-3b73-b9fe79d52b4c
md"""
In order to get the matrix representation of the weighted graph use
"""

# ╔═╡ 0213d442-647d-11eb-3b7c-85ba0343c503
adjacency_matrix(meta_graph) .* weights(meta_graph)

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

# ╔═╡ Cell order:
# ╟─eb6a3510-6477-11eb-0e4e-33557d794e45
# ╟─6009f070-5ef8-11eb-340a-d9780be085ad
# ╟─df4d9fab-13da-4df7-b51e-0689112f65fe
# ╠═bdd75f9a-17e1-4b80-aa88-8a1477032441
# ╠═6b1af27c-5d0a-43a2-b3a5-b02770aeb841
# ╠═165ba943-b546-42d0-84b2-00391572ff8e
# ╟─0f0dc575-7660-4b32-b158-95a9a0ab31e8
# ╟─5f1e3589-48fe-418a-958b-74b5dc0d7eff
# ╠═b01cef89-6258-4050-9d35-7628eaf54010
# ╟─67a2e792-647a-11eb-208e-4df018d00425
# ╠═d3feb786-2c69-416f-8fda-e2b4da0c0c1c
# ╟─51528bcb-0dac-4e32-8b8a-772fa964cbd8
# ╠═99c5a7ee-9d4b-4bbf-9ddb-29f5778438d9
# ╟─7057b8a6-91a9-495f-ac29-669d5652c8d0
# ╠═c28b2d55-63dc-4794-bfcd-a03172cb7f25
# ╟─c3946663-eddf-4bc1-bb52-9c82c8f7258c
# ╠═07f7ed69-3e9a-4a6b-a10f-de8d09aa0db5
# ╟─541303e2-02b3-4537-ab92-e3947652f6f6
# ╟─7e163209-7c52-4116-bcc2-572060b90fde
# ╠═b34c0187-86dd-482c-a1dd-11a461bc0be2
# ╟─7dead69c-36c1-4676-a072-3442d20ba899
# ╠═97d36935-3d2d-4079-a141-1bd030196328
# ╟─3e0e847a-cc7f-4bda-a321-0f8dcfc75bd7
# ╠═b1d74829-82fd-48b0-a0d9-3d2ae2b802b0
# ╟─afb8492d-a95e-40ae-9c34-a8fc9ce8a25e
# ╟─313359ed-a84c-4eb8-86da-3da41cf475d4
# ╠═a1fe05e9-b3e3-4055-831c-ca6289086fbe
# ╠═a5a085cf-b4dd-48c0-a3c2-967abc1445c2
# ╠═b0ab1ac5-8433-4818-8579-f2c36d0dee30
# ╟─5d7adf23-4fef-4597-a3ac-18adbef08d8e
# ╠═7ba0f472-f8a3-497d-8093-6f9275365841
# ╠═9f083058-6a12-41cc-bb65-ad81e5d79aea
# ╟─a22c9ec0-647b-11eb-2141-974fa4223428
# ╠═257c32c8-647b-11eb-1244-e1d2baa5c58d
# ╠═d9428a14-647b-11eb-336d-778226dd13e1
# ╠═2c703f99-5d25-44db-8651-92dd6427a605
# ╠═7381cca1-5f12-48d3-8a33-4642e8f80072
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
# ╠═fb7a80ae-647c-11eb-2909-9164e5a3676a
# ╟─97c76ed6-647d-11eb-3b73-b9fe79d52b4c
# ╠═0213d442-647d-11eb-3b7c-85ba0343c503
# ╟─a0a0cc5a-647d-11eb-380a-bb5c0da3d2bd
# ╟─1250300d-8bd5-41c3-a36f-b59064e8fbfd
# ╠═c5cf8e17-9dcc-4f37-ace2-dbc3d92a83d4
# ╠═2ecf4ffd-d41d-494c-9fec-d681a176a8ba
