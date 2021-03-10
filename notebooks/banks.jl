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

# ╔═╡ 999f094a-2f6b-11eb-0092-35e5ba473d17
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.add(PackageSpec(name = "DataAPI", version = "1.4"))
		Pkg.add(["SimpleWeightedGraphs", "LightGraphs", "MetaGraphs", "GraphDataFrameBridge", "StatsPlots", "DataFrames", "PlutoUI", "Underscores"])
	using LightGraphs, SimpleWeightedGraphs, MetaGraphs, GraphDataFrameBridge, SparseArrays, StatsPlots, DataFrames, PlutoUI, Underscores
end

# ╔═╡ 897916d0-30cb-11eb-19ba-c34c5c95e3b6
using LinearAlgebra

# ╔═╡ f8e7958e-2f75-11eb-1fbc-5d75c3f15774
weighted_adjacency_matrix(g::AbstractGraph) = (adjacency_matrix(g) .> 0) .* sparse(weights(g))

# ╔═╡ e610597e-819f-11eb-0873-77945a560e31


# ╔═╡ 1496f9b6-2e70-11eb-28ef-27fa4e2d12dc
md"# Financial networks"

# ╔═╡ e4369b64-2e5b-11eb-09f3-51b27a027763
md"""
## Interconnected balance sheets

Let us consider a financial market with three banks. The matrix $P$ describes the interbank network. If $p_{ij} > 0$ then bank $i$ has an obligation to pay something to bank $j$.
"""

# ╔═╡ c6421b54-2fed-11eb-0aff-65c50f94ef6f
@bind shock Slider(0:100, default=0, show_value=true)

# ╔═╡ 55b91a04-300b-11eb-1109-c5d9bf0108aa


# ╔═╡ 1a68b9bc-2f6a-11eb-2b3c-335990975b95
begin
	table = [
	(from = "A", to = "B", amount = 180),
	(from = "A", to = "X", amount = 180),
	(from = "X", to = "A", amount = 120),
	(from = "B", to = "C", amount = 100),
	(from = "B", to = "X", amount = 100),
	(from = "X", to = "B", amount = 30),
	(from = "C", to = "A", amount = 100),
	(from = "C", to = "D", amount = 100),
	(from = "C", to = "X", amount = 50),
	(from = "X", to = "C", amount = 160 - shock),
	(from = "D", to = "A", amount = 150),
	(from = "D", to = "X", amount = 150),
	(from = "X", to = "D", amount = 204)
	]
	df_edges = DataFrame(table)
	rename!(df_edges, :amount => :promise)
end

# ╔═╡ b811fe8c-2f6b-11eb-139d-99667df4dea2
network = MetaDiGraph(df_edges, :from, :to, weight=:promise)

# ╔═╡ 5010c036-2f73-11eb-2e20-c1048a6418ac
P = weighted_adjacency_matrix(network)

# ╔═╡ d7d6c528-2e5c-11eb-29bd-a528fdfd0cea
md"""
Then the sum of the $i$th column are the inside assets of bank $i$ and the sum of the $i$th row are the inside liabilities.

Note that I added a fifth node ``X``, representing the outside.
"""

# ╔═╡ 16f81466-2f78-11eb-2c81-551d200818c4
inside(P) = @view P[1:end-1,1:end-1]

# ╔═╡ 1f306afa-2e6f-11eb-2852-139a43570482
inside_assets = sum(inside(P), dims=1)

# ╔═╡ 510de79c-2fee-11eb-06c1-7d7b1ddc73e4
inside_assets

# ╔═╡ 37ae210a-2e6f-11eb-05a6-b3ca0e4a453a
inside_liabs = sum(inside(P), dims=2) 

# ╔═╡ 5493f9ea-2fee-11eb-116b-e39cece05885
inside_liabs

# ╔═╡ 5e93b1a8-2e5c-11eb-1859-cf71c4ebd6ad
md"""
The three banks have outside assets and outside liabilities.
"""

# ╔═╡ 5195e4bc-2e5c-11eb-36f0-c74ad8677e04
outside_assets = P[end,1:end-1]

# ╔═╡ 68113e72-2e6f-11eb-2943-77d3062bd1a7
outside_liabs = P[1:end-1,end]

# ╔═╡ 6a6caae6-2fee-11eb-0049-85482dc0bf42
balance_sheets = DataFrame(
	:bank_id => ["A", "B", "C", "D"],
	:bank_id_int => [1, 2, 3, 4],
	:inside_assets => vec(collect(inside_assets)),
	:outside_assets => vec(collect(outside_assets)),
	:inside_liabs => vec(collect(inside_liabs)),
	:outside_liabs => vec(collect(outside_liabs))
	)

