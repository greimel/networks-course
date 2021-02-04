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

# ╔═╡ 6d4ec768-649f-11eb-1093-054ab8976450
let
	using Pkg
 	Pkg.activate(temp = true)
	
	Pkg.add([
		PackageSpec(name="DataAPI", version="1.4"),
		PackageSpec(name = "LightGraphs", version = "1.3"),	
			])
	
	Pkg.add(["Cairo", "GraphPlot", "GraphDataFrameBridge", "DataFrames", "CSV", "Compose", "PlutoUI"])
	
	using PlutoUI
	using LightGraphs
	using GraphPlot
	using GraphDataFrameBridge
	using DataFrames
	using CSV
	using Compose
	using Cairo
end

# ╔═╡ 0b79fb30-66d3-11eb-052b-89cfca69b3a6
md"""
`view_ti_network.jl` | **Version 1.1** | *last updated: Feb 4*
"""

# ╔═╡ 7c18cc0e-66d3-11eb-3e8e-09d869dd5731
md"""
# The Co-Authorship Network of the Tinbergen Institute
"""

# ╔═╡ 0b3a89e6-66d3-11eb-2bf4-9b348d25a3a2
md"""
!!! danger "Note"
    The dataset is not publicly available. Please download it from *Canvas* and load it into the notebook. You can either specify `path_to_csv` or use the file picker.
"""

# ╔═╡ d6daf5ae-66d3-11eb-02a9-b33a381cf6cf
@bind file_data FilePicker()

# ╔═╡ c3b4327e-66d3-11eb-049a-ef792ef3bc8b
path_to_csv = "/path/to/ti_netwk0711.csv"

# ╔═╡ 2951a9a0-5e8e-11eb-0d4a-33a6525ffd81
links_list = let
	if length(file_data["data"]) > 0
		CSV.read(file_data["data"], DataFrame)
	else
		CSV.read(path_to_csv, DataFrame)
	end
end

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

# ╔═╡ d60da13e-6607-11eb-3069-ef521f73c7a9
katz_centrality(core3, 0.3)

# ╔═╡ cfc9f604-6604-11eb-23bc-699617b17d7d
md"""
# Appendix
"""

# ╔═╡ Cell order:
# ╟─0b79fb30-66d3-11eb-052b-89cfca69b3a6
# ╟─7c18cc0e-66d3-11eb-3e8e-09d869dd5731
# ╟─0b3a89e6-66d3-11eb-2bf4-9b348d25a3a2
# ╟─d6daf5ae-66d3-11eb-02a9-b33a381cf6cf
# ╠═c3b4327e-66d3-11eb-049a-ef792ef3bc8b
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
# ╠═d60da13e-6607-11eb-3069-ef521f73c7a9
# ╟─cfc9f604-6604-11eb-23bc-699617b17d7d
# ╠═6d4ec768-649f-11eb-1093-054ab8976450
