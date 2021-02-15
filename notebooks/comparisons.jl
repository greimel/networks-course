### A Pluto.jl notebook ###
# v0.12.20

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
`comparisons.jl` | **Version 0.2** | *last updated: Feb 15*
"""

# ╔═╡ 1b5e05a6-6d35-11eb-1921-3b5c6836e288
md"""
!!! danger "Preliminary version"
    Nice that you've found this notebook on github. We appreciate your engagement. Feel free to have a look. Please note that the notebook is subject to change.
"""

# ╔═╡ 549c17f0-6b77-11eb-3cc7-379d1bcfad6f
md"""
# Social Comparisons, Income Inequality and the Mortgage Boom

This lecture is loosely based on [this paper](https://www.greimel.eu/static/falling-behind-paper.pdf). Here is what we will cover.

#### Lecture Notes

1. We will discuss some evidence that our economic decisions are influenced by our peers. *(Our consumption of visible goods depends on the consumption of our peers' visible goods.)*

2. We will model the group of peers as a social network. (Building on the lecture on *Network Games*.)

#### Pluto Notebook

3. We will have a look at the *Distributional National Accounts* data set and visualize rising income inequality and the household debt boom in the US.
"""

# ╔═╡ 12679864-6f8a-11eb-09e6-fb19d007cb68
md"""
4. Use the network model as a potential link between rising income inequality and the household debt boom.
"""

# ╔═╡ 93204904-6b7e-11eb-2101-711075dfeb68
md"""
# The Distribution of Income and Wealth

We will first take a look at the a few facts from the US distributional national accounts data *(Piketty, Saez & Zucman, 2018)* and then try explain them using our simple model of social comparisons.

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

# ╔═╡ 076ab958-6b79-11eb-3426-37f1dab6d734
par = (β = 0.95, ξ = 0.9, ϕ = 0.7, p = 1)

# ╔═╡ 4b3e320e-6b79-11eb-2336-d57c4c0e784c
h_next, h₀, y₀, groups = let
	@unpack β, ξ, ϕ, p = par
	
	groups = ["bottom 50", "middle 40", "top 10"]
	
	κ₁ = ξ/(1 - ξ) * (1 + β)
	κ₂ = (1 + β)/κ₁ + 1
	
	y₀ = [0.5, 1, 2]

	G = [0.5 0.5 0  ;
		 0   0.5 0.5;
		 0.  0   0]
	
	h_next(y, h) = (1-β)/(κ₂ * p) * y + ϕ / κ₂ * G * h
	
	h₀ = (I - (ϕ/κ₂ * G)) \	((1-β)/(κ₂ * p) * y₀)
	
	(; h_next, h₀, y₀, groups)
end

# ╔═╡ d2fe0186-6b7b-11eb-02e6-cfb1e163889f
begin
	N = length(h₀)
	T = 10
	h_sim = zeros(N, T)
	h_sim[:, 1] = h₀
end

# ╔═╡ f6e061ce-6b7c-11eb-351d-8f890bc5318c
begin
	y_panel = zeros(N, T)
	y_panel[:, 1] .= y₀
	for t in 2:T
		y_panel[1, t] = y_panel[1, t-1]
		y_panel[2, t] = y_panel[2, t-1]
		y_panel[3, t] = 1.1 * y_panel[3, t-1]
	end
		
	for t in 2:T
		h_sim[:, t] = h_next(y_panel[:, t-1], h_sim[:, t-1])
	end
end	
	

# ╔═╡ b860a4d8-6b7c-11eb-27f2-99c8672eb53d
let
	fig = Figure()
	ax_h   = Axis(fig[1,1], title = "Housing")
	ax_y   = Axis(fig[1,2], title = "Income")
	ax_h2y = Axis(fig[1,3], title = "Housing/Income")
	
	for i in 1:N
		lines!(ax_y, y_panel[i,:], label = groups[i], color = wong_colors[i])
		lines!(ax_h, h_sim[i,:], label = groups[i], color = wong_colors[i])
		lines!(ax_h2y, h_sim[i,:] ./ y_panel[i,:], label = groups[i], color = wong_colors[i])
	end
	
	leg_attr = (orientation = :horizontal, tellheight = true, tellwidth = false)
	Legend(fig[0,:], ax_h; leg_attr...)
	
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

# ╔═╡ 7219b104-6f8a-11eb-3ed1-171f91da5c2e
debt_fig

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
let
	fig = Figure()
	ax = Axis(fig[1,1], title = "Mortgage-to-income by income group")
	
	for (i,d) in enumerate(groupby(df3, :three_groups))
			i80 = findfirst(d.year .== 1980)
			lines!(ax, d.year, d.mort2inc ./ d.mort2inc[i80], label = only(unique(d.three_groups)), color = wong_colors[i])
	end

	Legend(fig[1,2], ax)
	fig
end

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

# ╔═╡ 1982321e-6f8a-11eb-1b0b-8710ceb30b96
ineq_fig

# ╔═╡ 09cabee2-6b78-11eb-29c8-8f616a79d0e5
md"""
## Package environment
"""

# ╔═╡ b1baa0d2-6b7c-11eb-39ec-f393691c37d9
TableOfContents()

# ╔═╡ Cell order:
# ╟─7fadac3a-6b77-11eb-2030-f92648bcef71
# ╟─1b5e05a6-6d35-11eb-1921-3b5c6836e288
# ╟─549c17f0-6b77-11eb-3cc7-379d1bcfad6f
# ╠═1982321e-6f8a-11eb-1b0b-8710ceb30b96
# ╠═7219b104-6f8a-11eb-3ed1-171f91da5c2e
# ╟─12679864-6f8a-11eb-09e6-fb19d007cb68
# ╟─93204904-6b7e-11eb-2101-711075dfeb68
# ╟─6e871ffa-6f70-11eb-3aa2-ef38243ab266
# ╠═2a8377c2-6f70-11eb-0685-f179a9cae063
# ╟─b7a2d092-6f72-11eb-1b65-0b5fad667e97
# ╟─63f05226-6f72-11eb-3b34-35970668fdea
# ╟─e6cd3534-6f71-11eb-1b98-478ba82441c6
# ╠═0d061bc8-6f75-11eb-2e73-c354e5f99841
# ╟─dd06ba2e-6f72-11eb-2bdd-e19bcb59e76e
# ╠═46cc354c-6f73-11eb-1a28-a5b171989df4
# ╠═f397be00-6f72-11eb-1600-b74b07053aa6
# ╟─fcdbad94-6b78-11eb-1f33-4b35fee6b1b9
# ╠═076ab958-6b79-11eb-3426-37f1dab6d734
# ╠═4b3e320e-6b79-11eb-2336-d57c4c0e784c
# ╠═d2fe0186-6b7b-11eb-02e6-cfb1e163889f
# ╠═f6e061ce-6b7c-11eb-351d-8f890bc5318c
# ╠═b860a4d8-6b7c-11eb-27f2-99c8672eb53d
# ╟─df5509d8-6b77-11eb-1f61-6d9fe9729e46
# ╠═c4f5a49a-6b78-11eb-3f82-a52bde70c9d2
# ╟─03b47940-6f73-11eb-32d8-818a673be255
# ╟─0f2f65f0-6f73-11eb-282f-3ff2adc50614
# ╟─09cabee2-6b78-11eb-29c8-8f616a79d0e5
# ╠═449a52cc-6b7c-11eb-035a-355b0c334582
# ╠═5350a65e-6b7c-11eb-3725-d59f6c3cf1a7
# ╠═15253560-6b78-11eb-12f6-91d27770a192
# ╠═b1baa0d2-6b7c-11eb-39ec-f393691c37d9
