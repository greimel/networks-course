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

# ╔═╡ fdf43912-6623-11eb-2e6a-137c10342f32
begin
	_a_ = 1 # make sure this cell is run before other Pkg cell
	
	import Pkg
	Pkg.activate(temp = true)
	
	Pkg.add("PlutoUI")
	using PlutoUI: Slider, TableOfContents, CheckBox, NumberField
end

# ╔═╡ 0e30624c-65fc-11eb-185d-1d018f68f82c
md"""
`disease.jl` | **Version 0.3** | *last updated: Feb 8*
"""

# ╔═╡ d0ee632c-6621-11eb-39ac-cb766429529f
md"""
!!! danger "Preliminary version"
    Nice that you've found this notebook on github. We appreciate your engagement. Feel free to have a look. Please note that the assignment notebook is subject to change until a link is is uploaded to *Canvas*.
"""

# ╔═╡ 21be9262-6614-11eb-3ae6-79fdc6c56c3e
_b_ = _a_ + 1; md"""
Fancy version $(@bind fancy CheckBox()) (might not work on Safari)
"""

# ╔═╡ 3b444a90-64b3-11eb-0b8f-1facc32a4088
begin
	_c_ = _b_ + 1 # make sure this cell is run before other Pkg cell
	
	Pkg.add("AbstractPlotting")
	
	if fancy
		Pkg.add([
			Pkg.PackageSpec(name="JSServe"),
			Pkg.PackageSpec(name="WGLMakie"),
			])
		import WGLMakie, JSServe
		Page(exportable = true)
	else
		Pkg.add("CairoMakie")
		import CairoMakie
		CairoMakie.activate!(type = "png")
	end

	using AbstractPlotting: 
		Figure, Axis, Legend,
		lines!, scatter!, scatterlines, scatterlines!, vlines!, 
		hidedecorations!, ylims!, cgrad,
		@lift, Node
	
	Pkg.add("NetworkLayout")
	using NetworkLayout: NetworkLayout
end

# ╔═╡ 2b55141f-1cba-4a84-8811-98697d408d65
begin
	Pkg.add([
			Pkg.PackageSpec(name="DataAPI", version="1.4"),
			Pkg.PackageSpec(name="CSV", version="0.8"),
			Pkg.PackageSpec(name="CategoricalArrays", version="0.9"),
			Pkg.PackageSpec(name="Chain", version="0.4"),
			Pkg.PackageSpec(name="DataFrames", version="0.22"),
			Pkg.PackageSpec(name="Distributions", version="0.24"),
			Pkg.PackageSpec(name="FreqTables", version="0.4"),
			Pkg.PackageSpec(name="GeometryBasics", version="0.3.9"),
			Pkg.PackageSpec(name="LightGraphs", version="1.3"),
			Pkg.PackageSpec(name="NearestNeighbors", version="0.4.8"),
			Pkg.PackageSpec(name="Plots", version="1"),
			Pkg.PackageSpec(name="UnPack", version="1")
			])

	using Distributions: Distributions, LogNormal
	using Chain: @chain
	import CSV
	using GeometryBasics: Point2f0
	using NearestNeighbors: BallTree, knn
	using LightGraphs: SimpleGraph, add_edge!, StarGraph, CycleGraph, WheelGraph, betweenness_centrality, eigenvector_centrality, edges, adjacency_matrix, nv, ne
	using DataFrames: transform!, transform, DataFrame, ByRow, groupby, combine, rename!, Not, stack, unstack, leftjoin
	using CategoricalArrays: CategoricalArrays, categorical, cut
	using UnPack: @unpack
	using Statistics: mean
	
	_c_
end

# ╔═╡ c2940f90-661a-11eb-3d77-0fc1189e0960
begin
	elegant = !fancy
	(; elegant, fancy)
end

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
	#struct D <: State end # (Assignment)
end

# ╔═╡ f48fa122-649a-11eb-2041-bbf0d0c4670c
const States = Union{subtypes(State)...}

# ╔═╡ 10dd6814-f796-42ea-8d40-287ed7c9d239
md"
## Define the transitions
"

