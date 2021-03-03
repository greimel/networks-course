### A Pluto.jl notebook ###
# v0.12.21

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
	_a_ = 1 # cell #1
	
	using Pkg
	Pkg.activate(temp = true)
	
	Pkg.add(PackageSpec(name = "PlutoUI", version = "0.6.11-0.6"))
	using PlutoUI: TableOfContents, Slider, CheckBox
	
	Pkg.add([
		PackageSpec(name = "AbstractPlotting",  version = "0.15"),
		PackageSpec(name = "AxisKeys",        ),
			PackageSpec(name = "NamedArrays",        ),			
		PackageSpec(name = "CairoMakie",        version = "0.3"),
		PackageSpec(name = "CategoricalArrays", version = "0.9"),
		PackageSpec(name = "Colors",            version = "0.12"),
		PackageSpec(name = "Chain",             version = "0.4"),
		PackageSpec(name = "CSV",               version = "0.8"),
		PackageSpec(name = "HTTP",              version = "0.9"),			
		PackageSpec(name = "DataFrames",        version = "0.22"),			
		PackageSpec(name = "DataAPI",           version = "1.4"),
		PackageSpec(name = "LightGraphs",       version = "1.3"),
		PackageSpec(name = "UnPack",            version = "1"),
		PackageSpec(name = "XLSX",              version = "0.7"),
		PackageSpec(name = "ZipFile",           version = "0.9"),
		PackageSpec(name = "SimpleWeightedGraphs",version="1.1"),
			#Pkg.PackageSpec(name="Cairo", ),
			#Pkg.PackageSpec(name="Compose", ),
			#Pkg.PackageSpec(name="Images", ),
			#Pkg.PackageSpec(name="ImageIO", ),
			Pkg.PackageSpec(name="Downloads", ),
			Pkg.PackageSpec(name="Distributions", ),
			
			
		#PackageSpec(name = "Plots", version = "1.10"),	
			])
	
	Pkg.add(["GraphPlot", "NetworkLayout", "OffsetArrays"])
	using GraphPlot, NetworkLayout, OffsetArrays
	
	using Statistics: mean
	using SparseArrays#: sparse
	using LinearAlgebra: I, dot, diag, Diagonal, norm
	import Downloads
	
	import CairoMakie
	CairoMakie.activate!(type = "png")
	
	using AbstractPlotting#: 	
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
	_b_ = _a_ + 1 # cell #2
	nothing
	
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

# ╔═╡ 38f5d048-7747-11eb-30f7-89bade5ed0a3
md"""
`production.jl` | **Version 1.2** | *last updated: Mar 3*
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
	
	col = AbstractPlotting.wong_colors
	
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
	
	col = AbstractPlotting.wong_colors
	
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
	
	node_positions = NetworkLayout.Spring.layout(wgt)
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
		lines!(ax, collect(axes(production, 2)), parent(production[i,:]), color = AbstractPlotting.wong_colors[rem(i, 7) + 1])
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

# ╔═╡ 346fd998-77ad-11eb-0c0a-83a1290795af
function gplot_to_png(gp::Compose.Context)
	filename = tempname() * ".png"
	gp |> Compose.PNG(filename)
	Images.load(filename)
end

# ╔═╡ Cell order:
# ╟─38f5d048-7747-11eb-30f7-89bade5ed0a3
# ╟─19b0fa00-774a-11eb-1ede-89eceed8b8ff
# ╟─f1749b26-774b-11eb-2b42-43ffcb5cd7ee
# ╟─a771e504-77aa-11eb-199c-8778965769b6
# ╠═94375d0e-77aa-11eb-3934-edb020ab0fd7
# ╟─cb75f8ac-77aa-11eb-041c-4b3fe85ec22b
# ╠═76e6f44e-77aa-11eb-1f12-438937941606
# ╠═9b47991e-7c3d-11eb-1558-b5824ab10dc0
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
# ╠═346fd998-77ad-11eb-0c0a-83a1290795af
