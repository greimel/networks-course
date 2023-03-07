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


# ╔═╡ 8573d925-e4bd-4544-a264-b3a7ba8610a3
md"""
*Assignment submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ 2db89e2d-4d89-454d-bd1a-976a1f415623
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the randomly generated names above by the names of your group and put the right group number in [this cell](#93a79265-110d-4fb9-b2a7-97da4667f8c6).
	"""
end

# ╔═╡ 815648ae-78f2-42f1-a216-81b10c0a7850
md"""
`systemic-risk.jl` | **Version 1.2** | *last updated: Feb 28, 2022*
"""

# ╔═╡ c129dec7-eb81-4cab-91d5-2ef7a1c06b24
md"""
# Risk Sharing and Systemic Risk in Financial Networks

_Part A -- **Risk sharing** -- What's good about financial networks?_ \
based on _[Allen & Gale, 2000](https://www.jstor.org/stable/10.1086/262109), Journal of Political Economy_
* I. banks provide liquidity
* II. banks are fragile (subject to bank runs)
* III. an interbank market can **avoid default**, **prevent bank runs**

👉 _Part B -- **Systemic Risk** -- What's bad about financial networks?_ \
based on _[Acemoglu, Ozdaglar & Tahbaz-Salehi, 2015](https://www.aeaweb.org/articles?id=10.1257/aer.20130456), American Economic Review_

* I. Model setup
* II. **insolvency** and **bankruptcy** in the payment equilibrium
* III. **financial contagion**
* IV. **stability** and **resilience** of financial networks
  * more interbank lending leads to higher fragility
  * densely connected networks are **robust, yet fragile**
  * with **big shocks**, we want to have **disconnected components**
"""

# ╔═╡ 6060f7ec-52c1-4504-9fc9-dfaaff4c1109
md"""
# Assignment 3: Financial stability
"""

# ╔═╡ 1f9e1561-405d-4d49-a2ee-af2dfeb2d409
md"""
*submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ 4f30bb25-0f69-4c5a-948c-df89d75a0a24
md"""
!!! info "Note on Task 3"
    **Task 3** is not graded, but it will be discussed in the tutorial. You are invited to submit solutions for **Task 3**, but you don't have to.
"""

# ╔═╡ 07958953-43c8-441b-b6d6-6bcf0e027603
md"""
### Task 1: Imminent bank runs in Russia? (4 points)