# ╔═╡ 8ddb6f1e-649e-11eb-3982-83d2d319b31f
function transition(::I, par, node, args...; kwargs...)
	## The following lines will be helpful for the assignment (task 2)
	#if length(par.δ) == 1
	 	δ = only(par.δ)
	#else
	# 	δ = par.δ[node]
	#end
	x = rand()
	if x < par.ρ + δ # recover or die
		R()
	#elseif x < ...
	#	...
	else
		I()
	end
end

# ╔═╡ 61a36e78-57f8-4ef0-83b4-90e5952c116f
transition(::R, args...; kwargs...) = R()

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

# ╔═╡ 5d11a2df-3187-4509-ba7b-8388564573a6
function iterate(states, adjacency_matrix, par)
	states_new = Vector{States}(undef, N)
	iterate!(states_new, states, adjacency_matrix, par)
	
	states_new
end

# ╔═╡ 50d9fb56-64af-11eb-06b8-eb56903084e2
md"""
## Simulate on a Simple Network

* ``\rho_s``: $(@bind ρ_simple Slider(0.0:0.25:1.0, default = 0.0, show_value =true)) (recovery probability)
* ``\delta_s``: $(@bind δ_simple Slider(0.0:0.25:1.0, default = 0.0, show_value =true)) (death rate)
* ``p_s``: $(@bind p_simple Slider(0.0:0.25:1.0, default = 0.5, show_value =true)) (infection probability)
"""

# ╔═╡ 8d4cb5dc-6573-11eb-29c8-81baa6e3fffc
simple_graph = CycleGraph(10)

# ╔═╡ ce75fe16-6570-11eb-3f3a-577eac7f9ee8
md"""
## Simulate on a Big Network
"""

# ╔═╡ 37972f08-db05-4e84-9528-fe16cd86efbf
md"""
* ``\rho``: $(@bind ρ0 Slider(0.1:0.1:0.9, default = 0.1, show_value =true)) (recovery probability)
* ``\delta``: $(@bind δ0 Slider(0.0:0.02:0.2, default = 0.04, show_value =true)) (death rate)
* ``p``: $(@bind p0 Slider(0.1:0.1:0.9, default = 0.3, show_value =true)) (infection probability)
"""

# ╔═╡ 4dee5da9-aa4b-4551-974a-f7268d016617
md"""
# A First Look at Policies

We understand now how to model the spread of a disease using the SIR model.

#### Live Exercise 1: Corona policies

I will randomly assign you to break-out rooms.

👉 Think about one or two Corona policies. How would you evaluate them with our model?

👉 *(We'll talk later about social distancing and vaccinations. Probably you can come up with at least one other policy.)*
"""

# ╔═╡ 04227a80-5d28-43db-929e-1cdc5b31796d
md"""
#### Place to collect your ideas

*
*
*
"""

# ╔═╡ 78e729f8-ac7d-43c5-ad93-c07d9ac7f30e
md"""
## Social Distancing
"""

# ╔═╡ 7b43d3d6-03a0-4e0b-96e2-9de420d3187f
p_range = 0.1:0.1:0.9

# ╔═╡ e8b7861e-661c-11eb-1c06-bfedd6ab563f
md"""
It's really hard to see the difference, so let's use an alternative visualization.
"""

# ╔═╡ 1978febe-657c-11eb-04ac-e19b2d0e5a85
md"""
#### Live Exercise 2: Can we do better?

Can you think of a way to improve the effectiveness of the vaccination program? If you have 100 doses at your disposal, whom would you vaccinate?
"""

# ╔═╡ 12d7647e-6a13-11eb-2b1e-9f77bdb3a87a
md"""
## (End of Lecture)
"""

# ╔═╡ b402b1e2-6a12-11eb-16ac-7b19064562b8
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ e7d47230-6a12-11eb-0392-4360f36222b8
group_number = 99

# ╔═╡ eea88902-6a12-11eb-3a63-df8979fbdd55
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the randomly generated names above by the names of your group and put the right group number in the top cell.
	"""
end

# ╔═╡ 98d449ac-695f-11eb-3daf-dffb377aa5e2
md"""
#### Task 1: Distinguish between `R`ecovered and `D`ead

