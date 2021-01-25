### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 2ecf4ffd-d41d-494c-9fec-d681a176a8ba
let
	using Pkg
	Pkg.activate(temp = true)
	
	Pkg.add(["LightGraphs", "GraphPlot", "Plots", "SNAPDatasets", "FreqTables", "StatsBase", "PlutoUI"])
	using PlutoUI
	
	using LightGraphs # for handling analyzing networks
	using GraphPlot   # for plotting networks
	using SNAPDatasets  # cool datasets of *big* networks
	
	using Plots
	
	# Basic statistical analysis
	using Statistics
	using FreqTables    
	using StatsBase
end

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
## Graphs with names

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
	my_network = SimpleGraph(7)
	add_edge!(my_network, 1, 2)
	add_edge!(my_network, 2, 3)
end

# ╔═╡ 5f1e3589-48fe-418a-958b-74b5dc0d7eff
md"""
## Building a network from scratch

Below you find a template of building a network from scratch. Play with it make it your own! (you can set the number of nodes (currently $(nv(my_network))) and add a few edges (there are currently $(ne(my_network))).

(Can you rebuild one of the named networks from above?)
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

Don't run the following cell on an old computer. The plot takes around 1 minute on my recent MacBook Pro."

# ╔═╡ 07f7ed69-3e9a-4a6b-a10f-de8d09aa0db5
#gplot(big_network)

# ╔═╡ 541303e2-02b3-4537-ab92-e3947652f6f6
md"""
# Analyzing networks with LightGraphs.jl

**NOTE** The concepts of this section are introduced in the first lectures of the course. Have a look if you're curious. But it is rather meant as a references for your assignments.
"""

# ╔═╡ 7e163209-7c52-4116-bcc2-572060b90fde
md"""
## Counting the number of neighbors: The degree of a node

Let's count the number of neighbors for each node. That is, how many links does each node have?

For illustration, let's plot the degree of each node for the `simple_network` from above.
"""

# ╔═╡ b34c0187-86dd-482c-a1dd-11a461bc0be2
gplot(simple_network, nodelabel = degree_centrality(simple_network, normalize=false))

# ╔═╡ 7dead69c-36c1-4676-a072-3442d20ba899
md"
Now, let's compute it for the big network.
"

# ╔═╡ 97d36935-3d2d-4079-a141-1bd030196328
degrees = Int.(degree_centrality(big_network, normalize=false))

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


# ╔═╡ ef85efd2-da5c-4197-831e-110aebe5a1d7
plot(x -> log(1 - ecdf(degrees)(x)), 1, 250)

# ╔═╡ 62063f20-4041-454d-964b-e2e89a8634f0
diameter(big_network)

# ╔═╡ 2e02bf8a-b9f2-4aaf-8e58-e5d17e3d193c
is_connected(big_network)

# ╔═╡ 09095fa6-5aa3-4d4b-88a5-a3e04d701837
#gdistances

# ╔═╡ 1250300d-8bd5-41c3-a36f-b59064e8fbfd
md"""
# Appendix
"""

# ╔═╡ c5cf8e17-9dcc-4f37-ace2-dbc3d92a83d4
TableOfContents()

# ╔═╡ Cell order:
# ╟─6009f070-5ef8-11eb-340a-d9780be085ad
# ╟─df4d9fab-13da-4df7-b51e-0689112f65fe
# ╠═bdd75f9a-17e1-4b80-aa88-8a1477032441
# ╠═6b1af27c-5d0a-43a2-b3a5-b02770aeb841
# ╠═165ba943-b546-42d0-84b2-00391572ff8e
# ╟─0f0dc575-7660-4b32-b158-95a9a0ab31e8
# ╟─5f1e3589-48fe-418a-958b-74b5dc0d7eff
# ╠═b01cef89-6258-4050-9d35-7628eaf54010
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
# ╠═ef85efd2-da5c-4197-831e-110aebe5a1d7
# ╠═62063f20-4041-454d-964b-e2e89a8634f0
# ╠═2e02bf8a-b9f2-4aaf-8e58-e5d17e3d193c
# ╠═09095fa6-5aa3-4d4b-88a5-a3e04d701837
# ╟─1250300d-8bd5-41c3-a36f-b59064e8fbfd
# ╠═c5cf8e17-9dcc-4f37-ace2-dbc3d92a83d4
# ╠═2ecf4ffd-d41d-494c-9fec-d681a176a8ba