Following the Russian aggression against Ukraine, the US and the EU have imposed sanctions on Russia. Some commentators point out the possibility of bank runs in the following days. (See, for example [this bloomberg article](https://www.bloomberg.com/news/articles/2022-02-26/u-s-weighs-sanctions-on-russia-s-central-bank-over-ukraine)).
"""

# ╔═╡ 88580398-8b68-4830-9df9-ec1a1aeaf243
md"""
👉 (1.1 | 2 points) Briefly summarize _(some of)_ the measures that target the Russian financial system. (<200 words)
"""

# ╔═╡ 186b1fe4-4462-4c0d-a874-256ee3e3f700
answer11 = md"""
Your answer goes here...
"""

# ╔═╡ b13cbc28-5658-4f24-879e-bd6c10f7c7f0
show_words_limit(answer11, 200)

# ╔═╡ f7a60a89-40b2-4656-98a6-a258a4a5741d
md"""
👉 (1.2 | 2 points) What do think will be the implications of these measures on financial stability in Russia? Aim at making a connection to _(some of)_ the models we discussed in the lecture (_Diamond & Dybvig (1983)_, _Allen & Gale (2000)_, _Acemoglu et al (2015)_) (<200 words)
"""

# ╔═╡ 70e40546-b5e8-45dc-86a0-bfbef5403e30
answer12 = md"""
Your answer goes here ...
"""

# ╔═╡ 0a7829f4-c3a9-488d-aacc-6e8a02c3ef79
show_words_limit(answer12, 200)

# ╔═╡ 496f01ef-6422-412b-9142-c3893476bc0d
md"""
### Task 2: _Systemic Risk_ (6 points)
"""

# ╔═╡ 1e38675b-3482-4f85-b4fa-f476e84fb520
out = let
	#n = 6
	#m = 3
	ȳ = 2.1
	#IM1 = InterbankMarket(CompleteNetwork(n, ȳ))
	#IM2 = InterbankMarket(IslandNetwork(n ÷ m, m, ȳ))
	IM1 = InterbankMarket(IslandNetwork([5, 3, 3], ȳ))
	IM2 = InterbankMarket(IslandNetwork([6, 2, 1, 1, 1], ȳ))

	n1 = size(IM1.network.Y, 1)
	n2 = size(IM2.network.Y, 1)
	if n1 == n2
		n = n1
	else
		n = (n1, n2)
	end
	
	fig = Figure()
	ax1 = Axis(fig[1,1], aspect = 1, title = L"interbank market $y$")
	ax2 = Axis(fig[1,2], aspect = 1, title = L"interbank market $\tilde{y}$")
	numbered_graphplot!(ax1, IM1; layout = componentwise_circle)
	numbered_graphplot!(ax2, IM2; layout = componentwise_circle)

	(; IM1, IM2, fig, n, ȳ)
end; out.fig

# ╔═╡ 21dd99b3-ee5b-46e5-adf5-9c9ff9448272
@markdown("""
Consider the interbank networks ``y`` and ``\\tilde y`` of $(out.n) banks as depicted above. For all non-isolated banks the sum of interbank liabilities equal the sum of interbank claims (``y = $(out.ȳ)``).
""")

# ╔═╡ febcd0aa-0a19-405c-b5ed-5c73dab8929c
md"""
For this exercise you can use the tool below, to simulate the payment equilibrium for a given interbank market, shock size, and the bank that is hit by the shock.

* Which bank is hit? ``i`` $(@bind i_bank Slider(1:out.n, default = 1, show_value = true))
* Size of the shock ``\varepsilon``  $(@bind _ε4 Slider(0.0:0.2:3.0, show_value = true, default = 1.0))
* Select ``y`` or ``\tilde y`` $(@bind _IM Select([out.IM1 => "y", out.IM2 => "ỹ"]))
"""

# ╔═╡ cee410bb-1470-41f9-8e98-b96591eac7ca
let
	IM = _IM
	i = i_bank
	#_ε4 = 0.4
	
	updated_network(IM) .= initial_network(IM)

	x = updated_network(IM)
	y = initial_network(IM)
	
	n_banks = size(y, 1)

	# failed bank
	bank₀ = Bank(; ν = 2.0, c = 0.0, project = Project(; ζ = 0.1, A = 3.5, a = 2.0, ε = _ε4), γ = Failure())
	# sucessful bank
	bank₁ = Bank(; ν = 2.0, c = 0.0, project = Project(; ζ = 0.1, A = 3.5, a = 2.0))

	# vector of banks
	banks = let
		banks = [fill(bank₁, n_banks-1); bank₀]
		banks .= Ref(bank₁)
		banks[i] = bank₀
		banks
	end
	visualize_equilibrium(equilibrium(banks, IM))
end

# ╔═╡ 6733025d-20f0-48cd-b6d8-0dfb02bb7482
md"""
👉 (2.1 | 2 points) Consider financial network ``y``. What is the minimal number of shocks ``p`` that have to occur to wipe out the whole financial system. Which banks have to be hit? How big would the shocks ``\varepsilon`` have to be?
"""

# ╔═╡ 33bf5bdd-6e13-4375-bf26-bdac273d6738
answer21 = md"""
Your answer goes here ... You can type math like this: ``p = 17``, ``\varepsilon = 1.1``
"""

# ╔═╡ 07fc0a5c-8d9f-46a7-9893-fefa23007878
md"""
👉 (2.2 | 2 points) Consider financial network ``\tilde y``. What is the minimal number of shocks ``\tilde p`` that have to occur to wipe out the whole financial system. Which banks have to be hit? How big would the shocks ``\tilde \varepsilon`` have to be?
"""

# ╔═╡ 1f52926c-fc07-4652-97a8-6abbdb3e3b5e
answer22 = md"""
Your answer goes here ... You can type math like this: ``\tilde p = 17``, ``\tilde \varepsilon = 1.1``
"""

# ╔═╡ e903ac6c-1b5c-40ea-a925-e7243cbf9b02
md"""
👉 (2.3 | 2 points) Now consider ``\hat \varepsilon > \max\{\varepsilon, \tilde \varepsilon \}`` and ``\hat p = 1``. Which network is more stable? Which network is more resilient?
"""

# ╔═╡ 751e1643-43c2-4071-87cf-a904560e2bc4
answer23 = md"""
Your answer goes here ... You can type math like this: ``\hat p = 17``, ``\hat \varepsilon = 1.1``
"""

# ╔═╡ 25dae65d-65a6-462f-aba2-afd498bf4d5a
md"""
### Before you submit ...

👉 Make sure you have added **your names** and **your group number** in the cells below.

👉 Make sure that that **all group members proofread** your submission (especially your little essays).

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. (The source code is embedded in the html file.)
"""

# ╔═╡ 93a79265-110d-4fb9-b2a7-97da4667f8c6
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ 3946c3f6-3044-42e4-b161-09f4394b7147
group_number = 99

# ╔═╡ 4712bc8d-4e63-47c9-8367-dc417f1a7649
md"""
### Task 3 (not graded): Avoiding a bank run
"""

# ╔═╡ 54722cbe-6a91-4275-a78c-8a50715b86c8
md"""
Consider the setup of Allen & Gale with banks ``i \in \{1, 2, 3, 4\}``. Banks know that a fraction ``\gamma`` of the population are _early types_. In the social optimum, banks offer deposit contracts ``(c_1, c_2)``. The fraction of early types ``\omega_i`` in each bank is random. There are three possible states ``S_j = (\omega_{1j}, \omega_{2j}, \omega_{3j}, \omega_{4j})``

```math
\begin{align}
S_1 &= (\gamma, \gamma, \gamma, \gamma) \\
S_2 &= (\gamma + \varepsilon, \gamma + \varepsilon, \gamma - \varepsilon, \gamma - \varepsilon) \\
S_3 &= (\gamma - \varepsilon, \gamma - \varepsilon, \gamma + \varepsilon, \gamma + \varepsilon) \\
\end{align}
```

The states are shown in the figure below. The red dots mean "more early customers" (``\gamma + \varepsilon``), the green dots mean "more late customers" (``\gamma - \varepsilon``) and the gray dots mean "no shock" (``\gamma``).
"""

# ╔═╡ eb1e20e7-9873-45bd-ae30-ed147a70b457
md"""
Select state (the ``i`` in ``S_i``): $(@bind i_state NumberField(1:length(states))).
"""

# ╔═╡ 28bbf56b-1bdf-486f-8230-b9a6ee19a955
let
	g = SimpleDiGraph(G_minimal)

	fig, ax, _ = minimal_graphplot(g;
		theme...,
		node_color = exX.color,
		nlabels = string.(vertices(g)),
		nlabels_offset = Point2(0.05, 0.05),
		exX.node_styles,
		axis = (title = latexstring("Interbank network in state \$ S_$i_state \$"), )
	)

	fig
end

# ╔═╡ 7f0bad7b-439a-4639-bba4-5f0a52560042
states = [
	[:none, :none, :none, :none],
	[:early, :early, :late, :late],
	[:late, :late, :early, :early],
]

# ╔═╡ 497c6314-6f0f-4d45-9bd2-17d6f6b00ab9
md"""
👉 **(a)** What is the minimal number of edges that will prevent a bank run in period ``t=1`` in state ``S_1``? Explain briefly.
"""

# ╔═╡ 3abaa20d-a24d-4b2f-8d8d-4e01b719ab5e
answer_a = md"""
Your answer goes here ...
"""

# ╔═╡ d41cd681-2434-4525-9c67-9e184fdd1f67
show_words(answer_a)

# ╔═╡ 9a8b8946-e083-49f3-8a86-7ba2df4636fe
md"""
👉 **(b)** What is the minimal number of edges that will prevent a bank run in period ``t=1`` in all possible states? Explain and adjust the adjacency matrix `G_minimal` accordingly.
"""

# ╔═╡ e7eb6784-e947-4a14-8227-888d4646855e
G_minimal = [
	0 1 1 1;
    0 0 1 1;
	1 0 0 1;
	1 1 0 0
]

# ╔═╡ 23bd3f41-7c81-4b15-a07c-720c3a393118
answer_b = md"""
Your answer goes here ...
"""

# ╔═╡ e6f4813b-86bb-45a8-b017-c2d32f3c74b0
show_words(answer_b)

# ╔═╡ 207d92a3-b8fa-45e3-88b1-bb95bb7d981c
md"""
👉 **(c)** Assume that your minimal network from **(a)** has _uniform weights_. What is the lower bound ``y_\text{min}`` for that weight that will allow the socially optimal allocation in all states?
"""

# ╔═╡ 5a12e196-99b2-4d45-b373-8aec03f6cc0e
answer_c = md"""
Your answer goes here ...
"""

# ╔═╡ be0f68e9-36ad-4500-b941-fe47e1865eba
show_words(answer_c)

# ╔═╡ 0a7b61c5-8e11-4025-b6ad-8fcfc2701464
md"""
👉 **(d)** What will happen if ``y < y_\text{min}``?
"""

# ╔═╡ f596a5cc-d291-4358-b568-9b3872bc2dc8
answer_d = md"""
Your answer goes here ...
"""

# ╔═╡ dcdd349e-3edb-413f-b315-994b9395c3bc
show_words(answer_d)

# ╔═╡ c177b994-cf6c-4a90-8d64-a4feef88fd56
md"""
👉 **(e)** Assume that there is a complete interbank network with a uniform weights to ensure the socially optimal allocation in all states. What would be an alternative state ``S_4`` in which the complete interbank network has a better outcome?
"""

# ╔═╡ 71185d5e-ae37-4571-b380-a5b9f2b65205
answer_e = md"""
Your answer goes here ...
"""

# ╔═╡ 75b27e3b-f8b3-4345-ac43-2974d624ea72
show_words(answer_e)

# ╔═╡ 942580bf-60d3-49fe-be2a-2fab9869322d
md"""
# Part B -- *Systemic risk in financial networks*
"""

# ╔═╡ 0cb23460-2db6-4327-a01c-a013eb471a9e
md"""
## I. Model setup
"""

# ╔═╡ b542043b-b4ac-4207-b092-18b283c65524
md"""
### Interbank market – A network of promises

```math
y_{ij} > 0 \iff i \to j \iff
\begin{cases}
\text{$i$ promises to pay to $j$} \\
\text{$i$ has a liability with $j$} \\
\end{cases}
```


```math
(y_{ij}) = \begin{pmatrix} 
y_{11} & y_{12} & \cdots & y_{1j} & \cdots & y_{1n} \\
y_{21} & y_{22} & \cdots & y_{2j} & \cdots & y_{2n} \\
\vdots & \vdots & \ddots & \vdots & \ddots & \vdots \\
y_{i1} & y_{i2} & \cdots & y_{ij} & \cdots & y_{in} \\
\vdots & \vdots & \ddots & \vdots & \ddots & \vdots \\
y_{n1} & y_{n2} & \cdots & y_{nj} & \cdots & y_{nn}
\end{pmatrix}
```

The promises (payables) of bank ``i`` are ``\begin{pmatrix}y_{i1} & y_{i2} & \cdots & y_{in}\end{pmatrix}``

and the claims (receivables) of bank ``j`` are ``\begin{pmatrix} y_{1j} \\ y_{2j} \\ \vdots \\ y_{nj}
\end{pmatrix}``.

"""

# ╔═╡ 60615cd2-aa70-47e9-b432-b4051e17f628
begin
	n_banks = 3
	ȳ = 2.1
	nw = CompleteNetwork(n_banks, ȳ)
	IM = InterbankMarket(nw)

	numbered_graphplot(SimpleWeightedDiGraph(nw.Y),
		extend_limits = 0.1,
		figure = figure(220)
	)
end

# ╔═╡ e454ff61-2769-4095-8d0c-6958f79338ee
payables(IM)

# ╔═╡ b09eb768-f645-441d-a943-8c2fe373fd08
receivables(IM)

# ╔═╡ b309cc56-598f-4bd4-a523-edbbb850db58
# paid(IM)

# ╔═╡ 141e0dd3-a9bb-4ea6-8686-e18a2628d926
# received(IM)

# ╔═╡ e3ae420b-1d40-4d2d-99f3-728cfb8ca167
md"""
#### Ring, complete network and their mixtures
"""

# ╔═╡ 7d55098d-2665-44ec-a959-91e591ccc70e
md"""
specify the mixture parameter ``\gamma``: $(@bind _γ_ Slider(0:0.1:1, show_value = true, default = 0.5))
"""

# ╔═╡ 5e3fb6e9-eacb-4e4b-9a62-83632263be37
let	
	n = γNetwork(5, 0.5, _γ_)
	g = SimpleWeightedDiGraph(n.Y)
	
	numbered_graphplot(g; 
		extend_limits = 0.1,
		figure = figure(220),
		axis = (; title = label(n))
	)
end

# ╔═╡ 8f0dc26b-45c3-44ac-a0db-73e42b09f46b
md"""
#### Island network
"""

# ╔═╡ f1555793-db56-4b4c-909d-c8f3bf6cd857
md"""
* specify number of islands $(@bind _n_islands Slider(1:6, show_value = true, default = 4))
* specify the number of banks per island $(@bind _n_banks Slider(1:10, show_value = true, default = 5))
"""

# ╔═╡ d14e0faa-4509-46aa-bfe1-0ba89d04c8c7
let
	g = SimpleWeightedDiGraph(island_network(_n_islands, _n_banks, 0.5))

	numbered_graphplot(g; 
		extend_limits = 0.1,
		figure = figure((row_col(_n_islands) .* 220)...),
	)
end

# ╔═╡ 99b10989-c757-43e7-8fd2-65f8a5377023
function row_col(n)
	n_col = ceil(Int, √n)
	n_row = ceil(Int, n / n_col)
	(n_col, n_row)
end

# ╔═╡ d385bc7e-d9e9-4f61-a455-9973262bd37a
banks = let
	ν = 2.3
	c = 2.4
	ε = 2.4 # ȳ + 0.1 + 0.1 #4
	[Bank(; ν = ν, c = max(c - ε, 0)); fill(Bank(; ν, c), n_banks - 1)]
end

# ╔═╡ 9a771f35-8f15-4abc-a093-4b5cb84b909a
md"""
### Projects (i.e. illiquid assets)

The project pays ``z_i \in \{a, a-\varepsilon\}`` in period 1 and ``A`` in period two. The project can be liquidated in period on, paying ``(z_i + \ell \zeta A, 0)`` where ``\ell \in (0, 1]`` is the fraction liquidated.
"""

# ╔═╡ 1a7df5c9-3036-44a7-9eba-42ef4851d9ae
Base.@kwdef struct Project{T}
	"Payoff in ``t=2`` aa"
	A::T = 0
	"recoverable fraction when liquidating"
	ζ::T = 0
	"payoff in ``t=1``"
	a::T = 0
	"reduction of payoff after failure"
	ε::T = 0
	function Project(A, ζ, a, ε)		
		new{Float64}(float(A), float(ζ), float(a), float(ε))
	end
end

# ╔═╡ 7c7ba04a-fc84-4ca2-a903-faf1fae0a839
begin
	abstract type Outcome end
	struct Success <: Outcome end
	struct Failure <: Outcome end
end

# ╔═╡ 4d4cf195-0eef-4873-b8f8-b82c48ee6f26
begin
	function payoff(project, γ, ℓ)
		(; ζ, A) = project
		payoff(project, γ) + ℓ * A * ζ
	end
	
	payoff(project, γ::Success) = project.a
	payoff(project, γ::Failure) = project.a - project.ε
end

# ╔═╡ 3968e7cf-b56b-4e36-a89c-aea6840986d2
let
	project = Project(2.0, 0.8, 1.0, 0.5)
	
	π₁ = payoff(project, Success())
	π₂ = payoff(project, Success(), 0.75)
	π₃ = payoff(project, Failure())
	
	#(; π₁, π₂, π₃)
end

# ╔═╡ 3052a997-5084-4005-8985-7be98a08d659
md"""
### Banks
"""

# ╔═╡ ec82cd1e-6d3f-11ec-18d7-8dd51f5446de
Base.@kwdef struct Bank{T, O<:Outcome}
	ν::T = 4.5 # outside (senior) obligation (liability)
	c::T = 0.0 # outside (senior) asset (cash)
	project::Project{T} = Project()
	γ::O = Success()
end

# ╔═╡ c4ccc5ad-618d-4635-9d52-13be0df55198
md"""
## II. Insolvency, Bankruptcy and the Payment Equilibrium
"""

# ╔═╡ 37acf7b5-f93e-4ec9-9807-b247544713ed
_a = 5.0

# ╔═╡ 8377503b-4556-4dc0-9d15-330bdd4100e6
md"""
specify the shock ``\varepsilon`` $(@bind _ε1 Slider(0:0.1:_a, show_value = true, default = 0))
"""

# ╔═╡ 83817687-0e03-4be0-a66b-e74dcd300b15
let
	bank = Bank(; c = 0.5, project = Project(ζ = 0.5, A = 2, a = _a, ε = _ε1), γ = Failure())
	(; ν, c, project) = bank
	(; a, A, ζ) = project
	x, y = 1.7, 1.7

	(; ℓ, y_pc, ν_pc) = repayment(bank, x, y)

	bs_max = max(A + x + c + a, y + ν) * 1.05
	
	df = [
		(type = "liabs", spec = "1. senior liab (deposits) ν", value = ν_pc * ν),
		(type = "liabs", spec = "2. junior liab (interbank) y", value = y_pc * y),
		(type = "assets", spec = "3. early payoff a - ε", value = a - _ε1),
		(type = "assets", spec = "4. liquid assets x + c", value = x + c),
		(type = "assets", spec = "5. liquidated assets ℓ ζ A", value = ℓ * ζ * A),
		(type = "assets", spec = "6. illiquid asset (project) A", value = (1-ℓ) * A)
			] |> DataFrame
	@chain df begin
		data(_) * visual(BarPlot) * mapping(
			:type => "", :value, stack = :spec, color = :spec
		)
		draw(; axis = (limits = (nothing, nothing, nothing, bs_max),))
	end

	#(; ℓ, y_pc, ν_pc)
end

# ╔═╡ f8271303-ab1f-486a-aa34-8f1dc6b33cd2
let
	out = map(0:0.05:5.5) do ε
		project = Project(; a = 5.5, ε, ζ = 0.5, A = 3.5)
		bank = Bank(; ν = 4.7, c = 0.0, project, γ = Failure())
		i_bank = 1

		(; ε, repayment(bank, i_bank, IM)...)
	end 
	
	@chain out begin
		DataFrame
		stack([:ℓ, :y_pc, :ν_pc])
		@transform!(:panel = :variable == "ℓ" ? "liquidated" : "repaid")
		@transform!(:variable = @bycol recode(:variable, 
			"y_pc" => "% repaid (interbank)",
			"ν_pc" => "% repaid (outside)",
			"ℓ" => "% liquidated"
			)
		)
		data(_) * visual(Lines) * mapping(
			:ε => "size of shock ε",
			:value => "",
			color = :variable => "",
			row = :panel)
		draw(; legend = (position = :top, titleposition = :left))
	end
end

# ╔═╡ f3e015f2-33e1-4b2f-b34a-ee6a5751d96b
md"""
## III. Financial contagion
"""

# ╔═╡ 27039532-1c2b-4aee-858e-f9f0a135e62f
md"""
!!! note "Note"
    The plot only shows interbank assets and liabilities.
"""

# ╔═╡ 2ed68cbb-7e5b-4d17-9cb3-4f9404b63365
visualize_equilibrium(peq)

# ╔═╡ 6e3907db-9c66-4805-853b-11877c23a1d6
md"""
specify the shock ``\varepsilon`` $(@bind _ε3 Slider(0.0:0.2:2.0, show_value = true, default = 1.0))
"""

# ╔═╡ d07fa3a9-6687-4279-8fe7-e348152b18f4
peq = let
	ȳ = 2.5 # 0.2
	n_banks = 4
	#nw = CompleteNetwork(n_banks, ȳ)
	nw = RingNetwork(n_banks, ȳ)
	#nw = IslandNetwork(2, n_banks ÷ 2, ȳ)

	IM = InterbankMarket(nw)
	
	updated_network(IM) .= initial_network(IM)

	x = updated_network(IM)
	y = initial_network(IM)
	
	n_banks = size(y, 1)

	bank₀ = Bank(; ν = 2.0, c = 0.0, project = Project(; ζ = 0.1, A = 3.5, a = 2.0, ε = _ε3), γ = Failure())
	bank₁ = Bank(; ν = 2.0, c = 0.0, project = Project(; ζ = 0.1, A = 3.5, a = 2.0))
	banks = [bank₀; fill(bank₁, n_banks-1)]

	equilibrium(banks, IM)
end

# ╔═╡ 78a45e6a-a772-4fa7-bd9c-d728d5ea79e8
md"""
## IV. Systemic Risk: Stability and Resilience
"""

# ╔═╡ e9e6c131-c334-4674-9384-273cd40929dc
using Colors, LaTeXStrings

# ╔═╡ 3726a99d-8024-4fec-a047-43d370f795d9
blues(n) = range(colorant"lightblue", colorant"darkblue", length = n)

# ╔═╡ d649a654-e515-40b4-a45b-e095f1d12da7
md"""
### 1. More interbank lending leads to less stability and less resilience

Formally, for a given regular financial network ``(y_{ij})`` let ``\tilde y_{ij} = \beta y_{ij}`` for ``\beta > 1``. Financial network ``\tilde y`` is less resilient and less stable *(see __Proposition 3__)*.

* _Proposition 3_: More interbank lending leads to a more fragile system. (For a given network topology, the defaults are increasing in ``\bar y``.)
"""

# ╔═╡ 76f41f57-2971-4020-ab2f-87fad4a92489
shocks = (ε̲ = 1.0, ε̄ = 1000.0)

# ╔═╡ 2b7c65fe-8bf8-47f2-96b1-6dfe8888d494
let ε = 1.2
	ȳ_vec = 0.1:0.1:2
	γ_vec = 0:0.2:1.0

	p = 1
	n_banks = 10
	project = Project(; A = 2.0, ζ = 0.0, a = 5.6, ε)
	banks = [Bank(; ν = 5.45, project, γ = i ≤ p ? Failure() : Success()) for i ∈ 1:n_banks]
	
	fig = Figure()
	ax = Axis(fig[1,1], palette = (color = blues(length(γ_vec)), ),
				xlabel = L"\bar{y}",
				ylabel = "number of defaulted banks")

	max_defaulted = 0
	min_defaulted = 1000
	for γ in γ_vec
		network(ȳ) = γNetwork(n_banks, ȳ, γ)
		
		no_defaulted = map(ȳ_vec) do ȳ
			IM = InterbankMarket(network(ȳ))
			(; out) = equilibrium(banks, IM)
			defaulted_banks = sum(out.y_pc .< 1)
		end
		max_defaulted = max(max_defaulted, maximum(no_defaulted))
		min_defaulted = min(min_defaulted, minimum(no_defaulted))
		lines!(ax, ȳ_vec , no_defaulted, label = label(network(0)))
	end
	
	n = (max_defaulted - min_defaulted) ÷ 3
	ax.yticks = min_defaulted:n:max_defaulted
	ax.yminorticksvisible = true
	ax.yminorticks = IntervalsBetween(n)
	ax.yminorgridvisible = true
	
	axislegend(ax)
	fig	
end	

# ╔═╡ 0d4d9a5b-5e4f-4126-85ec-d31327cbf960
md"""
### 2. Densely connected networks are _robust, yet fragile_

> Our results thus confirm a conjecture of Andrew Haldane (2009, then Executive Director for Financial Stability at the Bank of England), who suggested that highly interconnected financial networks may be “robust-yet-fragile” in the sense that “within a certain range, connections serve as shock-absorbers [and] connectivity engenders robustness.” However, beyond that range, interconnections start to serve as a mechanism for the propagation of shocks, “the system [flips to] the wrong side of the knife-edge,” and fragility prevails.

* Upto some ``\varepsilon^*``, the shock does not spread
* Above this value, all banks default
* This is an example for a _phase transition_: it flips from being the most to the least stable and resilient network

__Compare *Propositions 4 and 6*__:
* _Proposition 4_: For small shocks and big ``\bar y``, the complete network ist the most resilitient and most stable financial network and the ring is the least resilient and least stable.

* _Proposition 6_: For big shocks, the ring and complete networks are the least resilient and least stable.

"""

# ╔═╡ 045c54d2-c76c-49f1-b849-d607e50b182b
let 
	ȳ = 6 #ȳ_vec[1]
	
	ε_vec = 0.0:0.05:2
	γ_vec = [0.0, 1.0] #1.0
	γ = 0.0

	p = 1
	n_banks = 10
	project(ε) = Project(; A = 2.0, ζ = 0.0, a = 5.6, ε)
	banks(ε) = [Bank(; ν = 5.45, project = project(ε), γ = i ≤ p ? Failure() : Success()) for i ∈ 1:n_banks]
	
	island_networks = [
		IslandNetwork(2, 5, ȳ);
		IslandNetwork(5, 2, ȳ);
		#IslandNetwork(10, 1, ȳ)
	] 

	networks = [γNetwork.(n_banks, ȳ, γ_vec); island_networks]

	max_defaulted = 0
	min_defaulted = 1000
	
	fig = Figure()
	ax = Axis(fig[1,1], #palette = (color = blues(length(γ_vec)), ),
				xlabel = L"shock size $ε$",
				ylabel = "number of defaulted banks")
		
	for network in networks
		
		no_defaulted = map(ε_vec) do ε

			IM = InterbankMarket(network)

			(; out) = equilibrium(banks(ε), IM)
			defaulted_banks = sum(out.y_pc .< 1)
		end
		lines!(ax, ε_vec , no_defaulted, label = label(network))
		max_defaulted = max(max_defaulted, maximum(no_defaulted))
		min_defaulted = min(min_defaulted, minimum(no_defaulted))
	end

	n = (max_defaulted - min_defaulted) ÷ 3
	ax.yticks = min_defaulted:n:max_defaulted
	ax.yminorticksvisible = true
	ax.yminorticks = IntervalsBetween(n)
	ax.yminorgridvisible = true
	
	axislegend(ax, position = :lt)
	fig	
end

# ╔═╡ f5938462-ae9d-44c0-a0b1-17d61e8ac0eb
md"""
# Implementation details
"""

# ╔═╡ 45430bb9-8914-4839-b936-79bcbc453822
md"""
## The Interbank Market

We look at $n_banks banks that have the same exposure to the project and the same total exposure to the interbank market.

"""

# ╔═╡ dafe2f99-d3b5-4450-bbab-c8ffe1ac11ea
struct InterbankMarket{FN <: FinancialNetwork}
	network::FN
	payments
	function InterbankMarket(network::FN) where FN
		new{FN}(network, copy(adjacency_matrix(network)))
	end
end

# ╔═╡ a99f36fe-298f-45fb-b5f5-c42d21d73e55
initial_network(interbank_market) = adjacency_matrix(interbank_market.network)

# ╔═╡ d8ddea58-b8d3-41a9-a3a4-8c53754bda32
updated_network(interbank_market) = interbank_market.payments

# ╔═╡ 44728e3a-3e88-4808-96d1-be17b58fde70
begin
	payables(IM::InterbankMarket) = sum(initial_network(IM), dims = 2)
	receivables(IM::InterbankMarket) = sum(initial_network(IM), dims = 1)
	
	paid(IM::InterbankMarket) = sum(updated_network(IM), dims = 2)
	received(IM::InterbankMarket) = sum(updated_network(IM), dims = 1)
end

# ╔═╡ 3a2f6c6d-432f-4f1e-a2c8-2dc11ca86aab
md"""
## Payments and Equilibrium
"""

# ╔═╡ a8e00a42-c018-4067-8e5b-a4d5c8f74108
function equilibrium(banks, IM; maxit = 100)
	x = updated_network(IM)
	y = initial_network(IM)

	x_new = copy(x)
	for it ∈ 1:maxit
		(; x_new, out) = iterate_payments(banks, IM)
		converged = x_new ≈ x
		x .= x_new
		
		if converged || it == maxit
			return (; out = DataFrame(out), x, y, it, success = it != maxit, banks, IM)
		end
	end
	
end

# ╔═╡ f950f7a5-4277-43bc-8700-21f6cd0d9c9f
function iterate_payments(banks, IM)
	x = updated_network(IM)
	y = initial_network(IM)
	
	x_new = copy(y)
	out = map(enumerate(banks)) do (i, bank)
		# compute repayment
		(; y_pc, ν_pc, ℓ) = repayment(bank, i, IM)
		# update payment matrix
		x_new[i, :] .*= y_pc
		# return bank's choices
		(; y_pc, ν_pc, ℓ, bank = i)
	end

	(; x_new, out)
end

# ╔═╡ 602e44bc-4d5b-4f7f-9a75-bf9b1576ac11
function repayment(bank, i_bank, IM::InterbankMarket)
	ȳ = payables(IM)[i_bank]
	x̄ = received(IM)[i_bank]

	repayment(bank, x̄, ȳ)
end

# ╔═╡ db5a2982-8986-48e3-85f5-75892afdb12a
function repayment(bank, x̄, ȳ)
	(; c, ν, project, γ) = bank
	(; ζ, A) = project
	
	h      = x̄ + c + payoff(project, γ, 0)
	assets = x̄ + c + payoff(project, γ, 1)

	if ν + ȳ ≤ h  # liabilities
		return (ℓ = 0.0, y_pc = 1.0, ν_pc = 1.0)
	elseif h < ν + ȳ ≤ h + ζ * A
		ℓ = (ν + ȳ - h)/(ζ * A)
		return (; ℓ, y_pc = 1.0, ν_pc = 1.0)
	elseif ν ≤ assets < ν + ȳ
		return (; ℓ = 1.0, y_pc = (assets - ν)/ȳ, ν_pc = 1.0)
	elseif assets < ν
		return (; ℓ = 1.0, y_pc = 0.0, ν_pc = assets/ν)
	end
end

# ╔═╡ dd257094-78c5-403b-942a-f0b29064e29e
md"""
## Functions for Task 3
"""

# ╔═╡ 335ec769-9a1c-413a-8130-033669343030
theme = (
	arrow_size = 25,
	node_size = 15,
	layout = Shell(),
)

# ╔═╡ d5808058-cc75-4091-8fd0-c5f163ba3cb9
exX = let
	S = states[i_state]
	n = length(S)

	node_styles = (title = "shock", df = DataFrame(label = string.([:early, :late, :none]), color = ["green", "red", "gray"]))

	df = @chain begin
		DataFrame(bank = 1:n, label = string.(S))
		leftjoin(_, node_styles.df, on = :label)
	end

	(; n, color = df.color, node_styles)
end;

# ╔═╡ 09debe63-1ccc-45fa-8f73-e8f05b794726
function node_legend(figpos, node_styles, title = "")
	
	elems = [MarkerElement(; color, markersize = 15, marker = :●) for color ∈ node_styles.color]

	if length(title) == 0
		title_tuple = ()
	else
		title_tuple = (title, )
	end
	
	Legend(
		figpos,
    	elems, node_styles.label, title_tuple...;
		orientation=:horizontal, titleposition=:left, framevisible=false
	)
end

# ╔═╡ dd3f555f-c7e3-4a01-b3b0-06e01dd7a075
function minimal_graphplot(args; node_styles = missing, kwargs...)
	fig, ax, plt = graphplot(args; kwargs...)

	hidedecorations!(ax)
	
	if !ismissing(node_styles)
		(title, df) = node_styles
		node_legend(fig[end+1,1], df, title)
	end

	(; fig, ax, plt)
end

# ╔═╡ d7139b58-1b84-4c61-9060-c3e8e27083a9
md"""
# Appendix
"""

# ╔═╡ ceaebe3d-a6b8-48d4-98fd-0fd3055b2943
using Chain, DataFrames, DataFrameMacros

# ╔═╡ f61a2b9a-d36c-4f03-95b4-226f31e7acba
using Graphs, SimpleWeightedGraphs

# ╔═╡ 707555ea-48d2-4ae6-9417-b47a972deb9d
using CairoMakie, AlgebraOfGraphics

# ╔═╡ 4984ca28-1de2-4e5f-9d27-8c13decff996
using CategoricalArrays: recode

# ╔═╡ 53660817-3947-4c30-bf61-3a36d6614a13
using PlutoUI: TableOfContents, Slider, Select, NumberField

# ╔═╡ d05680b7-4bf2-4d9e-99b9-fde6254a4b4c
using MarkdownLiteral: @markdown

# ╔═╡ 9630dabc-87b1-4bb9-82cc-7fbb59a45c34
TableOfContents()

# ╔═╡ f746a247-feb7-4291-b9bd-dba29eec7143
md"""
## Regular interbank market
"""

# ╔═╡ 31dca57c-b5fe-49c2-87e0-31b2999a6f65
abstract type FinancialNetwork end

# ╔═╡ 2a964fbe-80b5-4501-ad52-97686dae67bb
adjacency_matrix(network::FinancialNetwork) = network.Y

# ╔═╡ 55e97c59-79f0-4f81-b23b-079d03da6ecd
struct CompleteNetwork <: FinancialNetwork
	Y
	ȳ
	function CompleteNetwork(n, ȳ)
		Y = complete_network(n, ȳ)
		
		new(Y, ȳ)
	end
end

# ╔═╡ 4fbd40d2-0589-4ebf-adfb-ae686b25dd5c
function complete_network(n, ȳ)
	Y = fill(ȳ/(n-1), n, n)
		
	for i in 1:n
		Y[i,i] = 0.0
	end
	
	Y
end

# ╔═╡ 9484ba9a-6d4b-4417-81c7-cea34e194515
begin
	struct RingNetwork <: FinancialNetwork
		Y
		ȳ
		function RingNetwork(n, ȳ)
			Y = ring_network(n, ȳ)
	
			new(Y, ȳ)
		end
	end
end

# ╔═╡ 8c3cf1ef-187a-4f32-96b5-926d93519a30
function ring_network(n, ȳ)
	Y = zeros(n, n)
	
	for i in 1:(n-1)
		Y[i, i+1] = ȳ
	end
	Y[n, 1] = ȳ
	
	Y
end

# ╔═╡ a7834a3a-ed74-48ab-99ba-581f7a790bf9
struct γNetwork <: FinancialNetwork
	Y
	ȳ
	γ
	function γNetwork(n, ȳ, γ)
		Y = γ * ring_network(n, ȳ) + (1-γ) * complete_network(n, ȳ)
		
		new(Y, ȳ, γ)
	end
end

# ╔═╡ 46745175-c7bf-45b5-8e1a-d8ab9e9ca703
function label(nw::γNetwork)
	(; γ) = nw
	if γ == 1
		latexstring("\$\\gamma = $γ\$ (Ring)")
	elseif γ == 0
		latexstring("\$\\gamma = $γ\$ (Complete)")
	else
		latexstring("\\gamma = $γ")
	end
end

# ╔═╡ 3e7f87ae-da71-42c4-8ebb-6dc2aef7ce03
function island_network(n_islands, n_banks_per_island, ȳ)
	blocks = (CompleteNetwork(n_banks_per_island, ȳ).Y for _ in 1:n_islands)
	
	cat(blocks...,dims=(1,2))
end

# ╔═╡ 00cabaf0-e341-4fd5-9f3f-b513591087f1
function island_network(n_banks::AbstractVector, ȳ)
	blocks = (CompleteNetwork(n, ȳ).Y for n ∈ n_banks)
	
	cat(blocks...,dims=(1,2))
end

# ╔═╡ c054bded-ad5a-4c19-9758-5e81ece988ba
let
	struct IslandNetwork <: FinancialNetwork
		Y
		ȳ
		n_islands
		n_banks_per_island
	end

	function IslandNetwork(n_islands, n_banks_per_island, ȳ)
		Y = island_network(n_islands, n_banks_per_island, ȳ)	
		IslandNetwork(Y, ȳ, n_islands, n_banks_per_island)
	end
	function IslandNetwork(n_banks::AbstractVector, ȳ)
		Y = island_network(n_banks, ȳ)	
		IslandNetwork(Y, ȳ, length(n_banks), n_banks)
	end
end

# ╔═╡ 0ba6d675-477f-493d-a621-2431d32ad9a8
function label(nw::IslandNetwork)
	(; n_banks_per_island, n_islands) = nw
	if length(n_banks_per_island) == 1
		bank_or_banks = n_banks_per_island == 1 ? "bank" : "banks"
		return latexstring("\$ $n_islands \\times $n_banks_per_island \$ $bank_or_banks")
	else
		return latexstring("\$ $n_islands \$ islands ")
	end		
end

# ╔═╡ e6c8244a-6dca-4599-b3a5-02491bb99dfb
md"""
## Extending GraphMakie
"""

# ╔═╡ 9898ed0c-3510-4d05-8056-4112d3ca72c7
using GraphMakie, NetworkLayout

# ╔═╡ 8db75083-b0d6-409b-8efb-fe74a9f238b2
begin
	using NetworksUtils: NetworksUtils, componentwise_circle,
	numbered_graphplot, numbered_graphplot!, figure

	NetworksUtils.numbered_graphplot!(ax, IM::InterbankMarket, args...; kwargs...) = numbered_graphplot!(ax, SimpleWeightedDiGraph(adjacency_matrix(IM.network)), args...; kwargs...)
end

# ╔═╡ a50aba4a-9aba-4a90-965a-5e354969b606
md"""
## Visualizing payment equilibrium
"""

# ╔═╡ c8440043-3e63-4607-ba70-bd1ee016c5b4
red_if_lt_one(x) = x < 1 ? :red : :gray90

# ╔═╡ 3069c53d-9a1d-48e1-b0c6-ec4fae392bd7
function visualize_equilibrium(peq; graph = (;), bs = (;))
	(; x, banks) = peq
	fg = viz_eq_bal_sheets((; x, banks); bs...)

	graph_ax = Axis(fg.figure[:, -1:0], tellwidth = true)
	viz_eq_graph!(graph_ax, peq; graph...)

	fg.figure
end

# ╔═╡ 64248193-552e-47a0-8da5-0c58a6099b80
function viz_eq_graph(peq; kwargs...)
	fig = Figure()
	viz_eq_graph!(Axis(fig[1,1]), peq; kwargs...)
	fig
end

# ╔═╡ 41d5e579-418b-4988-9a6f-f75afeffe821
function viz_eq_graph!(ax, peq; kwargs...)
	(; IM, out) = peq
	graph = SimpleWeightedDiGraph(IM.network.Y)

	numbered_graphplot!(ax, graph;
		node_size = (2.5 .- out.ℓ) .* 10,
		node_color = red_if_lt_one.(out.y_pc),
		nlabels = string.(vertices(graph)),
		nlabels_offset = Point2(0.05, 0.05),
		kwargs...
	)
end

# ╔═╡ fd3dc6bf-f1e5-46de-b0b0-94adbc845d81
function viz_eq_bal_sheets((; x, banks); ymax = nothing, kwargs...)
	limits = (nothing, nothing, nothing, ymax)
	
	g_final = SimpleWeightedDiGraph(x)

	payment_df = @chain g_final begin
		edges
		DataFrame
		@transform(:edge_id = @bycol(1:ne(g_final)), :spec = "inside")
		rename!(:weight => :value)
	end

	outside_nts = map(enumerate(banks)) do (i, (; ν, c))
		(bank = i, liabs = ν, assets = c)
	end

	outside_df = @chain outside_nts begin
		DataFrame
		stack([:assets, :liabs], variable_name = :type)
		@transform(:spec = "outside", :edge_id = missing)
	end	

	# Attention rows and columns mixed up	
	inside_df = [
		@select(payment_df, :bank = :src, :value, :type = "liabs",  :spec, :edge_id);
		@select(payment_df, :bank = :dst, :value, :type = "assets", :spec, :edge_id)
	 ]

	df_bs = vcat(inside_df, outside_df, cols = :union)

	fg = @chain df_bs begin
		@subset(:spec == "inside")
		disallowmissing!
		@sort(:bank, :edge_id)
		data(_) * visual(BarPlot) * mapping(:type, :value,
			#alpha = :spec,
			color = :edge_id => nonnumeric,
			stack = :edge_id => nonnumeric, #stack = :spec,
			#color = :edge_id => nonnumeric,
			layout = :bank => nonnumeric
		)
		draw(_, axis = (; limits, tellwidth = true))
	end
end

# ╔═╡ 2d1f7620-de37-4e9f-8044-9459abda92ac
md"""
## Assignment infrastructure
"""

# ╔═╡ 6270dbc8-5002-4328-88a4-f1c7f060f571
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
end

# ╔═╡ 7f0ad695-ea05-483b-86c4-a63df55689e9
members = let
	names = map(group_members) do (; firstname, lastname)
		firstname * " " * lastname
	end
	join(names, ", ", " & ")
end

# ╔═╡ 76bc41d8-c97f-4120-9b13-679997411ca6
function wordcount(text)
	stripped_text = strip(replace(string(text), r"\s" => " "))
   	words = split(stripped_text, (' ', '-', '.', ',', ':', '_', '"', ';', '!', '\''))
   	length(filter(!=(""), words))
end

# ╔═╡ b72dedc8-bd5a-457e-ba67-13f26a0148dd
using PlutoTest: @test

# ╔═╡ a3874185-b0ec-49da-a9d7-7875416b3b4f
@test wordcount("  Hello,---it's me.  ") == 4

# ╔═╡ 3945c5e7-8d0c-4196-8eb1-2931cd85cd30
@test wordcount("This;doesn't really matter.") == 5

# ╔═╡ 0694c61f-bcd7-435e-8bfa-77e81bb580e7
show_words(answer) = md"_approximately $(wordcount(answer)) words_"

# ╔═╡ fe70e69a-1c07-4e50-b29e-6ca028bb1a3d
function show_words_limit(answer, limit)
	count = wordcount(answer)
	if count < 1.02 * limit
		return show_words(answer)
	else
		return almost(md"You are at $count words. Please shorten your text a bit, to get **below $limit words**.")
	end
end

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
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
NetworkLayout = "46757867-2c16-5918-afeb-47bfcb05e46a"
NetworksUtils = "4943429a-ba68-4c19-ade3-7332adbb3997"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"

[compat]
AlgebraOfGraphics = "~0.6.12"
CairoMakie = "~0.9.3"
CategoricalArrays = "~0.10.7"
Chain = "~0.5.0"
Colors = "~0.12.8"
DataFrameMacros = "~0.4.0"
DataFrames = "~1.4.3"
GraphMakie = "~0.4.3"
Graphs = "~1.7.4"
LaTeXStrings = "~1.3.0"
MarkdownLiteral = "~0.1.1"
NetworkLayout = "~0.4.4"
NetworksUtils = "~0.1.1"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.48"
SimpleWeightedGraphs = "~1.2.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "514c57b53f3fe5aaf84a613998fc9835bad33f81"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "52b3b436f8f73133d7bc3a6c71ee7ed6ab2ab754"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.3"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.AlgebraOfGraphics]]
deps = ["Colors", "Dates", "Dictionaries", "FileIO", "GLM", "GeoInterface", "GeometryBasics", "GridLayoutBase", "KernelDensity", "Loess", "Makie", "PlotUtils", "PooledArrays", "RelocatableFolders", "StatsBase", "StructArrays", "Tables"]
git-tree-sha1 = "f4d6d0f2fbc6b2c4a8eb9c4d47d14b9bf9c43d23"
uuid = "cbdf2221-f076-402e-a563-3d30da359d67"
version = "0.6.12"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

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
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA", "SnoopPrecompile"]
git-tree-sha1 = "20bd6ace08bb83bf5579e8dfb0b1e23e33518b04"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.9.3"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
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
git-tree-sha1 = "5084cc1a28976dd1642c9f337b28a3cb03e0f7d2"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.7"

[[deps.Chain]]
git-tree-sha1 = "8c4920235f6c561e401dfe569beb8b924adad003"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.5.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "86cce6fd164c26bad346cc51ca736e692c9f553c"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.7"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "aaabba4ce1b7f8a9b34c015053d3b1edf60fa49c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.4.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataFrameMacros]]
deps = ["DataFrames", "MacroTools"]
git-tree-sha1 = "92ae44e8d08667be722ca197c97e60bcff1db968"
uuid = "75880514-38bc-4a95-a458-c2aea5a3a702"
version = "0.4.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "0f44494fe4271cc966ac4fea524111bef63ba86c"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.3"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "e82c3c97b5b4ec111f3c1b55228cebc7510525a2"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.25"

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
git-tree-sha1 = "7fe1eff48e18a91946ff753baf834ff4d5c03744"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.78"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "802bfc139833d2ba893dd9e62ba1767c88d708ae"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.5"

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
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "38a92e40157100e796690421e34a11c107205c86"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "884477b9886a52a84378275737e2823a5c98e349"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.8.1"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "fb28b5dc239d0174d7297310ef7b84a11804dfab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.0.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "fe9aea4ed3ec6afdfbeb5a4f39a2208909b162a6"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.5"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.GraphMakie]]
deps = ["GeometryBasics", "Graphs", "LinearAlgebra", "Makie", "NetworkLayout", "StaticArrays"]
git-tree-sha1 = "693642d05cc34f336c3b01e7b722024ab308ac78"
uuid = "1ecd5474-83a3-4783-bb4f-06765db800d2"
version = "0.4.3"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "ba2d094a88b6b287bd25cfa86f301e7693ffae2f"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.7.4"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "678d136003ed5bceaab05cf64519e3f956ffa4ba"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.9.1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "342f789fd041a55166764c351da1710db97ce0e0"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.6"

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
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "842dd89a6cb75e02e85fdd75c760cdc43f5d6863"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.6"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "3f91cd3f56ea48d4d2a75c2a65455c5fc74fa347"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.3"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

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
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

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

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

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
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

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
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "InteractiveUtils", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "MiniQhull", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Serialization", "Showoff", "SignedDistanceFields", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun"]
git-tree-sha1 = "d3b9553c2f5e0ca588e4395a9508cef024bd9e8a"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.18.3"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "c1885d865632e7f37e5a1489a164f44c54fb80c9"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.5.2"

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
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test", "UnicodeFun"]
git-tree-sha1 = "f04120d9adf4f49be242db0b905bea0be32198d1"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.5.4"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.MiniQhull]]
deps = ["QhullMiniWrapper_jll"]
git-tree-sha1 = "9dc837d180ee49eeb7c8b77bb1c860452634b0d1"
uuid = "978d7f02-9e05-4691-894f-ae31a51d76ca"
version = "0.4.0"

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
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

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
version = "1.2.0"

[[deps.NetworksUtils]]
deps = ["GraphMakie", "Graphs", "InteractiveUtils", "Makie", "Markdown", "NetworkLayout", "SimpleWeightedGraphs", "Statistics"]
git-tree-sha1 = "66db9ab87e0c17c25ae59c18ccb2edc43efdf14e"
uuid = "4943429a-ba68-4c19-ade3-7332adbb3997"
version = "0.1.1"

[[deps.Observables]]
git-tree-sha1 = "6862738f9796b3edc1c09d0890afce4eca9e7e93"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.4"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

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
version = "0.8.1+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

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

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "f809158b27eba0c18c269cf2a2be6ed751d3e81d"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.17"

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
git-tree-sha1 = "84a314e3926ba9ec66ac097e3635e270986b0f10"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.9+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "d8ed354439950b34ab04ff8f3dfd49e11bc6c94b"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QhullMiniWrapper_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Qhull_jll"]
git-tree-sha1 = "607cf73c03f8a9f83b36db0b86a3a9c14179621f"
uuid = "460c41e3-6112-5d7f-b78c-b6823adb3f2d"
version = "1.0.0+1"

[[deps.Qhull_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "695c3049ad94fa38b7f1e8243cdcee27ecad0867"
uuid = "784f63db-0788-585a-bace-daefebcd302b"
version = "8.0.1000+0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

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
version = "0.7.0"

[[deps.SIMD]]
git-tree-sha1 = "bc12e315740f3a36a6db85fa2c0212a848bd239e"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.2"

[[deps.ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "2436b15f376005e8790e318329560dcc67188e84"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.3"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.ShiftedArrays]]
git-tree-sha1 = "503688b59397b3307443af35cd953a13e8005c16"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "2.0.0"

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

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "4e051b85454b4e4f66e6a6b7bdc452ad9da3dcf6"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.10"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "a5e15f27abd2692ccb61a99e0854dfb7d48017db"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.6.33"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArraysCore", "Tables"]
git-tree-sha1 = "13237798b407150a6d2e2bce5d793d7d9576e99e"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.13"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "f8cd5b95aae14d3d88da725414bdde342457366f"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.2"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

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
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

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
version = "1.2.12+3"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

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
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

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
# ╟─8573d925-e4bd-4544-a264-b3a7ba8610a3
# ╟─2db89e2d-4d89-454d-bd1a-976a1f415623
# ╟─815648ae-78f2-42f1-a216-81b10c0a7850
# ╟─c129dec7-eb81-4cab-91d5-2ef7a1c06b24
# ╟─6060f7ec-52c1-4504-9fc9-dfaaff4c1109
# ╟─1f9e1561-405d-4d49-a2ee-af2dfeb2d409
# ╟─4f30bb25-0f69-4c5a-948c-df89d75a0a24
# ╟─07958953-43c8-441b-b6d6-6bcf0e027603
# ╟─88580398-8b68-4830-9df9-ec1a1aeaf243
# ╠═186b1fe4-4462-4c0d-a874-256ee3e3f700
# ╟─b13cbc28-5658-4f24-879e-bd6c10f7c7f0
# ╟─f7a60a89-40b2-4656-98a6-a258a4a5741d
# ╠═70e40546-b5e8-45dc-86a0-bfbef5403e30
# ╟─0a7829f4-c3a9-488d-aacc-6e8a02c3ef79
# ╟─496f01ef-6422-412b-9142-c3893476bc0d
# ╟─1e38675b-3482-4f85-b4fa-f476e84fb520
# ╟─21dd99b3-ee5b-46e5-adf5-9c9ff9448272
# ╟─febcd0aa-0a19-405c-b5ed-5c73dab8929c
# ╟─cee410bb-1470-41f9-8e98-b96591eac7ca
# ╟─6733025d-20f0-48cd-b6d8-0dfb02bb7482
# ╠═33bf5bdd-6e13-4375-bf26-bdac273d6738
# ╟─07fc0a5c-8d9f-46a7-9893-fefa23007878
# ╠═1f52926c-fc07-4652-97a8-6abbdb3e3b5e
# ╟─e903ac6c-1b5c-40ea-a925-e7243cbf9b02
# ╠═751e1643-43c2-4071-87cf-a904560e2bc4
# ╟─25dae65d-65a6-462f-aba2-afd498bf4d5a
# ╠═93a79265-110d-4fb9-b2a7-97da4667f8c6
# ╠═3946c3f6-3044-42e4-b161-09f4394b7147
# ╟─4712bc8d-4e63-47c9-8367-dc417f1a7649
# ╟─54722cbe-6a91-4275-a78c-8a50715b86c8
# ╟─eb1e20e7-9873-45bd-ae30-ed147a70b457
# ╠═28bbf56b-1bdf-486f-8230-b9a6ee19a955
# ╟─7f0bad7b-439a-4639-bba4-5f0a52560042
# ╟─497c6314-6f0f-4d45-9bd2-17d6f6b00ab9
# ╠═3abaa20d-a24d-4b2f-8d8d-4e01b719ab5e
# ╟─d41cd681-2434-4525-9c67-9e184fdd1f67
# ╟─9a8b8946-e083-49f3-8a86-7ba2df4636fe
# ╠═e7eb6784-e947-4a14-8227-888d4646855e
# ╠═23bd3f41-7c81-4b15-a07c-720c3a393118
# ╟─e6f4813b-86bb-45a8-b017-c2d32f3c74b0
# ╟─207d92a3-b8fa-45e3-88b1-bb95bb7d981c
# ╠═5a12e196-99b2-4d45-b373-8aec03f6cc0e
# ╟─be0f68e9-36ad-4500-b941-fe47e1865eba
# ╟─0a7b61c5-8e11-4025-b6ad-8fcfc2701464
# ╠═f596a5cc-d291-4358-b568-9b3872bc2dc8
# ╟─dcdd349e-3edb-413f-b315-994b9395c3bc
# ╟─c177b994-cf6c-4a90-8d64-a4feef88fd56
# ╠═71185d5e-ae37-4571-b380-a5b9f2b65205
# ╟─75b27e3b-f8b3-4345-ac43-2974d624ea72
# ╟─942580bf-60d3-49fe-be2a-2fab9869322d
# ╟─0cb23460-2db6-4327-a01c-a013eb471a9e
# ╟─b542043b-b4ac-4207-b092-18b283c65524
# ╠═60615cd2-aa70-47e9-b432-b4051e17f628
# ╠═e454ff61-2769-4095-8d0c-6958f79338ee
# ╠═b09eb768-f645-441d-a943-8c2fe373fd08
# ╠═b309cc56-598f-4bd4-a523-edbbb850db58
# ╠═141e0dd3-a9bb-4ea6-8686-e18a2628d926
# ╟─e3ae420b-1d40-4d2d-99f3-728cfb8ca167
# ╟─7d55098d-2665-44ec-a959-91e591ccc70e
# ╠═5e3fb6e9-eacb-4e4b-9a62-83632263be37
# ╟─8f0dc26b-45c3-44ac-a0db-73e42b09f46b
# ╟─f1555793-db56-4b4c-909d-c8f3bf6cd857
# ╠═d14e0faa-4509-46aa-bfe1-0ba89d04c8c7
# ╠═99b10989-c757-43e7-8fd2-65f8a5377023
# ╠═d385bc7e-d9e9-4f61-a455-9973262bd37a
# ╟─9a771f35-8f15-4abc-a093-4b5cb84b909a
# ╠═1a7df5c9-3036-44a7-9eba-42ef4851d9ae
# ╠═7c7ba04a-fc84-4ca2-a903-faf1fae0a839
# ╠═4d4cf195-0eef-4873-b8f8-b82c48ee6f26
# ╟─3968e7cf-b56b-4e36-a89c-aea6840986d2
# ╟─3052a997-5084-4005-8985-7be98a08d659
# ╠═ec82cd1e-6d3f-11ec-18d7-8dd51f5446de
# ╟─c4ccc5ad-618d-4635-9d52-13be0df55198
# ╠═37acf7b5-f93e-4ec9-9807-b247544713ed
# ╟─8377503b-4556-4dc0-9d15-330bdd4100e6
# ╟─83817687-0e03-4be0-a66b-e74dcd300b15
# ╟─f8271303-ab1f-486a-aa34-8f1dc6b33cd2
# ╟─f3e015f2-33e1-4b2f-b34a-ee6a5751d96b
# ╟─27039532-1c2b-4aee-858e-f9f0a135e62f
# ╠═2ed68cbb-7e5b-4d17-9cb3-4f9404b63365
# ╠═6e3907db-9c66-4805-853b-11877c23a1d6
# ╠═d07fa3a9-6687-4279-8fe7-e348152b18f4
# ╟─78a45e6a-a772-4fa7-bd9c-d728d5ea79e8
# ╠═e9e6c131-c334-4674-9384-273cd40929dc
# ╠═3726a99d-8024-4fec-a047-43d370f795d9
# ╟─d649a654-e515-40b4-a45b-e095f1d12da7
# ╟─76f41f57-2971-4020-ab2f-87fad4a92489
# ╟─2b7c65fe-8bf8-47f2-96b1-6dfe8888d494
# ╟─0d4d9a5b-5e4f-4126-85ec-d31327cbf960
# ╠═045c54d2-c76c-49f1-b849-d607e50b182b
# ╟─f5938462-ae9d-44c0-a0b1-17d61e8ac0eb
# ╟─45430bb9-8914-4839-b936-79bcbc453822
# ╠═dafe2f99-d3b5-4450-bbab-c8ffe1ac11ea
# ╠═a99f36fe-298f-45fb-b5f5-c42d21d73e55
# ╠═d8ddea58-b8d3-41a9-a3a4-8c53754bda32
# ╠═44728e3a-3e88-4808-96d1-be17b58fde70
# ╟─3a2f6c6d-432f-4f1e-a2c8-2dc11ca86aab
# ╠═a8e00a42-c018-4067-8e5b-a4d5c8f74108
# ╠═f950f7a5-4277-43bc-8700-21f6cd0d9c9f
# ╠═602e44bc-4d5b-4f7f-9a75-bf9b1576ac11
# ╠═db5a2982-8986-48e3-85f5-75892afdb12a
# ╟─dd257094-78c5-403b-942a-f0b29064e29e
# ╠═335ec769-9a1c-413a-8130-033669343030
# ╠═d5808058-cc75-4091-8fd0-c5f163ba3cb9
# ╠═09debe63-1ccc-45fa-8f73-e8f05b794726
# ╠═dd3f555f-c7e3-4a01-b3b0-06e01dd7a075
# ╟─d7139b58-1b84-4c61-9060-c3e8e27083a9
# ╠═ceaebe3d-a6b8-48d4-98fd-0fd3055b2943
# ╠═f61a2b9a-d36c-4f03-95b4-226f31e7acba
# ╠═707555ea-48d2-4ae6-9417-b47a972deb9d
# ╠═4984ca28-1de2-4e5f-9d27-8c13decff996
# ╠═53660817-3947-4c30-bf61-3a36d6614a13
# ╠═d05680b7-4bf2-4d9e-99b9-fde6254a4b4c
# ╠═9630dabc-87b1-4bb9-82cc-7fbb59a45c34
# ╟─f746a247-feb7-4291-b9bd-dba29eec7143
# ╠═31dca57c-b5fe-49c2-87e0-31b2999a6f65
# ╠═2a964fbe-80b5-4501-ad52-97686dae67bb
# ╠═55e97c59-79f0-4f81-b23b-079d03da6ecd
# ╠═4fbd40d2-0589-4ebf-adfb-ae686b25dd5c
# ╠═9484ba9a-6d4b-4417-81c7-cea34e194515
# ╠═8c3cf1ef-187a-4f32-96b5-926d93519a30
# ╠═a7834a3a-ed74-48ab-99ba-581f7a790bf9
# ╠═46745175-c7bf-45b5-8e1a-d8ab9e9ca703
# ╠═3e7f87ae-da71-42c4-8ebb-6dc2aef7ce03
# ╠═00cabaf0-e341-4fd5-9f3f-b513591087f1
# ╠═c054bded-ad5a-4c19-9758-5e81ece988ba
# ╠═0ba6d675-477f-493d-a621-2431d32ad9a8
# ╟─e6c8244a-6dca-4599-b3a5-02491bb99dfb
# ╠═9898ed0c-3510-4d05-8056-4112d3ca72c7
# ╠═8db75083-b0d6-409b-8efb-fe74a9f238b2
# ╟─a50aba4a-9aba-4a90-965a-5e354969b606
# ╠═c8440043-3e63-4607-ba70-bd1ee016c5b4
# ╠═3069c53d-9a1d-48e1-b0c6-ec4fae392bd7
# ╠═64248193-552e-47a0-8da5-0c58a6099b80
# ╠═41d5e579-418b-4988-9a6f-f75afeffe821
# ╠═fd3dc6bf-f1e5-46de-b0b0-94adbc845d81
# ╟─2d1f7620-de37-4e9f-8044-9459abda92ac
# ╠═6270dbc8-5002-4328-88a4-f1c7f060f571
# ╠═7f0ad695-ea05-483b-86c4-a63df55689e9
# ╠═76bc41d8-c97f-4120-9b13-679997411ca6
# ╠═b72dedc8-bd5a-457e-ba67-13f26a0148dd
# ╠═a3874185-b0ec-49da-a9d7-7875416b3b4f
# ╠═3945c5e7-8d0c-4196-8eb1-2931cd85cd30
# ╠═0694c61f-bcd7-435e-8bfa-77e81bb580e7
# ╠═fe70e69a-1c07-4e50-b29e-6ca028bb1a3d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
