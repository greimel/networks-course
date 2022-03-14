### A Pluto.jl notebook ###
# v0.18.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ f5450eab-0f9f-4b7f-9b80-992d3c553ba9


# ╔═╡ 82a47f6a-7ba6-404c-a250-3f85cea0dd6a
md"""
*Assignment submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ 6481888a-8c19-46c6-b5b8-d2a86c3749a8
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the randomly generated names above by the names of your group in [this cell](#622a2e9c-495b-43d1-b976-1743f28ff84a) and put the right group number and [this cell](#d8edddf9-0f24-4efe-88d0-ed10c84e8ce8).
	"""
end

# ╔═╡ 38f5d048-7747-11eb-30f7-89bade5ed0a3
md"""
`production.jl` | **Version 1.6** | *last updated: Mar 10 2022*
"""

# ╔═╡ f1749b26-774b-11eb-2b42-43ffcb5cd7ee
md"""
# The Economy as a Network of Sectors

This notebook will be the basis for part of **two lectures** *and* **Assignment 5**. Here is what we will cover.

_Lecture A -- **Shock Propagation in an Input-Output Network**_ \
based on _[Long & Plosser (1983)](https://www.jstor.org/stable/1840430), Journal of Political Economy_ and _[Carvalho (2014)](https://www.aeaweb.org/articles.php?doi=10.1257/jep.28.4.23), Journal of Economic Perspectives_.

1. Introduce Input-Output Tables. Re-interpret them as a network of economic sectors connected by input-output linkages
2. Visualize and analyze this *intersectoral network*
3. Simulate the *dynamic* production network model of [Long & Plosser (1983)](https://www.jstor.org/stable/1840430)
4. Visualize propagation of shocks in the model of Long & Plosser. Discuss the role of centrality

_Lecture B -- **Network Origins of Aggregate Fluctuations**_ \
based on _[Acemoglu, Carvalho, Ozdaglar & Tahbaz-Salehi (2012)](https://economics.mit.edu/files/8135), Econometrica_

5. Solve the *static* production network model of [Acemoglu, Carvalho, Ozdaglar & Tahbaz-Salehi (2012)](https://economics.mit.edu/files/8135)
6. Show that sector-specific shocks don't necessarily wash out in equilibrium. 
7. Show by simulation that iid industry-specific shocks will lead to aggregate flucuations



#### Assignment 5

8. Simulate how the Covid shocks propagates through the economy

"""

# ╔═╡ a771e504-77aa-11eb-199c-8778965769b6
md"""
## Appetizers

This plot shows how a shock to single sector propagates to other sectors.
"""

# ╔═╡ 94375d0e-77aa-11eb-3934-edb020ab0fd7
fig

# ╔═╡ cb75f8ac-77aa-11eb-041c-4b3fe85ec22b
md"""
This plot shows how the aggregate economy reacts to shocking two groups of sectors. The groups are equally big, but differ by their centrality.
"""

# ╔═╡ 76e6f44e-77aa-11eb-1f12-438937941606
fig_welfare

# ╔═╡ 9b47991e-7c3d-11eb-1558-b5824ab10dc0
md"""
This plot shows how industry-specific iid shocks can either $(i)$ wash out, or $(ii)$ translate into aggregate fluctuations, depending on the network structure.
"""

# ╔═╡ d772a28a-7c3d-11eb-012f-9b81ad67f9a8
fluct_fig

# ╔═╡ cebdd63e-774a-11eb-3cd5-951c43b3c3ff
md"""
# Assignment 5: The Covid Crisis
"""

# ╔═╡ 2c840e2e-9bfa-4a5f-9be2-a29d8cdf328d
md"""
*submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ 04e5b93a-77ae-11eb-0240-ad7517f0fde3
md"""
For this problem set you will simulate a Covid crisis using the model from the lecture.

### Task 1: Which industries were hit by Covid? (3 points)

👉 Find 5 (groups of) industries and explain how they have been hit by the Corona crisis *directly* (that is, not through propagation within the production network.)

