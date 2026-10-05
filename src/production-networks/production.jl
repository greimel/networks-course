### A Pluto.jl notebook ###
# v1.0.4

#> [frontmatter]
#> chapter = 6
#> section = 1
#> order = 1
#> title = "The economy as a network of sectors"
#> layout = "layout.jlhtml"
#> tags = ["production-networks"]
#> description = ""

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ a09cb7a6-17e4-4570-ae0b-8104c39bbc24
using SimpleWeightedGraphs

# ╔═╡ 773c5304-4165-433c-bd33-f41d3fb9856a
using PlutoUI: TableOfContents, Slider, CheckBox, as_svg

# ╔═╡ f8116e43-37f6-4c28-ab62-85aab79ff986
using CairoMakie.Makie.MathTeXEngine: texfont

# ╔═╡ 790e88cb-f6e8-43ae-99b8-876f3abbd3a2
using DataFrameMacros

# ╔═╡ e87a3bc3-9dd9-4af3-baf0-fba7d3ccfdc9
using DataFrames

# ╔═╡ f6de4c5a-7d3f-417b-bd5c-1d793e937307
using Chain: @chain

# ╔═╡ 6526d6e4-774a-11eb-0b7a-bd644b5f7fea
begin
	using OffsetArrays
	
	using Statistics: mean
	using SparseArrays#: sparse
	using LinearAlgebra: I, dot, diag, Diagonal, norm
	import Downloads
	
	using Distributions
	using AxisKeys: KeyedArray
	using NamedArrays: NamedArray
	using CategoricalArrays: cut
	using Colors: RGBA
end

# ╔═╡ a5b8d51f-22d2-48f7-840e-41c154528d36
using GraphMakie, CairoMakie

# ╔═╡ 59576485-57a5-4efc-838e-b4edf27eb420
using AlgebraOfGraphics

# ╔═╡ 0d80d4ce-f720-4325-8255-8110f0bcb15e
using NetworkLayout

# ╔═╡ 579444bc-774a-11eb-1d80-0557b12da169
begin	
	using Graphs
	using SimpleWeightedGraphs: AbstractSimpleWeightedGraph, SimpleWeightedDiGraph
	const LG = Graphs
	
	function weighted_adjacency_matrix(graph::Graphs.AbstractGraph; dir = :in)
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
		eig = LG.eigs(A, which=LG.LM(), nev=1)
		eigenvector = eig[2]
	
		centrality = abs.(vec(eigenvector))
	end
	
	LG.indegree(graph::AbstractSimpleWeightedGraph) = sum(weighted_adjacency_matrix(graph), dims = 1) # column sum
	LG.outdegree(graph::AbstractSimpleWeightedGraph) = sum(weighted_adjacency_matrix(graph), dims = 2) # row sum
		
end

# ╔═╡ 4a054faa-6d3b-4c50-89fa-12843546cc76
using PlutoTest: @test

# ╔═╡ 38f5d048-7747-11eb-30f7-89bade5ed0a3
md"""
`production.jl` | **Version 1.8** | *content updated: 10 Mar 2023, packages updated: 4 Oct 2026*
"""

# ╔═╡ f1749b26-774b-11eb-2b42-43ffcb5cd7ee
md"""
# The Economy as a Network of Sectors

Here is what we will cover.

_Part A -- **Shock Propagation in an Input-Output Network**_ \
based on _[Long & Plosser (1983)](https://www.jstor.org/stable/1840430), Journal of Political Economy_ and _[Carvalho (2014)](https://www.aeaweb.org/articles.php?doi=10.1257/jep.28.4.23), Journal of Economic Perspectives_.

1. Introduce Input-Output Tables. Re-interpret them as a network of economic sectors connected by input-output linkages
2. Visualize and analyze this *intersectoral network*
3. Simulate the *dynamic* production network model of [Long & Plosser (1983)](https://www.jstor.org/stable/1840430) \
   (Visualize propagation of shocks | discuss the role of centrality)

_Part B -- **Network Origins of Aggregate Fluctuations**_ \
based on _[Acemoglu, Carvalho, Ozdaglar & Tahbaz-Salehi (2012)](https://economics.mit.edu/files/8135), Econometrica_

4. Solve the *static* production network model of [Acemoglu, Carvalho, Ozdaglar & Tahbaz-Salehi (2012)](https://economics.mit.edu/files/8135)--_see the lecture notes_
5. Show that sector-specific shocks don't necessarily wash out in equilibrium--_see the lecture notes_ 
6. Show by simulation that iid industry-specific shocks will lead to aggregate flucuations

#### Exercises

7. Simulate how the Covid shocks propagates through the economy


#### Additional Reading

* **What if? The Economic Effects for Germany of a Stop of Energy Imports from Russia** *(Bachmann, Baqaee, Bayer, Kuhn, Löschel, Moll, Peichl, Pittel & Schularick, 2022)*
* **Micro Propagation and Macro Aggregation** *(Baqaee & Rubbo, 2022)* 
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
# 1. Input-Output Tables: *Production Recipes* for the Economy
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

# ╔═╡ 280e8390-776a-11eb-0aed-19b0ba929c84
#graphplot(SimpleWeightedDiGraph(wgts'))

# ╔═╡ f65f7f8c-7769-11eb-3399-79bde01513cd
md"""
#### Important industries
"""

# ╔═╡ 04e731d0-7751-11eb-21fd-e7f9b022cdc9
md"""
# 2. Analyzing the *Intersectoral Network* 

Recall, ``G = W'``. Also, in order to satisfy the assumptions of the model, we have to normalize the row sums to 1.
"""

# ╔═╡ 5aff086a-7751-11eb-039e-fd1b769b6fea
md"""
# 3. Simulating a *Dynamic* Production Network Model

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
	(; α, β, θ, θ₀, H) = param
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
	(; α, β) = param
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

# ╔═╡ 15334fc2-7773-11eb-303e-67e90901f850
begin
	AA = weighted_adjacency_matrix(grph) |> Matrix |> transpose
	param = params(AA)
	
	(; production) = impulse_response(10, AA, param, [1], -0.3, T_shock = 0:2)
	
	color_extr = extrema(production)
end

# ╔═╡ 36334032-7774-11eb-170f-5b7f9b7e0ec7
t_range = axes(production, 2) |> x -> range(first(x), last(x), step=step(x))

# ╔═╡ f534c32c-7772-11eb-201c-233b5b7a27a4
md"""
``t``: $(@bind t Slider(t_range, default = 1, show_value = true))
"""

# ╔═╡ cbb1e550-7751-11eb-1313-7ff968453f36
md"""
## Big Network from Input-Output Tables
"""

# ╔═╡ 4595d42a-8f0b-42e6-ab5c-f829a0ad2933
md"""
#### 4. & 5. see lecture notes
"""

# ╔═╡ ee72ef4c-7751-11eb-1781-6f4d027a9e66
md"""
# 6. Network Origins of Aggregate Fluctuations

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

# ╔═╡ cebdd63e-774a-11eb-3cd5-951c43b3c3ff
md"""
# 7. Assignment: The Covid Crisis
"""

# ╔═╡ 04e5b93a-77ae-11eb-0240-ad7517f0fde3
md"""
For this problem set you will simulate a Covid crisis using the model from the lecture.

### Task 1: Which industries were hit by Covid? (3 points)

Find 5 (groups of) industries that were hit by the Corona crisis *directly* (that is, not through propagation within the production network.)

