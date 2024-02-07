### A Pluto.jl notebook ###
# v0.19.22

#> [frontmatter]
#> chapter = 2
#> section = 4
#> order = 1
#> title = "Random networks"
#> layout = "layout.jlhtml"
#> tags = ["networks-basics"]
#> description = ""

using Markdown
using InteractiveUtils

# ╔═╡ b84074c1-199a-42d2-bfdd-72ae16c8b175
using PlutoUI

# ╔═╡ 887fff56-36ab-4ddd-8755-a914300a8288
using Graphs

# ╔═╡ 3e6061cf-5416-4578-a176-44a7bf7cf52d
using GraphMakie

# ╔═╡ 1ff6def8-d773-46a4-bda2-4427b445439e
using CairoMakie

# ╔═╡ 1dcf6c6a-1ece-4483-a136-43d1d2ddc1b4
using GraphDataFrameBridge

# ╔═╡ b1530ca8-ee92-4e96-9b48-39af285f6034
using NetworkLayout

# ╔═╡ be84b8d0-91ab-45f8-bf20-632fd5e40669
using DataFrames

# ╔═╡ 6f5200cb-d0a0-4b9c-86d6-cbcaf94bd5c5
using CSV, HTTP

# ╔═╡ ac985088-ea5f-4cd6-b020-7501863b2468
using Statistics, StatsBase

# ╔═╡ 0b79fb30-66d3-11eb-052b-89cfca69b3a6
md"""
`random-networks.jl` | **Version 1.1** | *last updated: Feb 2, 2023*
"""

# ╔═╡ 7c18cc0e-66d3-11eb-3e8e-09d869dd5731
md"""
# Comparing random networks with the TI co-authorship network
"""

# ╔═╡ 476877a2-6cc8-11eb-2a7f-e59927a8595e
md"
### Giant component of Erdos-Renyi random networks
"

# ╔═╡ 540960e8-6cc8-11eb-1b5c-490e3a96eb35
g1 = erdos_renyi(1000, 1/1200)

# ╔═╡ 372c8ebe-6cc8-11eb-0823-cda3f2cf433b
g2 = erdos_renyi(1000, 1/800)

# ╔═╡ 6a0c3a3c-6cc8-11eb-0bbb-95b7c79309f2
components1 = sort(connected_components(g1), by=size, rev=true) 

# ╔═╡ b2172ae4-6cc8-11eb-22bc-1bf38f1a7373
components2 = sort(connected_components(g2), by=size, rev=true) 

# ╔═╡ 9a8c241a-6cc8-11eb-0e76-6f5fc8cc8836
gc1 = g1[components1[1]]

# ╔═╡ bba07624-6cc8-11eb-1afb-f7d4855bc3bc
gc2 = g2[components2[1]]

# ╔═╡ 9d736cce-6cbe-11eb-32d5-55ada6f58da6
md"
### Tinbergen Institute coauthorship network
"

# ╔═╡ 8ab5cd0a-6cbe-11eb-217c-e189682e9faa
md"
### Erdos-Renyi random network
"

# ╔═╡ 1567451a-6cc0-11eb-3f56-cd7daeb7470e
md"
#### Find $n$ and $p$
"

# ╔═╡ dc572f2a-6cbe-11eb-3d86-77b920a482d9
md"
### Watts-Strogatz random network (Small World Model)
"

# ╔═╡ f3db7688-6cbe-11eb-1e73-1d9833ce4011
md"
### Barabasi-Albert network (preferential attachment)
"

# ╔═╡ 9f32c322-6cc1-11eb-1420-6dd67597ae22
md"
### Jackson-Rogers network
"

# ╔═╡ b9b71edc-6cc1-11eb-3171-db13c8e4d57a
md"
To be implemented ...
"

# ╔═╡ 0f6e69f2-6cc2-11eb-0b56-5bfdae1da750
md"
##### Create TI network from list of edges
"

# ╔═╡ 336f15b4-49c0-46bb-89eb-2e0388c57513
function csv_from_url(url)
	CSV.File(HTTP.get(url).body)
end

# ╔═╡ cfc9f604-6604-11eb-23bc-699617b17d7d
md"""
# Appendix
"""

# ╔═╡ ea3dad29-8293-483b-b0f5-5b546644690c
TableOfContents()

# ╔═╡ a00e1d40-9798-4850-9e46-e33a75fd0f31
md"""
## Download data
"""

# ╔═╡ 804efc30-f0ba-4205-9580-887b212d878c
url_ti = "https://greimel.github.io/networks-course/assets/datasets/ti_netwk0711.csv"

