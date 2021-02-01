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

# ╔═╡ 2b55141f-1cba-4a84-8811-98697d408d65
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.add(["LightGraphs", "GeometryBasics", "PlutoUI", "FreqTables", "PooledArrays", "NearestNeighbors", "Distributions", "DataFrames", "Plots"])
	
	using GeometryBasics, NearestNeighbors, Distributions
	using LightGraphs
	using PlutoUI
	using PooledArrays
	using DataFrames
	using Plots
end

# ╔═╡ 31bbc540-68cd-4d4a-b87a-d648e003524c
TableOfContents()

# ╔═╡ b8d874b6-648d-11eb-251c-636c5ebc1f42
begin
	abstract type State end
	struct S <: State end
	struct I <: State end
	struct R <: State end
end

# ╔═╡ f48fa122-649a-11eb-2041-bbf0d0c4670c
const States = Union{subtypes(State)...}

# ╔═╡ 10dd6814-f796-42ea-8d40-287ed7c9d239
md"
# Define the transitions
"

# ╔═╡ 61a36e78-57f8-4ef0-83b4-90e5952c116f
transition_(::R,      args...; kwargs...) = R()

# ╔═╡ d3bfc9aa-649e-11eb-2c36-b1fba4507f07
# transition_(::D,      args...; kwargs...) = ...

# ╔═╡ 8ddb6f1e-649e-11eb-3982-83d2d319b31f
function transition_(::I, par, args...; kwargs...)
	x = rand()
	
	if x < par.ρ # recover
		R()
	else
		I()
	end
end

# ╔═╡ ffe07e00-0408-4986-9205-0fbb025a698c
function transition_(::S, par, node, adjacency_matrix, is_infected)
	inv_prob_transmission = 1.0
	
	for i in is_infected
		inv_prob_transmission *= 1 - par.p * adjacency_matrix[i, node]
	end
	
	π =	1.0 - inv_prob_transmission
	
	rand() < π ? I() : S()
end

# ╔═╡ f4c62f95-876d-4915-8372-258dfde835f7
function transition!(states_new, states, adjacency_matrix, par)

	is_infected = findall(isa.(states, I))
	
	for i in 1:size(adjacency_matrix, 1)
		states_new[i] = transition_(states[i], par, i, adjacency_matrix, is_infected)
	end
	
	states_new
end

# ╔═╡ 07f4816c-b893-4771-be3f-cc10695720cf
md"""
# Simulate
"""


# ╔═╡ fecf62c5-2c1d-4709-8c17-d4b6e0565617
function initial_state(N, n_infected)
	# fill with "Susceptible"
	init = States[S() for i in 1:N]
	# spread out the desired number of infected people
	inds_I = 1:(N÷n_infected):N
	for i in inds_I
		init[i] = I()
	end
	
	init
end

# ╔═╡ e7c5f754-649b-11eb-1f34-0392ece0b1f6


# ╔═╡ b0d34450-6497-11eb-01e3-27582a9f1dcc
llabel(x::DataType) = string(Base.typename(x).name)

# ╔═╡ 63b2882e-649b-11eb-28de-bd418b43a35f
llabel(x) = llabel(typeof(x))

# ╔═╡ a89c6f63-35e4-44d8-bfd1-20ed73549fea
function summarize(sim)
	T = size(sim, 2)
	levels = unique(sim)
	
	llabel.(sim)
	
	df = DataFrame(t = 1:T)
	
	for lev in levels
		#lev::DataType{T}
		#@show T
		df[:, llabel(lev)] = dropdims(sum(sim .== Ref(lev), dims = 1), dims = 1)
	end
	df
end

# ╔═╡ 53e344e6-6497-11eb-08ab-7f0468fb47b0
Type{S}.name

# ╔═╡ 37972f08-db05-4e84-9528-fe16cd86efbf
md"""
* ``\rho``: $(@bind ρ0 Slider(0.1:0.1:0.9, default = 0.1, show_value =true)) (recovery probability)
* ``\delta``: $(@bind δ0 Slider(0.0:0.02:0.2, default = 0.04, show_value =true)) (death rate)
* ``p``: $(@bind p0 Slider(0.1:0.1:0.9, default = 0.3, show_value =true)) (infection probability)
"""

# ╔═╡ 2d3466df-48b3-432f-843d-8f83d7fb575e
par = (ρ = ρ0, δ = δ0, p = p0)

# ╔═╡ 11ea4b84-649c-11eb-00a4-d93af0bd31c8
function tidy_simulation_output(sim)
	# go from type to symbol (S() => "S")
	sim1 = llabel.(sim)
	
	# make it a DataFrame with T columns and N rows
	df0 = DataFrame(sim1)
	rename!(df0, string.(1:size(df0,2)))
	
	# add a column with node identifier
	df0.node_id = 1:size(df0, 1)
	
	# stack df to
	# node_id | t | state
	df = stack(df0, Not(:node_id), variable_name = :t, value_name = :state)
	# make t numeric
	transform!(df, :t => ByRow(x -> parse(Int, eval(x))),
			       :state => categorical,
				   renamecols = false)
	
	df
