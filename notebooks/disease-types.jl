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

# ╔═╡ 3b444a90-64b3-11eb-0b8f-1facc32a4088
begin
	_a_ = 1 # make sure this cell is run before other Pkg cell
	
	import Pkg
	Pkg.activate(temp = true)
	
	Pkg.add(["WGLMakie", "JSServe"])
	Pkg.add("NetworkLayout")
	using WGLMakie, JSServe
	using NetworkLayout: NetworkLayout
	
	Page(exportable = true)
end

# ╔═╡ 2b55141f-1cba-4a84-8811-98697d408d65
begin
	Pkg.add(Pkg.PackageSpec(name="DataAPI", version="1.4"))
	Pkg.add(["LightGraphs",
			 "GeometryBasics", "PlutoUI", "FreqTables", "PooledArrays", "NearestNeighbors", "CategoricalArrays", "Distributions", "DataFrames", "Plots"
			])

	using GeometryBasics, NearestNeighbors, Distributions
	using LightGraphs
	using PlutoUI
	using PooledArrays
	using DataFrames
	using Plots
	using CategoricalArrays: CategoricalArrays, categorical
	
	_a_
end

# ╔═╡ 0e30624c-65fc-11eb-185d-1d018f68f82c
md"""
`disease.jl` | **Version 0.1** | *last updated: Feb 3*
"""

# ╔═╡ 7666d01c-6575-11eb-0197-8d34dd66d720
md"""
**NOTE!** This notebook does not run in Safari!
"""

# ╔═╡ f4266196-64aa-11eb-3fc1-2bf0e099d19c
md"""
# Diffusion on Networks: Modeling Transmission of Disease

This notebook will be the basis for part of **Lecture 3** *and* **Assignment 2**. Here is what we will cover.

1. We will model the diffusion of disease on a network. We will analyze how the parameters of the model change the outcomes.
"""

# ╔═╡ b36832aa-64ab-11eb-308a-8f031686c8d6
md"""
2. We will show how various policies mitigate the spread of the disease. We will see how we can map *social distancing*, *travel restrictions* and *vaccination programs* into the model. 

   The plot below shows how the number of infected people decreases when we randomly pick 10% of the population. *(Can we improve the efficacy of the vaccination program by targeting specific people?)*
"""

# ╔═╡ c8f92204-64ac-11eb-0734-2df58e3373e8
md"""
3. In your assignment you will make to model a little richer by ``(i)`` separating the `R` state into *dead* and *immune* (which includes recovered and vaccinated) and ``(ii)`` taking into account age-specific death (case-fatality) rates.

   *(Can we now improve the efficacy of the vaccination program even more?)*
"""

# ╔═╡ 2f9f008a-64aa-11eb-0d9a-0fdfc41d4657
md"""
# The SIR Model

In the simplest case, there are three states.

1. `S`usceptible
2. `I`nfected
3. `R`emoved (recovered or dead)

(For your assignment you will split up the `R` state into immune and dead.)
"""

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
## Define the transitions
"

# ╔═╡ 8ddb6f1e-649e-11eb-3982-83d2d319b31f
function transition(::I, par, args...; kwargs...)
	x = rand()
	if x < par.ρ + par.δ # recover or die
		R()
	else
		I()
	end
end

# ╔═╡ 61a36e78-57f8-4ef0-83b4-90e5952c116f
transition(::R, args...; kwargs...) = R()

# ╔═╡ d3bfc9aa-649e-11eb-2c36-b1fba4507f07
# transition(::D,      args...; kwargs...) = ...

# ╔═╡ ffe07e00-0408-4986-9205-0fbb025a698c
function transition(::S, par, node, adjacency_matrix, is_infected)
	inv_prob_transmission = 1.0
	
	for i in is_infected
		inv_prob_transmission *= 1 - par.p * adjacency_matrix[i, node]
	end
	
	π =	1.0 - inv_prob_transmission
	
	rand() < π ? I() : S()
end

# ╔═╡ f4c62f95-876d-4915-8372-258dfde835f7
function iterate!(states_new, states, adjacency_matrix, par)

	is_infected = findall(isa.(states, I))
	
	for i in 1:size(adjacency_matrix, 1)
		states_new[i] = transition(states[i], par, i, adjacency_matrix, is_infected)
	end
	
	states_new
end

