### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

# ╔═╡ f5450eab-0f9f-4b7f-9b80-992d3c553ba9
HTML("<div style=\"\nposition: absolute;\nwidth: calc(100% - 30px);\nborder: 50vw solid #282936;\nborder-top: 500px solid #282936;\nborder-bottom: none;\nbox-sizing: content-box;\nleft: calc(-50vw + 15px);\ntop: -500px;\nheight: 500px;\npointer-events: none;\n\"></div>\n\n<div style=\"\nheight: 500px;\nwidth: 100%;\nbackground: #282936;\ncolor: #fff;\npadding-top: 68px;\n\">\n<span style=\"\nfont-family: Vollkorn, serif;\nfont-weight: 700;\nfont-feature-settings: 'lnum', 'pnum';\n\"> \n<p style=\"text-align: center; font-size: 2rem;\">\n<em> Assignment 2: School closures </em>\n</p>\n</div>\n\n<style>\nbody {\noverflow-x: hidden;\n}\n</style>")

# ╔═╡ d7ab1943-d456-400d-b4c3-dda9f6c1fe26
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the randomly generated names above by the names of your group and put the right group number in [this cell](#d73b9db2-742d-4c75-9ff0-2cdce26a8ec8).
	"""
end

# ╔═╡ 13313236-502d-46ca-bf24-a4defd6d792f
md"""
`school-closures.jl` | **Version 0.3** | *last updated: Feb 14, 2022*
"""

# ╔═╡ 44c1c228-d864-49ab-a8bf-bd7d6bd260cd
md"""
# Assignment 2: School Closures in the Covid-19 Pandemic
"""

# ╔═╡ ec2e4346-1246-40cc-83e4-bb8c7e76bdd0
md"""
*submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ f45eb218-92d8-4bfe-87f6-e128c17db7c2
md"""
In this assignment we want to understand the effect of school closures on the dynamics of the pandemic. Children have a much lower probability of getting hospitalized. **Would it still make sense to close schools to keep hospitalizations low?**

We construct a network of adults and children, where children are linked via schools, adults in their jobs and parents are linked to children.
"""

# ╔═╡ cd6c5481-ccc7-47d8-acda-4e90fc98b10e
@markdown("""
<details> <summary> Click on arrow for details </summary>

* `N = $(setup.N_hh)` households in `N_locations = $(setup.N_locations)` different locations
* **households** (families) are modeled as *complete networks*, variable family size (with and without children, sometimes single-parents)
* all children of same location go to same **school** (modeled as a *complete network*)
*  **adults** are linked through their **job** (there are `N_employers = $(setup.N_employers)` employers, each modeled as a _complete network_)

</details>
""")

# ╔═╡ 14989685-a257-40c5-8e24-79fff0d1b825
md"""
In the plot below, the red dots are children, and the green dots are adults. The  $(setup.N_locations) clusters of red dots are schools.
"""

# ╔═╡ eaf1fd63-5977-4b99-9c11-ec301fba8078
fg

# ╔═╡ edbf2ae4-237d-4755-9419-b98b8ef52fc2
md"""
We assume that `child`ren and `adult`s differ by their transition probabilities. Children do not get hospitalized (``\chi = 0``), while their recovery rates are the same (both ``\rho``). (All these parameters are made up.)
"""

# ╔═╡ aba35d11-a5da-4e48-ace5-d7f317198b3e
	transitions_df = DataFrame([
		(member_type = "child", χ = 0.0, ρ = 0.4),
 		(member_type = "adult", χ = 0.2, ρ = 0.3)
	])

# ╔═╡ bd986adf-2688-470f-8d62-9b66ed3f3d0f
md"""
We also make assumptions about the transmission probabilities within families, workplaces and schools.
"""

# ╔═╡ 0aa33258-a8c2-403f-b466-95dbaee2cc75
transmission_df = DataFrame([
		(linktype = :family, p = 0.3),
 		(linktype = :school, p = 0.3),
 		(linktype = :work,   p = 0.3)
	])

# ╔═╡ a35ae69d-6c82-4ac0-bbd9-0f443747b3e6
md"""
### Task 1: Introduce *hospitalized* into the model (3 points)

👉 Add a new state `H`ospitalized.
"""

# ╔═╡ f1664b58-75c1-4a79-9540-85303ed3a42f
begin
	abstract type State end
	struct S <: State end # susceptible
	struct I <: State end # infected
#	struct H <: State end # hospitalized
	struct R <: State end # recovered
end

# ╔═╡ d6beb034-5171-46a2-a05a-2133f58e54e9
if @isdefined H
	if hasproperty(States.b.b, :b)
		correct(md"You've successfully defined type `H`.")
	else
		almost(md"You've successfully defined `H`. But you need to do it in the right place. Uncomment the line that defines `H`.")
	end
else
	hint(md"Uncomment the line that defines `H`.")
end

# ╔═╡ e73f7e86-eaac-493c-b34d-8f08ba5d3c6a
md"""
👉 Add a transition rule for `H`. You may assume that recovery rates are the same for those in and outside of hospital.
"""

# ╔═╡ 5bfce3c7-5fe4-43e8-9987-3a7764be243c
#function transition(::H, node, args...; kwargs...)
#	(; ρ) = node
#
#	x = rand()
#	if ... 
#		...
#	else
#		...	
#	end
#end

# ╔═╡ 444ecb80-138e-43ef-8feb-4a8b1b40e4eb
try
	test0 = transition(H(), (ρ = 0,)) == H()
	test1 = transition(H(), (ρ = 1,)) == R()
	
	if test0 && test1
		correct(md"You've successfully specified a transition rule for `H`.")
	else
		keep_working(md"The transition rule for `H` doesn't seem to work correctly")
	end
catch e
	if e isa MethodError
		keep_working(md"The transition rule for `H` is not yet defined.")
	else
		keep_working(md"The transition rule for `H` doesn't seem to work correctly")
	end
end

# ╔═╡ bd828ca7-5737-400e-be9e-6e23b07c02ad
hint(md"You can look at the section **Define the transitions** for inspiration.")

# ╔═╡ edb73532-2868-452c-afe2-e1fce60abb77
md"""
👉 Go to section [**Define the transitions**](#ade7f9b5-cf6e-4278-95e0-651691baa892) and adjust the transition rules for the other states if necessary.
"""

# ╔═╡ 45c718bb-ecfe-4107-bd84-1244184dc62a
begin
	try
		test1 = transition(I(), (χ = 1, ρ = 0), 0) == H()
		test2 = transition(I(), (χ = 0, ρ = 1), 0) == R()
		test3 = transition(I(), (χ = 0, ρ = 0), 0) == I()
	
		if test1 && test2 && test3
			correct(md"It seems that you've adjusted the transition rule for `I`. *(Note: the other rules are not checked)*")
		else
			keep_working()
		end
	catch
		keep_working()
	end
end

# ╔═╡ 2e2f0ad7-d3c7-4a91-abe7-817f399783c3
md"""
Great! You can now have a look how the simulations from the lecture have automatically updated.
"""

# ╔═╡ 5fe6969a-2453-4ac9-bf15-c2d9310115f1
md"""
### Task 2: Flatten the curve of `H`ospitalized (4 points)

We consider a scenario from the start of a new wave with a small numer of infections at time zero. Without taking any measures the model predicts that the total number of people who will be hospitalized will exceed the maximum capacity. In order to prevent this from happening, your options are to announce a lockdown of either schools or workplaces on a pre-specified set of future days from day 0. Lockdown days of schools are economically more costly than lockdown days of workplaces. Therefore, it is important to obtain insights on how effective school lockdowns are in terms of preventing the spreading of Covid-19. In this assignment you will use simulation of the spreading of Covid-19 under various scenarios to extract those insights, and subsequently formulate a motivated lockdown policy based on these insights.
"""

# ╔═╡ 886ae5b6-f052-4082-bfa1-c8a23f4c880a
out_big.fig

# ╔═╡ fd9cdd83-d12c-49d6-9521-02b15f692f70
T = 30

# ╔═╡ cba2a2cb-c2d5-4cb5-a3d1-a2a5d02bb336
out_big = let

	hospital_capacity = 0.1
	
	node_df1 = leftjoin(node_df, transitions_df, on = :member_type)
	
	edge_df_sorted = @chain edge_df begin
		@sort(:src, :dst)
		leftjoin!(_, transmission_df, on = :linktype)
	end
	
	Random.seed!(1234)
	sim = simulate(g, T, edge_df_sorted, node_df1; lockdown)

	attr = (;
		layout,
		node_attr  = (; strokewidth = 0.1),
		edge_width = 0.5,
		edge_color = (:black, 0.3),
	)
	
	out_big = sir_plot(sim, g; hline = hospital_capacity, attr...)
end

# ╔═╡ 9fadd61c-2532-4ad5-9c60-f17c18821624
md"""

Now it's your turn.

👉 Decide when you want to lockdown schools and adjust the cell above. Make sure you close schools no longer than **5** days in total.
"""

# ╔═╡ 80350d9e-ace6-4970-8861-0e767030f3d6
begin
	lockdown = fill(Symbol[], T)
	for t in (1:5) .+ 2
#		lockdown[t] = [:school]
	end

	lockdown
end

# ╔═╡ 14991792-4dee-472a-a331-23be55edc92c
@assert all(lockdown .⊆ Ref([:school, :work, :family]))

# ╔═╡ 6dda8f0a-64d4-47e2-aae7-65d2d48deac7
md"""

👉 Next include the possibility to lock down workplaces as well. Can the number of school lockdown days be reduced or even avoided at all?
"""

# ╔═╡ 3945ab48-4d4a-41d1-80bb-75038aab4f7e
md"""
👉 Now write a short report describing your choice.

+ Describe how you selected the lockdown period.

+ Why are hospitalizations decreasing even though children never get hospitalized?

+ Be accurate but concise. Aim at no more than 500 words.
"""

# ╔═╡ c3537e04-800f-4fa8-9320-a64db4391287
answer2 = md"""
Your answer

goes here ...
"""

# ╔═╡ 1bc07c3c-f71e-444a-9c22-b447295d5d99
md"_approx. $(wordcount(answer2)) words_"

# ╔═╡ 808fa60d-79a2-47e4-95d1-98a74b87ffc7
if answer2 == md"""
Your answer

goes here ...
"""
	keep_working(md"Place your cursor in the code cell and replace the dummy text, and evaluate the cell.")
elseif wordcount(answer2) > 1.1 * 500
	almost(md"Try to shorten your text a bit, to get below 500 words.")
else
	correct(md"Great, we are looking forward to reading your answer!")
end

# ╔═╡ c140b224-c10d-437b-85c0-2755c8d72970
md"""
### Task 3: Main insights and reflection on the model and method used (3 points)

👉 Finally write a short essay describing the main findings based on the model

+ Describe what insights you obtained from the model.

+ Explain the limitations of the model and the simulation setup. 

+ Be accurate but concise. Aim at no more than 500 words.
"""

# ╔═╡ 5b53a9c1-d176-4740-95e8-98283ad57cf9
answer3 = md"""
Your answer

goes here ...
"""

# ╔═╡ e61f91d5-80e6-4dc8-814f-c4c038af284f
md"_approx $(wordcount(answer3)) words_"

# ╔═╡ 064bfd13-944a-4d3b-8075-cf5d92018878
md"""
### Before you submit ...

👉 Make sure you have added your names and your group number [in the cells below](#d73b9db2-742d-4c75-9ff0-2cdce26a8ec8).

👉 Make sure that that **all group members proofread** your submission (especially your little essay).

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. (The source code is embedded in the html file.)
"""

# ╔═╡ d73b9db2-742d-4c75-9ff0-2cdce26a8ec8
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ 5c85f4fb-4431-4196-9663-c5ddbc719a0a
group_number = 99

# ╔═╡ 8c133759-f2ca-4c0c-a5e5-19f5ff188436
md"""
# Setting up the SIR model
"""

# ╔═╡ d1b16bec-ae19-4740-80fe-a711fd145089
const States = Union{subtypes(State)...}

# ╔═╡ ade7f9b5-cf6e-4278-95e0-651691baa892
md"
### Define the transitions
"

# ╔═╡ ca1610dc-653a-4df9-bfc7-0366576ded08
function transition(::I, node, args...; kwargs...)
	(; ρ, χ) = node
	x = rand()
	if x < ρ # recover
		R()
# 	elseif ...
# 		...
	else # infected
		I()
	end
end

# ╔═╡ 5cb8fa66-9a1e-4d27-a1c6-f26c1b7f3532
transition(::R, args...; kwargs...) = R()

# ╔═╡ baad47a0-398e-4f9f-9af6-7686acdc25e4
function transition(::S, node, adjacency_matrix, is_infected, edge_df_sorted::DataFrame, lockdown)
	(; node_id) = node
	inv_prob = 1.0
	for i in is_infected
		if adjacency_matrix[node_id, i] == 0
			p = 0
		else
			(; p, linktype) = get_edge_fast(node_id, i, edge_df_sorted)
			if linktype ∈ lockdown
				p = 0
			end
		end
	 	inv_prob *= 1 - p
	end
	
	#inv_prob = prod(1 - par.p * adjacency_matrix[i, node] for i in is_infected, init = 1.0)
	
	π =	1.0 - inv_prob
	
	rand() < π ? I() : S()
end

# ╔═╡ 396f4c50-1b1e-449e-bf39-557018f2dd78
function iterate(states, adjacency_matrix, par, lockdown)
	states_new = Vector{States}(undef, N)
	iterate!(states_new, states, adjacency_matrix, par, lockdown)
	
	states_new
end

# ╔═╡ d600e317-61a8-4b7e-a5ab-706b175f5765
function iterate!(states_new, states, adjacency_matrix, edge_df_sorted,  node_df1, lockdown)

	is_infected = findall(isa.(states, I))
	
	for i in 1:size(adjacency_matrix, 1)
		node_row = node_df1[i,:]
		@assert node_row.node_id == i
		states_new[i] = transition(states[i], node_row, adjacency_matrix, is_infected, edge_df_sorted, lockdown)
	end
	
	states_new
end

# ╔═╡ b636cf26-de30-4d0d-8f59-f5872440b1d1
md"""
### Helper functions
"""

# ╔═╡ 993546ec-5dbe-4c08-9c11-072bc343390a
function get_edge(i, j, edge_df_sorted)
	i, j = minmax(i, j)
	@subset(edge_df_sorted, :src == i, :dst == j)
end

# ╔═╡ 56ca0088-97e0-493b-95fb-88bc35610d6d
function get_edge_fast(i, j, edge_df_sorted)
	src, dst = minmax(i, j)

	i_src_from = findfirst(==(src), edge_df_sorted.src)

	if isnothing(i_src_from)
		@info i, j
	end
	i_src_to = findfirst(>(src), edge_df_sorted.src[i_src_from:end])

	src_rows = edge_df_sorted[i_src_from:end,:]
	if !isnothing(i_src_to)
		src_rows = src_rows[1:i_src_to - 1,:]
	end

	i_row = findfirst(==(dst), src_rows.dst)

	if isnothing(i_row)
		@info i, j
	end

	src_rows[i_row, :]
end

# ╔═╡ 891e5c60-468a-44c7-9b5a-609dcdb02cc2
let
	#edge_df_sorted_xx = sort(edge_df, [:src, :dst])
	
	#i, j = 478, 479 #1, 161
	#t1 = @elapsed get_edge(i, j, edge_df_sorted_xx)
	#t2 = @elapsed get_edge_fast(i, j, edge_df_sorted_xx)

	#t2 / t1 - 1
end

# ╔═╡ 08abc77a-814a-11ec-3d54-439126a38a85
md"""
# Behind the Scenes: Constructing the Network
"""

# ╔═╡ e4bf4d41-9568-42a1-b01b-e22fc5c39ec1
md"""
## Nodes
"""

# ╔═╡ 3d85c3c6-9303-47e6-9fa6-5fc975cf750a
setup = (; N_locations = 6, N_hh = 200, N_employers = 50)

# ╔═╡ 5b944c23-442c-4f02-924c-2bad76b7970d
function member_type(member_id)
	if member_id == 1
		return "adult"
	elseif member_id == 2
		if rand() < 2/3
			return "adult"
		else # single-parent
			return "child"
		end
	else
		return "child"
	end
end

# ╔═╡ 223a560f-fc61-4432-9409-5cb2cb3d9789
node_df = let
	(; N_hh, N_locations, N_employers) = setup
	household_size = rand(1:4, N_hh)

	@chain begin
		DataFrame(:hh_id => 1:N_hh)
		@transform(:school_district = @c rand(1:N_locations, N_hh))
		@groupby(:hh_id, :school_district)
		@combine(:member_id = 1:rand(1:4))
		@transform!(:member_type = member_type(:member_id))
		@transform!(:node_id = @c 1:length(:hh_id))
		@transform!(:employer = :member_type == "adult" ? N_locations + rand(1:N_employers) : :school_district)
		@transform!(:node_color = :member_type == "adult" ? colorant"green" : colorant"red")
	end
end

# ╔═╡ bf5ca480-d913-4b21-a85b-b1b2c0b4c2f9
md"""
## Edges
"""

# ╔═╡ 0da25924-c89b-4a1b-b63e-7cb2d17fcbc3
begin
	TP = typeof((i = 1, j = 1, linktype = :family))

	edge_list = TP[]
	
	# families
	gdf = @chain node_df begin
		@groupby(:hh_id)
	end

	for df in gdf
		for (i,j) ∈ Iterators.product(df.node_id, df.node_id)
			i ≠ j && push!(edge_list, (; i, j, linktype = :family))
		end
	end

	# schools / employers
	gdf = @chain node_df begin
		@groupby(:employer)
	end

	for df in gdf
		for (i,j) ∈ Iterators.product(df.node_id, df.node_id)
			if only(unique(df.employer)) ≤ setup.N_locations
				linktype = :school
				i ≠ j && push!(edge_list, (; i, j, linktype))
			else
				linktype = :work
				i ≠ j && push!(edge_list, (; i, j, linktype))
			end
		end
	end

	n_v = size(node_df, 1)

	edge_df00 = DataFrame(edge_list)
	edge_df0 = @chain edge_df00 begin
		@groupby(:i, :j)
		combine(first, _)
	end

	g = SimpleGraph(sparse(edge_df0.i, edge_df0.j, 1, n_v, n_v))

	edge_df = @chain edges(g) begin
		DataFrame
		leftjoin!(_, edge_df0, on = [:src => :i, :dst => :j])
	end
end

# ╔═╡ dc8b82e1-5e15-4832-a460-a2ce0da2ffc1
begin
	positions = Spring()(g)
	layout = _ -> positions
end

# ╔═╡ 71cf8b81-f7d2-43cb-97e8-b5e7928c4120
using NetworkLayout

# ╔═╡ 065c0b3c-d738-4581-b9f8-6446a20d0c0a
md"""
## Plotting the network
"""

# ╔═╡ 36edee11-497d-415c-b589-8a333573bb8c
fg = graphplot(g; layout,
	node_df.node_color, node_size = 7,
	edge_width = 0.3,# transmission_probability.(edge_df.p, edge_df.linktype, lockdown),
	edge_color = (:black, 0.5)
)

# ╔═╡ 3cd01849-fabd-4e97-841a-2eea57c93167
md"""
# Appendix
"""

# ╔═╡ 19c68050-596c-4604-99b2-eb5fc045db10
md"""
## Functions for the simulation
"""

# ╔═╡ 2ef4585f-7c76-4382-bdc6-455a08448c6f
function initial_state(N, infected_nodes, recovered_nodes)
	# fill with "Susceptible"
	init = States[S() for i in 1:N]
	
	init[infected_nodes] .= Ref(I())
	init[recovered_nodes] .= Ref(R())
	
	init
end

# ╔═╡ acaa8906-56e8-4202-8a82-98afb4c2f458
function initial_state(N, n_infected)
	
	# spread out the desired number of infected people
	infected_nodes = 1:(N÷n_infected):N
	
	initial_state(N, infected_nodes, [])
end

# ╔═╡ 58228108-6500-443b-8350-3d4e10f75988
function simulate(graph, T, edge_df_sorted, node_df1, init = initial_state(nv(graph), max(nv(graph) ÷ 100, 1)); lockdown = fill(:none, T))
	mat = adjacency_matrix(graph)
	N = nv(graph)
	
	sim = Matrix{States}(undef, N, T)
	sim[:,1] .= init
	
	for t = 2:T
		iterate!(view(sim, :, t), view(sim, :, t-1), mat, edge_df_sorted, node_df1, lockdown[t])
	end
	sim
end

# ╔═╡ 6fb0e547-f592-4765-bf6f-70e441119ea0
md"""
## Processing the Simulated Data
"""

# ╔═╡ a9ed4bc1-f943-456f-b122-484b9455a90a
function ordered_states(states)
	levels = unique(states)
	order  = ["S", "I", "H", "R", "D"]
	if levels ⊆ order
		return sorted = order ∩ levels
	else
		return levels
	end
end

# ╔═╡ 486fc0c3-b4fe-4f3a-b434-fe6dbb7181a3
function fractions_over_time(sim)
	tidy_sim = tidy_simulation_output(sim)
	N, T = size(sim)
	
	return @chain tidy_sim begin
		@groupby(:t, :state)
		@combine(:fraction = length(:node_id) / N)
		# put states into nice order
		@transform(:state = @c levels!(:state, ordered_states(:state)))
	end
end

# ╔═╡ 02daff76-2eeb-4f87-ba0c-3632180b2e2b
function tidy_simulation_output(sim)
	# go from type to symbol (S() => "S")
	sim1 = label.(sim)
	
	# make it a DataFrame with T columns and N rows
	df0 = DataFrame(sim1, :auto)
	rename!(df0, string.(1:size(df0,2)))
	
	# add a column with node identifier
	df0.node_id = 1:size(df0, 1)
	
	# stack df to
	# node_id | t | state
	df = stack(df0, Not(:node_id), variable_name = :t, value_name = :state)
	# make t numeric
	@transform!(df, 
		:t = parse(Int, eval(:t)),
		:state = @c categorical(:state)
	)	
	df
end

# ╔═╡ b0000ea5-8d36-42f8-9416-8d1a3737c401
label(x::DataType) = string(Base.typename(x).name)

# ╔═╡ 0a023b5e-d5f3-4a0f-b1f8-b3bf9d715074
label(x) = label(typeof(x))

# ╔═╡ b15bf71d-3062-49d6-a3cc-4ce2f1cb83df
md"""
## Constructing the Figures
"""

# ╔═╡ a7d3635a-846f-42a1-bb0c-1a132b15aeb0
function compare_sir(sim1, sim2, graph; kwargs...)
	t = Observable(1)
		
	fig = Figure(padding = (0,0,0,0))
	legpos = fig[1:2,2]
	panel1 = fig[1,1]
	panel2 = fig[2,1]
	
	axs1 = sir_plot!(panel1, legpos,  sim1, graph, t; kwargs...)
	axs2 = sir_plot!(panel2, nothing, sim2, graph, t; kwargs...)
		
	axs1.leg.orientation[] = :vertical	
	
	@assert axes(sim1, 2) == axes(sim2, 2)
	
	(; fig, t, T_range = axes(sim1, 2))
end

# ╔═╡ 9c3605bb-a0c6-4c7f-ae62-942733c2e3c1
function sir_plot(sim, graph; kwargs...)
	t = Observable(1)
	
	fig = Figure()
	main_fig = fig[2,1]
	leg_pos = fig[1,1]

	sir_plot!(main_fig, leg_pos, sim, graph, t; kwargs...)
	
	(; fig, t, T_range = axes(sim, 2))
	
end

# ╔═╡ dd4e214a-0d9b-446b-be65-ff4c0817e87e
function sir_plot!(figpos, legpos, sim, graph, t; hline=missing, kwargs...)
				
	states = ordered_states(label.(subtypes(State)))

	colors = Makie.wong_colors()[[5,2,3,1,6,4,7]]
	
	color_dict = Dict(s => colors[i] for (i,s) in enumerate(states))
	
	ax_f, leg = plot_fractions!(figpos[1,2], t, sim, color_dict; legpos, hline)
	ax_d = plot_diffusion!(figpos[1,1], graph, sim, t, color_dict; kwargs...)

	(; ax_f, ax_d, leg)

end

# ╔═╡ bde45cf6-a0f7-4ebb-b361-adc8d0e6aad6
function plot_fractions!(figpos, t, sim, color_dict; legpos = nothing, hline = missing)	
	df = fractions_over_time(sim)
			
	plt = data(df) * visual(Lines) * mapping(
		:t => AlgebraOfGraphics.L"t", :fraction, color = :state => ""
	) * visual(Lines)
	
	fg = draw!(figpos, plt, palettes = (; color = collect(color_dict)))

	ax = only(fg).axis
	vlines!(ax, @lift([$t]), color = :gray50, linestyle=(:dash, :loose))
	if !ismissing(hline)
		hlines!(ax, hline, color = (:red, 50), linestyle = :dash)
	end
	ylims!(ax, -0.05, 1.05)

	# some attributes to make the legend nicer
	attr = (orientation = :horizontal, titleposition = :left, framevisible = false)
	
	if !isnothing(legpos)
		leg = legend!(legpos, fg; attr...)
	else
		leg = nothing
	end
 
	(; ax=fg, leg)
end

# ╔═╡ 94d1cfd9-8e2d-42d3-9968-c84b89e1bfc3
function plot_diffusion!(figpos, graph, sim, t, color_dict; kwargs...)
	sim_colors = [color_dict[label(s)] for s in sim]
	state_as_color_t = @lift(sim_colors[:,$t])
	
    ax = Axis(figpos)

	hidedecorations!(ax)

	N, T = size(sim)
	msize = N < 20 ? 10 : N < 100 ? 5 : 3

	graphplot!(ax, graph;
		node_size  = msize,
		node_color = state_as_color_t,
		kwargs...
	)
	
	ax
end

# ╔═╡ 311110d0-f62e-49e1-bf27-ebf09e1c08a1
md"""
## Package environment
"""

# ╔═╡ bff18f1e-9ec9-4f52-b800-7ecd631f39fa
using Graphs, SimpleWeightedGraphs

# ╔═╡ af67ffba-216c-480e-8523-b7236bf1fe83
using SparseArrays

# ╔═╡ 2e2e455b-9ba2-4c22-b7db-a014b9384935
using Colors: @colorant_str

# ╔═╡ 1f8b5ffc-cc22-41f1-bf87-9a58e16ea2b5
using DataFrames, DataFrameMacros

# ╔═╡ ff3f0580-0b8f-40c0-9e8d-ddf556745354
using Chain: @chain

# ╔═╡ 64031dfe-3f01-4ec1-aff7-5646cfde96f0
using GraphMakie, AlgebraOfGraphics, CairoMakie

# ╔═╡ 84a3ad96-4854-4ab8-be5c-b4859d1a2e39
using MarkdownLiteral: @markdown

# ╔═╡ c5b3e888-3b6f-449b-8f72-455fe86743d2
using CategoricalArrays

# ╔═╡ e35ed6b2-3e18-40b5-b9fd-c6bb216ed2a0
using Random

# ╔═╡ 338a5dc3-7099-4163-948e-ee1f0e362481
md"""
## Infrastructure
"""

# ╔═╡ f5e85900-1ea7-4dd3-8999-2e121efa9447
using PlutoUI

# ╔═╡ 337e73e7-5454-4f1f-9d5e-9b01a5c2cd10
TableOfContents()

# ╔═╡ f23193dd-d1f8-4be3-8060-ed90cba0c168
members = let
	names = map(group_members) do (; firstname, lastname)
		firstname * " " * lastname
	end
	join(names, ", ", " & ")
end

# ╔═╡ c49c0fce-0bc7-4665-81bf-24e61707fde7
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
	function wordcount(text)
		stripped_text = strip(replace(string(text), r"\s" => " "))
    	words = split(stripped_text, ('-','.',',',':','_','"',';','!'))
    	length(words)
	end
end

# ╔═╡ d4baea2f-3919-49eb-8d31-1bba68b322a7
md"""
## Acknowledgement
"""

# ╔═╡ dcce8f3c-7c26-4cdb-92d6-a98b091a1419
Markdown.MD(
	Markdown.Admonition("warning", "The design of this notebook is based on", 
[md"""
		
_**Computational Thinking**, a live online Julia/Pluto textbook._ [(computationalthinking.mit.edu)](https://computationalthinking.mit.edu)
"""]
	))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AlgebraOfGraphics = "cbdf2221-f076-402e-a563-3d30da359d67"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
CategoricalArrays = "324d7699-5711-5eae-9e2f-1d82baa6b597"
Chain = "8be319e6-bccf-4806-a6f7-6fae938471bc"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
DataFrameMacros = "75880514-38bc-4a95-a458-c2aea5a3a702"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
GraphMakie = "1ecd5474-83a3-4783-bb4f-06765db800d2"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
NetworkLayout = "46757867-2c16-5918-afeb-47bfcb05e46a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[compat]
AlgebraOfGraphics = "~0.6.0"
CairoMakie = "~0.6.6"
CategoricalArrays = "~0.10.2"
Chain = "~0.4.10"
Colors = "~0.12.8"
DataFrameMacros = "~0.2.1"
DataFrames = "~1.3.2"
GraphMakie = "~0.3.1"
Graphs = "~1.5.1"
MarkdownLiteral = "~0.1.1"
NetworkLayout = "~0.4.4"
PlutoUI = "~0.7.32"
SimpleWeightedGraphs = "~1.2.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "6f1d9bc1c08f9f4a8fa92e3ea3cb50153a1b40d4"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.1.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[deps.AlgebraOfGraphics]]
deps = ["Colors", "Dates", "FileIO", "GLM", "GeoInterface", "GeometryBasics", "GridLayoutBase", "KernelDensity", "Loess", "Makie", "PlotUtils", "PooledArrays", "RelocatableFolders", "StatsBase", "StructArrays", "Tables"]
git-tree-sha1 = "a79d1facb9fb0cd858e693088aa366e328109901"
uuid = "cbdf2221-f076-402e-a563-3d30da359d67"
version = "0.6.0"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "ffc6588e17bcfcaa79dfa5b4f417025e755f83fc"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "4.0.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA", "StaticArrays"]
git-tree-sha1 = "774ff1cce3ae930af3948c120c15eeb96c886c33"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.6.6"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "c308f209870fdbd84cb20332b6dfaf14bf3387f8"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.2"