👉 Add a new state `D`ead.
"""

# ╔═╡ 8a2c223e-6960-11eb-3d8a-516474e6653c
md"""
👉 Add a transition rule for `D`.
"""

# ╔═╡ 809375ba-6960-11eb-29d7-f9ab3ee61367
# transition(::D, args...; kwargs...) = #= your code here =#

# ╔═╡ 945d67f6-6961-11eb-33cf-57ffe340b35f
md"""
👉 Go to section **Define the transtions** and adjust the transition rules for the other states if necessary.
"""

# ╔═╡ 48818cf0-6962-11eb-2024-8fca0690dd78
md"""
Great! You can now have a look how the simulations from the lecture have automatically updated.
"""

# ╔═╡ fac414f6-6961-11eb-03bb-4f58826b0e61
md"""
#### Task 2: Introduce age-specific death rates

The death probabilities are highly heterogeneous across age groups. See for example [this article in Nature.](https://www.nature.com/articles/s41586-020-2918-0)

>  We find that age-specific IFRs estimated by the ensemble model range from 0.001% (95% credible interval, 0–0.001) in those aged 5–9 years old (range, 0–0.002% across individual national-level seroprevalence surveys) to 8.29% (95% credible intervals, 7.11–9.59%) in those aged 80+ (range, 2.49–15.55% across individual national-level seroprevalence surveys).

Below find the data from supplementary table S3 from this article.
"""

# ╔═╡ 75b4c0c2-69f3-11eb-1ebc-75efd2d0bf1f
md"""
Let us assume there are the following age groups with age specific $\delta$. *(Feel free to experiment a bit and change how these are computed.)*

"""

# ╔═╡ 33c4ea42-6a10-11eb-094c-75343532f835
md"""
We want to adjust the code so that it can handle node-specific $\delta$. The way we are going to do it is to pass a vector $\vec \delta = (\delta_1, \ldots, \delta_N)$ that holds the death probability for each node.

👉 Go the the definition of `transition(::I, ...)`, make sure you understand the code snippet in the comment and uncomment the lines.

"""

# ╔═╡ 2e3413ae-6962-11eb-173c-6d53cfd8a968
md"""
#### Task 3: Whom to vaccinate?

In the lecture we've figured out, how we can improve on vaccinating random people. Now there is more structure in the model. Can you improve on the situation?

First, let's construct the graph and specify the death rates. *(You don't need to change this.)*
"""

# ╔═╡ 18e84a22-69ff-11eb-3909-7fd30fcf3040
function pseudo_random(N, n, offset = 1)
	step = N ÷ n
	range(offset, step = step, length = n)
end

# ╔═╡ 0d2b1bdc-6a14-11eb-340a-3535d7bfbec1
md"""

Now it's your turn.

👉 Decide which nodes you want to vaccinate and adjust the cell below. Make sure you only vaccinate `N_vacc` nodes.
"""

# ╔═╡ 297e4d74-6a12-11eb-0302-0f97bab2c906
md"""
Now write a short essay describing your choice. *(Your simulation results are subject to random noise. Make sure you run you simulations multiple times to make sure they are robust.)*

👉 Describe how you would select nodes to be vaccinated

👉 Be accurate but concise. Aim at no more than 500 words.
"""

# ╔═╡ d0f3064a-6a11-11eb-05bf-09f67a451510
answer1 = md"""
Your answer goes here ...
"""

# ╔═╡ 9c562b8c-6a12-11eb-1e07-c378e9304a1d
md"""
#### Before you submit ...

👉 Make sure you have added your names and your group number at the top.

👉 Make sure that that **all group members proofread** your submission (especially your little essay).

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. In addition, **upload the source code** of the notebook (the .jl file).
"""

# ╔═╡ 515edb16-69f3-11eb-0bc9-a3504565b80b
md"""
### Details on age-specific infection fatality rates
"""

# ╔═╡ 1abd6992-6962-11eb-3db0-f3dbe5f095eb
ifr_csv = CSV.File(IOBuffer(
		"""