# ╔═╡ 50d9fb56-64af-11eb-06b8-eb56903084e2
md"""
## Simulate on a Simple Network

* ``\rho_s``: $(@bind ρ_simple PlutoUI.Slider(0.0:0.25:1.0, default = 0.0, show_value =true)) (recovery probability)
* ``\delta_s``: $(@bind δ_simple PlutoUI.Slider(0.0:0.25:1.0, default = 0.0, show_value =true)) (death rate)
* ``p_s``: $(@bind p_simple PlutoUI.Slider(0.0:0.25:1.0, default = 0.5, show_value =true)) (infection probability)
"""

# ╔═╡ 8d4cb5dc-6573-11eb-29c8-81baa6e3fffc
simple_graph = CycleGraph(10)

# ╔═╡ ce75fe16-6570-11eb-3f3a-577eac7f9ee8
md"""
## Simulate on a Big Network
"""

# ╔═╡ 37972f08-db05-4e84-9528-fe16cd86efbf
md"""
* ``\rho``: $(@bind ρ0 PlutoUI.Slider(0.1:0.1:0.9, default = 0.1, show_value =true)) (recovery probability)
* ``\delta``: $(@bind δ0 PlutoUI.Slider(0.0:0.02:0.2, default = 0.04, show_value =true)) (death rate)
* ``p``: $(@bind p0 PlutoUI.Slider(0.1:0.1:0.9, default = 0.3, show_value =true)) (infection probability)
"""

# ╔═╡ 4dee5da9-aa4b-4551-974a-f7268d016617
md"""
# A First Look at Policies
"""

# ╔═╡ 78e729f8-ac7d-43c5-ad93-c07d9ac7f30e
md"""
## Social Distancing
"""

# ╔═╡ 7b43d3d6-03a0-4e0b-96e2-9de420d3187f
p_range = 0.1:0.1:0.9

# ╔═╡ 2c4dda14-6577-11eb-2ef7-997664b20722


# ╔═╡ 1978febe-657c-11eb-04ac-e19b2d0e5a85
md"""
Can we do better?
"""

# ╔═╡ 04227a80-5d28-43db-929e-1cdc5b31796d
md"""
## Travel ban

remove links
"""

# ╔═╡ 3d4eccc4-6577-11eb-11d0-09073ea3a50e
N = 1000

# ╔═╡ 5d11a2df-3187-4509-ba7b-8388564573a6
function iterate(states, adjacency_matrix, par)
	states_new = Vector{States}(undef, N)
	iterate!(states_new, states, adjacency_matrix, par)
	
	states_new
end

# ╔═╡ b44bf44f-7041-409a-aea2-7652f18853b0
md"""
## Vaccination

There are $N people and you can distribute $(N ÷ 10) doses of the vaccine. Whom would you vaccinate?
"""

# ╔═╡ fb4ff86c-64ad-11eb-2962-3372a2f2d9a5
md"""
# Assignment 2: Whom to Vaccinate When Death Rates are Age-Specfic
"""

# ╔═╡ 1b8c26b6-64aa-11eb-2d9a-47db5469a654
md"""
# Appendix
"""

# ╔═╡ 07a66c72-6576-11eb-26f3-810607ca7e51
md"""
## Functions for the simulation
"""

# ╔═╡ ca77fa78-657a-11eb-0faf-15ffd3fdc540
function initial_state(N, infected_nodes, recovered_nodes)
	# fill with "Susceptible"
	init = States[S() for i in 1:N]
	
	init[infected_nodes] .= Ref(I())
	init[recovered_nodes] .= Ref(R())
	
	init
end

# ╔═╡ fecf62c5-2c1d-4709-8c17-d4b6e0565617
function initial_state(N, n_infected)
	
	# spread out the desired number of infected people
	infected_nodes = 1:(N÷n_infected):N
	
	initial_state(N, infected_nodes, [])
end

# ╔═╡ 208445c4-5359-4442-9b9b-bde5e55a8c23
function simulate(graph, par, T, init = initial_state(nv(graph), max(nv(graph) ÷ 100, 1)))
	mat = adjacency_matrix(graph)
	N = nv(graph)
	
	sim = Matrix{States}(undef, N, T)
	sim[:,1] .= init
	
	for t = 2:T
		iterate!(view(sim, :, t), view(sim, :, t-1), mat, par)
	end
	sim
end

# ╔═╡ e4d016cc-64ae-11eb-1ca2-259e5a262f33
md"""
## Processing the Simulated Data
"""