# ╔═╡ c180072e-2fee-11eb-26b6-439de97c8e31
begin
	asset_df = @_ balance_sheets |> 
	    rename(__, :inside_assets => :inside, :outside_assets => :outside) |>
		select(__, :bank_id, :bank_id_int, :inside, :outside) |>
	    stack(__, Not([:bank_id, :bank_id_int]), value_name = :assets) #|>
	    #transform!(__, :bank_id => (x -> "assets") => :variable)
		
	liabs_df = @_ balance_sheets |> 
	    rename(__, :inside_liabs => :inside, :outside_liabs => :outside) |>
		select(__, :bank_id, :bank_id_int, :inside, :outside) |>
	    stack(__, Not([:bank_id, :bank_id_int]), value_name = :liabs) #|>
	    #transform!(__, :bank_id => (x -> "assets") => :variable)
	
	asset_df
	
	balance_sheet_df = rightjoin(asset_df, liabs_df, on=[:bank_id, :bank_id_int, :variable])
end	

# ╔═╡ c0f15350-3005-11eb-13c3-77f8606b7b01
begin
	@df balance_sheet_df groupedbar(:bank_id_int .- 0.225, :assets, group=:variable, bar_position=:stack, bar_width = 0.4, color = [1 1], alpha = [0.5 1.0])
	@df balance_sheet_df groupedbar!(:bank_id_int .+ 0.225, :liabs, group=:variable, bar_position=:stack, bar_width = 0.4, color=[2 2], alpha=[0.5 1.0])
	
	xticks!(1:4, ["A", "B", "C", "D"])
end

# ╔═╡ edf47f2c-2e6f-11eb-0490-b325aa95f4d9
md"All these define the net worth."

# ╔═╡ 735aa746-2e6f-11eb-048f-f30bc64688ec
networth = vec(inside_assets) .+ vec(outside_assets) .- vec(inside_liabs) .- vec(outside_liabs)

# ╔═╡ 002fa19c-2fee-11eb-340a-6761abf75578
networth

# ╔═╡ 5172a546-2f78-11eb-184b-496564964f0b
md"""
We could have gotten there using the outside node.
"""

# ╔═╡ b5d6962a-3036-11eb-317b-59961a94297f


# ╔═╡ 557616c0-3036-11eb-0237-739914b1171e
assets(P) = vec(dropdims(sum(P, dims=1), dims=1))

# ╔═╡ 5e5c9980-3036-11eb-2d53-7dac0d7597f9
liabilities(P) = vec(dropdims(sum(P, dims=2), dims=2))

# ╔═╡ 481e1be4-3036-11eb-3c9f-854a269ffb7f
net_worth(P) = assets(P) .- liabilities(P)

# ╔═╡ 33ac3a9c-2e74-11eb-29ca-1b58c4ad2b47
nw = net_worth(P)[1:end-1]

# ╔═╡ 99b3e4fa-2fed-11eb-27d4-2d8fabc915df
md"""
## Contagion and default cascades

What happens if the networth of a bank turns negative? Let's assume that banks default as soon as they cannot repay their debt.

How is the bank resolved?

1. Selling all the assets until ...
	
   * withdraw interbank deposits
   
   * liquidate long-term assets at discount

2. ... there are enough assets


 $C$ is left with assets worth 140. It's liabilities are 100 to $D$ and $A$ and 50 to $X$.

So the assets are paid in shares to these three 

"""

# ╔═╡ 287a8db0-3036-11eb-0fdd-2fa1f6cd8112


# ╔═╡ 040b3912-3038-11eb-2576-9b149ca43797
function iterate_defaults(P)
	net_worth_banks = net_worth(P)[1:end-1]
	i = findfirst(net_worth_banks .< 0)
	if isnothing(i)
		return P
	else
		# determine creditors
		liabs_i = P[i, :]
		share_liabs = liabs_i ./ sum(liabs_i)
		# split up i's assets amount creditors
		assets_i = P[:, i]	
		P_next = copy(P)
		for (j,share) in enumerate(share_liabs)
			P_next[:,j] .+= assets_i .* share
		end
		# wipe out bank i
		P_next[:,i] .= 0 # set assets to zero
		P_next[i, :] .= 0
	
		return P_next
	end
end

# ╔═╡ 1bcaecf2-303b-11eb-1eb0-e37ce6b6eeab
P1 = iterate_defaults(P)

# ╔═╡ b663b536-3037-11eb-2404-8d2647d3b920
net_worth(P1)

# ╔═╡ 552bc870-3038-11eb-08c6-61c57e91fe9e

P2 = iterate_defaults(P1)

