### A Pluto.jl notebook ###
# v0.12.18

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

# ╔═╡ 4ae207fc-5c91-11eb-3379-41c713cb7fa4
begin
	_a_ = 1 # make sure this cell is run before other Pkg cell
	
	import Pkg
	Pkg.activate(temp = true)
	
	Pkg.add(["WGLMakie", "JSServe"])
	using WGLMakie, JSServe
	
#	Page()
	Page(exportable = true)
end

# ╔═╡ e5fb0e7c-5c8b-11eb-0c6f-5f0a8ae6c436
begin
	Pkg.add(["DataFrames", "PlutoUI", "LightGraphs", "NetworkLayout"])
	using DataFrames, PlutoUI
	using LightGraphs
	using NetworkLayout: NetworkLayout, SFDP
	
	_a_ # make sure this cell is run after other Pkg cell
end

# ╔═╡ 7172fca8-5c8c-11eb-21cd-59ae55a80a71
TableOfContents()

# ╔═╡ 31ff1eb0-5c8e-11eb-1289-45a18d4b2b1a
md"""
# A template for a Pluto notebook with WGLMakie
"""

# ╔═╡ 4bb90e9c-5c8e-11eb-3eb1-abd17392b7ff
md"""
## A first interactive plot

Here is a first plot.
"""

# ╔═╡ 6ff218d2-5c8e-11eb-1cd6-afbed2f98bd8
begin
	x = Node(1:10)
	y = Node(fill(0.5, 10))
end

# ╔═╡ 03c245bc-5c8f-11eb-18e8-9bac88542f10
@bind y_val PlutoUI.Slider(0.1:0.1:0.8, default = 0.4, show_value = true)

# ╔═╡ c3a07db4-5c8e-11eb-17c4-1112f8210d10
y[] = fill(y_val, 10)

# ╔═╡ 94065256-5c8c-11eb-35f4-e1416cb8242d
let
	fig, _, _ = scatter(1:10, rand(10))
	scatter!(x, y)
	
	fig
end

# ╔═╡ be4f509a-5c9a-11eb-3daf-fd21648c0b18
md"""
## A first network
"""

# ╔═╡ ca34f57c-5c9a-11eb-001e-9f344bb65aaa
function adj_nodes_edges(graph)
	# Generate sparse adjacency matrix
	adj   = adjacency_matrix(graph)
	# generate 2D layout of the network
	node_positions = NetworkLayout.SFDP.layout(adj, Point2f0,
						tol = 0.1, C = 1, K = 1, iterations = 100)
	# generate a list of points that can be used to plot the graph
	edges_as_pts = Point2f0[]
	
	for e in edges(graph)
		push!(edges_as_pts, node_positions[e.src])
		push!(edges_as_pts, node_positions[e.dst])
		push!(edges_as_pts, Point2f0(NaN, NaN))
	end
	
	(; adj, node_positions, edges_as_pts)
end

# ╔═╡ 5edd8284-5c9b-11eb-1f50-33218703a2a7
graph = WheelGraph(15)

# ╔═╡ 3a4ceb3c-5c9b-11eb-1aac-47d46e717694
graph_etc = adj_nodes_edges(graph)

# ╔═╡ 6bf95c1e-5c90-11eb-1ae4-dd16ff96ae91
md"""
## Plotting the network
"""

# ╔═╡ 73cd2882-5c93-11eb-1300-1178b28cf0bb
scatter(graph_etc.node_positions)

# ╔═╡ ea0b4d5c-5c94-11eb-2b89-273935c4a76f
let
	fig, _, _ = lines(graph_etc.edges_as_pts, linewidth = 0.1, color = (:black, 0.1), axis = (title = "A network", ))
	scatter!(graph_etc.node_positions)
	
	fig
end

# ╔═╡ f6b76b92-5c96-11eb-1e1f-6f3e5d552448
let
	fig = Figure()
	ax = fig[1,1] = Axis(fig, title = "A network")
	
	hidedecorations!(ax)
	hidespines!(ax)
	
	lines!(ax, graph_etc.edges_as_pts, linewidth = 0.1, color = (:black, 0.1))
	scatter!(ax, graph_etc.node_positions)
	
	fig
end

# ╔═╡ 4fff6c4e-5c98-11eb-1797-7be3922c210e
md"""
## Visualizing diffusion on a network
"""

# ╔═╡ ef365082-5c9f-11eb-058c-055002be1158
md"""
### A dummy simulation
"""

# ╔═╡ 5f331996-5c9c-11eb-2959-37699a4d8ca1
T = 15

# ╔═╡ 987d64f0-5c9b-11eb-1fc3-63ef6114a54d
states = ["first state", "second state"]

# ╔═╡ a9436280-5c9b-11eb-0450-33c42809a7db
color_dict = Dict("first state" => :blue, "second state" => :red)