[[deps.Chain]]
git-tree-sha1 = "339237319ef4712e6e5df7758d0bccddf5c237d9"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.4.10"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f9982ef575e19b0e5c7a98c6e75ee496c0f73a93"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.12.0"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "6b6f04f93710c71550ec7e16b650c1b9a612d0b6"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.16.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "3f1f500312161f1ae067abe07d13b40f78f32e07"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.8"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "4aff51293dbdbd268df314827b7f409ea57f5b70"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.5"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataFrameMacros]]
deps = ["DataFrames"]
git-tree-sha1 = "cff70817ef73acb9882b6c9b163914e19fad84a9"
uuid = "75880514-38bc-4a95-a458-c2aea5a3a702"
version = "0.2.1"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ae02104e835f219b8930c7664b8012c93475c340"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.2"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "c6dd4a56078a7760c04b882d9d94a08a4669598d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.44"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "d7ab55febfd0907b285fbf8dc0c73c0825d9d6aa"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.3.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "67551df041955cc6ee2ed098718c8fcd7fc7aebe"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.12.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "StaticArrays"]
git-tree-sha1 = "770050893e7bc8a34915b4b9298604a3236de834"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.5"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "fb764dacfa30f948d52a6a4269ae293a479bbc62"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.6.1"

[[deps.GeoInterface]]
deps = ["RecipesBase"]
git-tree-sha1 = "6b1a29c757f56e0ae01a35918a2c39260e2c4b98"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "0.5.7"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.GraphMakie]]
deps = ["GeometryBasics", "Graphs", "LinearAlgebra", "Makie", "NetworkLayout", "StaticArrays"]
git-tree-sha1 = "8fc75ea16d1836cbcfb94227605afd49d5f3facf"
uuid = "1ecd5474-83a3-4783-bb4f-06765db800d2"
version = "0.3.1"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "1c5a84319923bea76fa145d49e93aa4394c73fc2"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.1"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "d727758173afef0af878b29ac364a0eca299fc6b"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.5.1"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "70938436e2720e6cb8a7f2ca9f1bbdbf40d7f5d0"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.6.4"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "9a5c62f231e5bba35695a20988fc7cd6de7eeb5a"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.3"

