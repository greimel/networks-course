### A Pluto.jl notebook ###
# v0.16.1

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

# ╔═╡ 6526d6e4-774a-11eb-0b7a-bd644b5f7fea
begin
	using PlutoUI: TableOfContents, Slider, CheckBox

	using GraphPlot, NetworkLayout, OffsetArrays
	
	using Statistics: mean
	using SparseArrays#: sparse
	using LinearAlgebra: I, dot, diag, Diagonal, norm
	import Downloads
	
	import CairoMakie
	CairoMakie.activate!(type = "png")
	
	using Makie#: 	
		#Legend, Figure, Axis, Colorbar,
		#lines!, scatter!, poly!, vlines!, hlines!, image!, hist, hist!,
		#hidedecorations!, hidespines!

	#import Cairo, Compose, Images
	
	using Distributions
	using AxisKeys: KeyedArray
	using NamedArrays: NamedArray
	using CategoricalArrays: cut
	using Colors: RGBA
	using Chain: @chain
	using DataFrames: DataFrames, DataFrame,
		select, select!, transform, transform!, combine,
		leftjoin, innerjoin, rightjoin, outerjoin,
		groupby, ByRow, Not, stack, unstack,
		disallowmissing!, dropmissing!, disallowmissing
	import CSV, HTTP, ZipFile
	import XLSX
	using UnPack: @unpack
	#using Plots
	#Plots.gr(fmt = :png)	
	
end

# ╔═╡ 579444bc-774a-11eb-1d80-0557b12da169
begin	
	using LightGraphs
	using SimpleWeightedGraphs: AbstractSimpleWeightedGraph, SimpleWeightedDiGraph
	const LG = LightGraphs
	
	function weighted_adjacency_matrix(graph::LightGraphs.AbstractGraph; dir = :in)
		A = LG.weights(graph) .* adjacency_matrix(graph)
		if dir == :in
			return A
		elseif dir == :out
			return A'
		else
			@error "provide dir ∈ [:in, :out]"
		end
	end
	
	LG.adjacency_matrix(graph::AbstractSimpleWeightedGraph) = LG.weights(graph) .> 0
	
	function LG.katz_centrality(graph::AbstractGraph, α::Real=0.3; dir = :in,  node_weights = ones(nv(graph)))
		v = node_weights

	    A = weighted_adjacency_matrix(graph; dir)
    	v = (I - α * A) \ v
    	v /=  norm(v)
	end
	
	function LG.eigenvector_centrality(graph::AbstractGraph; dir = :in)
		A = weighted_adjacency_matrix(graph; dir)
		eig = LightGraphs.eigs(A, which=LightGraphs.LM(), nev=1)
		eigenvector = eig[2]
	
		centrality = abs.(vec(eigenvector))
	end
	
	LG.indegree(graph::AbstractSimpleWeightedGraph) = sum(weighted_adjacency_matrix(graph), dims = 1) # column sum
	LG.outdegree(graph::AbstractSimpleWeightedGraph) = sum(weighted_adjacency_matrix(graph), dims = 2) # row sum
		
end

# ╔═╡ 55a868c8-0614-4074-9389-c957cf64cb20
md"""
!!! danger "Under construction!"

	This notebook is used for the course _Economic and Financial Network Analysis_ at the University of Amsterdam.

	**The notebook will get updated for Spring 2022.**

"""

# ╔═╡ 38f5d048-7747-11eb-30f7-89bade5ed0a3
md"""
`production.jl` | **Version 1.3** | *last updated: Oct 14 2021*
"""

# ╔═╡ f1749b26-774b-11eb-2b42-43ffcb5cd7ee
md"""
# The Economy as a Network of Sectors

This notebook will be the basis for part of **Lectures 9 and 10** *and* **Assignment 4**. Here is what we will cover.

#### Lecture 9
1. Introduce Input-Output Tables. Re-interpret them as a network of economic sectors connected by input-output linkages
2. Visualize and analyze this *intersectoral network*
3. Simulate the *dynamic* production network model of [Long & Plosser (1987)](https://www.jstor.org/stable/1840430)
4. Visualize propagation of shocks in the model of Long & Plosser. Discuss the role of centrality

#### Lecture 10

5. Solve the *static* production network model of [Acemoglu, Carvalho, Ozdaglar & Tahbaz-Salehi (2012)](https://economics.mit.edu/files/8135)
6. Show that sector-specific shocks don't necessarily wash out in equilibrium. 
7. Show by simulation that iid industry-specific shocks will lead to aggregate flucuations

#### Assignment

8. Simulate how the Covid shocks propagates through the economy

"""

# ╔═╡ a771e504-77aa-11eb-199c-8778965769b6
md"""
## Appetizers

This plot shows how a shock to single sector propagates to other sectors.
"""

# ╔═╡ cb75f8ac-77aa-11eb-041c-4b3fe85ec22b
md"""
This plot shows how the aggregate economy reacts to shocking two groups of sectors. The groups are equally big, but differ by their centrality.
"""

# ╔═╡ 9b47991e-7c3d-11eb-1558-b5824ab10dc0
md"""
This plot shows how industry-specific iid shocks can either $(i)$ wash out, or $(ii)$ translate into aggregate fluctuations, depending on the network structure.
"""

# ╔═╡ d9465a80-7750-11eb-2dd5-d3052d3d5c50
md"""
# Input-Output Tables: *Production Recipes* for the Economy
"""

# ╔═╡ cf680c48-7769-11eb-281c-d7a2d5ec8fe5
md"""
#### The list of industries
"""

# ╔═╡ dd41fe96-7769-11eb-06a6-3d6298f6e6fc
md"""
#### The Input-Output Table
"""

# ╔═╡ 128bb9e8-776a-11eb-3786-83531bd2dffb
md"""
#### The Input-Output table as a sparse matrix
"""

# ╔═╡ f65f7f8c-7769-11eb-3399-79bde01513cd
md"""
#### Important industries
"""

# ╔═╡ 04e731d0-7751-11eb-21fd-e7f9b022cdc9
md"""
# Analyzing the *Intersectoral Network* 

Recall, ``G = W'``. Also, in order to satisfy the assumptions of the model, we have to normalize the row sums to 1.
"""

# ╔═╡ 958f9f3e-77ac-11eb-323c-cd78c1fe4c23
#gplot(unweighted_network) |> gplot_to_png

