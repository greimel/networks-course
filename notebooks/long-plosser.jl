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

# ╔═╡ 5a27cdc8-330b-4c88-9fcd-ec885a0b7fe4
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.add(["LightGraphs", "CairoMakie", "UnPack", "OffsetArrays"])
	Pkg.add(["NetworkLayout"])
	Pkg.add(["PlutoUI"])
	Pkg.add(["Colors"])
	
	
	using CairoMakie
	
	CairoMakie.activate!(type = "png")
	using NetworkLayout
	using Colors
	using OffsetArrays
	using LightGraphs
	using LinearAlgebra, SparseArrays
	using LinearAlgebra: I
	using UnPack
	using PlutoUI
end

# ╔═╡ 42009620-6249-11eb-076b-957a526b3731
A, graph = let
	N = 10
	graph = CycleDiGraph(N)
	A = adjacency_matrix(graph)
	
	A = A ./ dropdims(sum(A, dims=2), dims=2)
	A, graph
end	

# ╔═╡ 14055e2c-6276-11eb-1d68-89736527b605
A

# ╔═╡ 81137be8-fc96-47d9-8cd3-6d3f063b0994
# parameters
param = let
	N = size(A, 1)
	θ = fill(1/(N+1), N) # utility weights of commodities
	θ₀ = 1/(N+1) # utility weight of leisure
	β = 0.95
	H = 1
	α = 0.3
	param = (; α, β, θ, θ₀, H)
end

# ╔═╡ ce8503da-624c-11eb-063b-ffdf6629feeb
get_γ(A, param) = (I - param.β * A) \ param.θ

# ╔═╡ 14dad81f-8a1a-40ec-865e-bf3f6c45e1d5
# equations
function L(A, param)
	@unpack α, β, θ, θ₀, H = param
	γ = get_γ(A, param)
	L = β .* γ .* (1-α) ./ (θ₀ + (1-α) * β * sum(γ)) .* H
end

# ╔═╡ bd2b0378-624c-11eb-3784-f19680ec2540
C(Y, A, param) = param.θ ./ get_γ(A, param) .* Y

# ╔═╡ 4a3e7cae-624d-11eb-1a67-336eb02a27d0
function welfare(y, param)
	dot(y, param.θ)
end

# ╔═╡ cb0cd7b0-c619-4a60-8762-8b12fa4b2665
function κ(A, param)
	N = size(A, 1)
	@unpack α, β = param
	γ = get_γ(A, param)
	
	κ = (1 - α) .* log.(L(A, param))
	for i in 1:N
		tmp = sum(A[i,j] == 0 ? 0 : A[i,j] * log(β * γ[i] * A[i,j] / γ[j]) for j in 1:N)
		κ[i] = κ[i] + α * tmp
	end
	κ
end

# ╔═╡ 48332d33-ef3d-4b92-8181-48148738dac9
# initial value
y₀(A, param) = (I - param.α * A) \ κ(A, param)

# ╔═╡ c500adfb-ff7a-4f0c-bace-3867903f26c9
y_next(y, ε, A, param) = κ(A, param) + param.α * A * y + ε

# ╔═╡ 321324ec-6276-11eb-037e-a3dd8d4b02b1


# ╔═╡ 8d1dd157-c464-4e0f-b570-b04dac7e4782
function impulse_response(T, A, param, shocked_nodes, ε₀; T_shock = 0, T₀=3)
	y = y₀(A, param)
	N = size(A, 2)
	
	t_indices = -T₀:T
	
	
	
	y_out = OffsetArray(zeros(N, length(t_indices)), 1:N, t_indices)
	w_out = OffsetArray(zeros(length(t_indices)), t_indices)
	
	y_out[:, -T₀] .= y
	w_out[-T₀]     = welfare(y, param)
	
	for t in (-T₀+1):T
		ε = zeros(N)
		if t ∈ T_shock 
			ε[shocked_nodes] = ε₀
		end
		y = y_next(y, ε, A, param)
		
		y_out[:, t] .= y
		w_out[t]     = welfare(y, param)
	end
	
	y_out .= y_out ./ -y_out[:,-T₀] .+ 1
	w_out .= w_out ./ -w_out[-T₀] .+ 1
	(production = y_out, welfare = w_out)
end

# ╔═╡ bc50a2ae-6270-11eb-1bb0-334a0d45a47c


# ╔═╡ 93844b20-624b-11eb-3950-afc439d44aaa
let
	nodes = 1:10
	
	fig = Figure()
	
	col = CairoMakie.Colors.distinguishable_colors(10)
	
	ax = Axis(fig[1,1])
	
	for node in nodes
		@unpack welfare = impulse_response(10, A, param, node, -0.3, T_shock = 0:0)
		lines!(ax, collect(axes(welfare, 1)), parent(welfare), color = col[node], label = "node $node")
	end
	
	Legend(fig[1,2], ax)

	fig
end

# ╔═╡ 67a3cf42-627a-11eb-2577-f5c57c66e8bb
t = Node(0)

# ╔═╡ 893dea14-6277-11eb-2b7b-fbe9186f3024
begin
	@unpack production = impulse_response(10, A, param, 1, -0.3, T_shock = 0:2)
	
	color_extr = extrema(production)
end