# ╔═╡ 1431a3d4-5c9e-11eb-1a70-49e4bfc3797b
state_T = let
	N = length(vertices(graph))
	tmp = fill(states[2], N, T)
	for t in 1:T
		tmp[1:min(t,N), t] .= states[1]
	end
	tmp
end

# ╔═╡ a73304ea-5c9c-11eb-3c3c-554d24d57a59
state_as_color_T = [color_dict[s] for s in state_T]

# ╔═╡ 0aecd3a2-5ca0-11eb-125b-b7fb93b6e872
md"""
### Plot
"""

# ╔═╡ 2f9d6ef4-5c9f-11eb-2c56-cbd9d4720814
md"Define the `observable` and the slider"

# ╔═╡ cb0c1048-5c9c-11eb-1916-8b0fe5c5b6b2
t = Node(1) # define observable

# ╔═╡ 5048525e-5c9c-11eb-283b-a11e4978c72a
@bind t0 PlutoUI.Slider(1:T, show_value=true, default = 1)

# ╔═╡ d5fc6dca-5c9c-11eb-1e38-e1a7de26d8a2
t[] = t0 # update observable with value from slider

# ╔═╡ 68a53b26-5c9f-11eb-122b-cda3d94a7fc7
md"Let's have a look at `t`."

# ╔═╡ f2bde74a-5c9c-11eb-00e5-9d7fb5600691
state_as_color_t = @lift(state_as_color_T[:,$t])

# ╔═╡ 1aea0812-5c9c-11eb-2ea1-f57f6e8ddecf
let
	fig = Figure()
	ax = fig[1,1] = Axis(fig, title = @lift("A network time " * string($t)))
	
	hidedecorations!(ax)
	hidespines!(ax)
	
	lines!(ax, graph_etc.edges_as_pts, linewidth = 0.1, color = (:black, 0.1))
	scatter!(ax, graph_etc.node_positions, color = state_as_color_t)
	
	fig
end

# ╔═╡ 68d40400-5ca2-11eb-2942-ed67e719358b
#let timestamps = 1:15
#	record(fig, joinpath(@__DIR__(), "time_animation.gif"), timestamps; framerate = 2) do tt
#    	t[] = tt
#	end
#end

# ╔═╡ Cell order:
# ╠═7172fca8-5c8c-11eb-21cd-59ae55a80a71
# ╠═4ae207fc-5c91-11eb-3379-41c713cb7fa4
# ╠═e5fb0e7c-5c8b-11eb-0c6f-5f0a8ae6c436
# ╟─31ff1eb0-5c8e-11eb-1289-45a18d4b2b1a
# ╟─4bb90e9c-5c8e-11eb-3eb1-abd17392b7ff
# ╠═6ff218d2-5c8e-11eb-1cd6-afbed2f98bd8
# ╠═03c245bc-5c8f-11eb-18e8-9bac88542f10
# ╠═c3a07db4-5c8e-11eb-17c4-1112f8210d10
# ╠═94065256-5c8c-11eb-35f4-e1416cb8242d
# ╟─be4f509a-5c9a-11eb-3daf-fd21648c0b18
# ╠═ca34f57c-5c9a-11eb-001e-9f344bb65aaa
# ╠═5edd8284-5c9b-11eb-1f50-33218703a2a7
# ╠═3a4ceb3c-5c9b-11eb-1aac-47d46e717694
# ╟─6bf95c1e-5c90-11eb-1ae4-dd16ff96ae91
# ╠═73cd2882-5c93-11eb-1300-1178b28cf0bb
# ╠═ea0b4d5c-5c94-11eb-2b89-273935c4a76f
# ╠═f6b76b92-5c96-11eb-1e1f-6f3e5d552448
# ╟─4fff6c4e-5c98-11eb-1797-7be3922c210e
# ╟─ef365082-5c9f-11eb-058c-055002be1158
# ╠═5f331996-5c9c-11eb-2959-37699a4d8ca1
# ╠═987d64f0-5c9b-11eb-1fc3-63ef6114a54d
# ╠═a9436280-5c9b-11eb-0450-33c42809a7db
# ╠═1431a3d4-5c9e-11eb-1a70-49e4bfc3797b
# ╠═a73304ea-5c9c-11eb-3c3c-554d24d57a59
# ╟─0aecd3a2-5ca0-11eb-125b-b7fb93b6e872
# ╟─2f9d6ef4-5c9f-11eb-2c56-cbd9d4720814
# ╠═cb0c1048-5c9c-11eb-1916-8b0fe5c5b6b2
# ╠═5048525e-5c9c-11eb-283b-a11e4978c72a
# ╠═d5fc6dca-5c9c-11eb-1e38-e1a7de26d8a2
# ╟─68a53b26-5c9f-11eb-122b-cda3d94a7fc7
# ╠═1aea0812-5c9c-11eb-2ea1-f57f6e8ddecf
# ╠═f2bde74a-5c9c-11eb-00e5-9d7fb5600691
# ╠═68d40400-5ca2-11eb-2942-ed67e719358b