# ╔═╡ 5aff086a-7751-11eb-039e-fd1b769b6fea
md"""
# Simulating a *Dynamic* Production Network Model

The model solution comes from equations (10b), (12), (14), (15) in [Long & Plosser (1987, p. 48)](https://www.jstor.org/stable/1840430)
"""

# ╔═╡ 2e7630ee-7770-11eb-32ae-112b4b282eaf
function params(W)
	N = size(W, 1)
	θ = fill(1/(N+1), N) # utility weights of commodities
	θ₀ = 1/(N+1) # utility weight of leisure
	β = 0.95
	H = 1
	α = 0.3
	param = (; α, β, θ, θ₀, H)
end

# ╔═╡ 4341e8cc-7770-11eb-04d5-c5d33d9a9e52
get_γ(W, param) = (I - param.β * W) \ param.θ

# ╔═╡ 486d0372-7770-11eb-1956-1d3314be6753
function L(W, param)
	@unpack α, β, θ, θ₀, H = param
	γ = get_γ(W, param)
	L = β .* γ .* (1-α) ./ (θ₀ + (1-α) * β * sum(γ)) .* H
end

# ╔═╡ 4e17451a-7770-11eb-3c41-6d98b73d410b
C(Y, W, param) = param.θ ./ get_γ(W, param) .* Y

# ╔═╡ 56a4c272-7770-11eb-0626-131942edd52d
function welfare(y, param)
	dot(y, param.θ)
end

# ╔═╡ 5bb435cc-7770-11eb-33b6-cb78835406bc
function κ(W, param)
	N = size(W, 1)
	@unpack α, β = param
	γ = get_γ(W, param)
	
	κ = (1 - α) .* log.(L(W, param))
	for i in 1:N
		tmp = sum(W[i,j] == 0 ? 0 : W[i,j] * log(β * γ[i] * W[i,j] / γ[j]) for j in 1:N)
		κ[i] = κ[i] + α * tmp
	end
	κ
end

# ╔═╡ 5dbcbd44-7770-11eb-0f60-f74a9945477e
y₀(W, param) = (I - param.α * W) \ κ(W, param)

# ╔═╡ 6378c2aa-7770-11eb-3edc-9d41e709750e
y_next(y, ε, W, param) = κ(W, param) + param.α * W * y + ε

# ╔═╡ 6ca12836-7770-11eb-271f-354367f89cb0
function impulse_response(T, W, param, shocked_nodes, ε₀; T_shock = 0, T₀=3)
	y = y₀(W, param)
	N = size(W, 2)
	
	t_indices = -T₀:T
	
	y_out = OffsetArray(zeros(N, length(t_indices)), 1:N, t_indices)
	w_out = OffsetArray(zeros(length(t_indices)), t_indices)
	
	y_out[:, -T₀] .= y
	w_out[-T₀]     = welfare(y, param)
	
	for t in (-T₀+1):T
		ε = zeros(N)
		if t ∈ T_shock 
			ε[shocked_nodes] .= ε₀
		end
		y = y_next(y, ε, W, param)
		
		y_out[:, t] .= y
		w_out[t]     = welfare(y, param)
	end
	
	y_out .= y_out ./ -y_out[:,-T₀] .+ 1
	w_out .= w_out ./ -w_out[-T₀] .+ 1
	(production = y_out, welfare = w_out)
end

# ╔═╡ c2842ace-7751-11eb-240f-550286e812af
md"""
## Simple Networks
"""

