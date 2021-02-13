### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ c6cb9ab0-6d4a-11eb-1cf6-a3da74c858f3
using Dates

# ╔═╡ 6b11d6da-6bab-11eb-1919-bddfe835570a
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.develop(Pkg.PackageSpec(path = expanduser("~/Data/DINA")))
	Pkg.add([
	#	Pkg.PackageSpec(url = "https://github.com/greimel/DINA.jl"),
		Pkg.PackageSpec(name = "DataAPI", version = "1.4"),
	])
	Pkg.add(["CairoMakie", "Revise", "DataFrames", "PlutoUI", "TableOperations", "StatsBase", "CategoricalArrays", "Tables", "Chain", "UnPack", "ReadableRegex", "CSV", "StatFiles"])
	
	using UnPack: @unpack
	using Chain: @chain
	using LinearAlgebra: dot
	import CSV
	using Revise
	using PlutoUI
	using Tables
	using TableOperations #: select, filter, transform
	using StatsBase
	using StatFiles
	using CategoricalArrays
	using DataFrames
	using CairoMakie, DINA
	using ReadableRegex
	
	Base.show(io::IO, ::MIME"text/html", x::CategoricalArrays.CategoricalValue) = print(io, get(x))


end

# ╔═╡ 8c26d136-6d4a-11eb-3817-77b20b14a9b4
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

# ╔═╡ b582d76e-6d4a-11eb-3d60-73a262968f25
gdpdef.year

# ╔═╡ c029567a-6bab-11eb-31d2-bd3b60724e99
md"""
# Distributional National Accounts
"""

# ╔═╡ dee716ce-6bab-11eb-1cdc-e18c5bf026a9
df80 = begin
	tbl = get_dina(1980)
	@assert tbl isa DINA.StatFiles.StatFile
	DataFrame(tbl)
end

# ╔═╡ 876ec3a8-6bb3-11eb-2d6c-39cfffb4d401
begin
	ids = [:id]
	grp = [:age]
	wgt = :dweght
	byvar = :peinc
	dbt_var = [:ownermort, :rentalmort, :nonmort, :hwdeb]
	var = [[:fiinc, :fninc, :ptinc, :peinc, :poinc, :ownerhome, :rentalhome]; dbt_var]
	cols = [ids; grp; wgt; var]
end

# ╔═╡ af9ad364-6e04-11eb-18fa-cf66c3cf4f6b


# ╔═╡ 31f69312-6bb1-11eb-220d-efd477af3e7a
df = dina_quantile_panel(var, byvar, 10; wgt)

# ╔═╡ aa5659fc-6be6-11eb-272c-09834723ab9b
size(df)

# ╔═╡ 1811758c-6bbd-11eb-1bde-81cead34ade8
df |> CSV.write("dina_aggregated.csv")

# ╔═╡ 11e25cc0-6e02-11eb-06ce-478cc66b8410
md"""
## Aggregate Debt
"""

# ╔═╡ 302d69a4-6e02-11eb-2ee6-01bd650a5a63
agg_df = let
	df1 = select(df,
		:group,
		:group => ByRow(x -> parse(Int, string(x)[6:end])) => :grp_id,
		:age, :year, wgt, var...
	)
	
	filter!(:age => !in([65]), df1)
	
	#transform!(df1, :grp_id => ByRow(x -> ifelse(x <= 5, "bottom 50", ifelse(x <= 9, "middle 40", "top 10"))) => :three_grps)
	
	df2 = combine(
		groupby(df1, :year),
		([v, wgt] => ((x,w) -> dot(x,w)/sum(w)) => v for v in var)...
	)
	
	df3 = leftjoin(df2, gdpdef, on = :year)
	rename!(df3, :GDPDEF => :prices)

	filter!(:prices => !ismissing, df3)
	
	disallowmissing!(df3)
	
	df3.prices = df3.prices ./ first(filter(:year => ==(1980), df3).prices)
	
	inc = :peinc
	
	transform!(df3, ([v, :prices] => ByRow(/) => "r_$(string(v))" for v in var)...)
	transform!(df2, ([d, inc] => ByRow(/) => string(d) * "2inc" for d in dbt_var)...)
#	transform!(df3, [:ownermort, :rentalmort] => ByRow(+) => :mort)
#	transform!(df3, [:mort, ] => ByRow(/) => "mort2inc")
end

# ╔═╡ 5ecf0b3c-6e02-11eb-280d-ef6617d94d3c
let d = agg_df
	fig = Figure()
	Label(fig[1,1], "Growth of Household-Debt-To-Income in the USA", tellwidth = false)
	ax1 = Axis(fig[2,1][1,1], ylabel = "relative to 1980")
	ax2 = Axis(fig[2,1][1,2], ylabel = "relative to total debt in 1980")
	
	axs = [ax1, ax2]
	
	colors = [:blue, :red, :green, :orange]
	i80 = findfirst(d.year .== 1980)
	
	for (i,dbt) in enumerate(dbt_var)
		var = string(dbt) * "2inc"
		for (j, fractionof) in enumerate([var, :hwdeb2inc])
			lines!(axs[j], d.year, d[!,var]/d[i80,fractionof], label = string(dbt), color = colors[i])
		end
	end

	leg_attr = (orientation = :horizontal, tellheight = true, tellwidth = false)
	leg = Legend(fig[3,1], ax1; leg_attr...)
	
	fig
end

# ╔═╡ f94d2ce4-6e01-11eb-3e0d-5f3a0d45f227
md"""
## Three Groups: Bottom 50, Middle 40, Top 10
"""