end

# ╔═╡ 2ed340be-649e-11eb-31a7-a369a8215914


# ╔═╡ 1523ee2e-6490-11eb-2216-a1806099830b
# 15 ms => 40 ms => 20ms

# ╔═╡ 213510df-9772-4be9-b58d-db173c21519a
N = 1000

# ╔═╡ 5d11a2df-3187-4509-ba7b-8388564573a6
function transition(states, adjacency_matrix, par)
	states_new = Vector{States}(undef, N)
	transition!(states_new, states, adjacency_matrix, par)
	
	states_new
end

# ╔═╡ 208445c4-5359-4442-9b9b-bde5e55a8c23
function simulate(mat, par, T, init = initial_state(N, 10))
	sim = Matrix{States}(undef, N, T)
	sim[:,1] .= init
	
	for t = 2:T
		transition!(view(sim, :, t), view(sim, :, t-1), mat, par)
	end
	sim
end

# ╔═╡ 4dee5da9-aa4b-4551-974a-f7268d016617
md"""
# A glance at policies
"""

# ╔═╡ 78e729f8-ac7d-43c5-ad93-c07d9ac7f30e
md"""
## Social distancing
"""

# ╔═╡ 7b43d3d6-03a0-4e0b-96e2-9de420d3187f
p_range = 0.1:0.1:0.9

# ╔═╡ b44bf44f-7041-409a-aea2-7652f18853b0
md"""
## Vaccination

There are $N people and you can distribute $(N ÷ 10) doses of the vaccine. Whom would you vaccinate?
"""

# ╔═╡ 04227a80-5d28-43db-929e-1cdc5b31796d
md"""
# Travel ban

remove links
"""

# ╔═╡ e82d5b7f-5f37-4696-9917-58b117b9c1d6
md"
# Spatial graph
"

# ╔═╡ 95b67e4d-5d41-4b86-bb9e-5de97f5d8957
# adapted from David Gleich
function spatial_graph(node_positions; degreedist = LogNormal(log(2),1))
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

# ╔═╡ c1971734-2299-4038-8bb6-f62d020f92cb
graph = let
	N = 1000
	id = 1:N
	x = rand(N)
	y = rand(N)
	node_positions = Point2f0.(x, y)
	
	spatial_graph(node_positions)
end

# ╔═╡ 512593af-f72c-4e67-88a3-896876efc52b
mat = adjacency_matrix(graph)

# ╔═╡ 0b35f73f-6976-4d85-b61f-b4188440043e
begin
	sim = simulate(mat, par, 100)
	df0 = summarize(sim)
	df = stack(df0, Not(:t)) 
	nothing
end

# ╔═╡ eada7ed0-649b-11eb-3257-a715ea450554
llabel.(sim)

# ╔═╡ 994a7574-649d-11eb-3011-dbb82db18b5e
tidy_sim = tidy_simulation_output(sim)

# ╔═╡ bf18bef2-649d-11eb-3e3c-45b41a3fa6e5
df000 = combine(groupby(tidy_sim, [:t, :state]), :node_id => (x -> length(x)/N) => :fraction)

# ╔═╡ 2f00e2c6-649e-11eb-156f-a53dfb6d9f3f
plot(df000.t, df000.fraction, group=df000.state)

# ╔═╡ 465f0169-2bd2-4935-aa3f-951cd08ba3c1
begin
	plt = plot()
	plot!(df.t, df.value, group = df.variable)
#	plot!(df.t, df.S, label = "S")	
#	plot!(df.t, df.I, label = "I")
#	plot!(df.t, df.R, label = "R")
end

# ╔═╡ c5f48079-f52e-4134-8e6e-6cd4c9ee915d
let
	plt = plot(title = "#infected when varying the infection probability")
	for p in p_range
		par = (p = p, ρ = ρ0, δ = δ0)
		
		sim = simulate(mat, par, 100)
		
		df0 = summarize(sim)
		
		plot!(df0.t, df0.I, label = "p = $p", color = :blue, alpha = (1 - p))
	end
	
	plt
end

# ╔═╡ ee230ae8-8885-4b40-9ad1-87ae295f11c1
n_contacts = degree_centrality(graph, normalize = false)

# ╔═╡ 2ef8ab6b-3862-474f-ae9f-38d45246ef99
begin
	degree_df = DataFrame(i = 1:N, n_contacts = n_contacts)
	sort!(degree_df, :n_contacts)
end

# ╔═╡ c99f637f-cca9-4b77-b2db-2f5a251b23de
top_100_nodes = degree_df.i[901:1000]

# ╔═╡ 14791f01-7625-457e-941e-cd180460fbc5
bottom_100_nodes = degree_df.i[1:100]