# ╔═╡ b0d34450-6497-11eb-01e3-27582a9f1dcc
label(x::DataType) = string(Base.typename(x).name)

# ╔═╡ 63b2882e-649b-11eb-28de-bd418b43a35f
label(x) = label(typeof(x))

# ╔═╡ 11ea4b84-649c-11eb-00a4-d93af0bd31c8
function tidy_simulation_output(sim)
	# go from type to symbol (S() => "S")
	sim1 = label.(sim)
	
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

# ╔═╡ bf18bef2-649d-11eb-3e3c-45b41a3fa6e5
function fractions_over_time(sim)
	tidy_sim = tidy_simulation_output(sim)
	N, T = size(sim)
	
	
	combine(groupby(tidy_sim, [:t, :state]), :node_id => (x -> length(x)/N) => :fraction)
end

# ╔═╡ 47ac6d3c-6556-11eb-209d-f7a8219512ee
md"""
## Constructing the Figures
"""

# ╔═╡ f6f71c0e-6553-11eb-1a6a-c96f38c7f17b
function plot_fractions!(figpos, t, df, color_dict, legpos = nothing)	
	ax = Axis(figpos)
	
	for (i, gdf) in enumerate(groupby(df, :state))
		s = only(unique(gdf.state)) |> string
		
		AbstractPlotting.lines!(ax, gdf.t, gdf.fraction, label = s, color = color_dict[s])
	end
	
	vlines!(ax, @lift([$t]), color = :gray50, linestyle=(:dash, :loose))
	
	AbstractPlotting.ylims!(ax, -0.05, 1.05)
	
	if !isnothing(legpos)
		leg = Legend(legpos, ax)
		leg.tellwidth[] = false
		leg.tellheight[] = true
		leg.orientation[] = :horizontal
	else
		leg = nothing
	end
	
	(; ax, leg)
end

# ╔═╡ 4a9b5d8a-64b3-11eb-0028-898635af227c
function plot_diffusion!(figpos, edges_as_pts, node_positions, sim, t, color_dict)
	sim_colors = [color_dict[label(s)] for s in sim]
	state_as_color_t = @lift(sim_colors[:,$t])
	
    ax = Axis(figpos)

	hidedecorations!(ax)
    #hidespines!(ax)

	N, T = size(sim)
	msize = N < 20 ? 10 : N < 100 ? 5 : 3
	
	
	AbstractPlotting.lines!(ax, edges_as_pts, linewidth = 0.1, color = (:black, 0.1))
    AbstractPlotting.scatter!(ax, node_positions, markersize=msize, color = state_as_color_t);
	
	ax
end

# ╔═╡ 51a16fcc-6556-11eb-16cc-71a978e02ef0
function sir_plot!(figpos, legpos, sim, edges_as_pts, node_positions, t)
	
	
	df = fractions_over_time(sim)
			
	states = label.(subtypes(State))
	colors = cgrad(:viridis, length(states), categorical=true)
	color_dict = Dict(s => colors[i] for (i,s) in enumerate(states))
	
	ax_f, leg = plot_fractions!(figpos[1,2], t, df, color_dict, legpos)
	ax_d = plot_diffusion!(figpos[1,1], edges_as_pts, node_positions, sim, t, color_dict)

	(; ax_f, ax_d, leg)

end 

# ╔═╡ e82d5b7f-5f37-4696-9917-58b117b9c1d6
md"
## Spatial graph
"

# ╔═╡ 95b67e4d-5d41-4b86-bb9e-5de97f5d8957
# adapted from David Gleich, Purdue University
# https://www.cs.purdue.edu/homes/dgleich/cs515-2020/julia/viral-spreading.html
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
function spatial_graph(N::Int)
	id = 1:N
	x = rand(N)
	y = rand(N)
	node_positions = Point2f0.(x, y)
	
	spatial_graph(node_positions), node_positions
end

# ╔═╡ 49b21e4e-6577-11eb-38b2-45d30b0f9c80
graph, node_positions = spatial_graph(1000)

# ╔═╡ c5f48079-f52e-4134-8e6e-6cd4c9ee915d
let
	plt = Plots.plot(title = "#infected when varying the infection probability")
	for p in p_range
		par = (p = p, ρ = ρ0, δ = δ0)
		
		sim = simulate(graph, par, 100)
		
		df0 = fractions_over_time(sim)
		
		filter!(:state => ==("I"), df0)
		
		Plots.plot!(df0.t, df0.fraction, label = "p = $p", color = :blue, alpha = (1 - p))
	end
	
	plt
