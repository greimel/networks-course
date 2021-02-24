### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 449a52cc-6b7c-11eb-035a-355b0c334582
begin
	_a_ = 1 # make sure this cell is run before other Pkg cell
	
	using Pkg: Pkg, PackageSpec
	Pkg.activate(temp = true)
	
	Pkg.add("PlutoUI")
	using PlutoUI: Slider, TableOfContents, CheckBox, NumberField
end

# ╔═╡ 5350a65e-6b7c-11eb-3725-d59f6c3cf1a7
begin
	_b_ = _a_ + 1 # make sure this cell is run before other Pkg cell
	
	Pkg.add(Pkg.PackageSpec(name="AbstractPlotting", version = "0.15"))
	
	fancy = false
	
	if fancy
		Pkg.add([
			Pkg.PackageSpec(name="JSServe"),
			Pkg.PackageSpec(name="WGLMakie"),
			])
		import WGLMakie
		using JSServe: Page
		WGLMakie.activate!()
		Page(exportable = true)
	else
		Pkg.add("CairoMakie")
		import CairoMakie
		CairoMakie.activate!(type = "png")
	end

	using AbstractPlotting: 
		Figure, Axis, Legend, Label, Box, Top, 
		lines!, scatter!, scatterlines, scatterlines!, vlines!, 
		hidedecorations!, ylims!, cgrad,
		@lift, Node, wong_colors
	
	Pkg.add("NetworkLayout")
	using NetworkLayout: NetworkLayout
end

# ╔═╡ 15253560-6b78-11eb-12f6-91d27770a192
begin
	_c_ = _b_ + 1
	
	Pkg.add([
			PackageSpec(name = "DataAPI", version = "1.4"),
			PackageSpec(name = "CategoricalArrays", version = "0.9"),
			PackageSpec(name = "CSV", version = "0.8"),
			PackageSpec(name = "DataFrames", version = "0.22"),
			PackageSpec(name = "HTTP", version = "0.9"),
			PackageSpec(name = "UnPack", version = "1"),
			
			])
	
	using CategoricalArrays
	using DataFrames
	import CSV, HTTP
	using Dates: year
	using LinearAlgebra: I, dot
	using UnPack: @unpack
	
	Base.show(io::IO, ::MIME"text/html", x::CategoricalArrays.CategoricalValue) = print(io, get(x))
end


# ╔═╡ 7fadac3a-6b77-11eb-2030-f92648bcef71
md"""
`comparisons.jl` | **Version 1.1** | *last updated: Feb 24*
"""

# ╔═╡ 549c17f0-6b77-11eb-3cc7-379d1bcfad6f
md"""
# Social Comparisons, Income Inequality and the Mortgage Boom

This lecture is loosely based on [this paper](https://www.greimel.eu/static/falling-behind-paper.pdf). Here is what we will cover.

#### Lecture Notes

1. We will discuss some evidence that our economic decisions are influenced by our peers. *(Our consumption of visible goods depends on the consumption of our peers' visible goods.)*
   * [Neighbors of lottery winners buy bigger cars](https://www.aeaweb.org/articles?id=10.1257/aer.101.5.2226)
   * [Nonrich consume more visible goods when top incomes rise](https://www.mitpressjournals.org/doi/abs/10.1162/REST_a_00613)
   * [Home owners are less happy with their house when a big house is built nearby](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3378131)

2. Discuss how consumption network effects can be estimated [(paper)](https://academic.oup.com/restud/article/87/1/130/5486072)

3. We will model the group of peers as a social network. (Building on the lecture on *Network Games*.)

#### Pluto Notebook

4. We will have a look at the *Distributional National Accounts* data set and visualize rising income inequality and the household debt boom in the US.
    * [Data and paper](http://gabriel-zucman.eu/usdina/), [Julia package to manage dataset](https://github.com/greimel/DINA.jl)
5. Generate a debt boom from rising inequality using our model
"""

# ╔═╡ 93204904-6b7e-11eb-2101-711075dfeb68
md"""
# Distributional National Accounts

We will first take a look at a few facts from the US distributional national accounts data *(Piketty, Saez & Zucman, 2018)* and then try explain them using our simple model of social comparisons.

"""