You can look through the industry definitions in `df_nodes1` (below) or go to [the BEA website](https://www.bea.gov/data/industries).

👉 Put the codes of these industries into the `hit_industries` vector below.
"""

# ╔═╡ 2f672417-ab56-4e7b-b7b4-88655c2404c8
hit_industries = ["111200", "111300"]

# ╔═╡ 23100fcb-8118-471e-8dd8-47da26a981ae
md"""
👉 Explain your choice. _(< 300 words)_
"""

# ╔═╡ 5df355b6-77b1-11eb-120f-9bb529b208df
answer1 = md"""
Your answer goes here ...
"""

# ╔═╡ 85e7546c-77ae-11eb-0d0c-618c3669c903
md"""
### Task 2: Simulate a Covid crisis (4 points)

👉 By putting your selected industries into the `hit_industries` vector in **Task 1**, you have already simulated the Covid crisis. You can adjust the length of the shock (assume a period is a quarter) and the magnitude of the shock.

* Duration of the shock: $(@bind shock_duration Slider(1:10, default = 2, show_value = true))
* Magnitude of the shock: $(@bind shock_size Slider(0.1:0.1:2.0, default = 0.5, show_value = true))
"""

# ╔═╡ c3472d5b-c03e-4ff2-8cf9-bb0932ceb064
md"""
👉 Explain your findings in <200 words. Think about how much of the welfare loss is due to the directly hit industries, how much is due to network effects?
"""

# ╔═╡ 811e741e-77b1-11eb-000e-93a9a19a9f60
answer2 = md"""
Your answer goes here ...
"""

# ╔═╡ 48f0ffd4-77b0-11eb-04ab-43eac927ac9d
md"""
### Task 3: Is this model suitable for this exercise? (3 points)

👉 Explain in <200 words how well you think that the model simulation can capture the real-world Covid crisis?
"""

# ╔═╡ 9fb0a0a8-77b1-11eb-011f-7fc7a549f552
answer3 = md"""
Your answer goes here ...
"""

# ╔═╡ 8142a702-f442-4652-a004-602527c1a14d
md"""
### Before you submit ...

👉 Make sure you have added **your names** and **your group number** in the cells below.

👉 Make sure that that **all group members proofread** your submission (especially your little essays).

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. (The source code is embedded in the html file.)
"""

# ╔═╡ d8edddf9-0f24-4efe-88d0-ed10c84e8ce8
group_number = 99

# ╔═╡ 622a2e9c-495b-43d1-b976-1743f28ff84a
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ 24c076d2-774a-11eb-2412-f3747af382a2
md"""
# Appendix
"""

# ╔═╡ 3d47962f-958d-4729-bc20-e2bb5ab3e1e1
TableOfContents()

# ╔═╡ fe87f804-b3b6-4b6c-97cc-4a61e1b30eb1
fonts = (regular = texfont(), bold = texfont(:bold), italic = texfont(:italic))

# ╔═╡ 79d44149-c6f4-440e-8675-0574fad98a50
#fig_attr(; size = (350, 300)) = (; figure_padding=3, fonts, size)

# ╔═╡ de7f1884-c549-401e-85c1-4c1ba5774826
fig_attr(xscale=1, yscale=xscale) = (; figure_padding=3, size = (xscale * 200, yscale * 200), fonts)

# ╔═╡ 0a5e66ac-e64c-4734-8cb2-51fdf60e4bb9
minimal(; extend_limits=0.1, hidespines=true, kwargs...) = (; 
	xgridvisible=false, xticksvisible=false, xticklabelsvisible=false,
	ygridvisible=false, yticksvisible=false, yticklabelsvisible=false, 
	leftspinevisible=!hidespines, rightspinevisible=!hidespines, topspinevisible=!hidespines, bottomspinevisible=!hidespines,
	xautolimitmargin = (extend_limits, extend_limits),
	yautolimitmargin = (extend_limits, extend_limits),
	kwargs...
)

# ╔═╡ 50194494-7772-11eb-20ff-419e874ec00c
fig = let
	g = grph
	#wgt = Matrix(weights(graph) .* adjacency_matrix(graph)) 	
	#wg = SimpleWeightedDiGraph(wgt)
	
	fig = Figure(; fig_attr(2.5, 1.25)...)

	node_color = parent(production[:,t])

	graphplot(fig[1,1][1,1],
		g;
		ilabels = vertices(g),
		layout = Spring(),
		node_color,
		node_attr = (; colorrange = color_extr),
		edge_color = :gray,
		axis = minimal(hidespines=false, alignmode = Inside())
	)
	
	Colorbar(fig[1,2]; limits = color_extr)
	
	ax2 = Axis(fig[1,3], xlabel = L"t", alignmode = Inside())
	
	for i in 1:nv(g)
		lines!(ax2, collect(axes(production, 2)), parent(production[i,:]))
		vlines!(ax2, t, linestyle = :dash, color = :gray)
	end

	Label(fig[0,:], "Shock transmission in a production network")
	fig
end;

# ╔═╡ 94375d0e-77aa-11eb-3934-edb020ab0fd7
fig

# ╔═╡ 95f4f0d0-7772-11eb-1b2a-d179e76950fe
fig

# ╔═╡ 7122605e-7753-11eb-09b8-4f0066353d17
md"""
## Downloading the Input-Output Table for the US
"""

# ╔═╡ 356d2016-7754-11eb-2e6f-07d1c12831b5
md"""
Data is usually messy. Here is some evidence.
"""

# ╔═╡ ad8a6380-7755-11eb-1542-9972c0daa480
md"""
**The vector of input industries is not the vector of output industries.**
"""

# ╔═╡ 724dc756-7754-11eb-3a22-a309a77b2f28
md"""
Here are the industries that are *only outputs*.
"""

# ╔═╡ 7658c6d2-7754-11eb-32a9-41bf10cd7f6b
md"""
Here are the industries that are *only inputs*.
"""

# ╔═╡ 83bdf67e-7753-11eb-06a2-cf39291d8a87
md"""
## Cleaning the Input-Output Table
"""

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

# ╔═╡ 48dc654c-7765-11eb-313a-c598a7d09fb7
md"""
## List of Sectors
"""

# ╔═╡ 42b21fce-774a-11eb-2d00-c3bfd55a35fc
md"""
## Package Environment
"""

# ╔═╡ ec2a87fa-09a8-449f-8e32-37a97a754a75
import CSV, HTTP, ZipFile, XLSX

# ╔═╡ b223523e-7753-11eb-1d9a-67c0281ae473
begin
	url = "https://apps.bea.gov/industry/xls/io-annual/CxI_DR_2007_2012_DOM_DET.xlsx"
	file = Downloads.download(url)
	f = XLSX.readxlsx(file)
	sh = f["2007"]
end

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

# ╔═╡ 5bbac0ac-7754-11eb-0ec0-7d564524afe6
all(code_column .== code_row)

# ╔═╡ 75b9fd42-7754-11eb-3219-c57ef876f04b
out_not_in = @chain df_out begin
	filter(:code => !in(df_in.code), _)
    select(:code, :name)
end

# ╔═╡ ade0d2f4-7754-11eb-2693-074c67837de3
in_not_out = @chain df_in begin
	subset(:code => ByRow(x -> x ∉ df_out.code))
	#@subset(:code ∈ [df_out.code])
	#filter(:code => !in(df_out.code), _)
    select([:code, :name])
end

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
	@subset!(io_edges0, :value > 0)
end

# ╔═╡ 5d85143c-7765-11eb-1a1c-29f3421fe857
begin
	node_names, wgts = nodes_weights_from_edges(io_edges0, :input, :output, :value)
	droptol!(wgts, 0.0)
	
	node_names, wgts
end;

# ╔═╡ 0f0c1661-30e2-47de-b6f0-dbb85f6dae5f
sum(wgts .> 0) / (403^2)

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
	#sorted_nodes = sortperm(outdegree_centrality(network)[:], rev = true)
	#sorted_nodes = sortperm(katz_centrality(network)[:], rev = true)
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
	
	fig = Figure(; fig_attr(1.4, 1.2)...)
	
	ax = Axis(fig[1,1], title = "Welfare loss after shock\nto different industries")
	
	for (i, nodes) in enumerate(nodes_vec)
		(; welfare) = impulse_response(10, A, params(A), nodes[1], -0.5, T_shock = 0:2)
		lines!(ax, collect(axes(welfare, 1)), parent(welfare), label = nodes[2] * " $(length(nodes[1]))")
	end
	
	axislegend(ax, position = :rb)

	fig
end

# ╔═╡ 76e6f44e-77aa-11eb-1f12-438937941606
fig_welfare

# ╔═╡ 834669c4-776c-11eb-29b7-77dc465077d7
begin
	wgts_n = wgts ./ sum(wgts, dims=2) |> dropzeros!
	network_n = SimpleWeightedDiGraph(wgts_n')
	extrema(wgts_n)
end

# ╔═╡ 5c2ef34e-776f-11eb-2a6f-ff99b5d24997
unweighted_network = SimpleDiGraph(wgts .> 0.01)

# ╔═╡ d6a23266-7757-11eb-346c-534caaf657fb
begin
	df_all = outerjoin(df_in, df_out, on = [:code, :name])
	n_rows = size(df_all, 1)
	
	@assert length(unique(df_all.code)) == n_rows
	@assert length(unique(df_all.name)) == n_rows
	
	df_all
end

# ╔═╡ cbc03264-7769-11eb-345a-71ae30cc7526
@subset(df_all, :code ∈ node_names)

# ╔═╡ bd27268e-7766-11eb-076b-71688ecb4ae3
begin
	df_nodes = @subset(df_all, :code ∈ node_names)
	df_nodes.inputs_used    = sum(wgts, dims=2) |> vec
	df_nodes.used_as_input = sum(wgts, dims=1) |> vec
	@transform!(df_nodes, :node_id = @bycol 1:length(:code))
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
sort(df_nodes1, :eigv_c, rev = true)

# ╔═╡ ebfcbb8e-77ae-11eb-37fc-e798175197d0
df_nodes1

# ╔═╡ 2b54193b-ed2e-4f22-bdfb-e95f0a274812
hit_nodes_df = @subset(df_nodes, :code ∈ hit_industries)

# ╔═╡ ea1afdc0-77b4-11eb-1c7a-2f92bbdb83a6
fig_covid = let
	hit_nodes = hit_nodes_df.node_id
	n_hit = length(hit_nodes)
	
	nodes_vec = [bot_n[1:n_hit] => "bottom", top_n[1:n_hit] => "top", hit_nodes => "Covid"]
	
	A = weighted_adjacency_matrix(network)'
	
	fig = Figure(; fig_attr(1.5, 1)...)
		
	ax = Axis(fig[1,1], title = "Welfare loss after shock\nto different industries")
	
	for (i, nodes) in enumerate(nodes_vec)
		(; welfare) = impulse_response(10, A, params(A), nodes[1], -shock_size, T_shock = 0:shock_duration)
		lines!(ax, collect(axes(welfare, 1)), parent(welfare), label = nodes[2] * " $(length(nodes[1]))")
	end
	
	axislegend(ax, position = :rb)#(fig[1,2], ax)

	fig
end

# ╔═╡ be81874a-f60a-45b5-8855-1a77f50227d2
md"""
### Plotting
"""

# ╔═╡ 5a931c10-774a-11eb-05cb-d7ed3da85835
md"""
## Patch 1: Weights and Centralities
"""

# ╔═╡ 39f2fdd5-27bb-40c0-a8c0-1bb90aeaccf7
md"""
## Assignment infrastructure
"""

# ╔═╡ 7a2980a0-77cf-42cf-a79d-93e1686ff2d8
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
end

# ╔═╡ 6a87bbe9-6e4b-4802-998f-e0517b11bc7e
function wordcount(text)
	stripped_text = strip(replace(string(text), r"\s" => " "))
   	words = split(stripped_text, (' ', '-', '.', ',', ':', '_', '"', ';', '!', '\''))
   	length(filter(!=(""), words))
end

# ╔═╡ 7a9cc068-8469-4f8d-bfa1-c49101c4dc23
@test wordcount("  Hello,---it's me.  ") == 4

# ╔═╡ 4a3d7e25-a941-486b-a1f8-8f7d563468d3
@test wordcount("This;doesn't really matter.") == 5

# ╔═╡ 1f7d4622-d3ed-4bcb-a655-289cbcaa62a6
show_words(answer) = md"_approximately $(wordcount(answer)) words_"

# ╔═╡ 664efcec-77b1-11eb-2301-5da84a5de423
show_words(answer1)

# ╔═╡ 03f290eb-b8ca-4ef1-a029-98f07723485a
function show_words_limit(answer, limit)
	count = wordcount(answer)
	if count ≤ 1.1 * limit
		return show_words(answer)
	else
		return almost(md"You are at $count words. Please shorten your text a bit, to get **below $limit words**.")
	end
end

# ╔═╡ 9298e2de-77b1-11eb-0a56-1f50bb0f4dc3
show_words_limit(answer2, 200)

# ╔═╡ 9da09070-77b1-11eb-0d2e-e9a4433bf34e
show_words_limit(answer3, 200)

# ╔═╡ ae9b740b-d0a6-46b0-a548-672a72f92e45
members = let
	names = map(group_members) do (; firstname, lastname)
		firstname * " " * lastname
	end
	join(names, ", ", " & ")
end

# ╔═╡ 2c840e2e-9bfa-4a5f-9be2-a29d8cdf328d
md"""
*submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[compat]
AlgebraOfGraphics = "~0.13.2"
AxisKeys = "~0.2.17"
CSV = "~0.10.17"
CairoMakie = "~0.15.15"
CategoricalArrays = "~1.1.1"
Chain = "~1.0.0"
Colors = "~0.13.2"
DataFrameMacros = "~0.4.1"
DataFrames = "~1.8.2"
Distributions = "~0.25.131"
GraphMakie = "~0.6.6"
Graphs = "~1.15.0"
HTTP = "~1.11.0"
NamedArrays = "~0.10.5"
NetworkLayout = "~0.4.11"
OffsetArrays = "~1.17.0"
PlutoTest = "~0.2.4"
PlutoUI = "~0.7.83"
SimpleWeightedGraphs = "~1.5.1"
XLSX = "~0.13.0"
ZipFile = "~0.10.1"

[deps]
AlgebraOfGraphics = "cbdf2221-f076-402e-a563-3d30da359d67"
AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
CategoricalArrays = "324d7699-5711-5eae-9e2f-1d82baa6b597"
Chain = "8be319e6-bccf-4806-a6f7-6fae938471bc"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
DataFrameMacros = "75880514-38bc-4a95-a458-c2aea5a3a702"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
GraphMakie = "1ecd5474-83a3-4783-bb4f-06765db800d2"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
NamedArrays = "86f7a689-2022-50b4-a561-43c23ac3c673"
NetworkLayout = "46757867-2c16-5918-afeb-47bfcb05e46a"
OffsetArrays = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
ZipFile = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.9"
manifest_format = "2.0"
project_hash = "43a78ccc4a35a6bca8eb83a3f795225a7b2698e2"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "7063ad1083578215c7c4bf410368150abe8d5524"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.45"
weakdeps = ["AxisKeys", "IntervalSets", "LinearAlgebra", "StaticArrays", "StructArrays", "Test", "Unitful"]

    [deps.Accessors.extensions]
    AxisKeysExt = "AxisKeys"
    IntervalSetsExt = "IntervalSets"
    LinearAlgebraExt = "LinearAlgebra"
    StaticArraysExt = "StaticArrays"
    StructArraysExt = "StructArrays"
    TestExt = "Test"
    UnitfulExt = "Unitful"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "7c2c19b5a26e601634bf718490b89d59685f122e"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.7.1"
weakdeps = ["SparseArrays", "StaticArrays"]

    [deps.Adapt.extensions]
    AdaptSparseArraysExt = "SparseArrays"
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AdaptivePredicates]]
git-tree-sha1 = "7e651ea8d262d2d74ce75fdf47c4d63c07dba7a6"
uuid = "35492f91-a3bd-45ad-95db-fcad7dcfedb7"
version = "1.2.0"