# ╔═╡ f8ee8f92-acea-4def-b8d5-eaa452a66349
function init_vaccine(whom; N=N, n_vacc=100, n_I=50)
	# fill with "Susceptible"
	init = States[S() for i in 1:N]
	
	# vaccinate people
	if whom == :top
		ind_R = degree_df.i[(end-n_vacc):end]
	elseif whom == :bottom
		ind_R = degree_df.i[begin:(begin+n_vacc)]
	elseif whom == :none
		ind_R = Int[]
	else
		@error "Provide :top, :bottom or :none"
	end
	
	init[ind_R] .= Ref(R())
	
	ind_I = rand(degree_df.i[(begin+n_vacc):(end-n_vacc)], n_I)
	init[ind_I] .= Ref(I())
	
	init
	
end

# ╔═╡ 674f577e-29c4-499e-836b-6642cb2e7e03
let
	plt = plot(title = "#infected when vaccinating different groups")
	for (lab, init) in ["top" => init_vaccine(:top), "bottom" => init_vaccine(:bottom), "none" => init_vaccine(:none)]
		#par = (p = p, ρ = ρ0, δ = δ0)
		
		sim = simulate(mat, par, 100, init)
		
		df0 = summarize(sim)
		
		plot!(df0.t, df0.I, label = lab)
	end
	
	plt
end

# ╔═╡ bea21e32-7b13-4772-9e34-9b4b1f3333fb
_graph = CompleteGraph(N)

# ╔═╡ Cell order:
# ╠═31bbc540-68cd-4d4a-b87a-d648e003524c
# ╠═2b55141f-1cba-4a84-8811-98697d408d65
# ╠═b8d874b6-648d-11eb-251c-636c5ebc1f42
# ╠═f48fa122-649a-11eb-2041-bbf0d0c4670c
# ╟─10dd6814-f796-42ea-8d40-287ed7c9d239
# ╠═5d11a2df-3187-4509-ba7b-8388564573a6
# ╠═f4c62f95-876d-4915-8372-258dfde835f7
# ╠═61a36e78-57f8-4ef0-83b4-90e5952c116f
# ╠═d3bfc9aa-649e-11eb-2c36-b1fba4507f07
# ╠═8ddb6f1e-649e-11eb-3982-83d2d319b31f
# ╠═ffe07e00-0408-4986-9205-0fbb025a698c
# ╟─07f4816c-b893-4771-be3f-cc10695720cf
# ╠═fecf62c5-2c1d-4709-8c17-d4b6e0565617
# ╠═208445c4-5359-4442-9b9b-bde5e55a8c23
# ╠═e7c5f754-649b-11eb-1f34-0392ece0b1f6
# ╠═a89c6f63-35e4-44d8-bfd1-20ed73549fea
# ╠═b0d34450-6497-11eb-01e3-27582a9f1dcc
# ╠═63b2882e-649b-11eb-28de-bd418b43a35f
# ╠═53e344e6-6497-11eb-08ab-7f0468fb47b0
# ╠═37972f08-db05-4e84-9528-fe16cd86efbf
# ╠═2f00e2c6-649e-11eb-156f-a53dfb6d9f3f
# ╠═2d3466df-48b3-432f-843d-8f83d7fb575e
# ╠═0b35f73f-6976-4d85-b61f-b4188440043e
# ╠═eada7ed0-649b-11eb-3257-a715ea450554
# ╠═11ea4b84-649c-11eb-00a4-d93af0bd31c8
# ╠═994a7574-649d-11eb-3011-dbb82db18b5e
# ╠═bf18bef2-649d-11eb-3e3c-45b41a3fa6e5
# ╠═2ed340be-649e-11eb-31a7-a369a8215914
# ╠═1523ee2e-6490-11eb-2216-a1806099830b
# ╠═465f0169-2bd2-4935-aa3f-951cd08ba3c1
# ╠═512593af-f72c-4e67-88a3-896876efc52b
# ╠═213510df-9772-4be9-b58d-db173c21519a
# ╟─4dee5da9-aa4b-4551-974a-f7268d016617
# ╟─78e729f8-ac7d-43c5-ad93-c07d9ac7f30e
# ╠═7b43d3d6-03a0-4e0b-96e2-9de420d3187f
# ╠═c5f48079-f52e-4134-8e6e-6cd4c9ee915d
# ╟─b44bf44f-7041-409a-aea2-7652f18853b0
# ╠═ee230ae8-8885-4b40-9ad1-87ae295f11c1
# ╠═2ef8ab6b-3862-474f-ae9f-38d45246ef99
# ╠═c99f637f-cca9-4b77-b2db-2f5a251b23de
# ╠═14791f01-7625-457e-941e-cd180460fbc5
# ╠═f8ee8f92-acea-4def-b8d5-eaa452a66349
# ╠═674f577e-29c4-499e-836b-6642cb2e7e03
# ╠═04227a80-5d28-43db-929e-1cdc5b31796d
# ╟─e82d5b7f-5f37-4696-9917-58b117b9c1d6
# ╠═95b67e4d-5d41-4b86-bb9e-5de97f5d8957
# ╠═c1971734-2299-4038-8bb6-f62d020f92cb
# ╠═bea21e32-7b13-4772-9e34-9b4b1f3333fb
