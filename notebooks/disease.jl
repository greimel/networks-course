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

# ╔═╡ 32169866-5ca6-11eb-23ea-b9376fee89a9
begin
	_a_ = 1 # make sure this cell is run before other Pkg cell
	
	import Pkg
	Pkg.activate(temp = true)
	
	Pkg.add(["WGLMakie", "JSServe"])
	using WGLMakie, JSServe
	
	Page(exportable = true)
end

# ╔═╡ 34ad1df2-5ca6-11eb-25d6-6732d171cdc7
begin
	Pkg.add(["DataFrames", "PlutoUI", "LightGraphs", "NetworkLayout"])
	Pkg.add(["Distributions", "NearestNeighbors", "GeometryBasics"])
	Pkg.add(["PooledArrays"])
	#Pkg.add(PackageSpec(url="https://github.com/greimel/TabularMakie.jl"))
	
	using DataFrames, PlutoUI
	using LightGraphs
	using NetworkLayout: NetworkLayout, SFDP
	
	using NearestNeighbors: BallTree, knn
	using Distributions: LogNormal
	using GeometryBasics
	
	using PooledArrays
	# using TabularMakie
	
	using PlutoUI
	
	_a_ # make sure this cell is run after other Pkg cell
end

# ╔═╡ 79b35162-5cb2-11eb-061a-b7e2c77fc4a2
using Distributions

# ╔═╡ 94770402-5bf0-11eb-2e1b-b310fde05f0e
TableOfContents()

# ╔═╡ 94c9c7ee-5ca6-11eb-3b9f-dff68cabc208
md"""
# Diffusion on Networks: Variations of the SIR model
"""

# ╔═╡ 386c0068-5cb3-11eb-14b0-1da10f7af55e
md"""
## Spreading of a disease
"""

# ╔═╡ 96781c36-5cb4-11eb-1565-d5274fa01da4
T = 100

# ╔═╡ 9cf2a2b6-5cb4-11eb-06d4-bd3cdbf3a586
md"""
Set the parameters.

* ``p`` $(@bind p_out PlutoUI.Slider(0.1:0.1:0.9, show_value = true, default = 0.3)) the probability of transmission
* ``\rho`` $(@bind ρ_out PlutoUI.Slider(0.1:0.1:0.9, show_value = true, default = 0.2)) the probability of being removed 
"""

# ╔═╡ cd2672dc-5cb4-11eb-35d6-07bd4e06968b
states = ["susceptible", "infected", "recovered"]

# ╔═╡ 4159d66c-5cb7-11eb-08cd-d991a06fb3df
color_dict = Dict("susceptible" => :blue, "infected" => :red, "recovered" => :yellow)

# ╔═╡ a669c542-5cb7-11eb-3af0-19ff72d7bec3
md"""
### Visualization
"""

# ╔═╡ b3e79320-5cb7-11eb-3e14-cb163f150cde
t = Node(1)

# ╔═╡ c24d5a26-5cb7-11eb-3367-c1155dffe452
@bind t0 PlutoUI.Slider(1:T, show_value = true, default = 1)

# ╔═╡ d4525fe6-5cb7-11eb-3990-49b899501821
t[] = t0

# ╔═╡ 12bad1ba-5cb7-11eb-0a05-7305f8fcac52
md"""
### Functions for the simulation
"""

# ╔═╡ 406d78da-5cb5-11eb-23b8-1b5f864b0713
begin
	abstract type Mode end
	struct Outcomes <: Mode end
	struct Probabilities <: Mode end
end

# ╔═╡ de4b18d8-5cb4-11eb-290b-7d6648ead153
function prob_sick_given_healty(prob_sick_old, A, p)
	log_not_infected = log.(1 .- p.*prob_sick_old)	
	pr_healthy_given_healthy = exp.(A*log_not_infected)
	
	1 .- pr_healthy_given_healthy
end

# ╔═╡ ed77b4f6-5cb4-11eb-3437-d91b13a375db
function prob_sick(prob_sick_old, A, p, ρ)
	log_not_infected = log.(1 .- p.*prob_sick_old)
	pr_healthy_given_healthy = exp.(A*log_not_infected)
	pr_healthy_given_sick = ρ
	

  	pr_sick = (1 .- pr_healthy_given_healthy) .*(1 .- prob_sick_old) .+ (1 .- pr_healthy_given_sick) .* prob_sick_old