[[deps.AlgebraOfGraphics]]
deps = ["Accessors", "Colors", "DataAPI", "Dates", "Dictionaries", "FileIO", "GLM", "GeoInterface", "GeometryBasics", "GridLayoutBase", "Isoband", "KernelDensity", "Loess", "Makie", "NaturalSort", "PlotUtils", "PolygonOps", "PooledArrays", "PrecompileTools", "RelocatableFolders", "StatsBase", "StructArrays", "Tables"]
git-tree-sha1 = "88b1f363a4c69268ab705bcb5a049768a367bed9"
uuid = "cbdf2221-f076-402e-a563-3d30da359d67"
version = "0.13.2"

    [deps.AlgebraOfGraphics.extensions]
    AlgebraOfGraphicsDynamicQuantitiesExt = "DynamicQuantities"
    AlgebraOfGraphicsUnitfulExt = "Unitful"

    [deps.AlgebraOfGraphics.weakdeps]
    DynamicQuantities = "06fc5a27-2a28-4c7c-a15d-362465fb6821"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e092fa223bf66a3c41f9c022bd074d916dc303e7"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.2"

[[deps.ArgCheck]]
git-tree-sha1 = "f9e9a66c9b7be1ad7372bbd9b062d9230c30c5ce"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.5.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "d57bd3762d308bded22c3b82d033bff85f6195c6"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.4.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Automa]]
deps = ["PrecompileTools", "TranscodingStreams"]
git-tree-sha1 = "94eab0b3ccdcac361188cc661daf69d4433c1818"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "1.2.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "4126b08903b777c88edf1754288144a0492c05ad"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.8"