You can look through the industry definitions in `df_nodes1` (below) or go to [the BEA website](https://www.bea.gov/data/industries).

"""

# ╔═╡ 5df355b6-77b1-11eb-120f-9bb529b208df
answer1 = md"""
Your answer goes here ...
"""

# ╔═╡ 664efcec-77b1-11eb-2301-5da84a5de423
show_words(answer1)

# ╔═╡ ebfcbb8e-77ae-11eb-37fc-e798175197d0
df_nodes1

# ╔═╡ 85e7546c-77ae-11eb-0d0c-618c3669c903
md"""
### Task 2: Simulate a Covid crisis (4 points)

👉 Adapt the code in [this cell](#ea1afdc0-77b4-11eb-1c7a-2f92bbdb83a6) to simulate the Covid crisis. In particular, specify the set of shocked nodes (from **Task 1**) and the length of the shock (assume a period is a quarter).

👉 Explain your findings in <200 words. Think about how much of the welfare loss is due to the directly hit industries, how much is due to network effects?
"""

# ╔═╡ 811e741e-77b1-11eb-000e-93a9a19a9f60
answer2 = md"""
Your answer goes here ...
"""

# ╔═╡ 9298e2de-77b1-11eb-0a56-1f50bb0f4dc3
show_words_limit(answer2, 200)

# ╔═╡ 3ec33a62-77b1-11eb-0821-e547d1422e6f
# your

# ╔═╡ 4359dbee-77b1-11eb-3755-e1c1532212bb
# code

# ╔═╡ 45db03f2-77b1-11eb-2edd-6104bc85915b
# goes

# ╔═╡ 486cd850-77b1-11eb-1dd2-15ca68d98173
# here

# ╔═╡ ea1afdc0-77b4-11eb-1c7a-2f92bbdb83a6
fig_covid = let
	nodes_vec = [bot_n => "bottom", top_n => "top"]
	
	A = weighted_adjacency_matrix(network)'
	
	fig = Figure()
		
	ax = Axis(fig[1,1], title = "Welfare loss after shock to different industries")
	
	for (i, nodes) in enumerate(nodes_vec)
		(; welfare) = impulse_response(10, A, params(A), nodes[1], -0.5, T_shock = 0:2)
		lines!(ax, collect(axes(welfare, 1)), parent(welfare), label = nodes[2] * " $(length(nodes[1]))")
	end
	
	Legend(fig[1,2], ax)

	fig
end

# ╔═╡ 48f0ffd4-77b0-11eb-04ab-43eac927ac9d
md"""
### Task 3: Is this model suitable for this exercise? (3 points)

👉 Explain in <200 words how well you think that the model simulation can capture the real-world Covid crisis?
"""

# ╔═╡ 9fb0a0a8-77b1-11eb-011f-7fc7a549f552
answer3 = md"""
Your answer goes here ...
"""

# ╔═╡ 9da09070-77b1-11eb-0d2e-e9a4433bf34e
show_words_limit(answer3, 200)

# ╔═╡ 8142a702-f442-4652-a004-602527c1a14d
md"""
### Before you submit ...

👉 Make sure you have added **your names** and **your group number** in the cells below.

👉 Make sure that that **all group members proofread** your submission (especially your little essays).

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. (The source code is embedded in the html file.)
"""

# ╔═╡ 622a2e9c-495b-43d1-b976-1743f28ff84a
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ d8edddf9-0f24-4efe-88d0-ed10c84e8ce8
group_number = 99

# ╔═╡ d9465a80-7750-11eb-2dd5-d3052d3d5c50
md"""
# Input-Output Tables: *Production Recipes* for the Economy
"""

# ╔═╡ cf680c48-7769-11eb-281c-d7a2d5ec8fe5
md"""
#### The list of industries
"""

# ╔═╡ cbc03264-7769-11eb-345a-71ae30cc7526
@subset(df_all, :code ∈ node_names)

# ╔═╡ dd41fe96-7769-11eb-06a6-3d6298f6e6fc
md"""
#### The Input-Output Table
"""

# ╔═╡ 278c829c-7767-11eb-1d04-cb38ee52b79b
df_io

# ╔═╡ 128bb9e8-776a-11eb-3786-83531bd2dffb
md"""
#### The Input-Output table as a sparse matrix
"""

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

# ╔═╡ f65f7f8c-7769-11eb-3399-79bde01513cd
md"""
#### Important industries
"""

# ╔═╡ bd27268e-7766-11eb-076b-71688ecb4ae3
begin
	df_nodes = @subset(df_all, :code ∈ node_names)
	df_nodes.inputs_used    = sum(wgts, dims=2) |> vec
	df_nodes.used_as_input = sum(wgts, dims=1) |> vec
	
	df_nodes
end;

# ╔═╡ d9fd6bb0-7766-11eb-150b-410bb7d09d20
sort(df_nodes, :inputs_used, rev = true)

# ╔═╡ 04e731d0-7751-11eb-21fd-e7f9b022cdc9
md"""
# Analyzing the *Intersectoral Network* 

Recall, ``G = W'``. Also, in order to satisfy the assumptions of the model, we have to normalize the row sums to 1.
"""

# ╔═╡ 775f99b8-77a9-11eb-2ebf-7bbe0d398306
extrema(wgts)

# ╔═╡ 6cec81a0-77ac-11eb-06e3-bd9dcb73a896
network = SimpleWeightedDiGraph(wgts')

# ╔═╡ 834669c4-776c-11eb-29b7-77dc465077d7
begin
	wgts_n = wgts ./ sum(wgts, dims=2) |> dropzeros!
	network_n = SimpleWeightedDiGraph(wgts_n')
	extrema(wgts_n)
end

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

# ╔═╡ 5c2ef34e-776f-11eb-2a6f-ff99b5d24997
unweighted_network = SimpleDiGraph(wgts .> 0.01)

# ╔═╡ 958f9f3e-77ac-11eb-323c-cd78c1fe4c23
graphplot(
	unweighted_network,
	edge_width = 0.5,
	edge_color = (:black, 0.5)
)

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

# ╔═╡ 7db9fa00-7773-11eb-0942-ed884b67533c
node_colors[] = parent(production[:,t0])

# ╔═╡ 36334032-7774-11eb-170f-5b7f9b7e0ec7
t = Observable(0)

# ╔═╡ 3843a2c2-7774-11eb-1bf5-5178a9014ae2
t[] = t0

# ╔═╡ f534c32c-7772-11eb-201c-233b5b7a27a4
@bind t0 Slider(axes(production, 2), default = 1, show_value = true)

# ╔═╡ 95f4f0d0-7772-11eb-1b2a-d179e76950fe
t0; fig

# ╔═╡ 15334fc2-7773-11eb-303e-67e90901f850
begin
	AA = weighted_adjacency_matrix(grph) |> Matrix |> transpose
	param = params(AA)
	
	(; production) = impulse_response(10, AA, param, [1], -0.3, T_shock = 0:2)
	
	color_extr = extrema(production)
end

# ╔═╡ 939fa06e-7772-11eb-086c-ff1bf54525f1
node_colors = Observable(rand(nv(grph)))

# ╔═╡ a09cb7a6-17e4-4570-ae0b-8104c39bbc24
using SimpleWeightedGraphs

# ╔═╡ 50194494-7772-11eb-20ff-419e874ec00c
fig = let
	graph = grph
	
	wgt = Matrix(weights(graph) .* adjacency_matrix(graph)) 	

	fig = Figure()

	ax1 = Axis(fig[1,1][1,1])
	hidedecorations!(ax1)
	
	graphplot!(ax1,
		SimpleWeightedDiGraph(wgt);
		layout = Spring(),
		node_color = node_colors,
		nodes = (; colorrange = color_extr),
		arrow_show = true,
		arrow_size = 15,
		edge_color = (:black, 0.5),
	)

	Colorbar(fig[1,2]; limits = color_extr)
	
	ax2 = Axis(fig[1,3])
	
	for i in 1:nv(graph)
		lines!(ax2, collect(axes(production, 2)), parent(production[i,:]))
		vlines!(ax2, t, linestyle = :dash, color = :gray)
	end

	Label(fig[0,:], "Shock transmission in a production network")
	fig
end;

# ╔═╡ cbb1e550-7751-11eb-1313-7ff968453f36
md"""
## Big Network from Input-Output Tables
"""

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
	
	ax = Axis(fig[1,1], title = "Welfare loss after shock to different industries")
	
	for (i, nodes) in enumerate(nodes_vec)
		(; welfare) = impulse_response(10, A, params(A), nodes[1], -0.5, T_shock = 0:2)
		lines!(ax, collect(axes(welfare, 1)), parent(welfare), label = nodes[2] * " $(length(nodes[1]))")
	end
	
	Legend(fig[1,2], ax)

	fig
end

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

# ╔═╡ 24c076d2-774a-11eb-2412-f3747af382a2
md"""
# Appendix
"""

# ╔═╡ 773c5304-4165-433c-bd33-f41d3fb9856a
using PlutoUI: TableOfContents, Slider, CheckBox

# ╔═╡ 3d47962f-958d-4729-bc20-e2bb5ab3e1e1
TableOfContents()

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
	subset(:code => ByRow(x -> x ∉ df_out.code))
	#@subset(:code ∈ [df_out.code])
	#filter(:code => !in(df_out.code), _)
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

# ╔═╡ 6197cf52-7758-11eb-2c66-b7df9d59cbf7
begin
	io_edges0 = stack(df_io, Not("output"), variable_name = "input")
	@subset!(io_edges0, :value > 0)
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

# ╔═╡ 42b21fce-774a-11eb-2d00-c3bfd55a35fc
md"""
## Package Environment
"""

# ╔═╡ 790e88cb-f6e8-43ae-99b8-876f3abbd3a2
using DataFrameMacros

# ╔═╡ e87a3bc3-9dd9-4af3-baf0-fba7d3ccfdc9
using DataFrames

# ╔═╡ f6de4c5a-7d3f-417b-bd5c-1d793e937307
using Chain: @chain

# ╔═╡ ec2a87fa-09a8-449f-8e32-37a97a754a75
import CSV, HTTP, ZipFile, XLSX

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

# ╔═╡ be81874a-f60a-45b5-8855-1a77f50227d2
md"""
### Plotting
"""

# ╔═╡ a5b8d51f-22d2-48f7-840e-41c154528d36
using GraphMakie, CairoMakie

# ╔═╡ 59576485-57a5-4efc-838e-b4edf27eb420
using AlgebraOfGraphics

# ╔═╡ 0d80d4ce-f720-4325-8255-8110f0bcb15e
using NetworkLayout

# ╔═╡ 5a931c10-774a-11eb-05cb-d7ed3da85835
md"""
## Patch 1: Weights and Centralities
"""

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

# ╔═╡ ae9b740b-d0a6-46b0-a548-672a72f92e45
members = let
	names = map(group_members) do (; firstname, lastname)
		firstname * " " * lastname
	end
	join(names, ", ", " & ")
end

# ╔═╡ 6a87bbe9-6e4b-4802-998f-e0517b11bc7e
function wordcount(text)
	stripped_text = strip(replace(string(text), r"\s" => " "))
   	words = split(stripped_text, (' ', '-', '.', ',', ':', '_', '"', ';', '!', '\''))
   	length(filter(!=(""), words))
end

# ╔═╡ 4a054faa-6d3b-4c50-89fa-12843546cc76
using PlutoTest: @test

# ╔═╡ 7a9cc068-8469-4f8d-bfa1-c49101c4dc23
@test wordcount("  Hello,---it's me.  ") == 4

# ╔═╡ 4a3d7e25-a941-486b-a1f8-8f7d563468d3
@test wordcount("This;doesn't really matter.") == 5

# ╔═╡ 1f7d4622-d3ed-4bcb-a655-289cbcaa62a6
show_words(answer) = md"_approximately $(wordcount(answer)) words_"

# ╔═╡ 03f290eb-b8ca-4ef1-a029-98f07723485a
function show_words_limit(answer, limit)
	count = wordcount(answer)
	if count ≤ 1.1 * limit
		return show_words(answer)
	else
		return almost(md"You are at $count words. Please shorten your text a bit, to get **below $limit words**.")
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
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

[compat]
AlgebraOfGraphics = "~0.6.5"
AxisKeys = "~0.2.1"
CSV = "~0.10.2"
CairoMakie = "~0.7.4"
CategoricalArrays = "~0.10.2"
Chain = "~0.4.10"
Colors = "~0.12.8"
DataFrameMacros = "~0.2.1"
DataFrames = "~1.3.2"
Distributions = "~0.25.49"
GraphMakie = "~0.3.2"
Graphs = "~1.6.0"
HTTP = "~0.9.17"
NamedArrays = "~0.9.6"
NetworkLayout = "~0.4.4"
OffsetArrays = "~1.10.8"
PlutoTest = "~0.2.1"
PlutoUI = "~0.7.35"
SimpleWeightedGraphs = "~1.2.1"
XLSX = "~0.7.9"
ZipFile = "~0.9.4"
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
deps = ["Colors", "Dates", "Dictionaries", "FileIO", "GLM", "GeoInterface", "GeometryBasics", "GridLayoutBase", "KernelDensity", "Loess", "Makie", "PlotUtils", "PooledArrays", "RelocatableFolders", "StatsBase", "StructArrays", "Tables"]
git-tree-sha1 = "032144cbb772cf0aef2954dfe5cc2c0bebeaaadd"
uuid = "cbdf2221-f076-402e-a563-3d30da359d67"
version = "0.6.5"

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
git-tree-sha1 = "745233d77146ad221629590b6d82fe7f1ddb478f"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "4.0.3"

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

[[deps.AxisKeys]]
deps = ["AbstractFFTs", "ChainRulesCore", "CovarianceEstimation", "IntervalSets", "InvertedIndices", "LazyStack", "LinearAlgebra", "NamedDims", "OffsetArrays", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "8380654f50f0d73731060da163a5ae31aa29347e"
uuid = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
version = "0.2.1"

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
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "9519274b50500b8029973d241d32cfbf0b127d97"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.2"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA", "StaticArrays"]
git-tree-sha1 = "aedc7c910713eb616391cf95218277b714a7913f"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.7.4"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

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
git-tree-sha1 = "c9a6160317d1abe9c44b3beb367fd448117679ca"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.13.0"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "12fc73e5e0af68ad3137b886e3f7c1eacfca2640"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.17.1"

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

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

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

[[deps.CovarianceEstimation]]
deps = ["LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "a3e070133acab996660d31dcf479ea42849e368f"
uuid = "587fd27a-f159-11e8-2dae-1979310e6154"
version = "0.2.7"

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

[[deps.Dictionaries]]
deps = ["Indexing", "Random"]
git-tree-sha1 = "63004a55faf43a5f7be7f5eca36ce355e9a75b2c"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.18"

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
git-tree-sha1 = "9d3c0c762d4666db9187f363a76b47f7346e673b"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.49"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "84f04fe68a3176a583b864e492578b9466d87f1e"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.6"

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
git-tree-sha1 = "ae13fcbc7ab8f16b0856729b050ef0c446aa3492"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.4+0"

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
git-tree-sha1 = "80ced645013a5dbdc52cf70329399c35ce007fae"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.13.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "04d13bfa8ef11720c24e4d840c0033d145537df7"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.17"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "4c7d3757f3ecbcb9055870351078552b7d1dbd2d"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.0"

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
git-tree-sha1 = "7413cb602a7cbe44129016e8cd45981209823404"
uuid = "1ecd5474-83a3-4783-bb4f-06765db800d2"
version = "0.3.2"

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
git-tree-sha1 = "57c021de207e234108a6f1454003120a1bf350c4"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.6.0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "70938436e2720e6cb8a7f2ca9f1bbdbf40d7f5d0"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.6.4"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "SpecialFunctions", "Test"]
git-tree-sha1 = "65e4589030ef3c44d3b90bdc5aac462b4bb05567"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.8"

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
deps = ["FileIO", "JpegTurbo", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "464bdef044df52e6436f8c018bea2d48c40bb27b"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.1"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

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
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "a77b273f1ddec645d1b7c4fd5fb98c8f90ad10a5"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.1"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

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
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "cd0fd02ab0d129f03515b7b68ca77fb670ef2e61"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.16.5"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "c5fb1bfac781db766f9e4aef96adc19a729bc9b2"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.2.1"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test"]
git-tree-sha1 = "70e733037bbf02d691e78f95171a1fa08cdc6332"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.2.1"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

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

[[deps.NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "2fd5787125d1a93fbe30961bd841707b8a80d75b"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.9.6"

[[deps.NamedDims]]
deps = ["AbstractFFTs", "ChainRulesCore", "CovarianceEstimation", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "64a54c2992d5da90e3fa19e1bcf65c06bcda2bac"
uuid = "356022a1-0364-5f58-8944-0da4b18d706f"
version = "0.2.46"

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
git-tree-sha1 = "7e2166042d1698b6072352c74cfd1fca2a968253"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.6"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "eb4dbb8139f6125471aa3da98fb70f02dc58e49c"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.14"

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
git-tree-sha1 = "3a121dfbba67c94a5bec9dde613c3d0cbcf3a12b"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.3+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "13468f237353112a01b2d6b32f3d0f80219944aa"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.2"

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

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "cd214d5c737563369887ac465a6d3c0fd7c1f854"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.1"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "85bf3e4bd279e405f91489ce518dedb1e32119cb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.35"

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
git-tree-sha1 = "de893592a221142f3db370f48290e3a2ef39998f"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.4"

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

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

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

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "6a2f7d70512d205ca8c7ee31bfa9f142fe74310c"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.12"

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

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

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
git-tree-sha1 = "5ba658aeecaaf96923dce0da9e703bd1fe7666f9"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.4"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "00b725fffc9a7e9aac8850e4ed75b4c1acbe8cd2"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.5.5"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "6354dfaf95d398a1a70e0b28238321d5d17b2530"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c3d8ba7f3fa0625b062b82853a7d5229cb728b6b"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.1"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8977b17906b0a1cc74ab2e3a05faa16cf08a8291"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.16"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "25405d7016a47cf2bd6cd91e66f4de437fd54a07"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.16"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "677488c295051568b0b79a77a8c44aa86e78b359"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.6.28"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "57617b34fa34f91d536eb265df67c2d4519b8b98"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.5"

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

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XLSX]]
deps = ["Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "2af4b3e329b51f1a41acb346e64156f904860a74"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.7.9"

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
git-tree-sha1 = "3593e69e469d2111389a9bd06bac1f3d730ac6de"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.4"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

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

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "78736dab31ae7a53540a6b752efc61f77b304c5b"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.8.6+1"

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
# ╟─82a47f6a-7ba6-404c-a250-3f85cea0dd6a
# ╟─6481888a-8c19-46c6-b5b8-d2a86c3749a8
# ╟─38f5d048-7747-11eb-30f7-89bade5ed0a3
# ╟─f1749b26-774b-11eb-2b42-43ffcb5cd7ee
# ╟─a771e504-77aa-11eb-199c-8778965769b6
# ╠═94375d0e-77aa-11eb-3934-edb020ab0fd7
# ╟─cb75f8ac-77aa-11eb-041c-4b3fe85ec22b
# ╠═76e6f44e-77aa-11eb-1f12-438937941606
# ╟─9b47991e-7c3d-11eb-1558-b5824ab10dc0
# ╠═d772a28a-7c3d-11eb-012f-9b81ad67f9a8
# ╟─cebdd63e-774a-11eb-3cd5-951c43b3c3ff
# ╟─2c840e2e-9bfa-4a5f-9be2-a29d8cdf328d
# ╟─04e5b93a-77ae-11eb-0240-ad7517f0fde3
# ╠═5df355b6-77b1-11eb-120f-9bb529b208df
# ╟─664efcec-77b1-11eb-2301-5da84a5de423
# ╠═ebfcbb8e-77ae-11eb-37fc-e798175197d0
# ╟─85e7546c-77ae-11eb-0d0c-618c3669c903
# ╠═811e741e-77b1-11eb-000e-93a9a19a9f60
# ╟─9298e2de-77b1-11eb-0a56-1f50bb0f4dc3
# ╠═3ec33a62-77b1-11eb-0821-e547d1422e6f
# ╠═4359dbee-77b1-11eb-3755-e1c1532212bb
# ╠═45db03f2-77b1-11eb-2edd-6104bc85915b
# ╠═486cd850-77b1-11eb-1dd2-15ca68d98173
# ╟─ea1afdc0-77b4-11eb-1c7a-2f92bbdb83a6
# ╟─48f0ffd4-77b0-11eb-04ab-43eac927ac9d
# ╠═9fb0a0a8-77b1-11eb-011f-7fc7a549f552
# ╟─9da09070-77b1-11eb-0d2e-e9a4433bf34e
# ╟─8142a702-f442-4652-a004-602527c1a14d
# ╠═622a2e9c-495b-43d1-b976-1743f28ff84a
# ╠═d8edddf9-0f24-4efe-88d0-ed10c84e8ce8
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
# ╠═a09cb7a6-17e4-4570-ae0b-8104c39bbc24
# ╠═50194494-7772-11eb-20ff-419e874ec00c
# ╟─cbb1e550-7751-11eb-1313-7ff968453f36
# ╠═8212939e-7770-11eb-1f4e-9b698be25d1f
# ╠═9aa77c76-7770-11eb-35ed-9b83924e8176
# ╟─ee72ef4c-7751-11eb-1781-6f4d027a9e66
# ╠═3585b022-7853-11eb-1a05-7b4fe3921051
# ╠═ddfcd760-7853-11eb-38f7-298a4c1cb5aa
# ╟─24c076d2-774a-11eb-2412-f3747af382a2
# ╠═773c5304-4165-433c-bd33-f41d3fb9856a
# ╠═3d47962f-958d-4729-bc20-e2bb5ab3e1e1
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
# ╠═ae9b740b-d0a6-46b0-a548-672a72f92e45
# ╠═6a87bbe9-6e4b-4802-998f-e0517b11bc7e
# ╠═4a054faa-6d3b-4c50-89fa-12843546cc76
# ╠═7a9cc068-8469-4f8d-bfa1-c49101c4dc23
# ╠═4a3d7e25-a941-486b-a1f8-8f7d563468d3
# ╠═1f7d4622-d3ed-4bcb-a655-289cbcaa62a6
# ╠═03f290eb-b8ca-4ef1-a029-98f07723485a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