from	to	IFR_pc
0	4	0.003
5	9	0.001
10	14	0.001
15	19	0.003
20	24	0.006
25	29	0.013
30	34	0.024
35	39	0.040
40	44	0.075
45	49	0.121
50	54	0.207
55	59	0.323
60	64	0.456
65	69	1.075
70	74	1.674
75	79	3.203
80	95	8.292
""" # note: the oldest age group is actually 80+
		));

# ╔═╡ 07c102c2-69ee-11eb-3b29-25e612df6911
ifr_df = @chain ifr_csv begin
	DataFrame
	transform!([:from, :to] => ByRow(mean ∘ tuple) => :age)
	transform!(:to => (x -> cut(x, [0, 40, 75, 100])) => :age_group)
end

# ╔═╡ d18f1b0c-69ee-11eb-2fc0-4f14873847fb
scatterlines(ifr_df.age, ifr_df.IFR_pc, 
			 axis = (xlabel="age group", ylabel = "infection fatality ratio (%)")
			)

# ╔═╡ 57a72310-69ef-11eb-251b-c5b8ab2c6082
ifr_df2 = @chain ifr_df begin
	groupby(:age_group)
	combine(:IFR_pc => mean, renamecols = false)
	
end

# ╔═╡ 74c35594-69f0-11eb-015e-2bf4b55e658c
md"""
### Get from infection fatality ratio to $\delta$

When the recovery rate is $\rho$, the expected time infected is $T_I = 1/\rho$. So we want the survival probability to 

