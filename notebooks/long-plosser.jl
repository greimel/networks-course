### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 5a27cdc8-330b-4c88-9fcd-ec885a0b7fe4
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.add(["LightGraphs", "Plots"])
	
	using Plots
	using LightGraphs
	using LinearAlgebra, SparseArrays
	using LinearAlgebra: I
end

# ╔═╡ 30b58d5b-4e94-46dc-8df0-412d78d7cf18
N = 10

# ╔═╡ 0dba5b6c-aa85-4873-b056-0b04466727bb
begin
	α = 0.3
	graph = CompleteGraph(N)
	A = adjacency_matrix(graph)
	#A = Diagonal(1 ./ dropdims(sum(A, dims=2), dims=2)) * A
	A = A ./ dropdims(sum(A, dims=2), dims=2)
	A .*= α
	b = fill(1-α, N)
	H = 1
end

# ╔═╡ 34ae34c4-3914-4383-958c-ebd63326840e


# ╔═╡ bc409e64-1f36-4728-96c9-b3ce7f137ad7
A

# ╔═╡ b50b8679-bd7e-480e-b796-ba0fe2f33eaa


# ╔═╡ 81137be8-fc96-47d9-8cd3-6d3f063b0994
begin
	θ = fill(1/(N+1), N) # utility weights of commodities
	θ₀ = 1/(N+1) # utility weight of leisure
	β = 0.95
end

# ╔═╡ 14dad81f-8a1a-40ec-865e-bf3f6c45e1d5
γ = (I - β * A) \ θ

# ╔═╡ a4cfa192-c7cf-42b6-9b45-265919eab03b
λ(t) = randn(N)

# ╔═╡ aa3f8506-9b95-4f7e-9523-6d6629371397
Y = rand(N)

# ╔═╡ 22923a7e-649e-4b29-a309-db9ab3b5c0a9
C = θ ./ γ .* Y

# ╔═╡ a56ed1f0-38b1-496d-bda0-c55a3561a54b
X(i,j) = β * γ[i] * A[i,j] / γ[j] * Y[j]

# ╔═╡ c87ae200-392f-4252-a93e-fe957caf48a2
[X(i,j) for i in 1:N, j in 1:N]

# ╔═╡ b06e2fd6-13c4-4364-816e-469aa76da607
L = β .* γ .* (1-α) ./ (θ₀ + (1-α) * β * sum(γ)) .* H

# ╔═╡ cb0cd7b0-c619-4a60-8762-8b12fa4b2665
begin
	κ = (1 - α) .* log.(L)
	for i in 1:N
		tmp = sum(A[i,j] == 0 ? 0 : A[i,j] * log(β * γ[i] * A[i,j] / γ[j]) for j in 1:N)
		κ[i] = κ[i] + α * tmp
	end
	κ
end

# ╔═╡ 48332d33-ef3d-4b92-8181-48148738dac9
y₀ = (I - α * A) \ κ

# ╔═╡ c500adfb-ff7a-4f0c-bace-3867903f26c9
y_next(y, A, ε) = κ + α * A * y + ε

# ╔═╡ 8d1dd157-c464-4e0f-b570-b04dac7e4782
let T = 15
	y = copy(y₀)
	
	out = zeros(T)
	out[1:4] .= sum(y)
	
	ε = zeros(N)
	ε[5] = - 0.1
	
	y = y_next(y, A, ε)
	out[5] = sum(y)
	
	for i in 6:T
		y = y_next(y, A, zeros(10))
		out[i] = sum(y)
	end
	
	plot(out)
end

# ╔═╡ 6c0db202-d212-4ad5-b5af-bba77a151825
bar(exp.(y₀))

# ╔═╡ Cell order:
# ╠═5a27cdc8-330b-4c88-9fcd-ec885a0b7fe4
# ╠═30b58d5b-4e94-46dc-8df0-412d78d7cf18
# ╠═0dba5b6c-aa85-4873-b056-0b04466727bb
# ╠═34ae34c4-3914-4383-958c-ebd63326840e
# ╠═bc409e64-1f36-4728-96c9-b3ce7f137ad7
# ╠═b50b8679-bd7e-480e-b796-ba0fe2f33eaa
# ╠═81137be8-fc96-47d9-8cd3-6d3f063b0994
# ╠═14dad81f-8a1a-40ec-865e-bf3f6c45e1d5
# ╠═a4cfa192-c7cf-42b6-9b45-265919eab03b
# ╠═aa3f8506-9b95-4f7e-9523-6d6629371397
# ╠═22923a7e-649e-4b29-a309-db9ab3b5c0a9
# ╠═a56ed1f0-38b1-496d-bda0-c55a3561a54b
# ╠═c87ae200-392f-4252-a93e-fe957caf48a2
# ╠═b06e2fd6-13c4-4364-816e-469aa76da607
# ╠═cb0cd7b0-c619-4a60-8762-8b12fa4b2665
# ╠═48332d33-ef3d-4b92-8181-48148738dac9
# ╠═c500adfb-ff7a-4f0c-bace-3867903f26c9
# ╠═8d1dd157-c464-4e0f-b570-b04dac7e4782
# ╠═6c0db202-d212-4ad5-b5af-bba77a151825
