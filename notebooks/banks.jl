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

# ╔═╡ 999f094a-2f6b-11eb-0092-35e5ba473d17
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.add(["SimpleWeightedGraphs", "LightGraphs", "MetaGraphs", "GraphDataFrameBridge", "StatsPlots", "DataFrames", "PlutoUI", "Underscores", "LinearAlgebra"])
	using LightGraphs, SimpleWeightedGraphs, MetaGraphs, GraphDataFrameBridge, SparseArrays, StatsPlots, DataFrames, PlutoUI, Underscores
end

# ╔═╡ 1496f9b6-2e70-11eb-28ef-27fa4e2d12dc
md"# Financial networks"

# ╔═╡ e4369b64-2e5b-11eb-09f3-51b27a027763
md"""
## Interconnected balance sheets

Let us consider a financial market with three banks. The matrix $P$ describes the interbank network. If $p_{ij} > 0$ then bank $i$ has an obligation to pay something to bank $j$.
"""

# ╔═╡ 8e69201a-7cf0-11eb-3428-cd15be95f091
md"""
## Class Exercise 1: Fictitious default algorithm for 3 banks
"""

# ╔═╡ 581fc370-7ce0-11eb-0a61-15e69c08540f
md"""
### Set the shock vector
* ``x_1``: $(@bind x₁ Slider(0:10, default=0, show_value=true))
* ``x_2``: $(@bind x₂ Slider(0:10, default=0, show_value=true))
* ``x_3``: $(@bind x₃ Slider(0:10, default=0, show_value=true))

"""


# ╔═╡ 254fe852-7ce1-11eb-20e9-b963b97123a4
md"""
## Balance sheets after shock
"""

# ╔═╡ 671d22b8-7ce1-11eb-0a55-170755aa0506
md"""
#### Net worth (equity) of the banks
"""

# ╔═╡ 1a68b9bc-2f6a-11eb-2b3c-335990975b95

begin
	table = [
	(from = "X", to = "A", amount = 10 - x₁),
	(from = "A", to = "X", amount = 5),
	(from = "A", to = "B", amount = 3),
	(from = "A", to = "C", amount = 1),	
	(from = "X", to = "B", amount = 4 - x₂),
	(from = "B", to = "X", amount = 4),
	(from = "B", to = "C", amount = 2),
	(from = "X", to = "C", amount = 3.8 - x₃),
	(from = "C", to = "X", amount = 6)
	]
	df_edges = DataFrame(table)
	rename!(df_edges, :amount => :promise)
end

# ╔═╡ b811fe8c-2f6b-11eb-139d-99667df4dea2
network = MetaDiGraph(df_edges, :from, :to, weight=:promise)

# ╔═╡ d7d6c528-2e5c-11eb-29bd-a528fdfd0cea
md"""
Then the sum of the $i$th column are the inside assets of bank $i$ and the sum of the $i$th row are the inside liabilities.

Note that an extra node ``X`` was added, representing the outside.
"""

# ╔═╡ 16f81466-2f78-11eb-2c81-551d200818c4
inside(P) = @view P[1:end-1,1:end-1]

# ╔═╡ 5e93b1a8-2e5c-11eb-1859-cf71c4ebd6ad
md"""
The three banks have outside assets and outside liabilities.
"""

# ╔═╡ edf47f2c-2e6f-11eb-0490-b325aa95f4d9
md"All these define the net worth."

# ╔═╡ 5172a546-2f78-11eb-184b-496564964f0b
md"""
Or alternatively using the outside node.
"""

# ╔═╡ 557616c0-3036-11eb-0237-739914b1171e
assets(P) = vec(dropdims(sum(P, dims=1), dims=1))

# ╔═╡ 5e5c9980-3036-11eb-2d53-7dac0d7597f9
liabilities(P) = vec(dropdims(sum(P, dims=2), dims=2))

# ╔═╡ 481e1be4-3036-11eb-3c9f-854a269ffb7f
net_worth(P) = assets(P) .- liabilities(P)