# ╔═╡ 6e871ffa-6f70-11eb-3aa2-ef38243ab266
md"""
!!! note "Note"
    The DINA dataset can only be downloaded in bulk. It is >1GB in zipped form. You can use my package [DINA.jl](https://github.com/greimel/DINA.jl) to easily download and store the data. 

    Here we will work with summary statistics that can are taken from [the docs of DINA.jl](https://greimel.github.io/DINA.jl/latest/).
"""

# ╔═╡ b7a2d092-6f72-11eb-1b65-0b5fad667e97
md"""
## The US Household Debt Boom
"""

# ╔═╡ dd06ba2e-6f72-11eb-2bdd-e19bcb59e76e
md"""
## The US Inequality Boom
"""

# ╔═╡ fcdbad94-6b78-11eb-1f33-4b35fee6b1b9
md"""
# Simulating the model
"""

# ╔═╡ 2b9592ca-7688-11eb-34c2-3d4f2e4f3159
par_md = md"""
* ``\beta``: discount factor (assume ``\beta = 1/(1+r)``)
* ``\theta``: utility weight of housing
* ``\phi``: strength of the comparison motive
* ``p``: house price
"""

# ╔═╡ dca5d17a-7687-11eb-3bd4-b774087e626d
par_md

# ╔═╡ 076ab958-6b79-11eb-3426-37f1dab6d734
par = (β = 0.95, θ = 0.30, ϕ = 0.7, p = 1)

# ╔═╡ 4b3e320e-6b79-11eb-2336-d57c4c0e784c
h_next, h₀, y₀, groups, m_next = let
	@unpack β, θ, ϕ, p = par
	
	groups = ["bottom 50", "middle 40", "top 10"]
	
	κ₀ = θ/(1 - θ) * (1 + β)
	κ₁ = (1 + β) * θ / p
	κ₂ = 1 - θ
	
	y₀ = [0.5, 1, 2]

	G = [0  0   0.5;
		 0  0   0.5;
		 0.  0  0]
	
	h_next(y, h) = κ₁ * y + (κ₂ * ϕ) * G * h
	
	function m_next(y, h)
		h_n = h_next(y, h)
		
		β .* (y - p/κ₀ * (h_n - ϕ * G * h)) 
	end
	
	h₀ = (I - (ϕ * κ₂ * G)) \ (κ₁ * y₀)
	
	(; h_next, h₀, y₀, groups, m_next)
end

# ╔═╡ d2fe0186-6b7b-11eb-02e6-cfb1e163889f
begin
	N = length(h₀)
	T = 10
	h_sim = zeros(N, T)
	m_sim = zeros(N, T)
	h_sim[:, 1] = h₀
end

# ╔═╡ f6e061ce-6b7c-11eb-351d-8f890bc5318c
begin
	y_panel = zeros(N, T)
	y_panel[:, 1] .= y₀
	
	m_sim[:, 1] .= m_next(y₀, h₀)
	
	for t in 2:T
		y_panel[1, t] = y_panel[1, t-1]
		y_panel[2, t] = y_panel[2, t-1]
		y_panel[3, t] = 1.1 * y_panel[3, t-1]
	end
		
	for t in 2:T
		h_sim[:, t] = h_next(y_panel[:, t], h_sim[:, t-1])
		m_sim[:, t] = m_next(y_panel[:, t], h_sim[:, t-1])
	end
end	
	

# ╔═╡ 1dd8274e-75f5-11eb-060a-d7b5dbb5731a
y_panel

# ╔═╡ d03b547a-75f4-11eb-2cb1-99c8da1411b7
begin
	sim_df = [(; grp=groups[i], t) for i in 1:N, t in 1:T] |> vec |> DataFrame
	sim_df.y = y_panel |> vec
	sim_df.h = h_sim |> vec
	sim_df.m = m_sim |> vec
	
	transform!(sim_df, [:h, :y] => ByRow(/) => :house2inc)
	transform!(sim_df, [:m, :y] => ByRow(/) => :mort2inc)
	
	sim_df
end