[[deps.AxisKeys]]
deps = ["IntervalSets", "LinearAlgebra", "NamedDims", "Tables"]
git-tree-sha1 = "74f4672d77b0a98c808880a556768fe2ccf99b13"
uuid = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
version = "0.2.17"

    [deps.AxisKeys.extensions]
    AbstractFFTsExt = "AbstractFFTs"
    ChainRulesCoreExt = "ChainRulesCore"
    CovarianceEstimationExt = "CovarianceEstimation"
    InterpolationsExt = "Interpolations"
    InvertedIndicesExt = "InvertedIndices"
    LazyStackExt = "LazyStack"
    OffsetArraysExt = "OffsetArrays"
    StatisticsExt = "Statistics"
    StatsBaseExt = "StatsBase"

    [deps.AxisKeys.weakdeps]
    AbstractFFTs = "621f4979-c628-5d54-868e-fcf4e3e8185c"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    CovarianceEstimation = "587fd27a-f159-11e8-2dae-1979310e6154"
    Interpolations = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
    InvertedIndices = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
    LazyStack = "1fad7336-0346-5a1a-a56f-a06ba010965b"
    OffsetArrays = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
    StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BaseDirs]]
git-tree-sha1 = "8c290a1b223deaeea9aea44b235d24546da8eb98"
uuid = "18cc8868-cbac-4acf-b575-c8ff214dc66f"
version = "1.4.0"

[[deps.BitFlags]]
git-tree-sha1 = "bbe1079eecf9c9fbb52765193ad2bae27ae09bc8"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.10"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"
version = "1.11.0"

[[deps.CRlibm]]
deps = ["CRlibm_jll"]
git-tree-sha1 = "66188d9d103b92b6cd705214242e27f5737a1e5e"
uuid = "96374032-68de-5a5b-8d9e-752f78720389"
version = "1.0.2"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "abed1e735dd4152f48c90cf0767e1790e25f332f"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.17"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "71aa551c5c33f1a4415867fe06b7844faadb0ae9"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.1.1"

[[deps.CairoMakie]]
deps = ["CRC32c", "Cairo", "Cairo_jll", "Colors", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "PrecompileTools"]
git-tree-sha1 = "1cda0b7d5abfc95357dae18aca934d401f7869ad"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.15.15"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "7b841680738c19948120f6e4cf8d0200518bd564"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.8+0"

[[deps.CategoricalArrays]]
deps = ["Compat", "DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "20ff1463035a170b25eba2ef9823bb9ad51635e4"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "1.1.1"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysArrowExt = "Arrow"
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStatsBaseExt = "StatsBase"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    Arrow = "69666777-d1a9-59fb-9406-91d4454c9d45"
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.Chain]]
git-tree-sha1 = "765487f32aeece2cf28aa7038e29c31060cb5a69"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "1.0.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "12177ad6b3cad7fd50c8b3825ce24a99ad61c18f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.26.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecInflate64]]
deps = ["TranscodingStreams"]
git-tree-sha1 = "d981a6e8656b1e363a2731716f46851a2257deb7"
uuid = "6309b1aa-fc58-479c-8956-599a07234577"
version = "0.1.3"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "970758a3d591a2a5c2a907c53f2e2f8c1b1d3537"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.9"

[[deps.CodecZstd]]
deps = ["TranscodingStreams", "Zstd_jll"]
git-tree-sha1 = "da54a6cd93c54950c15adf1d336cfd7d71f51a56"
uuid = "6b39b394-51ab-5f42-8807-6242bab2b4c2"
version = "0.8.7"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON"]
git-tree-sha1 = "07da79661b919001e6863b81fc572497daa58349"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.2"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "61761f58648aa7217445f24f841839b78c712232"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.3"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Reexport"]
git-tree-sha1 = "291665b547f137df070e4dd83e432b5fee8cc4a0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.2"

[[deps.Combinatorics]]
git-tree-sha1 = "c761b00e7755700f9cdf5b02039939d1359330e1"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.1.0"

[[deps.CommonSolve]]
deps = ["PrecompileTools"]
git-tree-sha1 = "6c389fa857f6ca5a95474b52a52023fd77f24cb7"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.14"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ComputePipeline]]
deps = ["Observables", "Preferences"]
git-tree-sha1 = "7bc84b769c1d384315e7b5c4ac03a6c303e6cf35"
uuid = "95dc2771-c249-4cd0-9c9f-1f3b4330693c"
version = "0.1.8"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "3c9be947934c38475bafe822c6d61aaed17f0738"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.6.0"