end

# ╔═╡ ee230ae8-8885-4b40-9ad1-87ae295f11c1
n_contacts = degree(graph)

# ╔═╡ 2ef8ab6b-3862-474f-ae9f-38d45246ef99
begin
	degree_df = DataFrame(i = 1:N, n_contacts = n_contacts)
	sort!(degree_df, :n_contacts)
end

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
	plt = Plots.plot(title = "#infected when vaccinating different groups")
	for (lab, init) in ["top" => init_vaccine(:top), "bottom" => init_vaccine(:bottom), "none" => init_vaccine(:none)]
		par = (p = p0, ρ = ρ0, δ = δ0)
		
		sim = simulate(graph, par, 100, init)
		
		df0 = fractions_over_time(sim)
		
		filter!(:state => ==("I"), df0)
		
		Plots.plot!(df0.t, df0.fraction, label = lab)
	end
	
	plt
end

# ╔═╡ c99f637f-cca9-4b77-b2db-2f5a251b23de
top_100_nodes = degree_df.i[901:1000]

# ╔═╡ 14791f01-7625-457e-941e-cd180460fbc5
bottom_100_nodes = degree_df.i[1:100]

# ╔═╡ 5fe4d47c-64b4-11eb-2a44-473ef5b19c6d
md"""
## Utils
"""

# ╔═╡ 66d78eb4-64b4-11eb-2d30-b9cee7370d2a
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

# ╔═╡ c511f396-6579-11eb-18b1-df745093a116
function compare_sir(sim1, sim2, graph, node_positions = NetworkLayout.Spring.layout(adjacency_matrix(graph), Point2f0))
	t = Node(1)
	
	edges_as_pts = edges_as_points(graph, node_positions)
	
	fig = Figure(padding = (0,0,0,0))
	legpos = fig[1:2,2]
	panel1 = fig[1,1]
	panel2 = fig[2,1]
	
	axs1 = sir_plot!(panel1, legpos,  sim1, edges_as_pts, node_positions, t)
	axs2 = sir_plot!(panel2, nothing, sim2, edges_as_pts, node_positions, t)
	
	hidedecorations!(axs1.ax_f)
	hidedecorations!(axs2.ax_f)
	
	axs1.leg.orientation[] = :vertical
	axs1.leg.tellwidth[]   = true
	axs1.leg.tellheight[]  = false
	
	
	@assert axes(sim1, 2) == axes(sim2, 2)
	
	(; fig, t, T_range = axes(sim1, 2))
end

# ╔═╡ 76b738fe-657a-11eb-31d3-413a08ee6e69
out_vacc = let
	N = 1000
	graph, node_positions = spatial_graph(N)
	
	par = (p = 0.1, ρ = ρ0, δ = δ0)
	
	infected_nodes = rand(1:N, 100)
	vaccinated_nodes = rand(1:N, 100)
	
	init0 = initial_state(N, infected_nodes, [])
	initv = initial_state(N, infected_nodes, vaccinated_nodes)
	
	sim0 = simulate(graph, par, 100, init0)
	simv = simulate(graph, par, 100, initv)
	
	compare_sir(sim0, simv, graph, node_positions)
end;

# ╔═╡ 83b817d2-657d-11eb-3cd2-332a348142ea
out_vacc.fig

# ╔═╡ 67e74a32-6578-11eb-245c-07894c89cc7c
function sir_plot(sim, graph, node_positions = NetworkLayout.Spring.layout(adjacency_matrix(graph), Point2f0))
	t = Node(1)
	
	edges_as_pts = edges_as_points(graph, node_positions)

	fig = Figure()
	main_fig = fig[2,1]
	leg_pos = fig[1,1]

	sir_plot!(main_fig, leg_pos, sim, edges_as_pts, node_positions, t)
	
	(; fig, t, T_range = axes(sim, 2))
	
end

# ╔═╡ d6694c32-656c-11eb-0796-5f485cccccf0
out_simple = let
	T = 10
	
	par = (ρ = ρ_simple, δ = δ_simple, p = p_simple)
	
	sim = simulate(simple_graph, par, T)
	
	sir_plot(sim, simple_graph)
	
end;	