# ╔═╡ 99b3e4fa-2fed-11eb-27d4-2d8fabc915df
md"""
## Contagion and default cascades

What happens if the networth of a bank turns negative? Let's assume that banks default as soon as they cannot repay their debt.

How is the bank resolved?

1. Selling all the assets until ...
	
   * withdraw interbank deposits
   
   * liquidate long-term assets at discount

2. ... there are enough assets


Example: after an initial shock of 7 to the asset value of bank $A$, it is left with assets worth 3. It's total liabilities are 9, that is, 3 to $B$, 1 to $C$ and 5 to $X$.

So the assets are paid in shares to $B$ and $C$ 

"""

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

# ╔═╡ bc2cca64-7d41-11eb-2bca-3920cdea2799
defaulting_bank(P) = 1*(net_worth(P)[1:end-1].<0)

# ╔═╡ cd476e30-30bb-11eb-3d74-3dfe163dd8d6
md"""
## The model of Eisenberg & Noe (2001)

The ingredients to the model are

* a matrix $P$ of promised payments within the network (liabilities)
* a vector $c$ of outside assets
* a vector $b$ of promised payments to the outside (outside liabilities)
"""

# ╔═╡ 0ac15288-30be-11eb-2b1d-1f9ed94ea488
md"We can compute the total liabilites of each bank $\bar p_i$,"

# ╔═╡ 223dd138-30bf-11eb-2d6a-a7340ed947ec
x = [x₁, x₂, x₃]

# ╔═╡ b9a50b18-30bd-11eb-094b-c3a2fdaff2ee
md"the net worth given a shock $x_i$,"

# ╔═╡ a0373756-30be-11eb-1969-35f00a6e69e2
md"The *relative liability matrix* $A$,"

# ╔═╡ 1a69698e-30c6-11eb-321f-afab06b8b793
md" ### Fictitious default algorithm"

# ╔═╡ b5fcacf6-7cea-11eb-33cf-1f00ec82e5b8
md"""
# Assignment 5: Default cascades
"""

# ╔═╡ 44a4a86a-7cea-11eb-03a3-fd95ba32cf4e
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ 61c84fb4-7cea-11eb-121d-a3105a0d206b
group_number = 99

# ╔═╡ a427475c-7cea-11eb-36c5-1366401d11ff
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the randomly generated names above by the names of your group and put the right group number in the above cell.
	"""
end

# ╔═╡ ec022592-7cea-11eb-3fbc-5de4f6053b67
md"""
### Task 1: Inspecting `iterate_defaults()` (4 points)

In this exercise we have a closer look at the implementation of the function `iterate_defaults()`, which is used above to iterate the steps in the default cascade.

"""

# ╔═╡ 6b80952c-7cef-11eb-11b8-f1f3ebcf6c29
md"""
👉 (1.1 | 2 points) 
Explain why iterating the function `iterate_defaults()` leads to convergence in at most $n$ steps, where $n$ is the number of banks. (<100 words)
"""

# ╔═╡ 1118c16a-7ceb-11eb-39dd-1bf0b131d7f4
answer11 = md"""
Your answer

goes here ...
"""

# ╔═╡ 75028acc-7cef-11eb-3d53-57a0c6cbc4f9
md"""
👉 (1.2 | 2 points) 
In each round the function `iterate_defaults()` only considers the first insolvent bank, and not, for instance the last. If at some point there are several banks that are insolvent, doesn't this make the result depend on the order in which the banks are labelled? Clearly and concisely explain why/why not. (<100 words)
"""

# ╔═╡ 8a71a2a8-7cef-11eb-3332-9771fa581810
answer12 = md"""
Your answer

goes here ...
"""

# ╔═╡ fb37222e-7cef-11eb-35bf-37c4fdcab766
md"""
### Task 2: Comparing different ways to obtain the clearing payments vector (6 points)

In this exercise we implement and compare different ways to obtain the clearing payments vector.

"""

# ╔═╡ 94aadf14-7cef-11eb-2cd8-ad20a985dbe5
md"""
👉 (2.1 | 3 points) 
Use the (iterated) output of `iterate_defaults()` to find the clearing payment vector and verify it (for several different initial balance sheet configurations) by comparing the output to that of  `Φ(p)`. (<200 words, excluding code)
"""

# ╔═╡ a569ea52-7cef-11eb-088e-99b9f97063c3
answer21 = md"""
Your answer