[[deps.ConstructionBase]]
git-tree-sha1 = "b4b092499347b18a015186eae3042f72267106cb"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.6.0"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.CoreMath]]
deps = ["CoreMath_jll"]
git-tree-sha1 = "8c0480f92b1b1796239156a1b9b1bfb1b39499b4"
uuid = "b7a15901-be09-4a0e-87d2-2e66b0e09b5a"
version = "0.1.0"

[[deps.CoreMath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a692a4c1dc59a4b8bc0b6403876eb3250fde2bc3"
uuid = "a38c48d9-6df1-5ac9-9223-b6ada3b5572b"
version = "0.1.0+0"

[[deps.Crayons]]
git-tree-sha1 = "54b76cbb40d9a0f5368c880725b2f141da77c94f"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.2.0"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrameMacros]]
deps = ["DataFrames", "MacroTools"]
git-tree-sha1 = "5275530d05af21f7778e3ef8f167fb493999eea1"
uuid = "75880514-38bc-4a95-a458-c2aea5a3a702"
version = "0.4.1"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "5fab31e2e01e70ad66e3e24c968c264d1cf166d6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.8.2"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "b0bc6d2cad1fed8b7fd59a1551a991cb3d2809e6"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.6"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DelaunayTriangulation]]
deps = ["AdaptivePredicates", "EnumX", "ExactPredicates", "Random"]
git-tree-sha1 = "4ac548adcad90c1d5d677af13568a748af4c952b"
uuid = "927a84f5-c5f4-47a5-9785-b46e178433df"
version = "1.6.7"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "a55766a9c8f66cf19ffcdbdb1444e249bb4ace33"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.4.6"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "c7e3a542b999843086e2f29dac96a618c105be1d"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.12"
weakdeps = ["ChainRulesCore", "SparseArrays"]

    [deps.Distances.extensions]
    DistancesChainRulesCoreExt = "ChainRulesCore"
    DistancesSparseArraysExt = "SparseArrays"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "Roots", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "a958ab3a40c755563f5e1405c0846cb0446bf19d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.131"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsSparseConnectivityTracerExt = "SparseConnectivityTracer"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    SparseConnectivityTracer = "9f842d2f-2579-4b1d-911e-f412cf18a3f5"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.EnumX]]
git-tree-sha1 = "c49898e8438c828577f04b92fc9368c388ac783c"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.7"

[[deps.ExactPredicates]]
deps = ["IntervalArithmetic", "Random", "StaticArrays"]
git-tree-sha1 = "83231673ea4d3d6008ac74dc5079e77ab2209d8f"
uuid = "429591f6-91af-11e9-00e2-59fbe8cec110"
version = "2.2.9"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "4e468f521e1f9f86891cb07186de5df90360a666"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.12"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2bfb1e047e2ad0a5ca94365340bde8005d637568"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.8.4+0"

[[deps.Extents]]
git-tree-sha1 = "b309b36a9e02fe7be71270dd8c0fd873625332b4"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.6"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d9d3cd382f2c999f684e6bfa4039fcc16c153b6f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "9.0.2+0"

[[deps.FFTA]]
deps = ["AbstractFFTs", "DocStringExtensions", "LinearAlgebra", "MuladdMacro", "Primes", "Random", "Reexport"]
git-tree-sha1 = "65e55303b72f4a567a51b174dd2c47496efeb95a"
uuid = "b86e33f2-c0db-4aa1-a6e0-ab43e668529e"
version = "0.3.1"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "6621fef488e496356c9c9625d0562c12a6070819"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.20.0"
weakdeps = ["HTTP"]

    [deps.FileIO.extensions]
    HTTPExt = "HTTP"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport"]
git-tree-sha1 = "a1b2fbfe98503f15b665ed45b3d149e5d8895e4c"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.9.0"

    [deps.FilePaths.extensions]
    FilePathsGlobExt = "Glob"
    FilePathsURIParserExt = "URIParser"
    FilePathsURIsExt = "URIs"

    [deps.FilePaths.weakdeps]
    Glob = "c27321d9-0574-5035-807b-f59d2c89b15c"
    URIParser = "30578b45-9adc-5946-b283-645ec420af67"
    URIs = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "3bab2c5aa25e7840a4b065805c0cdfc01f3068d2"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.24"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "086b5fbd032baf544678cc15b52b015e4c4aceb8"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.17.1"
weakdeps = ["PDMats", "SparseArrays", "StaticArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStaticArraysExt = "StaticArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "907369da0f8e80728ab49c1c7e09327bf0d6d999"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.1.1"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "70329abc09b886fd2c5d94ad2d9527639c421e3e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.14.3+1"

[[deps.FreeTypeAbstraction]]
deps = ["BaseDirs", "ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "Mmap"]
git-tree-sha1 = "4ebb930ef4a43817991ba35db6317a05e59abd11"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.8"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "LogExpFunctions", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsModels"]
git-tree-sha1 = "c963639ae5b9aab54f543bdc7504f42f59880bec"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.9.5"

[[deps.Gamma]]
deps = ["LogExpFunctions"]
git-tree-sha1 = "becc397f7cfb06e343496ae6ffb04818a851da51"
uuid = "a0844989-3bd2-4988-8bea-c9407ab0941b"
version = "1.2.0"

[[deps.GeoFormatTypes]]
git-tree-sha1 = "7528a7956248c723d01a0a9b0447bf254bf4da52"
uuid = "68eda718-8dee-11e9-39e7-89f7f65f511f"
version = "0.4.5"

[[deps.GeoInterface]]
deps = ["DataAPI", "Extents", "GeoFormatTypes"]
git-tree-sha1 = "20f6b13b28c6304104968374f38c24ef71a8ea16"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.6.2"

    [deps.GeoInterface.extensions]
    GeoInterfaceMakieExt = ["Makie", "GeometryBasics"]
    GeoInterfaceRecipesBaseExt = "RecipesBase"

    [deps.GeoInterface.weakdeps]
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "LinearAlgebra", "PrecompileTools", "Random", "StaticArrays"]
git-tree-sha1 = "ec46c5825710fa1a15d468acb2d93cc939a7a5fe"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.5.13"
weakdeps = ["Extents", "GeoInterface", "IntervalSets"]

    [deps.GeometryBasics.extensions]
    ExtentsExt = "Extents"
    GeometryBasicsGeoInterfaceExt = "GeoInterface"
    IntervalSetsExt = "IntervalSets"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Giflib_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3efbbc027441271444dcd0c0a46f2d119dc4329"
uuid = "59f7168a-df46-5410-90c8-f2779963d0ec"
version = "6.1.3+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "090526e65de8f69648ac156daae153de8b56df62"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.88.3+0"

[[deps.GraphMakie]]
deps = ["DataStructures", "GeometryBasics", "Graphs", "LinearAlgebra", "Makie", "NetworkLayout", "PolynomialRoots", "SimpleTraits", "StaticArrays"]
git-tree-sha1 = "c290ddd361912279fa13cd19452cb86e1eda3966"
uuid = "1ecd5474-83a3-4783-bb4f-06765db800d2"
version = "0.6.6"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "a641238db938fff9b2f60d08ed9030387daf428c"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.3"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "69ffb934a5c5b7e086a0b4fee3427db2556fba6e"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.16+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "DataStructures", "Inflate", "LinearAlgebra", "Random", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "dbb2b976f605b220dfe139d6db9f3859680da09e"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.15.0"
weakdeps = ["Distributed", "SharedArrays"]

    [deps.Graphs.extensions]
    GraphsSharedArraysExt = "SharedArrays"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "ef70da5e123a06a29e2d6ddff0f09985bc226491"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.11.3"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "51059d23c8bb67911a2e6fd5130229113735fc7e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.11.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "9d9531a9cb63a9edc33836414e82a07e81710de2"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "100.14004.0+0"