end

# ╔═╡ ec0a1b4a-5cb4-11eb-2117-834bf96fcc67
function new_state(old_state, p_sh, p_rs)
	rn = rand()
	
	if old_state == "recovered"
		return "recovered"
	elseif old_state == "susceptible"
	    if rn < p_sh # new infection
			return "infected"
		else 
			return "susceptible"
		end
	elseif old_state == "infected"
		if rn < p_rs # recovered
			return "recovered"
		else
			return "infected"
		end
	end
	@error "shouldn't be here $old_state"
end

# ╔═╡ e237d30a-5cb4-11eb-3527-138a36031b43
function update_infected!(x_new, x, p, A, ::Outcomes; ρ=0)
	is_sick_old = 1 .* (x .== "infected")
	#is_recovered_old = x .== "recovered"
	
	pr_sick = prob_sick_given_healty(is_sick_old, A, p)
	
	#x_new = copy(x)
	for i in eachindex(x)
		old = x[i]
		new = new_state(old, pr_sick[i], ρ)
		
		x_new[i] = new
	end
	x_new
end

# ╔═╡ dce0c3da-5cb4-11eb-20e1-fdfb6073dc30
function update_infected(x, p, A, mode; ρ=0)
	x_new = copy(x)
	update_infected!(x_new, x, p, A, mode; ρ=0)
	
	return x_new
end

# ╔═╡ f807ec5c-5bf0-11eb-308a-81466ea962d7
md"
## A spatial network
"

# ╔═╡ ca39ebe0-5bf0-11eb-25e4-bf369dff4be1
begin
	N = 1000
	id = 1:N
	x = rand(N)
	y = rand(N)
	node_positions = Point2f0.(x, y)
end

# ╔═╡ 220ec158-5cb2-11eb-2d37-9926f18493ea
degreedist = LogNormal(log(2), 1) #[2]

# ╔═╡ 81246ff8-5cb2-11eb-2ac1-39f753ab6003
#plot(degreedist)

# ╔═╡ 675124b6-5cb2-11eb-3b8d-5b301842ac31
#mean(degreedist)

# ╔═╡ 589184ca-5bf1-11eb-09e8-9db924d162f1
# adapted from David Gleich
function spatial_graph(node_positions; degreedist = LogNormal(log(3),1))
  	n = length(node_positions)
	
	coords_matrix = hcat(Vector.(node_positions)...)
  	T = BallTree(coords_matrix)
	
	g = SimpleGraph(n)
	
	for i = 1:n
		# draw the number of links `deg`
    	deg = min(ceil(Int, rand(degreedist)), n - 1)
    	# use the `deg` closest nodes as neighbours
		idxs, dists = knn(T, coords_matrix[:,i], deg + 1)
    	for j in idxs
      		if i != j
				add_edge!(g, i, j)
      		end
    	end
  	end
	
	g
end

# ╔═╡ 333bdbce-5cb1-11eb-1c5d-ad41a5f7831b
# generate a list of points that can be used to plot the graph
function edges_as_points(graph, node_positions)
	edges_as_pts = Point2f0[]

	for e in edges(graph)
		push!(edges_as_pts, node_positions[e.src])
        push!(edges_as_pts, node_positions[e.dst])
        push!(edges_as_pts, Point2f0(NaN, NaN))
    end
	
	edges_as_pts
end

# ╔═╡ 164a8a98-5cb0-11eb-0b6b-0df3a8cb942b
graph = spatial_graph(node_positions; degreedist)
#graph = CompleteGraph(N)

# ╔═╡ 0058c274-5cb5-11eb-1943-257819793991
init = let
	N = nv(graph)
	init = fill("susceptible", N)
	init[rand(1:N-1, 5)] .= "infected"
	init[end] = "recovered"
	
	init = PooledArray(init)
end

# ╔═╡ 5456d46c-5cb3-11eb-0dab-81204e6afc5c
sim = let
	N = nv(graph)
	
	sim = fill("susceptible", N, T)
	sim[:,1] .= init
	
	A = adjacency_matrix(graph)
	
	for t in 2:T	
		update_infected!(view(sim, :, t), view(sim, :, t-1), p_out, A, Outcomes(), ρ = ρ_out)
	end
	sim