# ╔═╡ 339dee36-6d37-11eb-0b57-cf3dc61977a7
begin
	df1 = select(df,
		:group,
		:group => ByRow(x -> parse(Int, string(x)[6:end])) => :grp_id,
		:age, :year, wgt, var...
	)
	
	filter!(:age => !in([65]), df1)
	
	transform!(df1, :grp_id => ByRow(x -> ifelse(x <= 5, "bottom 50", ifelse(x <= 9, "middle 40", "top 10"))) => :three_grps)
	
	df2 = combine(
		groupby(df1, [:three_grps, :year]),
		([v, wgt] => ((x,w) -> dot(x,w)/sum(w)) => v for v in var)...
	)
	
	df3 = leftjoin(df2, gdpdef, on = :year)
	rename!(df3, :GDPDEF => :prices)

	filter!(:prices => !ismissing, df3)
	
	disallowmissing!(df3)
	
	df3.prices = df3.prices ./ first(filter(:year => ==(1980), df3).prices)
	
	transform!(df3, ([v, :prices] => ByRow(/) => "r_$(string(v))" for v in var)...)
	transform!(df3, [:ownermort, :fiinc] => ByRow(/) => "mort2inc")
end



# ╔═╡ e8d56ff8-6d42-11eb-13c0-73e77a9df363
let
	fig = Figure()
	ax = Axis(fig[1,1], title="Growth of real pre-tax incomes across income groups")
	
	colors = [:blue, :red, :green]
	
	for (i,d) in enumerate(groupby(df3, :three_grps))
			i80 = findfirst(d.year .== 1980)
			lines!(ax, d.year, d.r_peinc ./ d.r_peinc[i80], label = only(unique(d.three_grps)), color = colors[i])
	end
	
	vlines!(ax, [1980, 2007])
	Legend(fig[1,2], ax)
	fig
end

# ╔═╡ 5406fb5e-6d3c-11eb-0723-4bc72209a494
let
	fig = Figure()
	ax = Axis(fig[1,1])
	
	colors = [:blue, :red, :green]
	
	for (i,d) in enumerate(groupby(df3, :three_grps))
			i80 = 17 #findfirst(d.year == 1980)
			lines!(ax, d.year, d.mort2inc ./ d.mort2inc[i80], label = only(unique(d.three_grps)), color = colors[i])
	end

	Legend(fig[1,2], ax)
	fig
end

# ╔═╡ 87157a66-6d41-11eb-2a54-df5acc3c8f5c
dir = mktempdir()

# ╔═╡ c99ea1de-6d41-11eb-3b7a-293ea34a45d8
path = joinpath(dir, "macrohistory.dta")

# ╔═╡ 4eaeaaa8-6d41-11eb-33df-cf83b212130d
download("http://macrohistory.net/JST/JSTdatasetR4.dta", path)

# ╔═╡ 5b4205f8-6d41-11eb-0a36-8bf2431d6e2d
history_df = DataFrame(load(path))

# ╔═╡ e81d2d5e-6d41-11eb-219c-89787f066d0e
begin
	cpi_df = select(history_df, :year, :country, :cpi)
	filter!("country" => ==("USA"), cpi_df)
	select!(cpi_df, Not("country"))
	disallowmissing!(cpi_df)
end

# ╔═╡ 4190cb66-6d42-11eb-2342-e534a589c46f
lines(cpi_df.year, cpi_df.cpi)

# ╔═╡ ad57105a-6bab-11eb-398b-3d52dcac3e84
md"""
# Appendix
"""

# ╔═╡ bb5e7aa8-6bab-11eb-2d1e-6fa08cd912d0
TableOfContents()

# ╔═╡ Cell order:
# ╟─8c26d136-6d4a-11eb-3817-77b20b14a9b4
# ╠═c6cb9ab0-6d4a-11eb-1cf6-a3da74c858f3
# ╠═b582d76e-6d4a-11eb-3d60-73a262968f25
# ╟─c029567a-6bab-11eb-31d2-bd3b60724e99
# ╠═dee716ce-6bab-11eb-1cdc-e18c5bf026a9
# ╠═876ec3a8-6bb3-11eb-2d6c-39cfffb4d401
# ╠═af9ad364-6e04-11eb-18fa-cf66c3cf4f6b
# ╠═31f69312-6bb1-11eb-220d-efd477af3e7a
# ╠═aa5659fc-6be6-11eb-272c-09834723ab9b
# ╠═1811758c-6bbd-11eb-1bde-81cead34ade8
# ╟─11e25cc0-6e02-11eb-06ce-478cc66b8410
# ╟─302d69a4-6e02-11eb-2ee6-01bd650a5a63
# ╠═5ecf0b3c-6e02-11eb-280d-ef6617d94d3c
# ╟─f94d2ce4-6e01-11eb-3e0d-5f3a0d45f227
# ╠═339dee36-6d37-11eb-0b57-cf3dc61977a7
# ╠═e8d56ff8-6d42-11eb-13c0-73e77a9df363
# ╠═5406fb5e-6d3c-11eb-0723-4bc72209a494
# ╠═87157a66-6d41-11eb-2a54-df5acc3c8f5c
# ╠═c99ea1de-6d41-11eb-3b7a-293ea34a45d8
# ╠═4eaeaaa8-6d41-11eb-33df-cf83b212130d
# ╠═5b4205f8-6d41-11eb-0a36-8bf2431d6e2d
# ╠═e81d2d5e-6d41-11eb-219c-89787f066d0e
# ╠═4190cb66-6d42-11eb-2342-e534a589c46f
# ╟─ad57105a-6bab-11eb-398b-3d52dcac3e84
# ╠═6b11d6da-6bab-11eb-1919-bddfe835570a
# ╠═bb5e7aa8-6bab-11eb-2d1e-6fa08cd912d0