# ╔═╡ b860a4d8-6b7c-11eb-27f2-99c8672eb53d
let
	fig = Figure()
	ax_h   = Axis(fig[1,1][2,1], title = "Housing")
	ax_y   = Axis(fig[1,1][2,3], title = "Income")
	ax_m   = Axis(fig[1,1][2,2], title = "Mortgage")
	
	ax_h2y = Axis(fig[1,1][1,1], title = "%Δ Housing/Income")
	ax_d2y = Axis(fig[1,1][1,2], title = "%Δ Mortgage/Income")
	
	col = wong_colors
	
	for (i, gdf) in enumerate(groupby(sim_df, :grp))
		grp = only(unique(gdf.grp))
		
		lines!(ax_y, gdf.t, gdf.y, label = grp, color = col[i])
		lines!(ax_h, gdf.t, gdf.h, label = grp, color = col[i])
		lines!(ax_m, gdf.t, gdf.m, label = grp, color = col[i])
		
		lines!(ax_h2y, gdf.t, gdf.house2inc ./ gdf.house2inc[1], label = grp, color = col[i])
		lines!(ax_d2y, gdf.t, gdf.mort2inc ./ gdf.mort2inc[1], label = grp, color = col[i])
	end
	
	#leg_attr = (orientation = :horizontal, tellheight = true, tellwidth = false)
	leg_attr = (; tellwidth = false)
	
	Legend(fig[1,1][1,3], ax_d2y; leg_attr...)
	
	fig
end

# ╔═╡ df5509d8-6b77-11eb-1f61-6d9fe9729e46
md"""
## Appendix
"""

# ╔═╡ c4f5a49a-6b78-11eb-3f82-a52bde70c9d2
function csv_from_url(url)
	csv = CSV.File(HTTP.get(url).body)
	df = DataFrame(csv)
end

# ╔═╡ 2a8377c2-6f70-11eb-0685-f179a9cae063
begin
	dina_df = csv_from_url("https://greimel.github.io/DINA.jl/dev/dina-aggregated.csv")
	
	transform!(dina_df, :three_groups => categorical, renamecols = false)
	
	levels!(dina_df.three_groups, ["bottom 50", "middle 40", "top 10"])
	
	wgt = :dweght
	inc = :peinc
	byvar = inc
	dbt_var = [:ownermort, :rentalmort, :nonmort, :hwdeb]
	var = [byvar; dbt_var]
	
	dina_df
end

# ╔═╡ e6cd3534-6f71-11eb-1b98-478ba82441c6
agg_df = let df = dina_df
    df1 = select(df,
	    :group_id,
	    :age, :year, wgt, var...
    )
			
    df2 = combine(
	    groupby(df1, :year),
	    ([v, wgt] => ((x,w) -> dot(x,w)/sum(w)) => v for v in var)...
    )
		
    transform!(df2, ([d, inc] => ByRow(/) => string(d) * "2inc" for d in dbt_var)...)
end

# ╔═╡ 63f05226-6f72-11eb-3b34-35970668fdea
debt_fig = let d = agg_df
	fig = Figure()
	
	# Define Layout, Labels, Titles
	Label(fig[1,1], "Growth of Household-Debt-To-Income in the USA", tellwidth = false)
	axs = [Axis(fig[2,1][1,i]) for i in 1:2]
	
	box_attr = (color = :gray90, )
	label_attr = (padding = (3,3,3,3), )
	
	Box(fig[2,1][1,1, Top()]; box_attr...)
	Label(fig[2,1][1,1, Top()], "relative to 1980"; label_attr...)
	
	Box(fig[2,1][1,2, Top()]; box_attr...)
	Label(fig[2,1][1,2, Top()], "relative to total debt in 1980"; label_attr...)
	
	# Plot
	i80 = findfirst(d.year .== 1980)
	
	for (i,dbt) in enumerate(dbt_var)
		var = string(dbt) * "2inc"
		for (j, fractionof) in enumerate([var, :hwdeb2inc])
			lines!(axs[j], d.year, d[!,var]/d[i80,fractionof], label = string(dbt), color = wong_colors[i])
		end
	end

	# Legend
	leg_attr = (orientation = :horizontal, tellheight = true, tellwidth = false)
	leg = Legend(fig[3,1], axs[1]; leg_attr...)
	
	fig
end

# ╔═╡ 03b47940-6f73-11eb-32d8-818a673be255
md"""
## Controlling for consumer price inflation

[to be improved]
"""

