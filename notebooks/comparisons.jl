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
		Figure, Axis, Legend,
		lines!, scatter!, scatterlines, scatterlines!, vlines!, 
		hidedecorations!, ylims!, cgrad,
		@lift, Node
	
	Pkg.add("NetworkLayout")
	using NetworkLayout: NetworkLayout
end

# ╔═╡ 15253560-6b78-11eb-12f6-91d27770a192
begin
	_c_ = _b_ + 1
	
	Pkg.add([
			#PackageSpec(name = "", version = "")_,
			#PackageSpec(name = "", version = "")),
			PackageSpec(name = "UnPack", version = "1")
			])
	
	using LinearAlgebra: I
	using UnPack: @unpack
end


# ╔═╡ 7fadac3a-6b77-11eb-2030-f92648bcef71
md"""
`comparisons.jl` | **Version 0.1** | *last updated: Feb 10*
"""

# ╔═╡ 549c17f0-6b77-11eb-3cc7-379d1bcfad6f
md"""
# Social Comparisons, Income Inequality and the Mortgage Boom

This lecture is loosely based on [this paper](https://www.greimel.eu/static/falling-behind-paper.pdf).

"""

# ╔═╡ 93204904-6b7e-11eb-2101-711075dfeb68
md"""
# The Distribution of Income and Wealth

Download DINA data
"""

# ╔═╡ fcdbad94-6b78-11eb-1f33-4b35fee6b1b9
md"""
# Simulating the model
"""

# ╔═╡ 076ab958-6b79-11eb-3426-37f1dab6d734
par = (β = 0.95, ξ = 0.3, ϕ = 0.7, p = 1)

# ╔═╡ 4b3e320e-6b79-11eb-2336-d57c4c0e784c
h_next, h₀, y₀ = let
	@unpack β, ξ, ϕ, p = par
	
	κ₁ = ξ/(1 - ξ) * (1 + β)
	κ₂ = (1 + β)/κ₁ + 1
	
	y₀ = [0.5, 1, 2]

	G = [0.5 0.5 0  ;
		 0   0.5 0.5;
		 0.  0   1]
	
	h_next(y, h) = (1-β)/(κ₂ * p) * y + ϕ / κ₂ * G * h
	
	h₀ = (I - (ϕ/κ₂ * G)) \	((1-β)/(κ₂ * p) * y₀)
	
	(; h_next, h₀, y₀)
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
		
end	
	

# ╔═╡ ceddbdfe-6b7a-11eb-011c-87d1f7272609
for t in 2:T
	h_sim[:, t] = h_next(y_panel[:, t-1], h_sim[:, t-1])
end

# ╔═╡ b860a4d8-6b7c-11eb-27f2-99c8672eb53d
let
	fig = Figure()
	ax_h = Axis(fig[1,1], title = "Housing")
	ax_y = Axis(fig[1,2], title = "Income")
	
	colors = cgrad(:viridis, N, categorical=true)
	
	for i in 1:N
		lines!(ax_y, y_panel[i,:], label = "group $i", color = colors[i])
		lines!(ax_h, h_sim[i,:], label = "group $i", color = colors[i])
	end
	Legend(fig[1,3], ax_h)
	
	fig
end

# ╔═╡ df5509d8-6b77-11eb-1f61-6d9fe9729e46
md"""
## Appendix
"""

# ╔═╡ c4f5a49a-6b78-11eb-3f82-a52bde70c9d2


# ╔═╡ 09cabee2-6b78-11eb-29c8-8f616a79d0e5
md"""
## Package environment
"""

# ╔═╡ b1baa0d2-6b7c-11eb-39ec-f393691c37d9
TableOfContents()

# ╔═╡ Cell order:
# ╟─7fadac3a-6b77-11eb-2030-f92648bcef71
# ╟─549c17f0-6b77-11eb-3cc7-379d1bcfad6f
# ╠═93204904-6b7e-11eb-2101-711075dfeb68
# ╟─fcdbad94-6b78-11eb-1f33-4b35fee6b1b9
# ╠═076ab958-6b79-11eb-3426-37f1dab6d734
# ╠═4b3e320e-6b79-11eb-2336-d57c4c0e784c
# ╠═d2fe0186-6b7b-11eb-02e6-cfb1e163889f
# ╠═f6e061ce-6b7c-11eb-351d-8f890bc5318c
# ╠═ceddbdfe-6b7a-11eb-011c-87d1f7272609
# ╠═b860a4d8-6b7c-11eb-27f2-99c8672eb53d
# ╟─df5509d8-6b77-11eb-1f61-6d9fe9729e46
# ╠═c4f5a49a-6b78-11eb-3f82-a52bde70c9d2
# ╟─09cabee2-6b78-11eb-29c8-8f616a79d0e5
# ╠═449a52cc-6b7c-11eb-035a-355b0c334582
# ╠═5350a65e-6b7c-11eb-3725-d59f6c3cf1a7
# ╠═15253560-6b78-11eb-12f6-91d27770a192
# ╠═b1baa0d2-6b7c-11eb-39ec-f393691c37d9