# ╔═╡ 9302b00c-656f-11eb-25b3-495ae1c843cc
md"""
``t``: $(@bind t0_simple NumberField(out_simple.T_range, default=1))
"""

# ╔═╡ 657c3a98-6573-11eb-1ccb-b1d974414647
out_simple.fig

# ╔═╡ d2813d40-656d-11eb-2cfc-e389ed2a0d84
out_simple.t[] = t0_simple

# ╔═╡ 0b35f73f-6976-4d85-b61f-b4188440043e
out_big = let
	T = 100
	
	par = (ρ = ρ0, δ = δ0, p = p0)
	
	graph, node_positions = spatial_graph(1000)
	sim = simulate(graph, par, T)	
	
	out_big = sir_plot(sim, graph, node_positions)
end;

# ╔═╡ 43a25dc8-6574-11eb-3607-311aa8d5451e
md"""
``t``: $(@bind t0_intro PlutoUI.Slider(out_big.T_range, show_value = true, default = 20))
"""

# ╔═╡ 3e9af1f4-6575-11eb-21b2-453dc18d1b7b
out_big.fig

# ╔═╡ 1bd2c660-6572-11eb-268c-732fd2210a58
out_big.fig

# ╔═╡ f4cd5fb2-6574-11eb-37c4-73d4b21c1883
md"""
Check to activate slider: $(@bind past_intro CheckBox(default = false))

``t``: $(@bind t0_big PlutoUI.Slider(out_big.T_range, show_value = true, default = 1))
"""

# ╔═╡ 373cb47e-655e-11eb-2751-0150985d98c1
out_big.t[] = past_intro ? t0_big : t0_intro

# ╔═╡ 34b1a3ba-657d-11eb-17fc-5bf325945dce
md"""
``t``: $(@bind t0_vacc PlutoUI.Slider(out_big.T_range, show_value = true, default = 1))
"""

# ╔═╡ 99a1f078-657a-11eb-2183-1b6a0598ffcd
out_vacc.t[] = t0_vacc

# ╔═╡ a81f5244-64aa-11eb-1854-6dbb64c8eb6a
md"""
## Package Environment
"""

# ╔═╡ bed07322-64b1-11eb-3324-7b7ac5e8fba2
md"""
## Other Stuff
"""

# ╔═╡ df9b4eb2-64aa-11eb-050c-adf04609ef21
Base.show(io::IO, ::MIME"text/html", x::CategoricalArrays.CategoricalValue) = print(io, get(x))

# ╔═╡ 31bbc540-68cd-4d4a-b87a-d648e003524c
TableOfContents()