$$(1-IFR) = (1 - \delta)^{T_I}.$$ 
"""

# ╔═╡ 6ffb63bc-69f0-11eb-3f84-d3fca5526a3e
get_δ_from_ifr(ifr, ρ) = 1 - (1 - ifr/100)^(ρ)

# ╔═╡ 98b2eefe-69f2-11eb-36f4-7b19a55cfe78
begin
	ρ_new = 1/7
	transform(ifr_df2, :IFR_pc => ByRow(x -> get_δ_from_ifr(x, ρ_new)) => "δ")
end

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
		
		lines!(ax, gdf.t, gdf.fraction, label = s, color = color_dict[s])
	end
	
	vlines!(ax, @lift([$t]), color = :gray50, linestyle=(:dash, :loose))
	
	ylims!(ax, -0.05, 1.05)
	
	# some attributes to make the legend nicer
	attr = (orientation = :horizontal, tellwidth = :false, tellheight = true)
	
	if !isnothing(legpos)
		leg = Legend(legpos, ax; attr...)
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

	N, T = size(sim)
	msize = N < 20 ? 10 : N < 100 ? 5 : 3
		
	lines!(ax, edges_as_pts, linewidth = 0.5, color = (:black, 0.3))
    scatter!(ax, node_positions, markersize=msize, strokewidth = 0, color = state_as_color_t);
	
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
	state = "I"
	fig = Figure()
	ax = Axis(fig[1,1], title = "#$(state) when varying the infection probability")
	for p in p_range
		par = (p = p, ρ = ρ0, δ = δ0)
		
		sim = simulate(graph, par, 100)
		
		df0 = fractions_over_time(sim)
		
		filter!(:state => ==(state), df0)
		
		lines!(df0.t, df0.fraction, label = "p = $p", color = (:blue, 1 - p))
	end
	Legend(fig[1,2], ax)
	
	fig
end

# ╔═╡ bb924b8e-69f9-11eb-1e4e-7f841ac1c1bd
vacc = let
	N = 1000

	par = (p = 0.1, ρ = ρ0, δ = δ0)
	
	graph, node_positions = spatial_graph(N)
	
	vaccinated = [
		"none"   => [],
		"random" => rand(1:N, 100),	
		# place for your suggestions
		]
	
	infected_nodes = rand(1:N, 100)

	sims = map(vaccinated) do (label, vacc_nodes)
		init = initial_state(N, infected_nodes, vacc_nodes)
		
		sim = simulate(graph, par, 100, init)
		
		label => sim
	end
	
	(; graph, node_positions, sims=sims)
end;

# ╔═╡ 02b1e334-661d-11eb-3194-b382045810ef
fig_vaccc = let
	state = "I"
	
	fig = Figure()
	ax = Axis(fig[1,1], title = "#$(state) when vaccinating different groups")
	
	colors = cgrad(:viridis, max(3, length(vacc.sims)), categorical=true)

	for (i, (lab, sim)) in enumerate(vacc.sims)
				
		df0 = fractions_over_time(sim)
		
		filter!(:state => ==(state), df0)
		
		lines!(df0.t, df0.fraction, label = lab, color = colors[i])
	end
	
	# some attributes to make the legend nicer
	attr = (orientation = :horizontal, tellwidth = :false, tellheight = true)

	leg = Legend(fig[2,1], ax; attr...)

	fig
end

# ╔═╡ 7ed6b942-695f-11eb-38a1-e79655aedfa2
fig_vaccc

# ╔═╡ 29036938-69f4-11eb-09c1-63a7a75de61d
vacc_age_graph = let
	N = 1000
	p = 0.5
	ρ = ρ_new
	
	# age specfic death rates
	age_groups = rand(Distributions.Categorical([0.4, 0.35, 0.25]), N)
		
	δ_vec = get_δ_from_ifr.(ifr_df2.IFR_pc, ρ) .* 20 # we scale this up to remove some randomness
	δ_per_node = δ_vec[age_groups]
	
	par = (p = p, ρ = ρ, δ = δ_per_node)

	graph, node_positions = spatial_graph(N)
	
	bet_centr = betweenness_centrality(graph)
	
	(; par, graph, node_positions, bet_centr)
end;	

# ╔═╡ dceb5318-69fc-11eb-2e1b-0b8cef279e05
vacc_age = let
		
	@unpack par, graph, node_positions, bet_centr = vacc_age_graph
	N = nv(graph)
	
	N_vacc = N ÷ 5

	split = 50
	vaccinated = [
		"none"   => [],
		"random" => pseudo_random(N, N_vacc, 4),
		"central"=> sortperm(bet_centr, rev=true)[1:N_vacc],
		# place your suggestions here!
		]
	
	infected_nodes = pseudo_random(N, N ÷ 10, 1)

	sims = map(vaccinated) do (label, vacc_nodes)
		init = initial_state(N, infected_nodes, vacc_nodes)
		
		sim = simulate(graph, par, 100, init)
		
		label => sim
	end
	
	(; graph, node_positions, sims=sims)
end;

# ╔═╡ da82d3ea-69f6-11eb-343f-a30cdc36228a
fig_vacc_age = let
	state = "D"
	fig = Figure()
	ax = Axis(fig[1,1], title = "#$(state) when vaccinating different groups")
	
	colors = cgrad(:viridis, min(5, length(vacc_age.sims)), categorical=true)

	for (i, (lab, sim)) in enumerate(vacc_age.sims)
				
		df0 = fractions_over_time(sim)
		
		filter!(:state => ==(state), df0)
		
		lines!(df0.t, df0.fraction, label = lab, color = colors[i])
	end
	
	# some attributes to make the legend nicer
	attr = (orientation = :horizontal, tellwidth = :false, tellheight = true)

	leg = Legend(fig[2,1], ax; attr...)

	fig
end

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
	
	hidedecorations!(axs1.ax_f, grid = false)
	hidedecorations!(axs2.ax_f, grid = false)
	
	axs1.leg.orientation[] = :vertical
	axs1.leg.tellwidth[]   = true
	axs1.leg.tellheight[]  = false
	
	
	@assert axes(sim1, 2) == axes(sim2, 2)
	
	(; fig, t, T_range = axes(sim1, 2))
end

# ╔═╡ 0d610e80-661e-11eb-3b9a-93af6b0ad5de
out_vacc = compare_sir(last.(vacc.sims[[1,2]])..., vacc.graph, vacc.node_positions);

# ╔═╡ bf2c5f5a-661b-11eb-01c5-51740fba63e3
fancy && out_vacc.fig

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
	T = 15
	
	par = (ρ = ρ_simple, δ = δ_simple, p = p_simple)
	
	sim = simulate(simple_graph, par, T)
	
	sir_plot(sim, simple_graph)
	
end;	

# ╔═╡ 9302b00c-656f-11eb-25b3-495ae1c843cc
md"""
``t``: $(@bind t0_simple NumberField(out_simple.T_range, default=1))
"""

# ╔═╡ 657c3a98-6573-11eb-1ccb-b1d974414647
fancy && out_simple.fig

# ╔═╡ 3aeb0106-661b-11eb-362f-6b9af20f71d7
elegant && (t0_simple; out_simple.fig)

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
``t``: $(@bind t0_intro Slider(out_big.T_range, show_value = true, default = 20))
"""