# ╔═╡ 659c5f10-3037-11eb-2c52-c79a9ba4a92e
net_worth(P2)

# ╔═╡ 31663f12-3036-11eb-2a9a-4fa49ee4034a
P3 = iterate_defaults(P2)

# ╔═╡ 6864e7dc-303b-11eb-1b50-1b6ad01ee6c5
net_worth(P3)

# ╔═╡ cd476e30-30bb-11eb-3d74-3dfe163dd8d6
md"""
## The model of Eisenberg & Noe (2001)

The ingredients to the model are

* a matrix $P$ of promised payments within the network (liabilities)
* a vector $c$ of outside assets
* a vector $b$ of promised payments to the outside (outside liabilities)
"""

# ╔═╡ 0e7d6f9e-30bc-11eb-3f88-4fcc09d61b63
begin
	P̄ = Matrix(P[1:end-1, 1:end-1])
	b = Vector(P[1:end-1,end]) # outside liabilities
	c = Vector(P[end,1:end-1]) # outside assets
end

# ╔═╡ 0ac15288-30be-11eb-2b1d-1f9ed94ea488
md"We can compute the total liabilites of each bank $\bar p_i$,"

# ╔═╡ e14e1c92-30bd-11eb-29e7-87c1674ec2b8
p̄ = dropdims(sum(P̄, dims=2), dims=2) .+ b

# ╔═╡ e1ed618e-30be-11eb-37ce-bd8bb93bcdc9
in_assets = dropdims(sum(P̄, dims=1), dims=1)

# ╔═╡ b9a50b18-30bd-11eb-094b-c3a2fdaff2ee
md"the net worth given a shock $x_i$,"

# ╔═╡ fbef0f7e-30be-11eb-1bd2-a394c853240f
w(x) = c .- x .+ in_assets .- p̄

# ╔═╡ 40d62298-30c5-11eb-1919-adfabb15618c
md"""
### Choose the shocks

* ``x_1``: $(@bind x₁ Slider(0:10:c[1], default=0, show_value=true))
* ``x_2``: $(@bind x₂ Slider(0:10:c[2], default=0, show_value=true))
* ``x_3``: $(@bind x₃ Slider(0:10:c[3], default=0, show_value=true))
* ``x_4``: $(@bind x₄ Slider(0:10:c[4], default=0, show_value=true))

"""


# ╔═╡ 223dd138-30bf-11eb-2d6a-a7340ed947ec
x = [x₁, x₂, x₃, x₄]

# ╔═╡ 47a45546-30bf-11eb-118c-7d900bedcbbc
w(x)

# ╔═╡ a0373756-30be-11eb-1969-35f00a6e69e2
md"and the *relative liability matrix* $A$,"

# ╔═╡ 27a3fc5c-30be-11eb-3911-7facf5496e02
A = P̄ ./ p̄

# ╔═╡ d84ab20c-30bf-11eb-0101-07f064187474
p₀ = copy(p̄)

# ╔═╡ 1a69698e-30c6-11eb-321f-afab06b8b793
md" ### Fictious default algorithm"