end;

# ╔═╡ 3f274018-5cb6-11eb-05c2-a5b92b0c1741
sim_colors = [color_dict[s] for s in sim]

# ╔═╡ 00e4a9ba-5cb8-11eb-0e90-cd96a5a42d0e
state_as_color_t = @lift(sim_colors[:,$t])

# ╔═╡ 30edf75a-5cb1-11eb-1e9f-5939d8d94942
edges_as_pts = edges_as_points(graph, node_positions)

# ╔═╡ de4de51a-5cb7-11eb-3069-6b7ae3e256c7
let
    fig = Figure()
    ax = fig[1,1] = Axis(fig, title = @lift("A network -- time = " * string($t)))

	hidedecorations!(ax)
    hidespines!(ax)

	lines!(ax, edges_as_pts, linewidth = 0.1, color = (:black, 0.1))
    scatter!(ax, node_positions, markersize=5, color = state_as_color_t)

	fig
end

# ╔═╡ a3d092e4-5cb1-11eb-33b3-8977924524ff
begin
	fig, _, _ = lines(edges_as_pts, color = (:blue, 0.1))
	scatter!(node_positions, markersize = 5)
	fig
end

# ╔═╡ Cell order:
# ╠═94770402-5bf0-11eb-2e1b-b310fde05f0e
# ╠═32169866-5ca6-11eb-23ea-b9376fee89a9
# ╠═34ad1df2-5ca6-11eb-25d6-6732d171cdc7
# ╠═79b35162-5cb2-11eb-061a-b7e2c77fc4a2
# ╟─94c9c7ee-5ca6-11eb-3b9f-dff68cabc208
# ╟─386c0068-5cb3-11eb-14b0-1da10f7af55e
# ╠═96781c36-5cb4-11eb-1565-d5274fa01da4
# ╟─9cf2a2b6-5cb4-11eb-06d4-bd3cdbf3a586
# ╠═cd2672dc-5cb4-11eb-35d6-07bd4e06968b
# ╠═4159d66c-5cb7-11eb-08cd-d991a06fb3df
# ╠═0058c274-5cb5-11eb-1943-257819793991
# ╠═5456d46c-5cb3-11eb-0dab-81204e6afc5c
# ╠═3f274018-5cb6-11eb-05c2-a5b92b0c1741
# ╟─a669c542-5cb7-11eb-3af0-19ff72d7bec3
# ╠═b3e79320-5cb7-11eb-3e14-cb163f150cde
# ╠═c24d5a26-5cb7-11eb-3367-c1155dffe452
# ╠═d4525fe6-5cb7-11eb-3990-49b899501821
# ╠═00e4a9ba-5cb8-11eb-0e90-cd96a5a42d0e
# ╠═de4de51a-5cb7-11eb-3069-6b7ae3e256c7
# ╟─12bad1ba-5cb7-11eb-0a05-7305f8fcac52
# ╠═406d78da-5cb5-11eb-23b8-1b5f864b0713
# ╠═de4b18d8-5cb4-11eb-290b-7d6648ead153
# ╠═ed77b4f6-5cb4-11eb-3437-d91b13a375db
# ╠═ec0a1b4a-5cb4-11eb-2117-834bf96fcc67
# ╠═e237d30a-5cb4-11eb-3527-138a36031b43
# ╠═dce0c3da-5cb4-11eb-20e1-fdfb6073dc30
# ╟─f807ec5c-5bf0-11eb-308a-81466ea962d7
# ╠═ca39ebe0-5bf0-11eb-25e4-bf369dff4be1
# ╠═220ec158-5cb2-11eb-2d37-9926f18493ea
# ╠═81246ff8-5cb2-11eb-2ac1-39f753ab6003
# ╠═675124b6-5cb2-11eb-3b8d-5b301842ac31
# ╠═a3d092e4-5cb1-11eb-33b3-8977924524ff
# ╠═589184ca-5bf1-11eb-09e8-9db924d162f1
# ╠═333bdbce-5cb1-11eb-1c5d-ad41a5f7831b
# ╠═164a8a98-5cb0-11eb-0b6b-0df3a8cb942b
# ╠═30edf75a-5cb1-11eb-1e9f-5939d8d94942