# ╔═╡ 3e9af1f4-6575-11eb-21b2-453dc18d1b7b
fancy && out_big.fig

# ╔═╡ 5eafd0f0-6619-11eb-355d-f9de3ae53f6a
elegant && (t0_intro; out_big.fig)

# ╔═╡ 6948e6c6-661b-11eb-141c-370fc6ffe618
fancy && out_big.fig

# ╔═╡ f4cd5fb2-6574-11eb-37c4-73d4b21c1883
md"""
Check to activate slider: $(@bind past_intro CheckBox(default = false))

``t``: $(@bind t0_big Slider(out_big.T_range, show_value = true, default = 1))
"""

# ╔═╡ 1bd2c660-6572-11eb-268c-732fd2210a58
elegant && (t0_big; out_big.fig)

# ╔═╡ 373cb47e-655e-11eb-2751-0150985d98c1
out_big.t[] = past_intro ? t0_big : t0_intro

# ╔═╡ 34b1a3ba-657d-11eb-17fc-5bf325945dce
md"""
``t``: $(@bind t0_vacc Slider(out_big.T_range, show_value = true, default = 1))
"""

# ╔═╡ 99a1f078-657a-11eb-2183-1b6a0598ffcd
out_vacc.t[] = t0_vacc

# ╔═╡ 83b817d2-657d-11eb-3cd2-332a348142ea
elegant && (t0_vacc; out_vacc.fig)

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

# ╔═╡ 9c0ee044-6a0b-11eb-1899-bbb75f5ba57d
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
	function wordcount(text)
    	words=split(string(text), (' ','\n','\t','-','.',',',':','_','"',';','!'))
    	length(words)
	end
end

# ╔═╡ b9c7df54-6a0c-11eb-1982-d7157b2c5b92
if @isdefined D
	if hasproperty(States.b.b, :b)
		correct(md"You've successfully defined type `D`.")
	else
		almost(md"You've successfully defined `D`. But you need to do it in the right place. Go **The SIR Model** and uncomment the line that defines `D`.")
	end
else
	keep_working(md"Go **The SIR Model** and uncomment the line that defines `D`.")
end

# ╔═╡ dc9ac0c0-6a0a-11eb-2ca8-ada347bffa85
try
	transition(D())
	if transition(D()) == D()
		correct(md"You've successfully specified the transition rule for `D`.")
	else
		keey_working(md"The transition rule for `D` doesn't seem to work correctly")
	end
catch e
	if e isa MethodError
		keep_working(md"The transition rule for `D` is not yet defined.")
	else
		keep_working(md"The transition rule for `D` doesn't seem to work correctly")
	end
end

# ╔═╡ 1be1ac8a-6961-11eb-2736-79c77025255d
hint(md"You can look at the section **Define the transitions** for inspiration.")

# ╔═╡ 11c507a2-6a0f-11eb-35bf-55e1116a3c72
begin
	try
		test1 = transition(I(), (δ = 1, ρ = 0), 0) == D()
		test2 = transition(I(), (δ = 0, ρ = 1), 0) == R()
		test3 = transition(I(), (δ = 0, ρ = 0), 0) == I()
	
		if test1 && test2 && test3
			correct(md"It seems that you've successfully adjusted the transition rule for `I`. *(Note: the other rules are not checked)*")
		else
			keep_working()
		end
	catch
		keep_working()
	end
end

# ╔═╡ e64300dc-6a10-11eb-1f68-57120286535b
begin
	try
		test1 = transition(I(), (δ = (1, 0), ρ = 0), 1) == D()
		test2 = transition(I(), (δ = (0, 1), ρ = 0), 1) == I()
		test3 = transition(I(), (δ = (0, 0), ρ = 1), 1) == R()
		test4 = transition(I(), (δ = (0, 0), ρ = 0), 1) == I()
	
		if test1 && test2 && test3 && test4
			correct(md"It seems that you've successfully adjusted the transition rule for `I`.")
		else
			keep_working()
		end
	catch
		keep_working()
	end