[[deps.HypergeometricFunctions]]
deps = ["Gamma", "LinearAlgebra"]
git-tree-sha1 = "31bb6c92405c084617facc1d7ed9eb6c402d061e"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.30"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "e12629406c6c4442539436581041d372d69c55ba"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.12"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "8c193230235bbcee22c8066b0374f63b5683c2d3"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.5"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs", "WebP"]
git-tree-sha1 = "f0f005f997dfb8c5fe23920d99458a9619873893"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.10"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "2a81c3897be6fbcde0802a0ebe6796d0562f63ec"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.10"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "dcc8d0cd653e55213df9b75ebc6fe4a8d3254c65"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.2.2+0"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InlineStrings]]
git-tree-sha1 = "06b65886c7577a3784d616e29f1302c2e36e389d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.6"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InputBuffers]]
git-tree-sha1 = "e5392ea00942566b631e991dd896942189937b2f"
uuid = "0c81fc1b-5583-44fc-8770-48be1e1cca08"
version = "1.1.1"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "c72458f1962faeb003bf23cbdb75164fe6280906"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "c6c24bc9db44d9ad66af947398380233900e2bcd"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.15.2"
weakdeps = ["Unitful"]

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

[[deps.IntervalArithmetic]]
deps = ["CRlibm", "CoreMath", "MacroTools", "OpenBLASConsistentFPCSR_jll", "Printf", "Random", "RoundingEmulator"]
git-tree-sha1 = "1c531bf0f8a5c60a340926e058fd3f209b5eef5d"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "1.0.12"

    [deps.IntervalArithmetic.extensions]
    IntervalArithmeticArblibExt = "Arblib"
    IntervalArithmeticDiffRulesExt = "DiffRules"
    IntervalArithmeticForwardDiffExt = "ForwardDiff"
    IntervalArithmeticIntervalSetsExt = "IntervalSets"
    IntervalArithmeticIrrationalConstantsExt = "IrrationalConstants"
    IntervalArithmeticLinearAlgebraExt = "LinearAlgebra"
    IntervalArithmeticMakieExt = "Makie"
    IntervalArithmeticRecipesBaseExt = "RecipesBase"
    IntervalArithmeticSparseArraysExt = "SparseArrays"

    [deps.IntervalArithmetic.weakdeps]
    Arblib = "fb37089c-8514-4489-9461-98f9c8763369"
    DiffRules = "b552c78f-8df3-52c6-915a-8e097449b14b"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    IrrationalConstants = "92d709cd-6900-40b7-9082-c6be49f344b6"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.IntervalSets]]
git-tree-sha1 = "0db6aea5b64caa1c47e9fdd27394f0296f05e8bf"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.15"

    [deps.IntervalSets.extensions]
    IntervalSetsMakieExt = "Makie"
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

    [deps.IntervalSets.weakdeps]
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "4657a834b01ce00f2b94546095c4350617b9af2c"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.10.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "9496de8fb52c224a2e3f9ff403947674517317d9"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.6"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "037babc10853eeb8e585418922246cb97b8e5b74"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.0+1"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTA", "Interpolations", "StatsBase"]
git-tree-sha1 = "9eda8292dd3268b3b7ec9df21bbfac24e177ec52"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.12"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "39bca05343661c347aae0bca57a5994a0bf4f08d"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.2.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e5b100780d4d30d63b4618d7930d48af409c1772"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "23.1.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f88f3ccef05a6a72a0cf0ed417c8fd68530f4ab2"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.1"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc3ad4faf30015a3e8094c9b5b7f19e85bdf2386"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.42.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "aebd334d06cee9f24cea70bd19a39749daf73881"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.3+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d620582b1f0cbe2c72dd1d5bd195a9ce73370ab1"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.42.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics", "StatsAPI", "StatsFuns"]
git-tree-sha1 = "aac61f60ed2b1561ae1bbef4e6d7b75c27f1f9e3"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.6.6"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "b85e2797b2409570e84c4de46238c0ed5f6476ae"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "1.0.2"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f00544d95982ea270145636c181ceda21c4e2575"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.2.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Makie]]
deps = ["Animations", "Base64", "CRC32c", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "ComputePipeline", "Contour", "Dates", "DelaunayTriangulation", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG_jll", "FileIO", "FilePaths", "FixedPointNumbers", "Format", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageBase", "ImageIO", "InteractiveUtils", "Interpolations", "IntervalSets", "InverseFunctions", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MacroTools", "Markdown", "MathTeXEngine", "Observables", "OffsetArrays", "PNGFiles", "Packing", "Pkg", "PlotUtils", "PolygonOps", "PrecompileTools", "Printf", "REPL", "Random", "RelocatableFolders", "Scratch", "ShaderAbstractions", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun", "Unitful"]
git-tree-sha1 = "5f6f5d1b1fb7ff98c9a083bbfd4c661a9808e758"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.24.15"

    [deps.Makie.extensions]
    MakieDynamicQuantitiesExt = "DynamicQuantities"

    [deps.Makie.weakdeps]
    DynamicQuantities = "06fc5a27-2a28-4c7c-a15d-362465fb6821"

[[deps.MappedArrays]]
git-tree-sha1 = "0ee4497a4e80dbd29c058fcee6493f5219556f40"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.3"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "UnicodeFun"]
git-tree-sha1 = "aa1078778be5a8e5259ff04fbc3d258b3e78d464"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.6.9"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "8785729fa736197687541f7053f6d8ab7fc44f92"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.10"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.MuladdMacro]]
deps = ["PrecompileTools"]
git-tree-sha1 = "283bf85d4a767481dd924dff0eee1735e95f449e"
uuid = "46d2c3a1-f734-5fdb-9937-b9b9aeba4221"
version = "0.2.7"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "dbd2e8cd2c1c27f0b584f6661b4309609c5a685e"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.4"

[[deps.NamedArrays]]
deps = ["Combinatorics", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "OrderedCollections", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "33d258318d9e049d26c02ca31b4843b2c851c0b0"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.10.5"

[[deps.NamedDims]]
deps = ["LinearAlgebra", "Statistics"]
git-tree-sha1 = "f9e4a49ecd1ea2eccfb749a506fa882c094152b4"
uuid = "356022a1-0364-5f58-8944-0da4b18d706f"
version = "1.2.3"

    [deps.NamedDims.extensions]
    AbstractFFTsExt = "AbstractFFTs"
    ChainRulesCoreExt = "ChainRulesCore"
    CovarianceEstimationExt = "CovarianceEstimation"
    TrackerExt = "Tracker"

    [deps.NamedDims.weakdeps]
    AbstractFFTs = "621f4979-c628-5d54-868e-fcf4e3e8185c"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    CovarianceEstimation = "587fd27a-f159-11e8-2dae-1979310e6154"
    Requires = "ae029012-a4dd-5104-9daa-d747884805df"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.NaturalSort]]
