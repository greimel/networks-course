### A Pluto.jl notebook ###
# v0.12.19

using Markdown
using InteractiveUtils

# ╔═╡ 7aea5180-615c-11eb-2697-839dd9b58069
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.add(["DataFrames", "CSV"])
	
	using DataFrames
	using CSV
	
	_a_ = 1 # make sure this is cell #1
	nothing
end

# ╔═╡ f201dae0-615c-11eb-1d9a-25c74ffbe247
md"""
**NOTE:** This notebook fails on the first run because the Python installation doesn't realize that the package gets installed. Should work fine on the second run!
"""

# ╔═╡ 644a1208-615c-11eb-0aaa-33dcf1d53b9e
md"""
## Install Python and the package `twint`
"""

# ╔═╡ 6c8f7e08-615c-11eb-16a6-c758c1b75595
# Make sure Python is available - install if necessary
begin
	ENV["PYTHON"] = ""
	Pkg.add(["PyCall", "Conda"])
	Pkg.build("PyCall")
	
	import PyCall, Conda
	
	_b_ = _a_ + 1 # make sure this is cell #2
	nothing
end

# ╔═╡ 797dafd8-615c-11eb-284f-4371832ffa3a
begin
	util = PyCall.pyimport("importlib.util")
	twint_installed = !isnothing(util.find_spec("twint"))
	
	_c_ = _b_ + 1 # make sure this is cell #3
	nothing
end

# ╔═╡ 9dfa826c-615c-11eb-24b5-2148f792416f
# installing and using Python package "twint" for scraping twitter data
begin
	
	if !twint_installed
		# install twint from github repo
		run(`$(Conda._pip(Conda.ROOTENV)) install --user --upgrade -e "git+https://github.com/twintproject/twint.git@origin/master#egg=twint"`)
	end
	
	_d_ = _c_ + 1 # make sure this is cell #4
	nothing
end

# ╔═╡ a2a8869c-615c-11eb-04a1-dde99c34739f
begin
	twint = PyCall.pyimport("twint")
	
	_e_ = _d_ + 1 # make sure this is cell #5
	nothing
end

# ╔═╡ b3739688-615c-11eb-2c9f-43d1c52c639e
file_name = joinpath(".", "twitter-data.csv")

# ╔═╡ ac4d6410-615c-11eb-15fe-a3893067076c
c = let
	# Configure
	c = twint.Config()
	c.Search = "#econtwitter"
	#c.Lang = "dutch"
	#c.Geo = "52.377956,4.897070,5km"
	c.Limit = 500
	c.Output = file_name
	c.Store_csv = true
	c.Min_likes = 2
	c
end

# ╔═╡ c3882da6-615c-11eb-2ab2-b7ba153d6961
begin
	_x_ = 1
	isfile(file_name) && rm(file_name)
	twint.run.Search(c)
end

# ╔═╡ c7000448-615c-11eb-25b0-416b401146b6
begin
	_x_ # make sure that this cell is run after the CSV is created
	df0 = CSV.File(file_name) |> DataFrame
end

# ╔═╡ Cell order:
# ╟─f201dae0-615c-11eb-1d9a-25c74ffbe247
# ╟─644a1208-615c-11eb-0aaa-33dcf1d53b9e
# ╠═7aea5180-615c-11eb-2697-839dd9b58069
# ╠═6c8f7e08-615c-11eb-16a6-c758c1b75595
# ╠═797dafd8-615c-11eb-284f-4371832ffa3a
# ╠═9dfa826c-615c-11eb-24b5-2148f792416f
# ╠═a2a8869c-615c-11eb-04a1-dde99c34739f
# ╠═b3739688-615c-11eb-2c9f-43d1c52c639e
# ╠═ac4d6410-615c-11eb-15fe-a3893067076c
# ╠═c3882da6-615c-11eb-2ab2-b7ba153d6961
# ╠═c7000448-615c-11eb-25b0-416b401146b6