end

# ╔═╡ e79e6ed4-6a11-11eb-2d68-69a814ec657c
if answer1 == md"Your answer goes here ..."
	keep_working(md"Place your cursor in the code cell and replace the dummy text, and evaluate the cell.")
elseif wordcount(answer1) > 1.1 * 500
	almost(md"Try to shorten your text a bit, to get below 500 words.")
else
	correct(md"Great, we are looking forward to reading your answer!")
end

# ╔═╡ d14a8860-6a12-11eb-013e-d39bc64de8b2
members = let
	str = ""
	for (first, last) in group_members
		str *= str == "" ? "" : ", "
		str *= first * " " * last
	end
	str
end

# ╔═╡ fb4ff86c-64ad-11eb-2962-3372a2f2d9a5
md"""
# Assignment 2: Whom to Vaccinate When Death Rates are Age-Specfic

*submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ Cell order:
# ╟─0e30624c-65fc-11eb-185d-1d018f68f82c
# ╟─d0ee632c-6621-11eb-39ac-cb766429529f
# ╟─21be9262-6614-11eb-3ae6-79fdc6c56c3e
# ╟─c2940f90-661a-11eb-3d77-0fc1189e0960
# ╟─f4266196-64aa-11eb-3fc1-2bf0e099d19c
# ╟─43a25dc8-6574-11eb-3607-311aa8d5451e
# ╟─3e9af1f4-6575-11eb-21b2-453dc18d1b7b
# ╟─5eafd0f0-6619-11eb-355d-f9de3ae53f6a
# ╟─b36832aa-64ab-11eb-308a-8f031686c8d6
# ╟─7ed6b942-695f-11eb-38a1-e79655aedfa2
# ╟─c8f92204-64ac-11eb-0734-2df58e3373e8
# ╟─2f9f008a-64aa-11eb-0d9a-0fdfc41d4657
# ╠═b8d874b6-648d-11eb-251c-636c5ebc1f42
# ╠═f48fa122-649a-11eb-2041-bbf0d0c4670c
# ╟─10dd6814-f796-42ea-8d40-287ed7c9d239
# ╠═8ddb6f1e-649e-11eb-3982-83d2d319b31f
# ╠═61a36e78-57f8-4ef0-83b4-90e5952c116f
# ╠═ffe07e00-0408-4986-9205-0fbb025a698c
# ╠═5d11a2df-3187-4509-ba7b-8388564573a6
# ╠═f4c62f95-876d-4915-8372-258dfde835f7
# ╠═50d9fb56-64af-11eb-06b8-eb56903084e2
# ╟─9302b00c-656f-11eb-25b3-495ae1c843cc
# ╟─657c3a98-6573-11eb-1ccb-b1d974414647
# ╟─3aeb0106-661b-11eb-362f-6b9af20f71d7
# ╠═d2813d40-656d-11eb-2cfc-e389ed2a0d84
# ╠═8d4cb5dc-6573-11eb-29c8-81baa6e3fffc
# ╠═d6694c32-656c-11eb-0796-5f485cccccf0
# ╟─ce75fe16-6570-11eb-3f3a-577eac7f9ee8
# ╠═37972f08-db05-4e84-9528-fe16cd86efbf
# ╟─6948e6c6-661b-11eb-141c-370fc6ffe618
# ╟─1bd2c660-6572-11eb-268c-732fd2210a58
# ╟─f4cd5fb2-6574-11eb-37c4-73d4b21c1883
# ╠═0b35f73f-6976-4d85-b61f-b4188440043e
# ╟─373cb47e-655e-11eb-2751-0150985d98c1
# ╟─4dee5da9-aa4b-4551-974a-f7268d016617
# ╟─04227a80-5d28-43db-929e-1cdc5b31796d
# ╟─78e729f8-ac7d-43c5-ad93-c07d9ac7f30e
# ╠═49b21e4e-6577-11eb-38b2-45d30b0f9c80
# ╠═7b43d3d6-03a0-4e0b-96e2-9de420d3187f
# ╠═c5f48079-f52e-4134-8e6e-6cd4c9ee915d
# ╠═99a1f078-657a-11eb-2183-1b6a0598ffcd
# ╟─34b1a3ba-657d-11eb-17fc-5bf325945dce
# ╟─bf2c5f5a-661b-11eb-01c5-51740fba63e3
# ╟─83b817d2-657d-11eb-3cd2-332a348142ea
# ╠═bb924b8e-69f9-11eb-1e4e-7f841ac1c1bd
# ╠═0d610e80-661e-11eb-3b9a-93af6b0ad5de
# ╟─e8b7861e-661c-11eb-1c06-bfedd6ab563f
# ╠═02b1e334-661d-11eb-3194-b382045810ef
# ╟─1978febe-657c-11eb-04ac-e19b2d0e5a85
# ╟─12d7647e-6a13-11eb-2b1e-9f77bdb3a87a
# ╠═b402b1e2-6a12-11eb-16ac-7b19064562b8
# ╠═e7d47230-6a12-11eb-0392-4360f36222b8
# ╟─eea88902-6a12-11eb-3a63-df8979fbdd55
# ╟─fb4ff86c-64ad-11eb-2962-3372a2f2d9a5
# ╟─98d449ac-695f-11eb-3daf-dffb377aa5e2
# ╟─b9c7df54-6a0c-11eb-1982-d7157b2c5b92
# ╟─8a2c223e-6960-11eb-3d8a-516474e6653c
# ╠═809375ba-6960-11eb-29d7-f9ab3ee61367
# ╟─dc9ac0c0-6a0a-11eb-2ca8-ada347bffa85
# ╟─1be1ac8a-6961-11eb-2736-79c77025255d
# ╟─945d67f6-6961-11eb-33cf-57ffe340b35f
# ╟─11c507a2-6a0f-11eb-35bf-55e1116a3c72
# ╟─48818cf0-6962-11eb-2024-8fca0690dd78
# ╟─fac414f6-6961-11eb-03bb-4f58826b0e61
# ╠═d18f1b0c-69ee-11eb-2fc0-4f14873847fb
# ╟─75b4c0c2-69f3-11eb-1ebc-75efd2d0bf1f
# ╠═98b2eefe-69f2-11eb-36f4-7b19a55cfe78
# ╟─33c4ea42-6a10-11eb-094c-75343532f835
# ╟─e64300dc-6a10-11eb-1f68-57120286535b
# ╟─2e3413ae-6962-11eb-173c-6d53cfd8a968
# ╠═29036938-69f4-11eb-09c1-63a7a75de61d
# ╠═18e84a22-69ff-11eb-3909-7fd30fcf3040
# ╟─0d2b1bdc-6a14-11eb-340a-3535d7bfbec1
# ╠═dceb5318-69fc-11eb-2e1b-0b8cef279e05
# ╟─da82d3ea-69f6-11eb-343f-a30cdc36228a
# ╟─297e4d74-6a12-11eb-0302-0f97bab2c906
# ╠═d0f3064a-6a11-11eb-05bf-09f67a451510
# ╟─e79e6ed4-6a11-11eb-2d68-69a814ec657c
# ╟─9c562b8c-6a12-11eb-1e07-c378e9304a1d
# ╟─515edb16-69f3-11eb-0bc9-a3504565b80b
# ╠═1abd6992-6962-11eb-3db0-f3dbe5f095eb
# ╠═07c102c2-69ee-11eb-3b29-25e612df6911
# ╟─57a72310-69ef-11eb-251b-c5b8ab2c6082
# ╟─74c35594-69f0-11eb-015e-2bf4b55e658c
# ╠═6ffb63bc-69f0-11eb-3f84-d3fca5526a3e
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
# ╠═fdf43912-6623-11eb-2e6a-137c10342f32
# ╠═3b444a90-64b3-11eb-0b8f-1facc32a4088
# ╠═2b55141f-1cba-4a84-8811-98697d408d65
# ╟─bed07322-64b1-11eb-3324-7b7ac5e8fba2
# ╠═df9b4eb2-64aa-11eb-050c-adf04609ef21
# ╠═31bbc540-68cd-4d4a-b87a-d648e003524c
# ╠═9c0ee044-6a0b-11eb-1899-bbb75f5ba57d
# ╠═d14a8860-6a12-11eb-013e-d39bc64de8b2