# ╔═╡ 0f2f65f0-6f73-11eb-282f-3ff2adc50614
begin
	gdpdef = CSV.File(IOBuffer(
"""
DATE	GDPDEF
1947-01-01	12.2662500000000000
1948-01-01	12.9542500000000000
1949-01-01	12.9345000000000000
1950-01-01	13.0880000000000000
1951-01-01	14.0227500000000000
1952-01-01	14.2650000000000000
1953-01-01	14.4392500000000000
1954-01-01	14.5722500000000000
1955-01-01	14.8172500000000000
1956-01-01	15.3225000000000000
1957-01-01	15.8322500000000000
1958-01-01	16.1905000000000000
1959-01-01	16.4132500000000000
1960-01-01	16.6380000000000000
1961-01-01	16.8140000000000000
1962-01-01	17.0190000000000000
1963-01-01	17.2137500000000000
1964-01-01	17.4767500000000000
1965-01-01	17.7955000000000000
1966-01-01	18.2945000000000000
1967-01-01	18.8252500000000000
1968-01-01	19.6257500000000000
1969-01-01	20.5900000000000000
1970-01-01	21.6772500000000000
1971-01-01	22.7747500000000000
1972-01-01	23.7565000000000000
1973-01-01	25.0605000000000000
1974-01-01	27.3225000000000000
1975-01-01	29.8405000000000000
1976-01-01	31.4877500000000000
1977-01-01	33.4400000000000000
1978-01-01	35.7845000000000000
1979-01-01	38.7665000000000000
1980-01-01	42.2740000000000000
1981-01-01	46.2737500000000000
1982-01-01	49.1317500000000000
1983-01-01	51.0447500000000000
1984-01-01	52.8917500000000000
1985-01-01	54.5665000000000000
1986-01-01	55.6680000000000000
1987-01-01	57.0402500000000000
1988-01-01	59.0510000000000000
1989-01-01	61.3700000000000000
1990-01-01	63.6722500000000000
1991-01-01	65.8217500000000000
1992-01-01	67.3197500000000000
1993-01-01	68.9162500000000000
1994-01-01	70.3870000000000000
1995-01-01	71.8645000000000000
1996-01-01	73.1792500000000000
1997-01-01	74.4417500000000000
1998-01-01	75.2792500000000000
1999-01-01	76.3655000000000000
2000-01-01	78.0732500000000000
2001-01-01	79.7897500000000000
2002-01-01	81.0505000000000000
2003-01-01	82.5510000000000000
2004-01-01	84.7730000000000000
2005-01-01	87.4147500000000000
2006-01-01	90.0637500000000000
2007-01-01	92.4825000000000000
2008-01-01	94.2887500000000000
2009-01-01	95.0027500000000000
2010-01-01	96.1067500000000000
2011-01-01	98.1152500000000000
2012-01-01	99.9987500000000000
2013-01-01	101.7512500000000000
2014-01-01	103.6322500000000000
2015-01-01	104.6225000000000000
2016-01-01	105.7190000000000000
2017-01-01	107.7050000000000000
2018-01-01	110.2917500000000000
2019-01-01	112.2615000000000000
2020-01-01	113.6112500000000000
"""
			)) |> DataFrame

	gdpdef.year = year.(gdpdef.DATE)
end

# ╔═╡ f397be00-6f72-11eb-1600-b74b07053aa6
begin df = dina_df
	df1 = select(df,
		:group_id,
		:three_groups,
		:age, :year, wgt, var...
	)
	
	filter!(:age => !in([65]), df1)
	
	#transform!(df1, :grp_id => ByRow(x -> ifelse(x <= 5, "bottom 50", ifelse(x <= 9, "middle 40", "top 10"))) => :three_grps)
	
	df2 = combine(
		groupby(df1, [:three_groups, :year]),
		([v, wgt] => ((x,w) -> dot(x,w)/sum(w)) => v for v in var)...
	)
	
	df3 = leftjoin(df2, gdpdef, on = :year)
	rename!(df3, :GDPDEF => :prices)

	filter!(:prices => !ismissing, df3)
	
	disallowmissing!(df3)
		
	df3.prices = df3.prices ./ first(filter(:year => ==(1980), df3).prices)
	
	transform!(df3, ([v, :prices] => ByRow(/) => "r_$(string(v))" for v in var)...)
	transform!(df3, [:ownermort, inc] => ByRow(/) => "mort2inc")
end