# ╔═╡ b6e76541-f97f-44fb-9149-ff07b5e51b78
begin
	using DataDeps
	ENV["DATADEPS_ALWAYS_ACCEPT"] = true

	register(DataDep(
   		"TI-network",
		"""
		The co-authorship network of the Tinbergen Institute 2007-2011.

		Made available with the permission of Marco van der Leij.
		""",
		url_ti,
		"dbb2a1d8ce1120ed274898ce76f84f7ef08f9938ad7f25f74d3b9f202dbc2137"
	))
end

# ╔═╡ dfdea6ae-e813-4a7f-8b92-ac7508baaf00
edge_df = CSV.File(joinpath(datadep"TI-network", "ti_netwk0711.csv")) |> DataFrame

# ╔═╡ 24dd4376-5e8f-11eb-02e7-f34f7c169726
#g_ti = MetaGraph(links_list, :from, :to)
g_ti = MetaGraph(edge_df, :from, :to)

# ╔═╡ bcc6ca3a-5e95-11eb-3f13-877d22fe2ff2
ti_plot = graphplot(g_ti,
	layout = Spring(),
	edge_color = "gray",
	edge_width = 0.5,
	node_size = 10,
	node_color = "orange",
	node_attr = (strokewidth = 1, strokecolor = :black),
)

# ╔═╡ 348e6d2c-6cba-11eb-1756-39b816e58c2a
g_ti

# ╔═╡ 415e6344-6cb6-11eb-2ab7-396f46c382b1
mean(degree(g_ti))

# ╔═╡ 14450eb4-6cb7-11eb-1191-73e97ac20e46
global_clustering_coefficient(g_ti)

# ╔═╡ bd41a722-6cb7-11eb-2eb3-5ff8e58b57d5
hist(degree(g_ti))

# ╔═╡ 8329d862-6cbe-11eb-3552-7d8ea15ed207
maximum(degree(g_ti))

# ╔═╡ b3a1e57e-6cba-11eb-2a05-19a21cef02ad
n = size(g_ti)[1]

# ╔═╡ 61a21dbe-6cbc-11eb-1842-a9421fd96269
g_ws = watts_strogatz(n, 4, 0.1)

# ╔═╡ b0aa1b0a-6cbc-11eb-32a1-31c2dfb60a7d
graphplot(g_ws,
	layout = Spring(),
	edge_color = "gray",
	edge_width = 0.5,
	node_size = 10,
	node_color = "orange",
	node_attr = (strokewidth = 1, strokecolor = :black),
)

# ╔═╡ 18350c76-6cbd-11eb-3fd1-35b68887e9b1
mean(degree(g_ws))

# ╔═╡ a18c29a6-6cbc-11eb-3eb8-4f32c56e9cda
global_clustering_coefficient(g_ws)

# ╔═╡ 6f244dca-6cbe-11eb-38cb-af6a63727d02
maximum(degree(g_ws))

# ╔═╡ cc228248-225a-42f1-a262-d57dca0c6410
hist(degree(g_ws))

# ╔═╡ 8a5f4efc-6cbc-11eb-15b5-51fdb2f0a44a
components_ws = sort(connected_components(g_ws), by=size, rev=true)

# ╔═╡ 820c94a8-6cbc-11eb-3c04-19829b78aa88
core_ws = g_ws[components_ws[1]]

# ╔═╡ 25575d32-6cbd-11eb-1d02-bd86a7f9356b
core_ws

# ╔═╡ 2e8bd82e-6cbd-11eb-13de-07a799a0e319
diameter(core_ws)

# ╔═╡ 6630610a-6cbd-11eb-3501-1f668cc8ca18
g_ba = barabasi_albert(n,2)

# ╔═╡ 821fad3a-6cbd-11eb-0729-8304f76f656c
graphplot(g_ba,
	layout = Spring(),
	edge_color = "gray",
	edge_width = 0.5,
	node_size = 10,
	node_color = "orange",
	node_attr = (strokewidth = 1, strokecolor = :black),
)


# ╔═╡ e0509180-aa45-46b9-93b6-5651a9d31450
mean(degree(g_ba)) # 2.4 for TI network

# ╔═╡ 0eb8abb6-6cbe-11eb-041d-6d4ff4748798
global_clustering_coefficient(g_ba) # 0.31 for TI network

# ╔═╡ 46aa0790-6cbe-11eb-1209-5fa06348c1b0
maximum(degree(g_ba))# 9 for TI network

# ╔═╡ f3a30ea2-6cbd-11eb-1416-d5c688010bac
hist(degree(g_ba))

# ╔═╡ 9c6480ee-6cbd-11eb-02ba-eda7e48c0663
components_ba = sort(connected_components(g_ba), by=size, rev=true)