# ╔═╡ Cell order:
# ╟─0e30624c-65fc-11eb-185d-1d018f68f82c
# ╟─7666d01c-6575-11eb-0197-8d34dd66d720
# ╟─f4266196-64aa-11eb-3fc1-2bf0e099d19c
# ╟─43a25dc8-6574-11eb-3607-311aa8d5451e
# ╟─3e9af1f4-6575-11eb-21b2-453dc18d1b7b
# ╟─b36832aa-64ab-11eb-308a-8f031686c8d6
# ╟─c8f92204-64ac-11eb-0734-2df58e3373e8
# ╟─2f9f008a-64aa-11eb-0d9a-0fdfc41d4657
# ╠═b8d874b6-648d-11eb-251c-636c5ebc1f42
# ╠═f48fa122-649a-11eb-2041-bbf0d0c4670c
# ╟─10dd6814-f796-42ea-8d40-287ed7c9d239
# ╠═8ddb6f1e-649e-11eb-3982-83d2d319b31f
# ╠═61a36e78-57f8-4ef0-83b4-90e5952c116f
# ╠═d3bfc9aa-649e-11eb-2c36-b1fba4507f07
# ╠═ffe07e00-0408-4986-9205-0fbb025a698c
# ╠═5d11a2df-3187-4509-ba7b-8388564573a6
# ╠═f4c62f95-876d-4915-8372-258dfde835f7
# ╟─50d9fb56-64af-11eb-06b8-eb56903084e2
# ╟─9302b00c-656f-11eb-25b3-495ae1c843cc
# ╟─657c3a98-6573-11eb-1ccb-b1d974414647
# ╠═8d4cb5dc-6573-11eb-29c8-81baa6e3fffc
# ╠═d6694c32-656c-11eb-0796-5f485cccccf0
# ╠═d2813d40-656d-11eb-2cfc-e389ed2a0d84
# ╟─ce75fe16-6570-11eb-3f3a-577eac7f9ee8
# ╟─37972f08-db05-4e84-9528-fe16cd86efbf
# ╟─1bd2c660-6572-11eb-268c-732fd2210a58
# ╟─f4cd5fb2-6574-11eb-37c4-73d4b21c1883
# ╠═0b35f73f-6976-4d85-b61f-b4188440043e
# ╟─373cb47e-655e-11eb-2751-0150985d98c1
# ╟─4dee5da9-aa4b-4551-974a-f7268d016617
# ╠═49b21e4e-6577-11eb-38b2-45d30b0f9c80
# ╟─78e729f8-ac7d-43c5-ad93-c07d9ac7f30e
# ╠═7b43d3d6-03a0-4e0b-96e2-9de420d3187f
# ╠═c5f48079-f52e-4134-8e6e-6cd4c9ee915d
# ╠═2c4dda14-6577-11eb-2ef7-997664b20722
# ╟─b44bf44f-7041-409a-aea2-7652f18853b0
# ╠═99a1f078-657a-11eb-2183-1b6a0598ffcd
# ╟─34b1a3ba-657d-11eb-17fc-5bf325945dce
# ╠═83b817d2-657d-11eb-3cd2-332a348142ea
# ╠═76b738fe-657a-11eb-31d3-413a08ee6e69
# ╟─1978febe-657c-11eb-04ac-e19b2d0e5a85
# ╟─2ef8ab6b-3862-474f-ae9f-38d45246ef99
# ╠═f8ee8f92-acea-4def-b8d5-eaa452a66349
# ╠═674f577e-29c4-499e-836b-6642cb2e7e03
# ╠═c99f637f-cca9-4b77-b2db-2f5a251b23de
# ╠═14791f01-7625-457e-941e-cd180460fbc5
# ╠═ee230ae8-8885-4b40-9ad1-87ae295f11c1
# ╟─04227a80-5d28-43db-929e-1cdc5b31796d
# ╠═3d4eccc4-6577-11eb-11d0-09073ea3a50e
# ╟─fb4ff86c-64ad-11eb-2962-3372a2f2d9a5
# ╟─1b8c26b6-64aa-11eb-2d9a-47db5469a654
# ╟─07a66c72-6576-11eb-26f3-810607ca7e51
# ╠═ca77fa78-657a-11eb-0faf-15ffd3fdc540
# ╠═fecf62c5-2c1d-4709-8c17-d4b6e0565617
# ╠═208445c4-5359-4442-9b9b-bde5e55a8c23
# ╟─e4d016cc-64ae-11eb-1ca2-259e5a262f33
# ╠═bf18bef2-649d-11eb-3e3c-45b41a3fa6e5
# ╠═11ea4b84-649c-11eb-00a4-d93af0bd31c8
# ╠═b0d34450-6497-11eb-01e3-27582a9f1dcc
# ╠═63b2882e-649b-11eb-28de-bd418b43a35f
# ╟─47ac6d3c-6556-11eb-209d-f7a8219512ee
# ╠═c511f396-6579-11eb-18b1-df745093a116
# ╠═67e74a32-6578-11eb-245c-07894c89cc7c
# ╠═51a16fcc-6556-11eb-16cc-71a978e02ef0
# ╠═f6f71c0e-6553-11eb-1a6a-c96f38c7f17b
# ╠═4a9b5d8a-64b3-11eb-0028-898635af227c
# ╟─e82d5b7f-5f37-4696-9917-58b117b9c1d6
# ╠═95b67e4d-5d41-4b86-bb9e-5de97f5d8957
# ╠═c1971734-2299-4038-8bb6-f62d020f92cb
# ╟─5fe4d47c-64b4-11eb-2a44-473ef5b19c6d
# ╠═66d78eb4-64b4-11eb-2d30-b9cee7370d2a
# ╟─a81f5244-64aa-11eb-1854-6dbb64c8eb6a
# ╠═3b444a90-64b3-11eb-0b8f-1facc32a4088
# ╠═2b55141f-1cba-4a84-8811-98697d408d65
# ╟─bed07322-64b1-11eb-3324-7b7ac5e8fba2
# ╠═df9b4eb2-64aa-11eb-050c-adf04609ef21
# ╠═31bbc540-68cd-4d4a-b87a-d648e003524c