# ╔═╡ fb8a35e4-6274-11eb-3b46-efe966cee7fc
@bind t0 PlutoUI.Slider(axes(production, 2), default = 1, show_value = true)

# ╔═╡ 70a40ad2-627a-11eb-0d97-f7354da92712
t[] = t0

# ╔═╡ 68b5d4ee-6274-11eb-0c36-5334c129f893
node_colors = Node(rand(nv(graph)))

# ╔═╡ c9ed747e-6274-11eb-1d1d-714cee58b5b1
node_colors[] = parent(production[:,t0])

# ╔═╡ 467f87ea-6273-11eb-3711-310ddb21835f
collect(weights(graph))

# ╔═╡ 665b9b94-6273-11eb-383f-496d56137094
wgt = Matrix(weights(graph) .* adjacency_matrix(graph))

# ╔═╡ 202bc43e-6271-11eb-1699-f1a49f4567a6
function network_plot(node_positions, edges_as_pts; axis = (;), scatter = (;), lines = (;), colorbar = (;))
	fig = Figure()
	
	ax = Axis(fig[1,1][1,1]; spinewidth = 0, axis...)
	
	hidedecorations!(ax)

	lp = arrows!(ax, edges_as_pts...; arrowsize = 15, lengthscale=0.87, lines...)
	sp = scatter!(ax, node_positions; scatter...)

	cb = Colorbar(fig[1,1][1,2]; colorbar...)
	cb.width = 30
	
	fig
end

# ╔═╡ ee096014-6271-11eb-1709-ff7acd68917b
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

# ╔═╡ 189faa00-6271-11eb-0030-cb39dd021a06
function nodes_edges(graph)
	wgt = Matrix(weights(graph) .* adjacency_matrix(graph)) 
	
	node_positions = NetworkLayout.Spring.layout(wgt)
#	node_positions = NetworkLayout.Spectral.layout(wgt) # node_weights = eigenvector_centrality(graph)
	
	#cutoffs = [0.001,0.01,0.05,0.15,0.4,1.0]
	
	edge_arrows = edges_as_arrows(edges(graph), node_positions)
	
	(; node_positions, edge_arrows)
end

# ╔═╡ 45b660f0-6272-11eb-255f-292f6840e53a
fig = let
	node_positions, edges = nodes_edges(graph)
	
	#colormap = CairoMakie.AbstractPlotting.ColorSchemes.linear_bmy_10_95_c78_n256
	
	fig = network_plot(node_positions, edges; 
		scatter = (; color = node_colors, colorrange = color_extr, strokewidth = 0 ),
		lines = (; arrowcolor = (:black, 0.5), linecolor = (:black, 0.5)), 
		colorbar = (; limits = color_extr),
		axis = (title = "Production network", ))
	
	ax = Axis(fig[1,2][1,1])
	
	for i in 1:nv(graph)
		lines!(ax, collect(axes(production, 2)), parent(production[i,:]), color = distinguishable_colors(nv(graph))[i])
		vlines!(ax, t)
	end
	
	fig
end;

# ╔═╡ 3d221bf2-6275-11eb-0a52-a5bc0ced7120
t0; fig

# ╔═╡ Cell order:
# ╠═5a27cdc8-330b-4c88-9fcd-ec885a0b7fe4
# ╠═14055e2c-6276-11eb-1d68-89736527b605
# ╠═42009620-6249-11eb-076b-957a526b3731
# ╠═81137be8-fc96-47d9-8cd3-6d3f063b0994
# ╠═ce8503da-624c-11eb-063b-ffdf6629feeb
# ╠═14dad81f-8a1a-40ec-865e-bf3f6c45e1d5
# ╠═bd2b0378-624c-11eb-3784-f19680ec2540
# ╠═4a3e7cae-624d-11eb-1a67-336eb02a27d0
# ╠═cb0cd7b0-c619-4a60-8762-8b12fa4b2665
# ╠═48332d33-ef3d-4b92-8181-48148738dac9
# ╠═c500adfb-ff7a-4f0c-bace-3867903f26c9
# ╠═321324ec-6276-11eb-037e-a3dd8d4b02b1
# ╠═8d1dd157-c464-4e0f-b570-b04dac7e4782
# ╠═bc50a2ae-6270-11eb-1bb0-334a0d45a47c
# ╠═93844b20-624b-11eb-3950-afc439d44aaa
# ╠═67a3cf42-627a-11eb-2577-f5c57c66e8bb
# ╠═70a40ad2-627a-11eb-0d97-f7354da92712
# ╠═893dea14-6277-11eb-2b7b-fbe9186f3024
# ╠═c9ed747e-6274-11eb-1d1d-714cee58b5b1
# ╠═fb8a35e4-6274-11eb-3b46-efe966cee7fc
# ╠═3d221bf2-6275-11eb-0a52-a5bc0ced7120
# ╠═68b5d4ee-6274-11eb-0c36-5334c129f893
# ╠═45b660f0-6272-11eb-255f-292f6840e53a
# ╠═467f87ea-6273-11eb-3711-310ddb21835f
# ╠═665b9b94-6273-11eb-383f-496d56137094
# ╠═202bc43e-6271-11eb-1699-f1a49f4567a6
# ╠═189faa00-6271-11eb-0030-cb39dd021a06
# ╠═ee096014-6271-11eb-1709-ff7acd68917b