# ╔═╡ ab5a872e-6cbd-11eb-07ef-2bf99eb613ad
core_ba = g_ba[components_ba[1]]

# ╔═╡ e4b378ca-6cbd-11eb-163f-1702ef3db8a4
core_ba   # {61, 88} for TI network

# ╔═╡ bd7f220c-6cbd-11eb-2a5c-35ed4c9478ec
diameter(core_ba)

# ╔═╡ c1e1a8b8-6cba-11eb-1ff4-39f46eb97606
p = mean(degree(g_ti))/(n-1)
#check 
#p = 139 / (115*114/2)

# ╔═╡ a6ec1ff2-6cba-11eb-0e53-cf07cba1ff45
g_er = erdos_renyi(n, p)

# ╔═╡ e2e9cb92-6cbc-11eb-370b-d7b35b220a77
graphplot(g_er,
	layout = Spring(),
	edge_color = "gray",
	edge_width = 0.5,
	node_size = 10,
	node_color = "orange",
	node_attr = (strokewidth = 1, strokecolor = :black),
)

# ╔═╡ e36c9d70-6cbb-11eb-1150-371082d44318
mean(degree(g_er))#, std(degree(g_ti))

# ╔═╡ d794adb2-6cbb-11eb-2ce2-0fb1998e0358
global_clustering_coefficient(g_er)#, std(local_clustering_coefficient(g_ti))

# ╔═╡ 782007ca-6cbe-11eb-3224-a9f691c7e7c6
maximum(degree(g_er))

# ╔═╡ 2d1580c2-6cbc-11eb-1b9c-d1843eab1c33
hist(degree(g_er))

# ╔═╡ 9a4aea7a-6cbb-11eb-296d-d304a4d02f36
components_er = sort(connected_components(g_er), by=size, rev=true)

# ╔═╡ 7faabfcc-6cbb-11eb-050f-93faebd37161
core_er = g_er[components_er[1]]

# ╔═╡ 159c6a0a-6cbc-11eb-1a57-fff6157c8cfb
core_er

# ╔═╡ 22c596e6-6cbc-11eb-1879-d5f3f24d3c2b
diameter(core_er)

# ╔═╡ a58a3582-64a3-11eb-01e1-11f707525149
# list of components (contains a list of nodes for each component)
components_ti = sort(connected_components(g_ti), by=size, rev=true)

# ╔═╡ aac6e282-6603-11eb-18bd-95a57f187167
# nodes in first (largest) component
core_ti = g_ti[components_ti[1]]

# ╔═╡ 6b24c8ca-6cb5-11eb-139c-195aea0edc7b
core_ti

# ╔═╡ f95cb1b2-6cb9-11eb-1c35-097ecbcd45c1
diameter(core_ti)

# ╔═╡ 92cb58e4-8ea6-47a4-8dd1-167fbc04fa18
md"""
## Packages
"""