git-tree-sha1 = "eda490d06b9f7c00752ee81cfa451efe55521e21"
uuid = "c020b1a1-e9b0-503a-9c33-f039bfc54a85"
version = "1.0.0"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "StaticArrays"]
git-tree-sha1 = "4d0e23083a6f884c60a9ec61a97e1098cc524be2"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.11"
weakdeps = ["Graphs"]

    [deps.NetworkLayout.extensions]
    NetworkLayoutGraphsExt = "Graphs"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "117432e406b5c023f665fa73dc26e79ec3630151"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.17.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLASConsistentFPCSR_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "38a93f17e431141c6470bb67a88952a7c4f0e928"
uuid = "6cdc7f73-28fd-5e50-80fb-958a8875b1af"
version = "0.3.34+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "97db9e07fe2091882c765380ef58ec553074e9c7"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.3"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "1bcebd887dd33f1108210b3954049b1bb8af0e7a"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.4.15+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.5+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "NetworkOptions", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "1d1aaa7d449b58415f97d2839c318b70ffb525a0"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.6.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "20dd6a885a6fe8b07584d3eb8073133ad04c72e3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.9+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "94ba93778373a53bfd5a0caaf7d809c445292ff4"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.2"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "123266c25174ef6c8d4718920abc206452cf8de6"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.41"
weakdeps = ["StatsBase"]

    [deps.PDMats.extensions]
    StatsBaseExt = "StatsBase"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "32b657a0d57c310a1a172bfc8c8cf68c5e674323"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.5"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "bc5bf2ea3d5351edf285a06b0016788a121ce92c"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.5.1"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1912a9f1b9ca55005b03ba075f8e19993583e237"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.58.2+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "ba0dc8a8a67cacac4842631f960c046e4e563675"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.8"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "e4a6721aa89e62e5d4217c0b21bd714263779dda"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.46.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Reexport", "Statistics"]
git-tree-sha1 = "f20e945b895d2009c6c28d8bbf40a5cd846f7c2f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.5.0"

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "09d065f418b85a6ea4be2236d2f33dd720fb1d2a"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.4"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e189d0623e7ce9c37389bac17e80aac3b0302e75"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.83"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PolynomialRoots]]
git-tree-sha1 = "b23a239f8a930b819f877af45fd5372fc6fa65ea"
uuid = "3a141323-8675-5d76-9d11-e1df1406c778"
version = "1.1.0"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "5005266de4bfe50e53ff44a5cb5c540b6e47a254"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.6.0"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "REPL", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "624de6279ab7d94fc9f672f0068107eb6619732c"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "3.3.2"

    [deps.PrettyTables.extensions]
    PrettyTablesTypstryExt = "Typstry"

    [deps.PrettyTables.weakdeps]
    Typstry = "f0ed7684-a786-439e-b1e3-3b82803b501e"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "25cdd1d20cd005b52fc12cb6be3f75faaf59bb9b"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.7"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "fbb92c6c56b34e1a2c4c36058f68f332bec840e7"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "472daaa816895cb7aee81658d4e7aec901fa1106"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "5e8e8b0ab68215d7a2b14b9921a946fee794749e"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.3"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "5b3d50eb374cea306873b371d3f8d3915a018f0b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.9.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6d40b2fe70437b01397d2a4d5b020008da4e7019"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.2+0"

[[deps.Roots]]
deps = ["Accessors", "CommonSolve", "Printf"]
git-tree-sha1 = "a700562d106889a6e103b0d4db2a14f94c43db0c"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "3.0.9"

    [deps.Roots.extensions]
    RootsChainRulesCoreExt = "ChainRulesCore"
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"
    RootsUnitfulExt = "Unitful"

    [deps.Roots.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "e24dc23107d426a096d3eae6c165b921e74c18e4"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.7.2"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "084c47c7c5ce5cfecefa0a98dff69eb3646b5a80"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.10"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays"]
git-tree-sha1 = "57aa595158717ef165e6f5ab639fe2e3178c0a2b"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.5.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.ShiftedArrays]]
git-tree-sha1 = "503688b59397b3307443af35cd953a13e8005c16"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "2.0.0"

[[deps.SignedDistanceFields]]
deps = ["Statistics"]
git-tree-sha1 = "3949ad92e1c9d2ff0cd4a1317d5ecbba682f4b92"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.1"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "7ddb0b49c109481b046972c0e4ab02b2127d6a75"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.6"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays"]
git-tree-sha1 = "749a2b719ec7f34f280c0d97ac3dab5c89818631"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.5.1"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2c79185e5261b159474903598c571ddd9f12ff7b"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.6"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "13cd91cc9be159e3f4d95b857fa2aa383b53772a"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.3"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "429071b23f4c9a13fb6582f807cc2ef454082408"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.9.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "be1cf4eb0ac528d96f5115b4ed80c26a8d8ae621"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.2"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "39e70e0ab5d7f89833a62ab7c79df15d4fc417c1"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.22"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6ab403037779dae8c514bad259f32a447262455a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.4"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "adb9da019510162e67a4493fc235c23203d8b09e"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.13"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "91a5737baed20ee31f3faea0e51f57461f6a689e"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "2.2.1"
weakdeps = ["ChainRulesCore", "InverseFunctions"]

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsAPI", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "0db41c4e0d9f3fa195395a6401a8290752c9cd3d"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.7.10"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "8a90c1d77c3277a5d43b83927b3cbe2c70a37484"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.7"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "ad8002667372439f2e3611cfd14097e03fa4bccd"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.7.3"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = ["GPUArraysCore", "KernelAbstractions"]
    StructArraysLinearAlgebraExt = "LinearAlgebra"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "b814d5005d6a529d740ffe06f8a86396f6501138"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.9.2"

    [deps.StructUtils.extensions]
    StructUtilsLazilyInitializedFieldsExt = ["LazilyInitializedFields"]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    LazilyInitializedFields = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a94d9bdda1b7bed0046cea645639ab3f62196fac"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.14.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TiffImages]]
deps = ["CodecZstd", "ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "PrecompileTools", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "9ca5f1f2d42f80df4b8c9f6ab5a64f438bbd9976"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.11.9"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.URIs]]
git-tree-sha1 = "908fec9df6c5de98548ead82a468c95ccf6cd263"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "1f0f9f401753701a7e4113b5056ca38d33875b55"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.29.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    ForwardDiffExt = "ForwardDiff"
    InverseFunctionsUnitfulExt = "InverseFunctions"
    LatexifyExt = ["Latexify", "LaTeXStrings"]
    NaNMathExt = "NaNMath"
    PrintfExt = "Printf"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"
    LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
    Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
    NaNMath = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
    Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "0716e01c3b40413de5dedbc9c5c69f27cddfddfc"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.3"

[[deps.WebP]]
deps = ["CEnum", "ColorTypes", "FileIO", "FixedPointNumbers", "ImageCore", "libwebp_jll"]
git-tree-sha1 = "aa1ca3c47f119fbdae8770c29820e5e6119b83f2"
uuid = "e3aaa7dc-3e4b-44e0-be63-ffb868ccd7c1"
version = "0.1.3"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "248a7031b3da79a127f14e5dc5f417e26f9f6db7"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.1.0"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.XLSX]]
deps = ["Colors", "Dates", "OrderedCollections", "PrecompileTools", "Printf", "Random", "Tables", "UUIDs", "Unicode", "XML", "ZipArchives"]
git-tree-sha1 = "6c5597f36032a251bc3be5cb865950653129a724"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.13.0"
weakdeps = ["FileIO", "StyledStrings"]

    [deps.XLSX.extensions]
    FileIOExt = "FileIO"
    StyledStringsSstsExt = "StyledStrings"