# ╔═╡ 0d061bc8-6f75-11eb-2e73-c354e5f99841
d2y_fig = let
	fig = Figure()
	ax = Axis(fig[1,1], title = "Mortgage-to-income by income group")
	
	for (i,d) in enumerate(groupby(df3, :three_groups))
			i80 = findfirst(d.year .== 1980)
			lines!(ax, d.year, d.mort2inc ./ d.mort2inc[i80], label = only(unique(d.three_groups)), color = wong_colors[i])
	end

	Legend(fig[1,2], ax)
	fig
end

# ╔═╡ 4ccfee7a-75f9-11eb-04c4-cde6a5543f00
d2y_fig

# ╔═╡ 46cc354c-6f73-11eb-1a28-a5b171989df4
ineq_fig = let
	fig = Figure()
	ax = Axis(fig[1,1], title="Growth of real pre-tax incomes across income groups")
	
	r_inc = Symbol("r_" * string(inc))
	
	for (i,d) in enumerate(groupby(df3, :three_groups))
			i80 = findfirst(d.year .== 1980)
			lines!(ax, d.year, d[:,r_inc] ./ d[i80,r_inc], label = only(unique(d.three_groups)), color = wong_colors[i])
	end
	
	vlines!(ax, [1980, 2007])
	Legend(fig[1,2], ax)
	fig
end

# ╔═╡ 657d5a46-75f9-11eb-2a6a-7579218682da
ineq_fig

# ╔═╡ 09cabee2-6b78-11eb-29c8-8f616a79d0e5
md"""
## Package environment
"""

# ╔═╡ b1baa0d2-6b7c-11eb-39ec-f393691c37d9
TableOfContents()

# ╔═╡ Cell order:
# ╟─7fadac3a-6b77-11eb-2030-f92648bcef71
# ╟─549c17f0-6b77-11eb-3cc7-379d1bcfad6f
# ╟─93204904-6b7e-11eb-2101-711075dfeb68
# ╟─6e871ffa-6f70-11eb-3aa2-ef38243ab266
# ╠═2a8377c2-6f70-11eb-0685-f179a9cae063
# ╟─b7a2d092-6f72-11eb-1b65-0b5fad667e97
# ╟─63f05226-6f72-11eb-3b34-35970668fdea
# ╟─e6cd3534-6f71-11eb-1b98-478ba82441c6
# ╠═0d061bc8-6f75-11eb-2e73-c354e5f99841
# ╟─dd06ba2e-6f72-11eb-2bdd-e19bcb59e76e
# ╟─46cc354c-6f73-11eb-1a28-a5b171989df4
# ╟─f397be00-6f72-11eb-1600-b74b07053aa6
# ╟─fcdbad94-6b78-11eb-1f33-4b35fee6b1b9
# ╟─2b9592ca-7688-11eb-34c2-3d4f2e4f3159
# ╠═4b3e320e-6b79-11eb-2336-d57c4c0e784c
# ╠═d2fe0186-6b7b-11eb-02e6-cfb1e163889f
# ╠═f6e061ce-6b7c-11eb-351d-8f890bc5318c
# ╠═1dd8274e-75f5-11eb-060a-d7b5dbb5731a
# ╠═d03b547a-75f4-11eb-2cb1-99c8da1411b7
# ╠═dca5d17a-7687-11eb-3bd4-b774087e626d
# ╠═076ab958-6b79-11eb-3426-37f1dab6d734
# ╠═b860a4d8-6b7c-11eb-27f2-99c8672eb53d
# ╠═4ccfee7a-75f9-11eb-04c4-cde6a5543f00
# ╠═657d5a46-75f9-11eb-2a6a-7579218682da
# ╟─df5509d8-6b77-11eb-1f61-6d9fe9729e46
# ╠═c4f5a49a-6b78-11eb-3f82-a52bde70c9d2
# ╟─03b47940-6f73-11eb-32d8-818a673be255
# ╟─0f2f65f0-6f73-11eb-282f-3ff2adc50614
# ╟─09cabee2-6b78-11eb-29c8-8f616a79d0e5
# ╠═449a52cc-6b7c-11eb-035a-355b0c334582
# ╠═5350a65e-6b7c-11eb-3725-d59f6c3cf1a7
# ╠═15253560-6b78-11eb-12f6-91d27770a192
# ╠═b1baa0d2-6b7c-11eb-39ec-f393691c37d9