# ╔═╡ Cell order:
# ╟─0b79fb30-66d3-11eb-052b-89cfca69b3a6
# ╟─7c18cc0e-66d3-11eb-3e8e-09d869dd5731
# ╟─476877a2-6cc8-11eb-2a7f-e59927a8595e
# ╠═540960e8-6cc8-11eb-1b5c-490e3a96eb35
# ╠═372c8ebe-6cc8-11eb-0823-cda3f2cf433b
# ╠═6a0c3a3c-6cc8-11eb-0bbb-95b7c79309f2
# ╠═b2172ae4-6cc8-11eb-22bc-1bf38f1a7373
# ╠═9a8c241a-6cc8-11eb-0e76-6f5fc8cc8836
# ╠═bba07624-6cc8-11eb-1afb-f7d4855bc3bc
# ╟─9d736cce-6cbe-11eb-32d5-55ada6f58da6
# ╟─bcc6ca3a-5e95-11eb-3f13-877d22fe2ff2
# ╠═348e6d2c-6cba-11eb-1756-39b816e58c2a
# ╠═415e6344-6cb6-11eb-2ab7-396f46c382b1
# ╠═14450eb4-6cb7-11eb-1191-73e97ac20e46
# ╠═6b24c8ca-6cb5-11eb-139c-195aea0edc7b
# ╠═f95cb1b2-6cb9-11eb-1c35-097ecbcd45c1
# ╠═bd41a722-6cb7-11eb-2eb3-5ff8e58b57d5
# ╠═8329d862-6cbe-11eb-3552-7d8ea15ed207
# ╟─8ab5cd0a-6cbe-11eb-217c-e189682e9faa
# ╟─1567451a-6cc0-11eb-3f56-cd7daeb7470e
# ╠═b3a1e57e-6cba-11eb-2a05-19a21cef02ad
# ╠═c1e1a8b8-6cba-11eb-1ff4-39f46eb97606
# ╠═a6ec1ff2-6cba-11eb-0e53-cf07cba1ff45
# ╟─e2e9cb92-6cbc-11eb-370b-d7b35b220a77
# ╠═e36c9d70-6cbb-11eb-1150-371082d44318
# ╠═d794adb2-6cbb-11eb-2ce2-0fb1998e0358
# ╠═159c6a0a-6cbc-11eb-1a57-fff6157c8cfb
# ╠═22c596e6-6cbc-11eb-1879-d5f3f24d3c2b
# ╠═782007ca-6cbe-11eb-3224-a9f691c7e7c6
# ╠═2d1580c2-6cbc-11eb-1b9c-d1843eab1c33
# ╟─dc572f2a-6cbe-11eb-3d86-77b920a482d9
# ╠═61a21dbe-6cbc-11eb-1842-a9421fd96269
# ╟─b0aa1b0a-6cbc-11eb-32a1-31c2dfb60a7d
# ╠═18350c76-6cbd-11eb-3fd1-35b68887e9b1
# ╠═a18c29a6-6cbc-11eb-3eb8-4f32c56e9cda
# ╠═25575d32-6cbd-11eb-1d02-bd86a7f9356b
# ╠═2e8bd82e-6cbd-11eb-13de-07a799a0e319
# ╠═6f244dca-6cbe-11eb-38cb-af6a63727d02
# ╠═cc228248-225a-42f1-a262-d57dca0c6410
# ╟─f3db7688-6cbe-11eb-1e73-1d9833ce4011
# ╠═6630610a-6cbd-11eb-3501-1f668cc8ca18
# ╟─821fad3a-6cbd-11eb-0729-8304f76f656c
# ╠═e0509180-aa45-46b9-93b6-5651a9d31450
# ╠═0eb8abb6-6cbe-11eb-041d-6d4ff4748798
# ╠═e4b378ca-6cbd-11eb-163f-1702ef3db8a4
# ╠═bd7f220c-6cbd-11eb-2a5c-35ed4c9478ec
# ╠═46aa0790-6cbe-11eb-1209-5fa06348c1b0
# ╠═f3a30ea2-6cbd-11eb-1416-d5c688010bac
# ╟─9f32c322-6cc1-11eb-1420-6dd67597ae22
# ╟─b9b71edc-6cc1-11eb-3171-db13c8e4d57a
# ╟─0f6e69f2-6cc2-11eb-0b56-5bfdae1da750
# ╠═24dd4376-5e8f-11eb-02e7-f34f7c169726
# ╠═336f15b4-49c0-46bb-89eb-2e0388c57513
# ╠═a58a3582-64a3-11eb-01e1-11f707525149
# ╠═aac6e282-6603-11eb-18bd-95a57f187167
# ╠═9a4aea7a-6cbb-11eb-296d-d304a4d02f36
# ╠═7faabfcc-6cbb-11eb-050f-93faebd37161
# ╠═8a5f4efc-6cbc-11eb-15b5-51fdb2f0a44a
# ╠═820c94a8-6cbc-11eb-3c04-19829b78aa88
# ╠═9c6480ee-6cbd-11eb-02ba-eda7e48c0663
# ╠═ab5a872e-6cbd-11eb-07ef-2bf99eb613ad
# ╟─cfc9f604-6604-11eb-23bc-699617b17d7d
# ╠═ea3dad29-8293-483b-b0f5-5b546644690c
# ╟─a00e1d40-9798-4850-9e46-e33a75fd0f31
# ╠═804efc30-f0ba-4205-9580-887b212d878c
# ╠═dfdea6ae-e813-4a7f-8b92-ac7508baaf00
# ╠═b6e76541-f97f-44fb-9149-ff07b5e51b78
# ╟─92cb58e4-8ea6-47a4-8dd1-167fbc04fa18
# ╠═b84074c1-199a-42d2-bfdd-72ae16c8b175
# ╠═887fff56-36ab-4ddd-8755-a914300a8288
# ╠═3e6061cf-5416-4578-a176-44a7bf7cf52d
# ╠═1ff6def8-d773-46a4-bda2-4427b445439e
# ╠═1dcf6c6a-1ece-4483-a136-43d1d2ddc1b4
# ╠═b1530ca8-ee92-4e96-9b48-39af285f6034
# ╠═be84b8d0-91ab-45f8-bf20-632fd5e40669
# ╠═6f5200cb-d0a0-4b9c-86d6-cbcaf94bd5c5
# ╠═ac985088-ea5f-4cd6-b020-7501863b2468
