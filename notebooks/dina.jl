### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 6b11d6da-6bab-11eb-1919-bddfe835570a
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.develop(Pkg.PackageSpec(path = expanduser("~/Data/DINA")))
	Pkg.add([
	#	Pkg.PackageSpec(url = "https://github.com/greimel/DINA.jl"),
		Pkg.PackageSpec(name = "DataAPI", version = "1.4"),
	])
	Pkg.add(["CairoMakie", "Revise", "DataFrames", "PlutoUI", "TableOperations", "StatsBase", "CategoricalArrays", "Tables", "Chain", "UnPack", "ReadableRegex", "CSV"])
	
	using UnPack: @unpack
	using Chain: @chain
	using LinearAlgebra: dot
	import CSV
	using Revise
	using PlutoUI
	using Tables
	using TableOperations #: select, filter, transform
	using StatsBase
	using CategoricalArrays
	using DataFrames
	using CairoMakie, DINA
	using ReadableRegex
	
	Base.show(io::IO, ::MIME"text/html", x::CategoricalArrays.CategoricalValue) = print(io, get(x))


end

# ╔═╡ c029567a-6bab-11eb-31d2-bd3b60724e99
md"""
# Distributional National Accounts
"""

# ╔═╡ dee716ce-6bab-11eb-1cdc-e18c5bf026a9
df80 = get_dina(1980)

# ╔═╡ 2c7d1fa6-6be2-11eb-087e-9947d090fd79
df80 isa DINA.StatFiles.StatFile

# ╔═╡ 876ec3a8-6bb3-11eb-2d6c-39cfffb4d401
begin
	ids = [:id]
	grp = [:age]
	wgt = :dweght
	var = [:fiinc, :fninc, :ownermort, :ownerhome, :rentalmort, :rentalhome]
end

# ╔═╡ d9b6b664-6bae-11eb-2ec6-41be8491f39b
cols = [ids; grp; wgt; var]

# ╔═╡ 175eb376-6baf-11eb-260d-9914bb428be2


# ╔═╡ b9948632-6be1-11eb-239a-b341eac2c8bc
[1962; 1964; 1966:2019] == sort(dina_years())

# ╔═╡ 3f96e872-6bbc-11eb-0d2e-dbca91b38292
all([1962; 1964; 1966:2019] .|> in(dina_years()))

# ╔═╡ 31f69312-6bb1-11eb-220d-efd477af3e7a
df = dina_quantile_panel(var, :fiinc, 10)

# ╔═╡ aa5659fc-6be6-11eb-272c-09834723ab9b
size(df)

# ╔═╡ 1811758c-6bbd-11eb-1bde-81cead34ade8
df |> CSV.write("dina_aggregated.csv")

# ╔═╡ 8ecc82f2-6bb1-11eb-1bcb-dbba92543f2b
begin
	fig = Figure()
	ax = Axis(fig[1,1])
	
	@chain df begin
		groupby([:group, :age])
		combine(_) do d
			lines!(ax, d.year, d.fiinc ./ 1000, label = only(unique(d.group)))
		end
	end
	fig
end

# ╔═╡ ad57105a-6bab-11eb-398b-3d52dcac3e84
md"""
# Appendix
"""

# ╔═╡ bb5e7aa8-6bab-11eb-2d1e-6fa08cd912d0
TableOfContents()

# ╔═╡ Cell order:
# ╟─c029567a-6bab-11eb-31d2-bd3b60724e99
# ╠═dee716ce-6bab-11eb-1cdc-e18c5bf026a9
# ╠═2c7d1fa6-6be2-11eb-087e-9947d090fd79
# ╠═876ec3a8-6bb3-11eb-2d6c-39cfffb4d401
# ╠═d9b6b664-6bae-11eb-2ec6-41be8491f39b
# ╠═175eb376-6baf-11eb-260d-9914bb428be2
# ╠═b9948632-6be1-11eb-239a-b341eac2c8bc
# ╠═3f96e872-6bbc-11eb-0d2e-dbca91b38292
# ╠═31f69312-6bb1-11eb-220d-efd477af3e7a
# ╠═aa5659fc-6be6-11eb-272c-09834723ab9b
# ╠═1811758c-6bbd-11eb-1bde-81cead34ade8
# ╠═8ecc82f2-6bb1-11eb-1bcb-dbba92543f2b
# ╟─ad57105a-6bab-11eb-398b-3d52dcac3e84
# ╠═6b11d6da-6bab-11eb-1919-bddfe835570a
# ╠═bb5e7aa8-6bab-11eb-2d1e-6fa08cd912d0