# ╔═╡ e1874e52-30bf-11eb-2415-371a7a1268a7
Φ(p) = min.(p̄, max.(0, c - x + A' * p))

# ╔═╡ 7407ffc2-30c2-11eb-0c3a-ede79dd93218
(Φ ∘ Φ ∘ Φ ∘ Φ ∘ Φ)(p₀)

# ╔═╡ ffd515c6-30c2-11eb-01d8-73cd3aca3285
out = let pₚᵣₑᵥ = copy(p₀)
	i = 0
	for ii in 1:50
		i = ii
		pₙ = Φ(pₚᵣₑᵥ)
		if pₙ ≈ pₚᵣₑᵥ
			break
		end
		pₚᵣₑᵥ .= pₙ 
	end
	
	p = pₚᵣₑᵥ
	(; i, p)
end

# ╔═╡ a8fd604e-30c4-11eb-2eaf-b9780c470802
default = out.p .< p̄

# ╔═╡ ce22d31a-30cc-11eb-2c23-53ea03759cb4
md"Computing the actual payments (?)"

# ╔═╡ afec8e8c-30c9-11eb-0fd0-c935cdb8d653
PP = diagm(.!default) * P̄ + diagm(default) * diagm(out.p) * A 

# ╔═╡ Cell order:
# ╠═999f094a-2f6b-11eb-0092-35e5ba473d17
# ╠═f8e7958e-2f75-11eb-1fbc-5d75c3f15774
# ╟─e610597e-819f-11eb-0873-77945a560e31
# ╟─1496f9b6-2e70-11eb-28ef-27fa4e2d12dc
# ╟─e4369b64-2e5b-11eb-09f3-51b27a027763
# ╠═c6421b54-2fed-11eb-0aff-65c50f94ef6f
# ╠═c0f15350-3005-11eb-13c3-77f8606b7b01
# ╠═002fa19c-2fee-11eb-340a-6761abf75578
# ╠═510de79c-2fee-11eb-06c1-7d7b1ddc73e4
# ╠═5493f9ea-2fee-11eb-116b-e39cece05885
# ╠═55b91a04-300b-11eb-1109-c5d9bf0108aa
# ╟─6a6caae6-2fee-11eb-0049-85482dc0bf42
# ╟─c180072e-2fee-11eb-26b6-439de97c8e31
# ╠═1a68b9bc-2f6a-11eb-2b3c-335990975b95
# ╠═b811fe8c-2f6b-11eb-139d-99667df4dea2
# ╠═5010c036-2f73-11eb-2e20-c1048a6418ac
# ╠═d7d6c528-2e5c-11eb-29bd-a528fdfd0cea
# ╠═16f81466-2f78-11eb-2c81-551d200818c4
# ╠═1f306afa-2e6f-11eb-2852-139a43570482
# ╠═37ae210a-2e6f-11eb-05a6-b3ca0e4a453a
# ╟─5e93b1a8-2e5c-11eb-1859-cf71c4ebd6ad
# ╠═5195e4bc-2e5c-11eb-36f0-c74ad8677e04
# ╠═68113e72-2e6f-11eb-2943-77d3062bd1a7
# ╟─edf47f2c-2e6f-11eb-0490-b325aa95f4d9
# ╠═735aa746-2e6f-11eb-048f-f30bc64688ec
# ╟─5172a546-2f78-11eb-184b-496564964f0b
# ╠═b5d6962a-3036-11eb-317b-59961a94297f
# ╠═33ac3a9c-2e74-11eb-29ca-1b58c4ad2b47
# ╠═557616c0-3036-11eb-0237-739914b1171e
# ╠═5e5c9980-3036-11eb-2d53-7dac0d7597f9
# ╠═481e1be4-3036-11eb-3c9f-854a269ffb7f
# ╟─99b3e4fa-2fed-11eb-27d4-2d8fabc915df
# ╠═287a8db0-3036-11eb-0fdd-2fa1f6cd8112
# ╠═040b3912-3038-11eb-2576-9b149ca43797
# ╠═1bcaecf2-303b-11eb-1eb0-e37ce6b6eeab
# ╠═b663b536-3037-11eb-2404-8d2647d3b920
# ╠═552bc870-3038-11eb-08c6-61c57e91fe9e
# ╠═659c5f10-3037-11eb-2c52-c79a9ba4a92e
# ╠═31663f12-3036-11eb-2a9a-4fa49ee4034a
# ╠═6864e7dc-303b-11eb-1b50-1b6ad01ee6c5
# ╟─cd476e30-30bb-11eb-3d74-3dfe163dd8d6
# ╠═0e7d6f9e-30bc-11eb-3f88-4fcc09d61b63
# ╟─0ac15288-30be-11eb-2b1d-1f9ed94ea488
# ╠═e14e1c92-30bd-11eb-29e7-87c1674ec2b8
# ╠═e1ed618e-30be-11eb-37ce-bd8bb93bcdc9
# ╟─b9a50b18-30bd-11eb-094b-c3a2fdaff2ee
# ╠═fbef0f7e-30be-11eb-1bd2-a394c853240f
# ╟─40d62298-30c5-11eb-1919-adfabb15618c
# ╠═223dd138-30bf-11eb-2d6a-a7340ed947ec
# ╠═47a45546-30bf-11eb-118c-7d900bedcbbc
# ╟─a0373756-30be-11eb-1969-35f00a6e69e2
# ╠═27a3fc5c-30be-11eb-3911-7facf5496e02
# ╠═d84ab20c-30bf-11eb-0101-07f064187474
# ╟─1a69698e-30c6-11eb-321f-afab06b8b793
# ╠═e1874e52-30bf-11eb-2415-371a7a1268a7
# ╠═7407ffc2-30c2-11eb-0c3a-ede79dd93218
# ╠═ffd515c6-30c2-11eb-01d8-73cd3aca3285
# ╠═a8fd604e-30c4-11eb-2eaf-b9780c470802
# ╟─ce22d31a-30cc-11eb-2c23-53ea03759cb4
# ╠═897916d0-30cb-11eb-19ba-c34c5c95e3b6
# ╠═afec8e8c-30c9-11eb-0fd0-c935cdb8d653