[[deps.ImageIO]]
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "a2951c93684551467265e0e32b577914f69532be"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.9"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "b15fc0a95c564ca2e0a7ae12c1f095ca848ceb31"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.5"

[[deps.IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "22df5b96feef82434b07327e2d3c770a9b21e023"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "46efcea75c890e5d820e670516dc156689851722"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.5.4"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "56b0b7772676c499430dc8eb15cfab120c05a150"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.15.3"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "7bcc8323fb37523a6a51ade2234eee27a11114c8"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.1.3"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MarkdownLiteral]]
deps = ["CommonMark", "HypertextLiteral"]
git-tree-sha1 = "0d3fa2dd374934b62ee16a4721fe68c418b92899"
uuid = "736d6165-7244-6769-4267-6b50796e6954"
version = "0.1.1"

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test"]
git-tree-sha1 = "70e733037bbf02d691e78f95171a1fa08cdc6332"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.2.1"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[deps.NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "SparseArrays"]
git-tree-sha1 = "cac8fc7ba64b699c678094fa630f49b80618f625"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "648107615c15d4e09f7eca16307bc821c1f718d8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.13+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "ee26b350276c51697c9c2d88a072b339f9f03d73"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.5"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "6d105d40e30b635cfed9d52ec29cf456e27d38f8"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.12"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "1155f6f937fa2b94104162f01fa400e192e4272f"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.2"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9bc1871464b12ed19297fbc56c4fb4ba84988b0d"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.47.0+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0b5cfbb704034b5b4c1869e36634438a047df065"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.1"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "6f1b25e8ea06279b5689263cc538f51331d7ca17"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "ae6145ca68947569058866e443df69587acc1806"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.32"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SIMD]]
git-tree-sha1 = "39e3df417a0dd0c4e1f89891a281f82f5373ea3b"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.0"