[[deps.XML]]
git-tree-sha1 = "92e8ddd9edfd0f374ec738689cbd1d50abfbf01e"
uuid = "72c71f33-b9b6-44de-8c94-c961784809e2"
version = "0.4.6"
weakdeps = ["AbstractTrees"]

    [deps.XML.extensions]
    XMLAbstractTreesExt = "AbstractTrees"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e52eca002a11c30a858185efdfb15311e1c7a6bf"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "808090ede1d41644447dd5cbafced4731c56bd2f"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.13+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "1a4a26870bf1e5d26cd585e38038d399d7e65706"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.8+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "58972370b81423fc546c56a60ed1a009450177c3"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.19.0+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.ZipArchives]]
deps = ["ArgCheck", "CodecInflate64", "CodecZlib", "InputBuffers", "PrecompileTools", "TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "3e6acd912522133953125645b263934ae2ac745e"
uuid = "49080126-0e18-4c2a-b176-c102e4b3760c"
version = "2.6.1"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "f492b7fe1698e623024e873244f10d89c95c340a"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.10.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1210ba774d3427387d307bf1f416d699b7c39417"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.15.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "cb007192783c56d8249db4cf0e3495001edfe414"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.5+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdrm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "28e57478e8a160d346a19c28b3fffb9273bcc9c2"
uuid = "8e53e030-5e6c-5a89-a30b-be5b7263a166"
version = "2.4.134+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "32781be40fe86735af02eae0dd22754e4b5f779d"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.59+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "libpng_jll"]
git-tree-sha1 = "e067c8bae65bb40866552296a2d5b4dc65b8928f"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.80.702+0"

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "7dbf96baae3310fe2fa0df0ccbb3c6288d5816c9"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.23.0+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.libwebp_jll]]
deps = ["Artifacts", "Giflib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libglvnd_jll", "Libtiff_jll", "libpng_jll"]
git-tree-sha1 = "52d3b9475133c3bc8c0a7f90f18bfc8cdb5a443a"
uuid = "c5f90fcd-3b7e-5836-afba-fc50a0988cb2"
version = "1.6.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"
"""

# ╔═╡ Cell order:
# ╟─38f5d048-7747-11eb-30f7-89bade5ed0a3
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
# ╠═0f0c1661-30e2-47de-b6f0-dbb85f6dae5f
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
# ╟─b48335da-7771-11eb-2b17-1507687e446c
# ╠═9a89d9b4-7772-11eb-0c86-9b5f5f1ab23e
# ╠═36334032-7774-11eb-170f-5b7f9b7e0ec7
# ╟─f534c32c-7772-11eb-201c-233b5b7a27a4
# ╠═95f4f0d0-7772-11eb-1b2a-d179e76950fe
# ╠═15334fc2-7773-11eb-303e-67e90901f850
# ╠═a09cb7a6-17e4-4570-ae0b-8104c39bbc24
# ╠═50194494-7772-11eb-20ff-419e874ec00c
# ╟─cbb1e550-7751-11eb-1313-7ff968453f36
# ╠═8212939e-7770-11eb-1f4e-9b698be25d1f
# ╠═9aa77c76-7770-11eb-35ed-9b83924e8176
# ╟─4595d42a-8f0b-42e6-ab5c-f829a0ad2933
# ╟─ee72ef4c-7751-11eb-1781-6f4d027a9e66
# ╠═3585b022-7853-11eb-1a05-7b4fe3921051
# ╠═ddfcd760-7853-11eb-38f7-298a4c1cb5aa
# ╟─cebdd63e-774a-11eb-3cd5-951c43b3c3ff
# ╟─2c840e2e-9bfa-4a5f-9be2-a29d8cdf328d
# ╟─04e5b93a-77ae-11eb-0240-ad7517f0fde3
# ╠═2f672417-ab56-4e7b-b7b4-88655c2404c8
# ╠═2b54193b-ed2e-4f22-bdfb-e95f0a274812
# ╟─23100fcb-8118-471e-8dd8-47da26a981ae
# ╠═5df355b6-77b1-11eb-120f-9bb529b208df
# ╟─664efcec-77b1-11eb-2301-5da84a5de423
# ╠═ebfcbb8e-77ae-11eb-37fc-e798175197d0
# ╟─85e7546c-77ae-11eb-0d0c-618c3669c903
# ╟─ea1afdc0-77b4-11eb-1c7a-2f92bbdb83a6
# ╟─c3472d5b-c03e-4ff2-8cf9-bb0932ceb064
# ╠═811e741e-77b1-11eb-000e-93a9a19a9f60
# ╟─9298e2de-77b1-11eb-0a56-1f50bb0f4dc3
# ╟─48f0ffd4-77b0-11eb-04ab-43eac927ac9d
# ╠═9fb0a0a8-77b1-11eb-011f-7fc7a549f552
# ╟─9da09070-77b1-11eb-0d2e-e9a4433bf34e
# ╟─8142a702-f442-4652-a004-602527c1a14d
# ╠═d8edddf9-0f24-4efe-88d0-ed10c84e8ce8
# ╠═622a2e9c-495b-43d1-b976-1743f28ff84a
# ╟─24c076d2-774a-11eb-2412-f3747af382a2
# ╠═773c5304-4165-433c-bd33-f41d3fb9856a
# ╠═3d47962f-958d-4729-bc20-e2bb5ab3e1e1
# ╠═f8116e43-37f6-4c28-ab62-85aab79ff986
# ╠═fe87f804-b3b6-4b6c-97cc-4a61e1b30eb1
# ╠═79d44149-c6f4-440e-8675-0574fad98a50
# ╠═de7f1884-c549-401e-85c1-4c1ba5774826
# ╠═0a5e66ac-e64c-4734-8cb2-51fdf60e4bb9
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
# ╟─42b21fce-774a-11eb-2d00-c3bfd55a35fc
# ╠═790e88cb-f6e8-43ae-99b8-876f3abbd3a2
# ╠═e87a3bc3-9dd9-4af3-baf0-fba7d3ccfdc9
# ╠═f6de4c5a-7d3f-417b-bd5c-1d793e937307
# ╠═ec2a87fa-09a8-449f-8e32-37a97a754a75
# ╠═6526d6e4-774a-11eb-0b7a-bd644b5f7fea
# ╟─be81874a-f60a-45b5-8855-1a77f50227d2
# ╠═a5b8d51f-22d2-48f7-840e-41c154528d36
# ╠═59576485-57a5-4efc-838e-b4edf27eb420
# ╠═0d80d4ce-f720-4325-8255-8110f0bcb15e
# ╟─5a931c10-774a-11eb-05cb-d7ed3da85835
# ╠═579444bc-774a-11eb-1d80-0557b12da169
# ╟─39f2fdd5-27bb-40c0-a8c0-1bb90aeaccf7
# ╠═7a2980a0-77cf-42cf-a79d-93e1686ff2d8
# ╠═6a87bbe9-6e4b-4802-998f-e0517b11bc7e
# ╠═4a054faa-6d3b-4c50-89fa-12843546cc76
# ╠═7a9cc068-8469-4f8d-bfa1-c49101c4dc23
# ╠═4a3d7e25-a941-486b-a1f8-8f7d563468d3
# ╠═1f7d4622-d3ed-4bcb-a655-289cbcaa62a6
# ╠═03f290eb-b8ca-4ef1-a029-98f07723485a
# ╠═ae9b740b-d0a6-46b0-a548-672a72f92e45
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
