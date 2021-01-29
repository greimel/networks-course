### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 5a27cdc8-330b-4c88-9fcd-ec885a0b7fe4
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.add(["LightGraphs", "CairoMakie", "UnPack", "OffsetArrays"])
	
	using CairoMakie
	
	CairoMakie.activate!(type = "png")
	using OffsetArrays
	using LightGraphs
	using LinearAlgebra, SparseArrays
	using LinearAlgebra: I
	using UnPack
end

# ╔═╡ 42009620-6249-11eb-076b-957a526b3731
A = let
	N = 10
	graph = StarGraph(N)
	A = adjacency_matrix(graph)
	
	A = A ./ dropdims(sum(A, dims=2), dims=2)
	A
end	

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

# ╔═╡ 8d1dd157-c464-4e0f-b570-b04dac7e4782
function impulse_response(T, A, param, shocked_nodes, ε₀; T_shock = 0, T₀=3)
	y = y₀(A, param)
	N = size(A, 2)
	
	x_axis = -T₀:T
	
	out = OffsetArray(zeros(T₀ + T + 1), x_axis)
	out[-T₀] = welfare(y, param)
	
	for t in (-T₀+1):T
		ε = zeros(N)
		if t ∈ T_shock 
			ε[shocked_nodes] = ε₀
		end
		y = y_next(y, ε, A, param)
		
		out[t] = welfare(y, param)
	end
	
	out ./ -out[-T₀] .+ 1
end

# ╔═╡ 93844b20-624b-11eb-3950-afc439d44aaa
let
	nodes = 1:10
	
	fig = Figure()
	
	col = CairoMakie.Colors.distinguishable_colors(10)
	
	ax = Axis(fig[1,1])
	
	for node in nodes
		output = impulse_response(10, A, param, node, -0.3, T_shock = 0:0)
		lines!(ax, parent(output), color = col[node], label = "node $node")
	end
	
	Legend(fig[1,2], ax)

	fig
end

# ╔═╡ Cell order:
# ╠═5a27cdc8-330b-4c88-9fcd-ec885a0b7fe4
# ╠═42009620-6249-11eb-076b-957a526b3731
# ╠═81137be8-fc96-47d9-8cd3-6d3f063b0994
# ╠═ce8503da-624c-11eb-063b-ffdf6629feeb
# ╠═14dad81f-8a1a-40ec-865e-bf3f6c45e1d5
# ╠═bd2b0378-624c-11eb-3784-f19680ec2540
# ╠═4a3e7cae-624d-11eb-1a67-336eb02a27d0
# ╠═cb0cd7b0-c619-4a60-8762-8b12fa4b2665
# ╠═48332d33-ef3d-4b92-8181-48148738dac9
# ╠═c500adfb-ff7a-4f0c-bace-3867903f26c9
# ╠═8d1dd157-c464-4e0f-b570-b04dac7e4782
# ╠═93844b20-624b-11eb-3950-afc439d44aaa