goes here ...
"""

# ╔═╡ aacfa932-7cef-11eb-1d7c-f58ff39631a0
md"""
👉 (2.2 | 3 points) 
As discussed in the lecture, if all banks default the clearing price can be expressed in terms of the network's Katz-Bonacich centrality.
Implement this method and verify the clearing payment vector (again for several different configurations) by comparing the output to that of `iterate_defaults()` and/or `Φ(p)`. (<200 words, excluding code)
"""

# ╔═╡ be050792-7cef-11eb-2743-c99bf7b85dbe
answer22 = md"""
Your answer

goes here ...
"""

# ╔═╡ 2a06bf42-7ceb-11eb-39a8-e1dcb8216637
md"""
#### Before you submit ...

👉 Make sure you have added your names and your group number above.

👉 Make sure that that **all group members proofread** your submission (especially your little essay).

👉 Make sure that you are **within the word limit**. Short and concise answers are appreciated. Answers longer than the word limit will lead to deductions.

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. In addition, **upload the source code** of the notebook (the .jl file).
"""

# ╔═╡ c34533bc-7cf2-11eb-2d42-c9e81081f95d
md"""
# Appendix
"""

# ╔═╡ 7d7467a6-7d1d-11eb-272b-3f875e224129
md"""
# Other stuff
"""

# ╔═╡ f8e7958e-2f75-11eb-1fbc-5d75c3f15774
#LightGraphs.adjacency_matrix(g::MetaDiGraph) = adjacency_matrix(network.graph) .* sparse(LightGraphs.weights(network))

weighted_adjacency_matrix(g::AbstractGraph) = (adjacency_matrix(g) .> 0) .* sparse(weights(g))

# ╔═╡ 5010c036-2f73-11eb-2e20-c1048a6418ac
P = weighted_adjacency_matrix(network);

# ╔═╡ 1f306afa-2e6f-11eb-2852-139a43570482
inside_assets = sum(inside(P), dims=1)

# ╔═╡ 510de79c-2fee-11eb-06c1-7d7b1ddc73e4
inside_assets

# ╔═╡ 37ae210a-2e6f-11eb-05a6-b3ca0e4a453a
inside_liabs = sum(inside(P), dims=2) 

# ╔═╡ 5493f9ea-2fee-11eb-116b-e39cece05885
inside_liabs

# ╔═╡ 5195e4bc-2e5c-11eb-36f0-c74ad8677e04
outside_assets = P[end,1:end-1]

# ╔═╡ 68113e72-2e6f-11eb-2943-77d3062bd1a7
outside_liabs = P[1:end-1,end]

# ╔═╡ 6a6caae6-2fee-11eb-0049-85482dc0bf42
balance_sheets = DataFrame(
#	:bank_id => ["A", "B", "C", "D"],
	:bank_id => ["A", "B", "C"],
#	:bank_id_int => [1, 2, 3, 4],
	:bank_id_int => [1, 2, 3],
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
	
#	xticks!(1:4, ["A", "B", "C", "D"])
	xticks!(1:3, ["A", "B", "C"])
end

# ╔═╡ 735aa746-2e6f-11eb-048f-f30bc64688ec
networth = vec(inside_assets) .+ vec(outside_assets) .- vec(inside_liabs) .- vec(outside_liabs)

# ╔═╡ 002fa19c-2fee-11eb-340a-6761abf75578
networth

# ╔═╡ 33ac3a9c-2e74-11eb-29ca-1b58c4ad2b47
nw = net_worth(P)[1:end-1]

# ╔═╡ 0c7ac7d8-7cd0-11eb-2efa-f1667a9260c6
net_worth(P)

# ╔═╡ 1bcaecf2-303b-11eb-1eb0-e37ce6b6eeab
P1 = iterate_defaults(P);

# ╔═╡ b663b536-3037-11eb-2404-8d2647d3b920
net_worth(P1)

# ╔═╡ 552bc870-3038-11eb-08c6-61c57e91fe9e

P2 = iterate_defaults(P1);

# ╔═╡ 659c5f10-3037-11eb-2c52-c79a9ba4a92e
net_worth(P2)

# ╔═╡ 31663f12-3036-11eb-2a9a-4fa49ee4034a
P3 = iterate_defaults(P2);

# ╔═╡ 6864e7dc-303b-11eb-1b50-1b6ad01ee6c5
net_worth(P3)

# ╔═╡ 0e7d6f9e-30bc-11eb-3f88-4fcc09d61b63
begin
	P̄ = Matrix(P[1:end-1, 1:end-1])
	b = Vector(P[1:end-1,end]) # outside liabilities
	c_minus_x = Vector(P[end,1:end-1]) # outside assets after shock at time 0
end

# ╔═╡ e14e1c92-30bd-11eb-29e7-87c1674ec2b8
p̄ = dropdims(sum(P̄, dims=2), dims=2) .+ b

# ╔═╡ d84ab20c-30bf-11eb-0101-07f064187474
p₀ = copy(p̄)

# ╔═╡ e1ed618e-30be-11eb-37ce-bd8bb93bcdc9
in_assets = dropdims(sum(P̄, dims=1), dims=1)

# ╔═╡ 27a3fc5c-30be-11eb-3911-7facf5496e02
A = P̄ ./ p̄

# ╔═╡ e1874e52-30bf-11eb-2415-371a7a1268a7
#Φ(p) = min.(p̄, c_minus_x + A' * p)
#
# The following version gives he same results (why?)
Φ(p) = min.(p, c_minus_x + A' * p)

# ╔═╡ 3e1f300e-7d13-11eb-0e56-696b3373af5c
(Φ )(p₀)

# ╔═╡ 80a148f2-7d1a-11eb-08cb-bfbefc26184f
(Φ ∘ Φ)(p₀)

# ╔═╡ 7407ffc2-30c2-11eb-0c3a-ede79dd93218
(Φ ∘ Φ ∘ Φ)(p₀)

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

# ╔═╡ 353c1ff6-7d1d-11eb-04f9-19de40f2909d
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

# ╔═╡ c9e1d91c-7d1c-11eb-27c3-933bb38fe109
md"(You have used approximately **$(wordcount(answer11))** words.)"

# ╔═╡ 4a4a4a08-7d1d-11eb-3a0e-4952fd0408e4
md"(You have used approximately **$(wordcount(answer12))** words.)"

# ╔═╡ d7bdfdc8-7d1b-11eb-0c52-bf940c2ab37b
md"(You have used approximately **$(wordcount(answer21))** words.)"

# ╔═╡ 614a40c0-7d1d-11eb-06fe-01398f390cc8
md"(You have used approximately **$(wordcount(answer22))** words.)"

# ╔═╡ Cell order:
# ╟─1496f9b6-2e70-11eb-28ef-27fa4e2d12dc
# ╟─e4369b64-2e5b-11eb-09f3-51b27a027763
# ╟─8e69201a-7cf0-11eb-3428-cd15be95f091
# ╟─581fc370-7ce0-11eb-0a61-15e69c08540f
# ╟─254fe852-7ce1-11eb-20e9-b963b97123a4
# ╟─c0f15350-3005-11eb-13c3-77f8606b7b01
# ╟─671d22b8-7ce1-11eb-0a55-170755aa0506
# ╠═002fa19c-2fee-11eb-340a-6761abf75578
# ╠═510de79c-2fee-11eb-06c1-7d7b1ddc73e4
# ╟─5493f9ea-2fee-11eb-116b-e39cece05885
# ╟─6a6caae6-2fee-11eb-0049-85482dc0bf42
# ╟─c180072e-2fee-11eb-26b6-439de97c8e31
# ╠═1a68b9bc-2f6a-11eb-2b3c-335990975b95
# ╠═b811fe8c-2f6b-11eb-139d-99667df4dea2
# ╠═5010c036-2f73-11eb-2e20-c1048a6418ac
# ╟─d7d6c528-2e5c-11eb-29bd-a528fdfd0cea
# ╠═16f81466-2f78-11eb-2c81-551d200818c4
# ╠═1f306afa-2e6f-11eb-2852-139a43570482
# ╠═37ae210a-2e6f-11eb-05a6-b3ca0e4a453a
# ╟─5e93b1a8-2e5c-11eb-1859-cf71c4ebd6ad
# ╠═5195e4bc-2e5c-11eb-36f0-c74ad8677e04
# ╠═68113e72-2e6f-11eb-2943-77d3062bd1a7
# ╟─edf47f2c-2e6f-11eb-0490-b325aa95f4d9
# ╠═735aa746-2e6f-11eb-048f-f30bc64688ec
# ╟─5172a546-2f78-11eb-184b-496564964f0b
# ╠═33ac3a9c-2e74-11eb-29ca-1b58c4ad2b47
# ╠═557616c0-3036-11eb-0237-739914b1171e
# ╠═5e5c9980-3036-11eb-2d53-7dac0d7597f9
# ╠═481e1be4-3036-11eb-3c9f-854a269ffb7f
# ╟─99b3e4fa-2fed-11eb-27d4-2d8fabc915df
# ╠═040b3912-3038-11eb-2576-9b149ca43797
# ╠═bc2cca64-7d41-11eb-2bca-3920cdea2799
# ╠═0c7ac7d8-7cd0-11eb-2efa-f1667a9260c6
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
# ╠═223dd138-30bf-11eb-2d6a-a7340ed947ec
# ╟─b9a50b18-30bd-11eb-094b-c3a2fdaff2ee
# ╟─a0373756-30be-11eb-1969-35f00a6e69e2
# ╠═27a3fc5c-30be-11eb-3911-7facf5496e02
# ╟─1a69698e-30c6-11eb-321f-afab06b8b793
# ╠═e1874e52-30bf-11eb-2415-371a7a1268a7
# ╠═d84ab20c-30bf-11eb-0101-07f064187474
# ╠═3e1f300e-7d13-11eb-0e56-696b3373af5c
# ╠═80a148f2-7d1a-11eb-08cb-bfbefc26184f
# ╠═7407ffc2-30c2-11eb-0c3a-ede79dd93218
# ╟─ffd515c6-30c2-11eb-01d8-73cd3aca3285
# ╠═a8fd604e-30c4-11eb-2eaf-b9780c470802
# ╟─b5fcacf6-7cea-11eb-33cf-1f00ec82e5b8
# ╠═44a4a86a-7cea-11eb-03a3-fd95ba32cf4e
# ╠═61c84fb4-7cea-11eb-121d-a3105a0d206b
# ╟─a427475c-7cea-11eb-36c5-1366401d11ff
# ╟─ec022592-7cea-11eb-3fbc-5de4f6053b67
# ╟─6b80952c-7cef-11eb-11b8-f1f3ebcf6c29
# ╠═1118c16a-7ceb-11eb-39dd-1bf0b131d7f4
# ╟─c9e1d91c-7d1c-11eb-27c3-933bb38fe109
# ╟─75028acc-7cef-11eb-3d53-57a0c6cbc4f9
# ╟─4a4a4a08-7d1d-11eb-3a0e-4952fd0408e4
# ╟─8a71a2a8-7cef-11eb-3332-9771fa581810
# ╟─fb37222e-7cef-11eb-35bf-37c4fdcab766
# ╟─94aadf14-7cef-11eb-2cd8-ad20a985dbe5
# ╟─a569ea52-7cef-11eb-088e-99b9f97063c3
# ╟─d7bdfdc8-7d1b-11eb-0c52-bf940c2ab37b
# ╟─aacfa932-7cef-11eb-1d7c-f58ff39631a0
# ╟─be050792-7cef-11eb-2743-c99bf7b85dbe
# ╟─614a40c0-7d1d-11eb-06fe-01398f390cc8
# ╟─2a06bf42-7ceb-11eb-39a8-e1dcb8216637
# ╟─c34533bc-7cf2-11eb-2d42-c9e81081f95d
# ╠═999f094a-2f6b-11eb-0092-35e5ba473d17
# ╟─7d7467a6-7d1d-11eb-272b-3f875e224129
# ╠═f8e7958e-2f75-11eb-1fbc-5d75c3f15774
# ╠═353c1ff6-7d1d-11eb-04f9-19de40f2909d
