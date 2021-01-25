### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ eabe56b0-5cf6-11eb-08cd-2156e2ca8163
begin
	import Pkg
	Pkg.activate(temp = true)
	Pkg.add("Plots")
	
	using Plots
	
	a_ = 1
end

# ╔═╡ 739ab076-5cc7-11eb-3697-599fcde5954c
let
	using Pkg
	Pkg.add(["LightGraphs", "GraphPlot", "SNAPDatasets", "FreqTables", "StatsBase"])
	using LightGraphs, GraphPlot, SNAPDatasets, FreqTables, StatsBase
	
	a_
end

# ╔═╡ ddf87b12-5cc5-11eb-0d4f-f3dd09839034
using PlutoUI

# ╔═╡ f1a2dec2-5cc6-11eb-2308-fb499f4133bc
md"This notebook is an introduction to the Julia programming language and gives a basic introduction of handling graphs in Julia."

# ╔═╡ 0d3aec92-edeb-11ea-3adb-cd0dc17cbdab
md"# A basic Julia syntax cheatsheet

This notebook briefly summarizes some of the basic Julia syntax that we will need for the problem sets.

*NOTE:* This part of the notebook is taken from [a notebook](https://github.com/mitmath/18S191/blob/Fall20/lecture_notebooks/Basic%20Julia%20syntax.jl) from the [MIT course Computional Thinking](https://computationalthinking.mit.edu/Fall20/).

"


# ╔═╡ 3b038ee0-edeb-11ea-0977-97cc30d1c6ff
md"## Variables

We can define a variable using `=` (assignment). Then we can use its value in other expressions:
"

# ╔═╡ 3e8e0ea0-edeb-11ea-22e0-c58f7c2168ce
x = 3

# ╔═╡ 59b66862-edeb-11ea-2d62-71dcc79dbfab
y = 2x

# ╔═╡ 5e062a24-edeb-11ea-256a-d938f77d7815
md"By default Julia displays the output of the last operation. (You can suppress the output by adding `;` (a semicolon) at the end.)
"

# ╔═╡ 7e46f0e8-edeb-11ea-1092-4b5e8acd9ee0
md"We can ask what type a variable has using `typeof`:"

# ╔═╡ 8a695b86-edeb-11ea-08cc-17263bec09df
typeof(y)

# ╔═╡ 8e2dd3be-edeb-11ea-0703-354fb31c12f5
md"## Functions"

# ╔═╡ 96b5a28c-edeb-11ea-11c0-597615962f54
md"We can use a short-form, one-line function definition for simple functions:"

# ╔═╡ a7453572-edeb-11ea-1e27-9f710fd856a6
f(x) = 2 + x

# ╔═╡ b341db4e-edeb-11ea-078b-b71ac00089d7
md"Typing the function's name gives information about the function. To call it we must use parentheses:"

# ╔═╡ 23f9afd4-eded-11ea-202a-9f0f1f91e5ad
f

# ╔═╡ cc1f6872-edeb-11ea-33e9-6976fd9b107a
f(10)

# ╔═╡ ce9667c2-edeb-11ea-2665-d789032abd11
md"For longer functions we use the following syntax with the `function` keyword and `end`:"

# ╔═╡ d73d3400-edeb-11ea-2dea-95e8c4a6563b
function g(x, y)
	z = x + y
	return z^2
end

# ╔═╡ e04ccf10-edeb-11ea-36d1-d11969e4b2f2
g(1, 2)

# ╔═╡ e297c5cc-edeb-11ea-3bdd-090f415685ab
md"## For loops"

# ╔═╡ ec751446-edeb-11ea-31ba-2372e7c71b42
md"Use `for` to loop through a pre-determined set of values:"

# ╔═╡ fe3fa290-edeb-11ea-121e-7114e5c573c1
let s = 0
	
	for i in 1:10
		s = s + i
	end
	
	s
end

# ╔═╡ 394b0ec8-eded-11ea-31fb-27392068ef8f
md"Here, `1:10` is a **range** representing the numbers from 1 to 10:"

# ╔═╡ 4dc00908-eded-11ea-25c5-0f7b2b7e18f9
typeof(1:10)

# ╔═╡ 6c44abb4-edec-11ea-16bd-557800b5f9d2
md"Above we used a `let` block to define a new local variable `s`. 
But blocks of code like this are usually better inside functions, so that they can be reused. For example, we could rewrite the above as follows:
"

# ╔═╡ 683af3e2-eded-11ea-25a5-0d90bf099d98
function mysum(n)
	s = 0
	
	for i in 1:n
		s = s + 1    
	end
	
	return s
end

# ╔═╡ 76764ea2-eded-11ea-1aa6-296f3421de1c
mysum(100)

# ╔═╡ 93a231f4-edec-11ea-3b39-299b3be2da78
md"## Conditionals: `if`"

# ╔═╡ 82e63a24-eded-11ea-3887-15d6bfabea4b
md"We can evaluate whether a condition is true or not by simply writing the condition:"

# ╔═╡ 9b339b2a-eded-11ea-10d7-8fc9a907c892
a = 3

# ╔═╡ 9535eb40-eded-11ea-1651-e33c9c23dbfb
a < 5

# ╔═╡ a16299a2-eded-11ea-2b56-93eb7a1010a7
md"We see that conditions have a Boolean (`true` or `false`) value. 

We can then use `if` to control what we do based on that value:"

# ╔═╡ bc6b124e-eded-11ea-0290-b3760cb81024
if a < 5
	"small"
	
else
	"big"
	
end

# ╔═╡ cfb21014-eded-11ea-1261-3bc30952a88e
md"""Note that the `if` also returns the last value that was evaluated, in this case the string `"small"` or `"big"`, Since Pluto is reactive, changing the definition of `a` above will automatically cause this to be reevaluated!"""

# ╔═╡ ffee7d80-eded-11ea-26b1-1331df204c67
md"## Arrays"

# ╔═╡ cae4137e-edee-11ea-14af-59a32227de1b
md"### 1D arrays (`Vector`s)"

# ╔═╡ 714f4fca-edee-11ea-3410-c9ab8825d836
md"We can make a `Vector` (1-dimensional, or 1D array) using square brackets:"

# ╔═╡ 82cc2a0e-edee-11ea-11b7-fbaa5ad7b556
v = [1, 2, 3]

# ╔═╡ 85916c18-edee-11ea-0738-5f5d78875b86
typeof(v)

# ╔═╡ 881b7d0c-edee-11ea-0b4a-4bd7d5be2c77
md"The `1` in the type shows that this is a 1D array.

We access elements also using square brackets:"

# ╔═╡ a298e8ae-edee-11ea-3613-0dd4bae70c26
v[2]

# ╔═╡ a5ebddd6-edee-11ea-2234-55453ea59c5a
v[2] = 10

# ╔═╡ a9b48e54-edee-11ea-1333-a96181de0185
md"Note that Pluto does not automatically update cells when you modify elements of an array, but the value does change."

# ╔═╡ 68c4ead2-edef-11ea-124a-03c2d7dd6a1b
md"A nice way to create `Vector`s following a certain pattern is to use an **array comprehension**:"

# ╔═╡ 84129294-edef-11ea-0c77-ffa2b9592a26
v2 = [i^2 for i in 1:10]

# ╔═╡ d364fa16-edee-11ea-2050-0f6cb70e1bcf
md"## 2D arrays (matrices)"

# ╔═╡ db99ae9a-edee-11ea-393e-9de420a545a1
md"We can make small matrices (2D arrays) with square brackets too:"

# ╔═╡ 04f175f2-edef-11ea-0882-712548ebb7a3
M = [1 2
	 3 4]

# ╔═╡ 0a8ac112-edef-11ea-1e99-cf7c7808c4f5
typeof(M)

# ╔═╡ 1295f48a-edef-11ea-22a5-61e8a2e1d005
md"The `2` in the type confirms that this is a 2D array."

# ╔═╡ 3e1fdaa8-edef-11ea-2f03-eb41b2b9ea0f
md"This won't work for larger matrices, though. For that we can use e.g."

# ╔═╡ 48f3deca-edef-11ea-2c18-e7419c9030a0
zeros(5, 5)

# ╔═╡ a8f26af8-edef-11ea-2fc7-2b776f515aea
md"Note that `zeros` gives `Float64`s by default. We can also specify a type for the elements:"

# ╔═╡ b595373e-edef-11ea-03e2-6599ef14af20
zeros(Int, 4, 5)

# ╔═╡ 4cb33c04-edef-11ea-2b35-1139c246c331
md"We can then fill in the values we want by manipulating the elements, e.g. with a `for` loop."

# ╔═╡ 54e47e9e-edef-11ea-2d75-b5f550902528
md"A nice alternative syntax to create matrices following a certain pattern is an array comprehension with a *double* `for` loop:"

# ╔═╡ 6348edce-edef-11ea-1ab4-019514eb414f
[i + j for i in 1:5, j in 1:6]

# ╔═╡ da543aa6-5cf6-11eb-3c03-b170e254f1b7
md"""
# Plots with Plots.jl
"""

# ╔═╡ 427c55aa-5cf7-11eb-214b-0d7713035e83
scatter(rand(100), rand(100))

# ╔═╡ e9231ac2-5cf9-11eb-3bc2-09f5527e374f
histogram(randn(1000))

# ╔═╡ 58f5f420-5cc6-11eb-2569-198d8fde52ef
md"""
# Graphs with LightGraphs.jl - Basics

In this section we show you how to create networks in Julia and how to visualize them.

1. special named graphs
2. do it yourself
3. from a dataset

"""

# ╔═╡ e09d1054-5cce-11eb-3676-4ded6f7a1bed
md"""
## Graphs with names

Let us plot our first networks. Below you see *star network* (can you imagine why it is called that way?). You can specify it by
"""

# ╔═╡ 2a7a4d56-5cca-11eb-2eb9-5ba63fb08f60
n_nodes = 10

# ╔═╡ 2e06390c-5cc9-11eb-121b-0b62b08045b7
graph = StarGraph(n_nodes)

# ╔═╡ fd349f66-5cc9-11eb-1c34-9bd978ad8f0a
gplot(graph)

# ╔═╡ ca78ffee-5cca-11eb-16f0-7d31af21eeb8
md"
Play around with this code. You can change the number of nodes and see you the plot will update automatically. 

You can also look at different *special* graphs

* wheel network (`WheelGraph`)
* circle network (`CycleGraph`)
* complete network (`CompleteGraph`)
* path network (`PathGraph`)

Try it and visualize a few graphs!

"

# ╔═╡ 0684a778-5cca-11eb-33ce-9f776f8f822a
ne(graph) # number of edges

# ╔═╡ 12529414-5cca-11eb-2b7a-8dabda743c6b
nv(graph) # number of vertices

# ╔═╡ 2bb95670-5cf6-11eb-150f-c9a46823e1c3
degree_centrality(graph, normalize=false)

# ╔═╡ 3dc235da-5cf6-11eb-3e7f-5f3a0b23c274
gplot(graph, nodelabel = degree_centrality(graph, normalize=false))

# ╔═╡ 04462bb6-5cd0-11eb-1f11-93893266fdb8
begin
	my_network = SimpleGraph(7)
	add_edge!(my_network, 1, 2)
	add_edge!(my_network, 2, 3)
end

# ╔═╡ b705ba38-5ccf-11eb-066b-f740c921de29
md"""
## Building a network from scratch

Below you find a template of building a network from scratch. Play with it make it your own! (you can set the number of nodes (currently $(nv(my_network))) and add a few edges (there are currently $(ne(my_network))).

(Can you rebuild one of the named networks from above?)

"""

# ╔═╡ 302e3dbc-5cd1-11eb-0df0-f7c2ac8da01b
gplot(my_network, layout = random_layout)

# ╔═╡ c3830328-5cf3-11eb-1950-79d3a58ef117
gplot(my_network, layout = spring_layout)

# ╔═╡ 49683a94-5cd1-11eb-04e1-8587582c0b91
md"""
You will probably realize that many graph drawing algorithms are not deterministic. The plot may look different if you re-execute it.
"""

# ╔═╡ 2552966c-5cd2-11eb-1502-ff44fcc3ebaf
md"""
## Giving networks a meaning

There are plenty of network datasets out there. You can check out the *Stanford Large Network Dataset Collection* [[link]](https://snap.stanford.edu/data/index.html). A very small subset of these datasets can be downloaded directly from Julia using the package *SNAPDatasets.jl* [[link]](https://github.com/JuliaGraphs/SNAPDatasets.jl).

Let us have a look at the Facebook dataset, with 4039 nodes and 88234 edges. [[link to description]](https://snap.stanford.edu/data/ego-Facebook.html)
"""

# ╔═╡ fc5204aa-5cea-11eb-0d51-d783dfa78c11
big_graph = loadsnap(:facebook_combined)

# ╔═╡ 2e2f9f62-5cf2-11eb-0a91-a5a1f83697d0
md"Even though the dataset is rather small compared to others from this collection, we already run into problems when we want to visualize the network. 

Don't run the following cell on an old computer. The plot takes around 1 minute on my recent MacBook Pro."

# ╔═╡ b21e4082-5ceb-11eb-261d-438b4b6b6b38
#gplot(big_graph)

# ╔═╡ 7e8d62ea-5cf3-11eb-2652-19b3fccc556e
md"""
Instead, we look for other means to visualize this dataset.
"""

# ╔═╡ 8bbbe5e2-5cf6-11eb-1c8a-bd7b6c52825d
md"""
# Graphs with LightGraphs.jl - Advanced

This a reference for your assignments. Feel free to skip this until we have covered the material in class.
"""

# ╔═╡ 3ca7a3fa-5ced-11eb-0ac5-d7da2c389767
degrees = degree_centrality(big_graph, normalize=false)

# ╔═╡ 6058e8a2-5cf7-11eb-3867-bd7af5bc7452
histogram(degrees)

# ╔═╡ dffa0664-5cf8-11eb-217d-c78e5f933144
sort(degrees)

# ╔═╡ d373dda4-5cf9-11eb-2980-4be79476cc2c
md"
This is a Pareto Plot ?
"

# ╔═╡ e64ecc02-5cf8-11eb-0d62-f5ce8b9a9375
plot(x -> log(1 - ecdf(degrees)(x)), 1, 250)

# ╔═╡ 25a09c26-5cf8-11eb-21ad-39f902b55c09
gdistances(big_graph)

# ╔═╡ 7211dad8-5cf7-11eb-10a2-156104464e93
is_connected(big_graph)

# ╔═╡ 93220036-5cf7-11eb-3a8a-255048c74ca0
diameter(big_graph)

# ╔═╡ dfd4e7ae-5cf7-11eb-2408-f39b935b1064


# ╔═╡ c5fec2b4-5cf7-11eb-3c38-ab30375084ad
md"
This already takes some time.
"

# ╔═╡ 350c52b0-5cc7-11eb-2655-1541585572d1
md"""
# Appendix
"""

# ╔═╡ d608ebb2-5cc5-11eb-23cf-ff1da24b24ca
TableOfContents()

# ╔═╡ Cell order:
# ╟─f1a2dec2-5cc6-11eb-2308-fb499f4133bc
# ╟─0d3aec92-edeb-11ea-3adb-cd0dc17cbdab
# ╟─3b038ee0-edeb-11ea-0977-97cc30d1c6ff
# ╠═3e8e0ea0-edeb-11ea-22e0-c58f7c2168ce
# ╠═59b66862-edeb-11ea-2d62-71dcc79dbfab
# ╟─5e062a24-edeb-11ea-256a-d938f77d7815
# ╟─7e46f0e8-edeb-11ea-1092-4b5e8acd9ee0
# ╠═8a695b86-edeb-11ea-08cc-17263bec09df
# ╟─8e2dd3be-edeb-11ea-0703-354fb31c12f5
# ╟─96b5a28c-edeb-11ea-11c0-597615962f54
# ╠═a7453572-edeb-11ea-1e27-9f710fd856a6
# ╟─b341db4e-edeb-11ea-078b-b71ac00089d7
# ╠═23f9afd4-eded-11ea-202a-9f0f1f91e5ad
# ╠═cc1f6872-edeb-11ea-33e9-6976fd9b107a
# ╟─ce9667c2-edeb-11ea-2665-d789032abd11
# ╠═d73d3400-edeb-11ea-2dea-95e8c4a6563b
# ╠═e04ccf10-edeb-11ea-36d1-d11969e4b2f2
# ╟─e297c5cc-edeb-11ea-3bdd-090f415685ab
# ╟─ec751446-edeb-11ea-31ba-2372e7c71b42
# ╠═fe3fa290-edeb-11ea-121e-7114e5c573c1
# ╟─394b0ec8-eded-11ea-31fb-27392068ef8f
# ╠═4dc00908-eded-11ea-25c5-0f7b2b7e18f9
# ╟─6c44abb4-edec-11ea-16bd-557800b5f9d2
# ╠═683af3e2-eded-11ea-25a5-0d90bf099d98
# ╠═76764ea2-eded-11ea-1aa6-296f3421de1c
# ╟─93a231f4-edec-11ea-3b39-299b3be2da78
# ╟─82e63a24-eded-11ea-3887-15d6bfabea4b
# ╠═9b339b2a-eded-11ea-10d7-8fc9a907c892
# ╠═9535eb40-eded-11ea-1651-e33c9c23dbfb
# ╟─a16299a2-eded-11ea-2b56-93eb7a1010a7
# ╠═bc6b124e-eded-11ea-0290-b3760cb81024
# ╟─cfb21014-eded-11ea-1261-3bc30952a88e
# ╟─ffee7d80-eded-11ea-26b1-1331df204c67
# ╟─cae4137e-edee-11ea-14af-59a32227de1b
# ╟─714f4fca-edee-11ea-3410-c9ab8825d836
# ╠═82cc2a0e-edee-11ea-11b7-fbaa5ad7b556
# ╠═85916c18-edee-11ea-0738-5f5d78875b86
# ╟─881b7d0c-edee-11ea-0b4a-4bd7d5be2c77
# ╠═a298e8ae-edee-11ea-3613-0dd4bae70c26
# ╠═a5ebddd6-edee-11ea-2234-55453ea59c5a
# ╟─a9b48e54-edee-11ea-1333-a96181de0185
# ╟─68c4ead2-edef-11ea-124a-03c2d7dd6a1b
# ╠═84129294-edef-11ea-0c77-ffa2b9592a26
# ╟─d364fa16-edee-11ea-2050-0f6cb70e1bcf
# ╟─db99ae9a-edee-11ea-393e-9de420a545a1
# ╠═04f175f2-edef-11ea-0882-712548ebb7a3
# ╠═0a8ac112-edef-11ea-1e99-cf7c7808c4f5
# ╟─1295f48a-edef-11ea-22a5-61e8a2e1d005
# ╟─3e1fdaa8-edef-11ea-2f03-eb41b2b9ea0f
# ╠═48f3deca-edef-11ea-2c18-e7419c9030a0
# ╟─a8f26af8-edef-11ea-2fc7-2b776f515aea
# ╠═b595373e-edef-11ea-03e2-6599ef14af20
# ╟─4cb33c04-edef-11ea-2b35-1139c246c331
# ╟─54e47e9e-edef-11ea-2d75-b5f550902528
# ╠═6348edce-edef-11ea-1ab4-019514eb414f
# ╟─da543aa6-5cf6-11eb-3c03-b170e254f1b7
# ╠═eabe56b0-5cf6-11eb-08cd-2156e2ca8163
# ╠═427c55aa-5cf7-11eb-214b-0d7713035e83
# ╠═e9231ac2-5cf9-11eb-3bc2-09f5527e374f
# ╟─58f5f420-5cc6-11eb-2569-198d8fde52ef
# ╠═739ab076-5cc7-11eb-3697-599fcde5954c
# ╟─e09d1054-5cce-11eb-3676-4ded6f7a1bed
# ╠═2a7a4d56-5cca-11eb-2eb9-5ba63fb08f60
# ╠═2e06390c-5cc9-11eb-121b-0b62b08045b7
# ╠═fd349f66-5cc9-11eb-1c34-9bd978ad8f0a
# ╟─ca78ffee-5cca-11eb-16f0-7d31af21eeb8
# ╠═0684a778-5cca-11eb-33ce-9f776f8f822a
# ╠═12529414-5cca-11eb-2b7a-8dabda743c6b
# ╠═2bb95670-5cf6-11eb-150f-c9a46823e1c3
# ╠═3dc235da-5cf6-11eb-3e7f-5f3a0b23c274
# ╟─b705ba38-5ccf-11eb-066b-f740c921de29
# ╠═04462bb6-5cd0-11eb-1f11-93893266fdb8
# ╠═302e3dbc-5cd1-11eb-0df0-f7c2ac8da01b
# ╠═c3830328-5cf3-11eb-1950-79d3a58ef117
# ╟─49683a94-5cd1-11eb-04e1-8587582c0b91
# ╟─2552966c-5cd2-11eb-1502-ff44fcc3ebaf
# ╠═fc5204aa-5cea-11eb-0d51-d783dfa78c11
# ╟─2e2f9f62-5cf2-11eb-0a91-a5a1f83697d0
# ╠═b21e4082-5ceb-11eb-261d-438b4b6b6b38
# ╟─7e8d62ea-5cf3-11eb-2652-19b3fccc556e
# ╟─8bbbe5e2-5cf6-11eb-1c8a-bd7b6c52825d
# ╠═3ca7a3fa-5ced-11eb-0ac5-d7da2c389767
# ╠═6058e8a2-5cf7-11eb-3867-bd7af5bc7452
# ╠═dffa0664-5cf8-11eb-217d-c78e5f933144
# ╠═d373dda4-5cf9-11eb-2980-4be79476cc2c
# ╠═e64ecc02-5cf8-11eb-0d62-f5ce8b9a9375
# ╠═25a09c26-5cf8-11eb-21ad-39f902b55c09
# ╠═7211dad8-5cf7-11eb-10a2-156104464e93
# ╠═93220036-5cf7-11eb-3a8a-255048c74ca0
# ╠═dfd4e7ae-5cf7-11eb-2408-f39b935b1064
# ╟─c5fec2b4-5cf7-11eb-3c38-ab30375084ad
# ╟─350c52b0-5cc7-11eb-2655-1541585572d1
# ╠═ddf87b12-5cc5-11eb-0d4f-f3dd09839034
# ╠═d608ebb2-5cc5-11eb-23cf-ff1da24b24ca
