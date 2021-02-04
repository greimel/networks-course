### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 6d4ec768-649f-11eb-1093-054ab8976450
let
	using Pkg
 	Pkg.activate(temp = true)
	
	Pkg.add(["Cairo", "LightGraphs", "GraphPlot", "GraphDataFrameBridge", "DataFrames", "CSV", "Compose"])

	using LightGraphs
	using GraphPlot
	using GraphDataFrameBridge
	using DataFrames
	using CSV
	using Compose
	using Cairo
end

# ╔═╡ 2951a9a0-5e8e-11eb-0d4a-33a6525ffd81
links_list = CSV.read("ti_netwk0711.csv", DataFrame)

# ╔═╡ 24dd4376-5e8f-11eb-02e7-f34f7c169726
g = MetaGraph(links_list, :from, :to)

# ╔═╡ a06b7ad2-6603-11eb-1588-195115c5f351
gplot(g, nodesize=0.1, NODESIZE=0.015, layout=spring_layout, nodestrokelw=1, nodestrokec = "black", nodefillc="orange")

# ╔═╡ a58a3582-64a3-11eb-01e1-11f707525149
# list of components (contains a list of nodes for each component)
components = connected_components(g)

# ╔═╡ aac6e282-6603-11eb-18bd-95a57f187167
# nodes in first (largest) component
core = components[1]

# ╔═╡ bcc6ca3a-5e95-11eb-3f13-877d22fe2ff2
ti_plot = gplot(g[core], nodesize=0.1, NODESIZE=0.015, layout=spring_layout, nodestrokelw=1, nodestrokec = "black", nodefillc="orange")

# ╔═╡ ff372202-649e-11eb-059f-cdb0d622e07b
# save as PDF (try other formats, such as PNG)
draw(PDF("ti_network.pdf"), ti_plot)

# ╔═╡ a2539aee-6605-11eb-0788-157d9b7c1060
# maximal subgraph with vertices of degree 3 or more
g1 = k_core(g, 3)

# ╔═╡ c96871cc-6605-11eb-161b-41af51664d50
gplot(g[g1],nodesize=0.1, NODESIZE=0.03, layout=spring_layout, nodestrokelw=1, nodestrokec = "black", nodefillc="orange")

# ╔═╡ 295dcee0-6608-11eb-04d7-a9232f4a727a
core3 = g[g1]

# ╔═╡ 66cedb40-660b-11eb-07cb-8107b36a0251
local_clustering_coefficient(core3)

# ╔═╡ b72d7a58-6607-11eb-11f0-d98ad7953ac0
degree_centrality(core3)

# ╔═╡ 52534b4e-6607-11eb-0478-390a8dbfc17b
eigenvector_centrality(core3)

# ╔═╡ 21f8b854-6608-11eb-0906-b977412f17e9


# ╔═╡ d60da13e-6607-11eb-3069-ef521f73c7a9
katz_centrality(core3, 0.3)

# ╔═╡ cfc9f604-6604-11eb-23bc-699617b17d7d
md"""
# Appendix
"""

# ╔═╡ Cell order:
# ╠═2951a9a0-5e8e-11eb-0d4a-33a6525ffd81
# ╠═24dd4376-5e8f-11eb-02e7-f34f7c169726
# ╠═a06b7ad2-6603-11eb-1588-195115c5f351
# ╠═a58a3582-64a3-11eb-01e1-11f707525149
# ╠═aac6e282-6603-11eb-18bd-95a57f187167
# ╠═bcc6ca3a-5e95-11eb-3f13-877d22fe2ff2
# ╠═ff372202-649e-11eb-059f-cdb0d622e07b
# ╠═a2539aee-6605-11eb-0788-157d9b7c1060
# ╠═c96871cc-6605-11eb-161b-41af51664d50
# ╠═295dcee0-6608-11eb-04d7-a9232f4a727a
# ╠═66cedb40-660b-11eb-07cb-8107b36a0251
# ╠═b72d7a58-6607-11eb-11f0-d98ad7953ac0
# ╠═52534b4e-6607-11eb-0478-390a8dbfc17b
# ╠═21f8b854-6608-11eb-0906-b977412f17e9
# ╠═d60da13e-6607-11eb-3069-ef521f73c7a9
# ╟─cfc9f604-6604-11eb-23bc-699617b17d7d
# ╠═6d4ec768-649f-11eb-1093-054ab8976450