[[deps.ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "9cc2955f2a254b18be655a4ee70bc4031b2b189e"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.ShiftedArrays]]
git-tree-sha1 = "22395afdcf37d6709a5a0766cc4a5ca52cb85ea0"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "1.0.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays", "Test"]
git-tree-sha1 = "a6f404cc44d3d3b28c793ec0eb59af709d827e4e"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.2.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e6bf188613555c78062842777b116905a9f9dd49"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.0"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "b4912cd034cdf968e06ca5f943bb54b17b97793a"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.5.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "2884859916598f974858ff01df7dfc6c708dd895"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "51383f2d367eb3b444c961d485c565e4c0cf4ba0"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.14"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f35e1879a71cca95f4826a14cdbf0b9e253ed918"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.15"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "677488c295051568b0b79a77a8c44aa86e78b359"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.6.28"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "d21f2c564b21a202f4677c0fba5b5ee431058544"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.4"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "991d34bbff0d9125d93ba15887d6594e8e84b305"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.5.3"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.isoband_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "a1ac99674715995a536bbce674b068ec1b7d893d"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.2+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"
"""

# ╔═╡ Cell order:
# ╟─f5450eab-0f9f-4b7f-9b80-992d3c553ba9
# ╟─d7ab1943-d456-400d-b4c3-dda9f6c1fe26
# ╟─13313236-502d-46ca-bf24-a4defd6d792f
# ╟─44c1c228-d864-49ab-a8bf-bd7d6bd260cd
# ╟─ec2e4346-1246-40cc-83e4-bb8c7e76bdd0
# ╟─f45eb218-92d8-4bfe-87f6-e128c17db7c2
# ╟─cd6c5481-ccc7-47d8-acda-4e90fc98b10e
# ╟─14989685-a257-40c5-8e24-79fff0d1b825
# ╟─eaf1fd63-5977-4b99-9c11-ec301fba8078
# ╟─edbf2ae4-237d-4755-9419-b98b8ef52fc2
# ╠═aba35d11-a5da-4e48-ace5-d7f317198b3e
# ╟─bd986adf-2688-470f-8d62-9b66ed3f3d0f
# ╟─0aa33258-a8c2-403f-b466-95dbaee2cc75
# ╟─a35ae69d-6c82-4ac0-bbd9-0f443747b3e6
# ╠═f1664b58-75c1-4a79-9540-85303ed3a42f
# ╟─d6beb034-5171-46a2-a05a-2133f58e54e9
# ╟─e73f7e86-eaac-493c-b34d-8f08ba5d3c6a
# ╠═5bfce3c7-5fe4-43e8-9987-3a7764be243c
# ╟─444ecb80-138e-43ef-8feb-4a8b1b40e4eb
# ╟─bd828ca7-5737-400e-be9e-6e23b07c02ad
# ╟─edb73532-2868-452c-afe2-e1fce60abb77
# ╟─45c718bb-ecfe-4107-bd84-1244184dc62a
# ╟─2e2f0ad7-d3c7-4a91-abe7-817f399783c3
# ╟─5fe6969a-2453-4ac9-bf15-c2d9310115f1
# ╠═886ae5b6-f052-4082-bfa1-c8a23f4c880a
# ╠═fd9cdd83-d12c-49d6-9521-02b15f692f70
# ╠═cba2a2cb-c2d5-4cb5-a3d1-a2a5d02bb336
# ╟─9fadd61c-2532-4ad5-9c60-f17c18821624
# ╠═80350d9e-ace6-4970-8861-0e767030f3d6
# ╠═14991792-4dee-472a-a331-23be55edc92c
# ╟─6dda8f0a-64d4-47e2-aae7-65d2d48deac7
# ╟─3945ab48-4d4a-41d1-80bb-75038aab4f7e
# ╟─c3537e04-800f-4fa8-9320-a64db4391287
# ╟─1bc07c3c-f71e-444a-9c22-b447295d5d99
# ╟─808fa60d-79a2-47e4-95d1-98a74b87ffc7
# ╟─c140b224-c10d-437b-85c0-2755c8d72970
# ╠═5b53a9c1-d176-4740-95e8-98283ad57cf9
# ╟─e61f91d5-80e6-4dc8-814f-c4c038af284f
# ╟─064bfd13-944a-4d3b-8075-cf5d92018878
# ╠═d73b9db2-742d-4c75-9ff0-2cdce26a8ec8
# ╠═5c85f4fb-4431-4196-9663-c5ddbc719a0a
# ╟─8c133759-f2ca-4c0c-a5e5-19f5ff188436
# ╠═d1b16bec-ae19-4740-80fe-a711fd145089
# ╟─ade7f9b5-cf6e-4278-95e0-651691baa892
# ╠═ca1610dc-653a-4df9-bfc7-0366576ded08
# ╠═5cb8fa66-9a1e-4d27-a1c6-f26c1b7f3532
# ╠═baad47a0-398e-4f9f-9af6-7686acdc25e4
# ╠═396f4c50-1b1e-449e-bf39-557018f2dd78
# ╠═d600e317-61a8-4b7e-a5ab-706b175f5765
# ╟─b636cf26-de30-4d0d-8f59-f5872440b1d1
# ╠═993546ec-5dbe-4c08-9c11-072bc343390a
# ╠═56ca0088-97e0-493b-95fb-88bc35610d6d
# ╠═891e5c60-468a-44c7-9b5a-609dcdb02cc2
# ╟─08abc77a-814a-11ec-3d54-439126a38a85
# ╟─e4bf4d41-9568-42a1-b01b-e22fc5c39ec1
# ╠═3d85c3c6-9303-47e6-9fa6-5fc975cf750a
# ╠═5b944c23-442c-4f02-924c-2bad76b7970d
# ╠═223a560f-fc61-4432-9409-5cb2cb3d9789
# ╟─bf5ca480-d913-4b21-a85b-b1b2c0b4c2f9
# ╠═0da25924-c89b-4a1b-b63e-7cb2d17fcbc3
# ╠═dc8b82e1-5e15-4832-a460-a2ce0da2ffc1
# ╠═71cf8b81-f7d2-43cb-97e8-b5e7928c4120
# ╟─065c0b3c-d738-4581-b9f8-6446a20d0c0a
# ╠═36edee11-497d-415c-b589-8a333573bb8c
# ╟─3cd01849-fabd-4e97-841a-2eea57c93167
# ╟─19c68050-596c-4604-99b2-eb5fc045db10
# ╠═2ef4585f-7c76-4382-bdc6-455a08448c6f
# ╠═acaa8906-56e8-4202-8a82-98afb4c2f458
# ╠═58228108-6500-443b-8350-3d4e10f75988
# ╟─6fb0e547-f592-4765-bf6f-70e441119ea0
# ╠═a9ed4bc1-f943-456f-b122-484b9455a90a
# ╠═486fc0c3-b4fe-4f3a-b434-fe6dbb7181a3
# ╠═02daff76-2eeb-4f87-ba0c-3632180b2e2b
# ╠═b0000ea5-8d36-42f8-9416-8d1a3737c401
# ╠═0a023b5e-d5f3-4a0f-b1f8-b3bf9d715074
# ╟─b15bf71d-3062-49d6-a3cc-4ce2f1cb83df
# ╠═a7d3635a-846f-42a1-bb0c-1a132b15aeb0
# ╠═9c3605bb-a0c6-4c7f-ae62-942733c2e3c1
# ╠═dd4e214a-0d9b-446b-be65-ff4c0817e87e
# ╠═bde45cf6-a0f7-4ebb-b361-adc8d0e6aad6
# ╠═94d1cfd9-8e2d-42d3-9968-c84b89e1bfc3
# ╟─311110d0-f62e-49e1-bf27-ebf09e1c08a1
# ╠═bff18f1e-9ec9-4f52-b800-7ecd631f39fa
# ╠═af67ffba-216c-480e-8523-b7236bf1fe83
# ╠═2e2e455b-9ba2-4c22-b7db-a014b9384935
# ╠═1f8b5ffc-cc22-41f1-bf87-9a58e16ea2b5
# ╠═ff3f0580-0b8f-40c0-9e8d-ddf556745354
# ╠═64031dfe-3f01-4ec1-aff7-5646cfde96f0
# ╠═84a3ad96-4854-4ab8-be5c-b4859d1a2e39
# ╠═c5b3e888-3b6f-449b-8f72-455fe86743d2
# ╠═e35ed6b2-3e18-40b5-b9fd-c6bb216ed2a0
# ╟─338a5dc3-7099-4163-948e-ee1f0e362481
# ╠═f5e85900-1ea7-4dd3-8999-2e121efa9447
# ╠═337e73e7-5454-4f1f-9d5e-9b01a5c2cd10
# ╠═f23193dd-d1f8-4be3-8060-ed90cba0c168
# ╠═c49c0fce-0bc7-4665-81bf-24e61707fde7
# ╟─d4baea2f-3919-49eb-8d31-1bba68b322a7
# ╟─dcce8f3c-7c26-4cdb-92d6-a98b091a1419
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