# ╔═╡ bc30e12a-7770-11eb-3db2-b753ec458ce5
function my_out_StarGraph(N)
	A = zeros(N, N)
	A[:,1] .= 1
	
	SimpleWeightedDiGraph(A')
end	

# ╔═╡ b48335da-7771-11eb-2b17-1507687e446c
function my_complete_DiGraph(N)
	A = fill(1/(N-1), N, N)
	A = A - 1/(N-1) * I
		
	SimpleWeightedDiGraph(A')
end

# ╔═╡ 9a89d9b4-7772-11eb-0c86-9b5f5f1ab23e
begin
	#grph = my_complete_DiGraph(10)
	#grph = my_out_StarGraph(10)
	grph = CycleDiGraph(10)
end	

# ╔═╡ 36334032-7774-11eb-170f-5b7f9b7e0ec7
t = Node(0)

# ╔═╡ 15334fc2-7773-11eb-303e-67e90901f850
begin
	AA = weighted_adjacency_matrix(grph) |> Matrix |> transpose
	param = params(AA)
	
	@unpack production = impulse_response(10, AA, param, [1], -0.3, T_shock = 0:2)
	
	color_extr = extrema(production)
end

# ╔═╡ f534c32c-7772-11eb-201c-233b5b7a27a4
@bind t0 Slider(axes(production, 2), default = 1, show_value = true)

# ╔═╡ 3843a2c2-7774-11eb-1bf5-5178a9014ae2
t[] = t0

# ╔═╡ 939fa06e-7772-11eb-086c-ff1bf54525f1
node_colors = Node(rand(nv(grph)))

# ╔═╡ 7db9fa00-7773-11eb-0942-ed884b67533c
node_colors[] = parent(production[:,t0])

# ╔═╡ cbb1e550-7751-11eb-1313-7ff968453f36
md"""
## Big Network from Input-Output Tables
"""

# ╔═╡ ee72ef4c-7751-11eb-1781-6f4d027a9e66
md"""
## Network Origins of Aggregate Fluctuations

Instead of studying shocks to individual sectors, we will now simulate shocks to the whole economy. We assume that for each sector ``i`` and time period ``t``, the sector specific log-productivity follows a *white noise* process: ``\varepsilon_{it} \sim N(0, \sigma^2)``.

We will simulate our welfare measure (flow utility).
"""

# ╔═╡ 3585b022-7853-11eb-1a05-7b4fe3921051
function simulate_business_cycles(graph; dist = Normal(0, 1), T₀ = 15, T = 100)
	N = nv(graph)
	W = weighted_adjacency_matrix(graph)'
	param = params(W)
	y = y₀(W, param)
		
	t_indices = -T₀:T
	
	y_out = OffsetArray(zeros(N, length(t_indices)), 1:N, t_indices)
	w_out = OffsetArray(zeros(length(t_indices)), t_indices)

	ε = rand(dist, N, T)
	
	y_out[:, -T₀:0] .= y
	w_out[-T₀:0]    .= welfare(y, param)
	
	for t in 1:T
		y = y_next(y, @view(ε[:,t]), W, param)
		
		y_out[:, t] .= y
		w_out[t]     = welfare(y, param)
	end
	
	y_out .= y_out ./ -y_out[:,-T₀] .+ 1
	w_out .= w_out ./ -w_out[-T₀] .+ 1
	
	(; y_out, w_out)	
end

# ╔═╡ ddfcd760-7853-11eb-38f7-298a4c1cb5aa
fluct_fig = let
	fig = Figure()
	
	ax = Axis(fig[1,1])
	
	N = 400
	
	grph = my_out_StarGraph(N)
	
	fluc = simulate_business_cycles(grph)
	
	for (i, row) in enumerate(eachrow(fluc.y_out))
		lines!(ax, collect(axes(fluc.y_out, 2)), collect(row), color = (:black, 0.1))
	end
	
	lines!(ax, collect(axes(fluc.y_out, 2)), collect(fluc.w_out), linewidth = 2, color = :red)

	ax0 = ax
	
	ax = Axis(fig[2,1])
	
	grph = CycleDiGraph(N)
	
	fluc = simulate_business_cycles(grph)
	
	for (i, row) in enumerate(eachrow(fluc.y_out))
		lines!(ax, collect(axes(fluc.y_out, 2)), collect(row), color = (:black, 0.1))
	end
	
	lines!(ax, collect(axes(fluc.y_out, 2)), collect(fluc.w_out), linewidth = 2, color = :red)
	
	linkaxes!(ax0, ax)
	hidexdecorations!(ax0)
	
	fig
	

	
end

# ╔═╡ d772a28a-7c3d-11eb-012f-9b81ad67f9a8
fluct_fig

# ╔═╡ d0630e36-774b-11eb-0750-370f1b1327e6
md"""
## (End of Lecture)
"""

# ╔═╡ 29f570c0-774b-11eb-2c1c-17a956c9fd27
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ 2fa2a558-774b-11eb-396b-832d0ce9a130
group_number = 99

# ╔═╡ 3cd55fca-774b-11eb-307a-61b685db1b54
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the randomly generated names above by the names of your group and put the right group number in the top cell.
	"""
end

# ╔═╡ 04e5b93a-77ae-11eb-0240-ad7517f0fde3
md"""
For this problem set you will simulate a Covid crisis using the model from the lecture.

### Task 1: Which industries were hit by Covid? (3 points)

👉 Find 5 (groups of) industries and explain how they have been hit by the Corona crisis *directly* (that is, not through propagation within the production network.)

You can look through the industry definitions in `df_nodes1` (below) or go to [the BEA website](https://www.bea.gov/data/industries).

"""

# ╔═╡ 5df355b6-77b1-11eb-120f-9bb529b208df
answer1 = md"""
Your answer

goes here ...
"""

# ╔═╡ 85e7546c-77ae-11eb-0d0c-618c3669c903
md"""
### Task 2: Simulate a Covid crisis (4 points)

👉 Adapt the code in simulates the the welfare effect of central industries by specifying the set of shocked nodes (from **Task 1**) and the length of the shock (assume a period is a quarter).

👉 Explain your findings in <200 words. Think about how much of the welfare loss is due to the directly hit industries, how much is due to network effects?
"""

# ╔═╡ 811e741e-77b1-11eb-000e-93a9a19a9f60
answer2 = md"""
Your answer

goes here ...
"""

# ╔═╡ 3ec33a62-77b1-11eb-0821-e547d1422e6f
# your

# ╔═╡ 4359dbee-77b1-11eb-3755-e1c1532212bb
# code

# ╔═╡ 45db03f2-77b1-11eb-2edd-6104bc85915b
# goes

# ╔═╡ 486cd850-77b1-11eb-1dd2-15ca68d98173
# here

# ╔═╡ 4e891b56-77b1-11eb-116d-e94250f1d70e


# ╔═╡ 48f0ffd4-77b0-11eb-04ab-43eac927ac9d
md"""
### Task 3: Is this model suitable for this exercise? (3 points)

👉 Explain in <200 words how well you think that the model simulation can capture the real-world Covid crisis?
"""

# ╔═╡ 9fb0a0a8-77b1-11eb-011f-7fc7a549f552
answer3 = md"""
Your answer

goes here ...
"""

# ╔═╡ 24c076d2-774a-11eb-2412-f3747af382a2
md"""
# Appendix
"""

# ╔═╡ 7122605e-7753-11eb-09b8-4f0066353d17
md"""
## Downloading the Input-Output Table for the US
"""

# ╔═╡ b223523e-7753-11eb-1d9a-67c0281ae473
begin
	url = "https://apps.bea.gov/industry/xls/io-annual/CxI_DR_2007_2012_DOM_DET.xlsx"
	file = Downloads.download(url)
	f = XLSX.readxlsx(file)
	sh = f["2007"]
end

# ╔═╡ 356d2016-7754-11eb-2e6f-07d1c12831b5
md"""
Data is usually messy. Here is some evidence.
"""

# ╔═╡ 12798090-7754-11eb-3fdf-852bc740ed2a
begin
	code_column = sh["A6:A410"] |> vec .|> string # output == row
	name_column = sh["B6:B410"] |> vec .|> string
	code_row    = sh["C5:OQ5"]  |> vec .|> string  # input == column
	name_row    = sh["C4:OQ4"]  |> vec .|> string
	io_matrix   = sh["C6:OQ410"] .|> float
	
	df_in = DataFrame(
		:code => vec(code_row),
		:name => vec(name_row)		
	)
	df_out = DataFrame(
		:code => vec(code_column),
		:name => vec(name_column),
	)
	
	io1 = NamedArray(io_matrix, (code_row, code_column), (:output, :input))
	io2 = KeyedArray(io_matrix, output = code_row, input = code_column)
	
	io1
end

# ╔═╡ ad8a6380-7755-11eb-1542-9972c0daa480
md"""
**The vector of input industries is not the vector of output industries.**
"""

# ╔═╡ 5bbac0ac-7754-11eb-0ec0-7d564524afe6
all(code_column .== code_row)

# ╔═╡ 724dc756-7754-11eb-3a22-a309a77b2f28
md"""
Here are the industries that are *only outputs*.
"""

# ╔═╡ 75b9fd42-7754-11eb-3219-c57ef876f04b
out_not_in = @chain df_out begin
	filter(:code => !in(df_in.code), _)
    select(:code, :name)
end

# ╔═╡ 7658c6d2-7754-11eb-32a9-41bf10cd7f6b
md"""
Here are the industries that are *only inputs*.
"""

# ╔═╡ ade0d2f4-7754-11eb-2693-074c67837de3
in_not_out = @chain df_in begin
	filter(:code => !in(df_out.code), _)
    select([:code, :name])
end

# ╔═╡ 83bdf67e-7753-11eb-06a2-cf39291d8a87
md"""
## Cleaning the Input-Output Table
"""

# ╔═╡ 0fe4809c-7758-11eb-2569-33b178bfccca
begin
	df_io = DataFrame(io_matrix, code_column)
	df_io[!,:output] = code_row
	select!(df_io, :output, :)
end

# ╔═╡ 278c829c-7767-11eb-1d04-cb38ee52b79b
df_io

# ╔═╡ 6197cf52-7758-11eb-2c66-b7df9d59cbf7
begin
	io_edges0 = stack(df_io, Not("output"), variable_name = "input")
	filter!(:value => >(0), io_edges0)
end

# ╔═╡ c312d5d6-775a-11eb-24cd-f1cf36f3dd40
begin
	function nodes_weights_from_edges(from, to, weight)
		# get the list of nodes
		node_names = unique([from; to]) |> sort
		# enumerate the nodes (node_id == index)
		node_dict = Dict(n => i for (i,n) in enumerate(node_names))
		# add columns with node_id
		i_from = [node_dict[n] for n in from]
		i_to   = [node_dict[n] for n in to]
		
		N = length(node_names)
		# create the weight matrix
		wgts = sparse(i_from, i_to, weight, N, N)
		
		# drop industries that are not used as inputs
		drop = findall(dropdims(sum(wgts, dims=2), dims=2) .≈ 0)
			
		(node_names = node_names[Not(drop)], sparse_wgts = wgts[Not(drop), Not(drop)])
	end
	
	nodes_weights_from_edges(df, from, to, weight) = 
		nodes_weights_from_edges(df[!,from], df[!,to], df[!,weight]) 
end

# ╔═╡ 5d85143c-7765-11eb-1a1c-29f3421fe857
begin
	node_names, wgts = nodes_weights_from_edges(io_edges0, :input, :output, :value)
	droptol!(wgts, 0.0)
	
	node_names, wgts
end;

# ╔═╡ 280e8390-776a-11eb-0aed-19b0ba929c84
wgts

# ╔═╡ 22c3abde-7767-11eb-0b6f-93ad1055bbae
extrema(wgts)

# ╔═╡ 44929fe0-7767-11eb-0318-e720b844f710
begin
	used_inputs = sum(wgts, dims=2) |> vec # row sums
	hist(used_inputs, axis = (title = "Inputs Used per Dollar of Output", ))
end

# ╔═╡ f6144074-7768-11eb-3624-51bbc44be7ec
begin
	used_as_input = sum(wgts, dims=1) |> vec # col sums
	#filter!(>(√eps()), used_as_input)
	hist(used_as_input, axis = (title = "Used as Inputs in Other Sectors", ))
end

# ╔═╡ 775f99b8-77a9-11eb-2ebf-7bbe0d398306
extrema(wgts)

# ╔═╡ 6cec81a0-77ac-11eb-06e3-bd9dcb73a896
network = SimpleWeightedDiGraph(wgts')

# ╔═╡ 8212939e-7770-11eb-1f4e-9b698be25d1f
begin
	sorted_nodes = sortperm(eigenvector_centrality(network)[:], rev = true)
	n = 40
	bot_n = sorted_nodes[end-n+1:end]
	top_n = sorted_nodes[1:n]
end

# ╔═╡ 9aa77c76-7770-11eb-35ed-9b83924e8176
fig_welfare = let
	nodes_vec = [bot_n => "bottom", top_n => "top"]
	#nodes = [bot_n, top_n]
	
	A = weighted_adjacency_matrix(network)'
	
	fig = Figure()
	
	col = Makie.wong_colors()
	
	ax = Axis(fig[1,1], title = "Welfare loss after shock to different industries")
	
	for (i, nodes) in enumerate(nodes_vec)
		@unpack welfare = impulse_response(10, A, params(A), nodes[1], -0.5, T_shock = 0:2)
		lines!(ax, collect(axes(welfare, 1)), parent(welfare), color = col[i], label = nodes[2] * " $(length(nodes[1]))")
	end
	
	Legend(fig[1,2], ax)

	fig
end

# ╔═╡ 76e6f44e-77aa-11eb-1f12-438937941606
fig_welfare

# ╔═╡ ea1afdc0-77b4-11eb-1c7a-2f92bbdb83a6
fig_covid = let
	nodes_vec = [bot_n => "bottom", top_n => "top"]
	
	A = weighted_adjacency_matrix(network)'
	
	fig = Figure()
	
	col = Makie.wong_colors()
	
	ax = Axis(fig[1,1], title = "Welfare loss after shock to different industries")
	
	for (i, nodes) in enumerate(nodes_vec)
		@unpack welfare = impulse_response(10, A, params(A), nodes[1], -0.5, T_shock = 0:2)
		lines!(ax, collect(axes(welfare, 1)), parent(welfare), color = col[i], label = nodes[2] * " $(length(nodes[1]))")
	end
	
	Legend(fig[1,2], ax)

	fig
end

# ╔═╡ 834669c4-776c-11eb-29b7-77dc465077d7
begin
	wgts_n = wgts ./ sum(wgts, dims=2) |> dropzeros!
	network_n = SimpleWeightedDiGraph(wgts_n')
	extrema(wgts_n)
end

# ╔═╡ 5c2ef34e-776f-11eb-2a6f-ff99b5d24997
unweighted_network = SimpleDiGraph(wgts .> 0.01)

# ╔═╡ 48dc654c-7765-11eb-313a-c598a7d09fb7
md"""
## List of Sectors
"""

# ╔═╡ d6a23266-7757-11eb-346c-534caaf657fb
begin
	df_all = outerjoin(df_in, df_out, on = [:code, :name])
	n_rows = size(df_all, 1)
	
	@assert length(unique(df_all.code)) == n_rows
	@assert length(unique(df_all.name)) == n_rows
	
	df_all
end

# ╔═╡ cbc03264-7769-11eb-345a-71ae30cc7526
filter(:code => in(node_names), df_all)

# ╔═╡ bd27268e-7766-11eb-076b-71688ecb4ae3
begin
	df_nodes = filter(:code => in(node_names), df_all)
	df_nodes.inputs_used    = sum(wgts, dims=2) |> vec
	df_nodes.used_as_input = sum(wgts, dims=1) |> vec
	
	df_nodes
end;

# ╔═╡ d9fd6bb0-7766-11eb-150b-410bb7d09d20
sort(df_nodes, :inputs_used, rev = true)

# ╔═╡ b43f6b02-776c-11eb-2685-655705eb1681
begin
	df_nodes1 = df_nodes
	df_nodes1.eigv_c = eigenvector_centrality(network, dir = :in)
	df_nodes1.eigv_c_out = eigenvector_centrality(network, dir = :out)
	df_nodes1.katz_c = katz_centrality(network)
	df_nodes1.katz_c = katz_centrality(network, dir = :out)
end

# ╔═╡ ffdbb91c-776c-11eb-3b28-51314d40f7a2
sort(df_nodes1, :eigv_c_out, rev = true)

# ╔═╡ ebfcbb8e-77ae-11eb-37fc-e798175197d0
df_nodes1

# ╔═╡ 66d81066-7772-11eb-21f3-9568518636c2
md"""
## Function for Plotting
"""

# ╔═╡ cb5e1b02-7772-11eb-2d21-dfe6c49aa7d0
function network_plot(node_positions, edges_as_pts; axis = (;), scatter = (;), lines = (;), colorbar = (;))
	fig = Figure()
	
	ax = Axis(fig[1,1][1,1]; spinewidth = 0, axis...)
	
	hidedecorations!(ax)

	lp = arrows!(ax, edges_as_pts...; arrowsize = 15, lengthscale=0.85, lines...)
	sp = scatter!(ax, node_positions; scatter...)

	cb = Colorbar(fig[1,1][1,2]; colorbar...)
	cb.width = 30
	
	fig
end

# ╔═╡ c3b13010-7772-11eb-0ba3-0d82c76c6a49
function edges_as_arrows(edges, node_positions;
			    		 weights = missing, min_wgt = -Inf, max_wgt = Inf)
	from = Point2f0[]
	dir  = Point2f0[]

	for e in edges
		if ismissing(weights) || (min_wgt < weights[e.src, e.dst] < max_wgt)
			push!(from, node_positions[e.src])
    	    push!(dir,   node_positions[e.dst] .- node_positions[e.src])
		end
    end
	
	from, dir
end

# ╔═╡ bb783ac4-7772-11eb-365a-1fd1b6847e27
function nodes_edges(graph)
	wgt = Matrix(weights(graph) .* adjacency_matrix(graph)) 
	
	node_positions = NetworkLayout.Spring()(wgt)
#	node_positions = NetworkLayout.Spectral.layout(wgt) # node_weights = eigenvector_centrality(graph)
	
	#cutoffs = [0.001,0.01,0.05,0.15,0.4,1.0]
	
	edge_arrows = edges_as_arrows(edges(graph), node_positions)
	
	(; node_positions, edge_arrows)
end

# ╔═╡ 50194494-7772-11eb-20ff-419e874ec00c
fig = let
	graph = grph
	node_positions, edges = nodes_edges(graph)
	
	#colormap = CairoMakie.AbstractPlotting.ColorSchemes.linear_bmy_10_95_c78_n256
	
	fig = network_plot(node_positions, edges; 
		scatter = (; color = node_colors, colorrange = color_extr, strokewidth = 0 ),
		lines = (; arrowcolor = (:black, 0.5), linecolor = (:black, 0.5)), 
		colorbar = (; limits = color_extr),
		axis = (title = "Production network", )
	)
	
	ax = Axis(fig[1,2][1,1])
	
	for i in 1:nv(graph)
		lines!(ax, collect(axes(production, 2)), parent(production[i,:]), color = Makie.wong_colors()[rem(i, 7) + 1])
		vlines!(ax, t)
	end
	
	fig
end;

# ╔═╡ 94375d0e-77aa-11eb-3934-edb020ab0fd7
fig

# ╔═╡ 95f4f0d0-7772-11eb-1b2a-d179e76950fe
t0; fig

# ╔═╡ 42b21fce-774a-11eb-2d00-c3bfd55a35fc
md"""
## Package Environment
"""

# ╔═╡ 5a931c10-774a-11eb-05cb-d7ed3da85835
md"""
## Patch 1: Weights and Centralities
"""

# ╔═╡ 8cf29922-7759-11eb-3584-6d0d967b83b7


# ╔═╡ 4779bd0a-774a-11eb-2548-038fcb0f7644
md"""
## Other stuff
"""

# ╔═╡ 4a355496-774a-11eb-0bd2-b36814663229
TableOfContents()

# ╔═╡ 47b5833e-774b-11eb-2209-cfa172c6425f
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
	function wordcount(text)
    	words=split(string(text), (' ','\n','\t','-'))
    	length(words)
	end
end

# ╔═╡ 664efcec-77b1-11eb-2301-5da84a5de423
md"(You have used approximately **$(wordcount(answer1))** words.)"

# ╔═╡ 9298e2de-77b1-11eb-0a56-1f50bb0f4dc3
md"(You have used approximately **$(wordcount(answer2))** words.)"

# ╔═╡ 9da09070-77b1-11eb-0d2e-e9a4433bf34e
md"(You have used approximately **$(wordcount(answer3))** words.)"

# ╔═╡ 4d3c33c8-774b-11eb-2aac-4146015c9248
members = let
	str = ""
	for (first, last) in group_members
		str *= str == "" ? "" : ", "
		str *= first * " " * last
	end
	str
end

# ╔═╡ 19b0fa00-774a-11eb-1ede-89eceed8b8ff
md"*Assignment submitted by* **$members** (*group $(group_number)*)"

# ╔═╡ cebdd63e-774a-11eb-3cd5-951c43b3c3ff
md"""
# Assignment 4: The Covid Crisis

*submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
CategoricalArrays = "324d7699-5711-5eae-9e2f-1d82baa6b597"
Chain = "8be319e6-bccf-4806-a6f7-6fae938471bc"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
GraphPlot = "a2cc645c-3eea-5389-862e-a155d0052231"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
LightGraphs = "093fc24a-ae57-5d10-9952-331d41423f4d"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
NamedArrays = "86f7a689-2022-50b4-a561-43c23ac3c673"
NetworkLayout = "46757867-2c16-5918-afeb-47bfcb05e46a"
OffsetArrays = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
UnPack = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
ZipFile = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"

[compat]
AxisKeys = "~0.1.18"
CSV = "~0.8.5"
CairoMakie = "~0.6.3"
CategoricalArrays = "~0.10.0"
Chain = "~0.4.7"
Colors = "~0.12.8"
DataFrames = "~1.2.2"
Distributions = "~0.25.11"
GraphPlot = "~0.4.4"
HTTP = "~0.9.13"
LightGraphs = "~1.3.5"
Makie = "~0.15.0"
NamedArrays = "~0.9.6"
NetworkLayout = "~0.4.0"
OffsetArrays = "~1.10.4"
PlutoUI = "~0.7.9"
SimpleWeightedGraphs = "~1.1.1"
UnPack = "~1.0.2"
XLSX = "~0.7.6"
ZipFile = "~0.9.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0-rc1"
manifest_format = "2.0"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[deps.AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "f87e559f87a45bece9c9ed97458d3afe98b1ebb9"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.1.0"

[[deps.ArrayInterface]]
deps = ["IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "2e004e61f76874d153979effc832ae53b56c20ee"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.22"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

[[deps.AxisKeys]]
deps = ["AbstractFFTs", "CovarianceEstimation", "IntervalSets", "InvertedIndices", "LazyStack", "LinearAlgebra", "NamedDims", "OffsetArrays", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "f7a17e0381cd8e627d9793433074823a2c1d7096"
uuid = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
version = "0.1.18"

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

[[deps.CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA", "StaticArrays"]
git-tree-sha1 = "7d37b0bd71e7f3397004b925927dfa8dd263439c"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.6.3"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "JSON", "Missings", "Printf", "RecipesBase", "Statistics", "StructTypes", "Unicode"]
git-tree-sha1 = "1562002780515d2573a4fb0c3715e4e57481075e"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.0"

[[deps.Chain]]
git-tree-sha1 = "c72673739e02d65990e5e068264df5afaa0b3273"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.4.7"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "bdc0937269321858ab2a4f288486cb258b9a0af7"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.3.0"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random", "StaticArrays"]
git-tree-sha1 = "ed268efe58512df8c7e224d2e170afd76dd6a417"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.13.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "32a2b8af383f11cbb65803883837a149d10dfe8a"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.10.12"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "StatsBase"]
git-tree-sha1 = "4d17724e99f357bfd32afa0a9e2dda2af31a9aea"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.8.7"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "c6461fc7c35a4bb8d00905df7adafcff1fe3a6bc"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.2"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.CovarianceEstimation]]
deps = ["LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "bc3930158d2be029e90b7c40d1371c4f54fa04db"
uuid = "587fd27a-f159-11e8-2dae-1979310e6154"
version = "0.2.6"

[[deps.Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[deps.DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4437b64df1e0adccc3e5d1adbc3ac741095e4677"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.9"

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

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "3889f646423ce91dd1055a76317e9a1d3a23fff1"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.11"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "92d8f9f208637e8d2d28c664051a00569c01493d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.1.5+1"

[[deps.EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "8041575f021cba5a099a456b4163c9a08b566a02"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

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
git-tree-sha1 = "f985af3b9f4e278b1d24434cbb546d6092fca661"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.3"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3676abafff7e4ff07bbd2c42b3d8201f31653dcc"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.9+8"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "256d8e6188f3f1ebfa1a5d17e072a0efafa8c5bf"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.10.1"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8c8eac2af06ce35973c3eadb4ab3243076a408e7"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.1"

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
git-tree-sha1 = "d51e69f0a2f8a3842bca4183b700cf3d9acce626"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "82853ebc70db4f5a3084853738c68fd497b22c7c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.3.10"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[deps.GraphPlot]]
deps = ["ArnoldiMethod", "ColorTypes", "Colors", "Compose", "DelimitedFiles", "LightGraphs", "LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "dd8f15128a91b0079dfe3f4a4a1e190e54ac7164"
uuid = "a2cc645c-3eea-5389-862e-a155d0052231"
version = "0.4.4"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "2c1cf4df419938ece72de17f368a021ee162762e"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Match", "Observables"]
git-tree-sha1 = "d44945bdc7a462fa68bb847759294669352bd0a4"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.5.7"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "44e3b40da000eab4ccb1aecdc4801c040026aeb5"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.13"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[deps.IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "db645f20b59f060d8cfae696bc9538d13fd86416"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.8.22"

[[deps.ImageIO]]
deps = ["FileIO", "Netpbm", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "d067570b4d4870a942b19d9ceacaea4fb39b69a1"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.6"

[[deps.IndirectArrays]]
git-tree-sha1 = "c2a145a145dc03a7620af1444e0264ef907bd44f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "0.5.1"

[[deps.Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[deps.IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["AxisAlgorithms", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "1e0e51692a3a77f1eeb51bf741bdd0439ed210e7"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.2"

[[deps.IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[deps.InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

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
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyStack]]
deps = ["LinearAlgebra", "NamedDims", "OffsetArrays", "Test", "ZygoteRules"]
git-tree-sha1 = "a8bf67afad3f1ee59d367267adb7c44ccac7fdee"
uuid = "1fad7336-0346-5a1a-a56f-a06ba010965b"
version = "0.0.7"

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
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

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

[[deps.LightGraphs]]
deps = ["ArnoldiMethod", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "432428df5f360964040ed60418dd5601ecd240b6"
uuid = "093fc24a-ae57-5d10-9952-331d41423f4d"
version = "1.3.5"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "LinearAlgebra"]
git-tree-sha1 = "7bd5f6565d80b6bf753738d2bc40a5dfea072070"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.2.5"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

[[deps.Makie]]
deps = ["Animations", "Artifacts", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "5761bfd21ad271efd7e134879e39a2289a032fc8"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.15.0"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "7bcc8323fb37523a6a51ade2234eee27a11114c8"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.1.3"

[[deps.MappedArrays]]
git-tree-sha1 = "18d3584eebc861e311a552cbb67723af8edff5de"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Match]]
git-tree-sha1 = "5cf525d97caf86d29307150fcba763a64eaa9cbe"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.1.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "Test"]
git-tree-sha1 = "69b565c0ca7bf9dae18498b52431f854147ecbf3"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.1.2"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

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
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[deps.NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "2fd5787125d1a93fbe30961bd841707b8a80d75b"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.9.6"

[[deps.NamedDims]]
deps = ["AbstractFFTs", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "52985b34519b12fd0dcebbe34e74b2dbe6d03183"
uuid = "356022a1-0364-5f58-8944-0da4b18d706f"
version = "0.2.35"

[[deps.Netpbm]]
deps = ["ColorVectorSpace", "FileIO", "ImageCore"]
git-tree-sha1 = "09589171688f0039f13ebe0fdcc7288f50228b52"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.1"

[[deps.NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "SparseArrays"]
git-tree-sha1 = "76bbbe01d2e582213e656688e63707d94aaadd15"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "5cc97a6f806ba1b36bac7078b866d4297ae8c463"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.4"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

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
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "520e28d4026d16dcf7b8c8140a3041f0e20a9ca8"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.7"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "f4049d379326c2c7aa875c702ad19346ecb2b004"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.1"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "59925f4ae6861cddc2313a47514b93b6740f9b6f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.9"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9bc1871464b12ed19297fbc56c4fb4ba84988b0d"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.47.0+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

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
git-tree-sha1 = "501c20a63a34ac1d015d5304da0e645f42d91c9f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.11"

[[deps.PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[deps.PolygonOps]]
git-tree-sha1 = "c031d2332c9a8e1c90eca239385815dc271abb22"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.1"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "cde4ce9d6f33219465b55162811d8de8139c0414"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

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
git-tree-sha1 = "12fbe86da16df6679be7521dfb39fbc861e1dc7b"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
git-tree-sha1 = "37d210f612d70f3f7d57d488cb3b6eff56ad4e41"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.0"

[[deps.RecipesBase]]
git-tree-sha1 = "b3fb709f3c97bfc6e948be68beeecb55a0b340ae"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.1"

[[deps.Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

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
git-tree-sha1 = "9ba33637b24341aba594a2783a502760aa0bff04"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.3.1"

[[deps.ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "9cc2955f2a254b18be655a4ee70bc4031b2b189e"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "a3a337914a035b2d59c9cbe7f1a38aaba1265b02"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.6"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

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
deps = ["LightGraphs", "LinearAlgebra", "Markdown", "SparseArrays", "Test"]
git-tree-sha1 = "f3f7396c2d5e9d4752357894889a87340262f904"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.1.1"

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
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "508822dca004bf62e210609148511ad03ce8f1d8"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.0"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "62701892d172a2fa41a1f829f66d2b0db94a9a63"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.3.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3fedeffc02e47d6e3eb479150c8e5cd8f15a77a0"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.10"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "fed1ec1e65749c4d96fc20dd13bea72b55457e62"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.9"

[[deps.StatsFuns]]
deps = ["LogExpFunctions", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "30cd8c360c54081f806b1ee14d2eecbef3c04c49"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.8"

[[deps.StructArrays]]
deps = ["DataAPI", "Tables"]
git-tree-sha1 = "ad1f5fd155426dcc879ec6ede9f74eb3a2d582df"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.4.2"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "e36adc471280e8b346ea24c5c87ba0571204be7a"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.7.2"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

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
git-tree-sha1 = "d0c690d37c73aeb5ca063056283fde5585a41710"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "OrderedCollections", "PkgVersion", "ProgressMeter"]
git-tree-sha1 = "03fb246ac6e6b7cb7abac3b3302447d55b43270e"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.4.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "7c53c35547de1c5b9d46a4797cf6d8253807108c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.5"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "59e2ad8fd1591ea019a5259bd012d7aee15f995c"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.3"

[[deps.XLSX]]
deps = ["Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "7744a996cdd07b05f58392eb1318bca0c4cc1dc7"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.7.6"

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

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "c3a5637e27e914a7a445b8d0ad063d701931e9f7"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "9e7a1e8ca60b742e508a315c17eef5211e7fbfd7"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.1"

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
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

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
# ╟─55a868c8-0614-4074-9389-c957cf64cb20
# ╟─38f5d048-7747-11eb-30f7-89bade5ed0a3
# ╟─19b0fa00-774a-11eb-1ede-89eceed8b8ff
# ╟─f1749b26-774b-11eb-2b42-43ffcb5cd7ee
# ╟─a771e504-77aa-11eb-199c-8778965769b6
# ╠═94375d0e-77aa-11eb-3934-edb020ab0fd7
# ╟─cb75f8ac-77aa-11eb-041c-4b3fe85ec22b
# ╠═76e6f44e-77aa-11eb-1f12-438937941606
# ╟─9b47991e-7c3d-11eb-1558-b5824ab10dc0
# ╠═d772a28a-7c3d-11eb-012f-9b81ad67f9a8
# ╟─d9465a80-7750-11eb-2dd5-d3052d3d5c50
# ╟─cf680c48-7769-11eb-281c-d7a2d5ec8fe5
# ╠═cbc03264-7769-11eb-345a-71ae30cc7526
# ╟─dd41fe96-7769-11eb-06a6-3d6298f6e6fc
# ╠═278c829c-7767-11eb-1d04-cb38ee52b79b
# ╟─128bb9e8-776a-11eb-3786-83531bd2dffb
# ╠═5d85143c-7765-11eb-1a1c-29f3421fe857
# ╠═280e8390-776a-11eb-0aed-19b0ba929c84
# ╠═22c3abde-7767-11eb-0b6f-93ad1055bbae
# ╠═44929fe0-7767-11eb-0318-e720b844f710
# ╠═f6144074-7768-11eb-3624-51bbc44be7ec
# ╟─f65f7f8c-7769-11eb-3399-79bde01513cd
# ╠═bd27268e-7766-11eb-076b-71688ecb4ae3
# ╠═d9fd6bb0-7766-11eb-150b-410bb7d09d20
# ╟─04e731d0-7751-11eb-21fd-e7f9b022cdc9
# ╠═775f99b8-77a9-11eb-2ebf-7bbe0d398306
# ╠═6cec81a0-77ac-11eb-06e3-bd9dcb73a896
# ╠═834669c4-776c-11eb-29b7-77dc465077d7
# ╠═b43f6b02-776c-11eb-2685-655705eb1681
# ╠═ffdbb91c-776c-11eb-3b28-51314d40f7a2
# ╠═5c2ef34e-776f-11eb-2a6f-ff99b5d24997
# ╠═958f9f3e-77ac-11eb-323c-cd78c1fe4c23
# ╟─5aff086a-7751-11eb-039e-fd1b769b6fea
# ╠═2e7630ee-7770-11eb-32ae-112b4b282eaf
# ╠═4341e8cc-7770-11eb-04d5-c5d33d9a9e52
# ╠═486d0372-7770-11eb-1956-1d3314be6753
# ╠═4e17451a-7770-11eb-3c41-6d98b73d410b
# ╠═56a4c272-7770-11eb-0626-131942edd52d
# ╠═5bb435cc-7770-11eb-33b6-cb78835406bc
# ╠═5dbcbd44-7770-11eb-0f60-f74a9945477e
# ╠═6378c2aa-7770-11eb-3edc-9d41e709750e
# ╠═6ca12836-7770-11eb-271f-354367f89cb0
# ╟─c2842ace-7751-11eb-240f-550286e812af
# ╠═bc30e12a-7770-11eb-3db2-b753ec458ce5
# ╠═b48335da-7771-11eb-2b17-1507687e446c
# ╠═9a89d9b4-7772-11eb-0c86-9b5f5f1ab23e
# ╠═7db9fa00-7773-11eb-0942-ed884b67533c
# ╠═36334032-7774-11eb-170f-5b7f9b7e0ec7
# ╠═3843a2c2-7774-11eb-1bf5-5178a9014ae2
# ╠═f534c32c-7772-11eb-201c-233b5b7a27a4
# ╠═95f4f0d0-7772-11eb-1b2a-d179e76950fe
# ╠═15334fc2-7773-11eb-303e-67e90901f850
# ╠═939fa06e-7772-11eb-086c-ff1bf54525f1
# ╠═50194494-7772-11eb-20ff-419e874ec00c
# ╟─cbb1e550-7751-11eb-1313-7ff968453f36
# ╠═8212939e-7770-11eb-1f4e-9b698be25d1f
# ╠═9aa77c76-7770-11eb-35ed-9b83924e8176
# ╟─ee72ef4c-7751-11eb-1781-6f4d027a9e66
# ╠═3585b022-7853-11eb-1a05-7b4fe3921051
# ╠═ddfcd760-7853-11eb-38f7-298a4c1cb5aa
# ╟─d0630e36-774b-11eb-0750-370f1b1327e6
# ╠═29f570c0-774b-11eb-2c1c-17a956c9fd27
# ╠═2fa2a558-774b-11eb-396b-832d0ce9a130
# ╟─3cd55fca-774b-11eb-307a-61b685db1b54
# ╟─cebdd63e-774a-11eb-3cd5-951c43b3c3ff
# ╟─04e5b93a-77ae-11eb-0240-ad7517f0fde3
# ╠═5df355b6-77b1-11eb-120f-9bb529b208df
# ╠═664efcec-77b1-11eb-2301-5da84a5de423
# ╠═ebfcbb8e-77ae-11eb-37fc-e798175197d0
# ╟─85e7546c-77ae-11eb-0d0c-618c3669c903
# ╠═811e741e-77b1-11eb-000e-93a9a19a9f60
# ╠═9298e2de-77b1-11eb-0a56-1f50bb0f4dc3
# ╠═3ec33a62-77b1-11eb-0821-e547d1422e6f
# ╠═4359dbee-77b1-11eb-3755-e1c1532212bb
# ╠═45db03f2-77b1-11eb-2edd-6104bc85915b
# ╠═486cd850-77b1-11eb-1dd2-15ca68d98173
# ╠═ea1afdc0-77b4-11eb-1c7a-2f92bbdb83a6
# ╟─4e891b56-77b1-11eb-116d-e94250f1d70e
# ╟─48f0ffd4-77b0-11eb-04ab-43eac927ac9d
# ╠═9fb0a0a8-77b1-11eb-011f-7fc7a549f552
# ╠═9da09070-77b1-11eb-0d2e-e9a4433bf34e
# ╟─24c076d2-774a-11eb-2412-f3747af382a2
# ╟─7122605e-7753-11eb-09b8-4f0066353d17
# ╠═b223523e-7753-11eb-1d9a-67c0281ae473
# ╟─356d2016-7754-11eb-2e6f-07d1c12831b5
# ╠═12798090-7754-11eb-3fdf-852bc740ed2a
# ╟─ad8a6380-7755-11eb-1542-9972c0daa480
# ╠═5bbac0ac-7754-11eb-0ec0-7d564524afe6
# ╟─724dc756-7754-11eb-3a22-a309a77b2f28
# ╠═75b9fd42-7754-11eb-3219-c57ef876f04b
# ╟─7658c6d2-7754-11eb-32a9-41bf10cd7f6b
# ╠═ade0d2f4-7754-11eb-2693-074c67837de3
# ╟─83bdf67e-7753-11eb-06a2-cf39291d8a87
# ╠═0fe4809c-7758-11eb-2569-33b178bfccca
# ╠═6197cf52-7758-11eb-2c66-b7df9d59cbf7
# ╠═c312d5d6-775a-11eb-24cd-f1cf36f3dd40
# ╟─48dc654c-7765-11eb-313a-c598a7d09fb7
# ╠═d6a23266-7757-11eb-346c-534caaf657fb
# ╟─66d81066-7772-11eb-21f3-9568518636c2
# ╠═bb783ac4-7772-11eb-365a-1fd1b6847e27
# ╠═cb5e1b02-7772-11eb-2d21-dfe6c49aa7d0
# ╠═c3b13010-7772-11eb-0ba3-0d82c76c6a49
# ╟─42b21fce-774a-11eb-2d00-c3bfd55a35fc
# ╠═6526d6e4-774a-11eb-0b7a-bd644b5f7fea
# ╟─5a931c10-774a-11eb-05cb-d7ed3da85835
# ╠═579444bc-774a-11eb-1d80-0557b12da169
# ╠═8cf29922-7759-11eb-3584-6d0d967b83b7
# ╟─4779bd0a-774a-11eb-2548-038fcb0f7644
# ╠═4a355496-774a-11eb-0bd2-b36814663229
# ╠═47b5833e-774b-11eb-2209-cfa172c6425f
# ╠═4d3c33c8-774b-11eb-2aac-4146015c9248
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
