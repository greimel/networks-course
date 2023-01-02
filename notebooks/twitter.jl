### A Pluto.jl notebook ###
# v0.19.16

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

# ╔═╡ 400cc04e-4784-11eb-11a2-ff8e245cad27
begin
	import Pkg
	Pkg.activate(temp = true)
	Pkg.add([
			Pkg.PackageSpec(name="Chain"),
			Pkg.PackageSpec(name="DataAPI",           version="1"),
			Pkg.PackageSpec(name="DataFrames",        version="1"),
			Pkg.PackageSpec(name="DataFrameMacros",   version="0.4"),
			Pkg.PackageSpec(name="CSV",               version="0.10"),
			Pkg.PackageSpec(name="CategoricalArrays", version="0.10"),
			
			])
	
	Pkg.add(["PlutoUI", "Graphs", "GraphMakie", "CairoMakie", "SimpleWeightedGraphs", "FreqTables", "Colors"])

	using SparseArrays, LinearAlgebra
	
	using PlutoUI: FilePicker, TableOfContents
	using Chain: @chain
	import CSV
	using DataAPI: refarray
	using DataFrames: DataFrames, DataFrame, groupby, leftjoin#, #select, select!, combine, transform, transform!, ByRow
	using DataFrameMacros: @transform!, @subset, @combine, @transform, @select
	using CategoricalArrays: CategoricalArrays, categorical
	using Graphs, SimpleWeightedGraphs
	using GraphMakie, CairoMakie, Colors
	using FreqTables
	
	_a_ = 1 # make sure that this is cell #1
	nothing
end

# ╔═╡ 6535e16c-6146-11eb-35c0-31aef62a631c
begin
	# Make sure Python is available - install if necessary
	ENV["PYTHON"] = ""
	Pkg.add(["PyCall", "Conda"])
	Pkg.build("PyCall")
	
	# Install twint (1)
	import Conda
	Conda.pip_interop(true)
	Conda.pip("install", "twint") # it could be so easy ...
	
	# ... but the above command installs twint 2.1.20 which doesn't work any more
	# So we have to download it from github and install it manually.
	
	# One-liner that doesn't always work on Windows
	# run(`$(Conda._pip(Conda.ROOTENV)) install --user --upgrade -e git+https://github.com/twintproject/twint.git@origin/master#egg=twint`)
	
	# Download twint
	import LibGit2
	twint_path = joinpath(@__DIR__(), "twint") # specify where to save twint
	#isdir(twint_path) && rm(twint_path, recursive = true)
	if !isdir(twint_path)
		repo_url = "https://github.com/greimel/twint"
		# fork of 
		#repo_url = "https://github.com/Museum-Barberini/twint"
		#repo_url = "https://github.com/twintproject/twint"
		repo = LibGit2.clone(repo_url, twint_path, branch = "fix/RefreshTokenException") # download twint from github
	end
	
	# Install twint (2)
	Conda.pip("install", "dataclasses") # manually install a dependency because that doesn't work automatically on windows
	dir = pwd() # save current directory, before leaving it
	cd(twint_path) # move to twint folder
	run(`$(Conda._pip(Conda.ROOTENV)) install .`)
	cd(dir) # move back
	
	# Load twint to Julia
	import PyCall
	twint = PyCall.pyimport("twint")
	
	_b_ = _a_ + 1 # make sure this is cell #2
	nothing
end

# ╔═╡ ba5e6141-9927-41e4-8688-cbbb17b8093c
using PlutoUI

# ╔═╡ 8493134e-6183-11eb-0059-6d6ecf0f17bf
md"
`twitter.jl` | **Version 1.10** | *last changed: Dec 7, 2022*"

# ╔═╡ 39feff38-617d-11eb-0682-874b2f747ff8
md"""
Now, it's your turn. Think of an interesting keyword or hashtag. And insert your keyword below. You will see that the graph above will update as soon as you evaluate the new keyword.
"""

# ╔═╡ 8c5a33dc-6174-11eb-397a-43d67c7773e0
keyword = "#econtwitter"

# ╔═╡ 574747d4-617e-11eb-20e7-5760a3a3f3e9
md"""
#### Task 1: Explain your choice (2 points)

👉 Describe in <150 words why *$(keyword)* is an interesting keyword to search for.
"""

# ╔═╡ cc8bb4e6-617c-11eb-10ed-a316641c78f7
answer1 = md"""
Your answer goes here ...
"""

# ╔═╡ 3ba06884-6481-11eb-20ea-69d7baf86fff
md"""
**NOTE** the word count is done by the function `wordcount` at the very bottom. It may not be completely accurate :-). If you are a few words above the limit, that's ok.
"""

# ╔═╡ b2975790-617f-11eb-3dad-ab030c5213ec
md"""
#### Task 2: Analyze the network (5 points)
👉 Describe the network in terms of the measures that are discussed in lectures 1 and 2. You can look at the notebook **first-networks.jl** and the section *Analyzing the network* for some inspiration.

👉 Interpret all results that you show.

👉 Be accurate but concise. Aim at no more than 500 words.

You can spread your answer over multiple cells. Add code and text cells as it suits you.
"""

# ╔═╡ 82b31aea-6180-11eb-0281-c512bdd2f667
answer2_1 = md"""
Start here ...
"""

# ╔═╡ f947607e-647f-11eb-2758-2f931b208406
# some

# ╔═╡ fc185e8e-647f-11eb-3351-910d651cf077
# analysis

# ╔═╡ f5e4f31a-647f-11eb-11c0-87221d14576e
# analyze

# ╔═╡ 05854c34-6480-11eb-021a-07c21ae697ba
# more

# ╔═╡ 0ee478fe-6480-11eb-3d3d-1bc21388754f
answer2_3 = md"""
... write more ... add more cells if you need. If you want to use the word count above, adjust the cell below.
"""

# ╔═╡ 840f84aa-6180-11eb-03bb-71fa9a6e9d17
md"""
#### Task 3: Looking under the hood (3 points)

Now look at section **Constructing a network** of this notebook. Make sure you understand what data are available to us and how we created the network from the data. 

👉 We want to read your critical thoughts in <250 words. You might tell us about an idea how to generate a different network from the data. Or what twist you would add to our network to make it more interesting. 
"""

# ╔═╡ e96b54dc-6180-11eb-027f-a9db3a83aa99
answer3 = md"""
Your answer goes here ...
"""

# ╔═╡ 3fcf627c-6182-11eb-3a6c-851a6f96bd4a
md"""
#### Before you submit ...

👉 Make sure you have added your names and your group number [in the cells below](#f021cb3e-6177-11eb-20f6-b5f9c69ed186).

👉 Make sure that that **all group members proofread** your submission (especially your little essay).

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. (The source code is embedded in the html file.)
"""

# ╔═╡ 235bcd50-6183-11eb-1272-65c61cfbf961
group_number = 99

# ╔═╡ f021cb3e-6177-11eb-20f6-b5f9c69ed186
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ 849cd5bc-617b-11eb-12eb-a7f0907fc718
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the [randomly generated names in this cell](#f021cb3e-6177-11eb-20f6-b5f9c69ed186) by the names of your group and put the [right group number in the cell above.](#235bcd50-6183-11eb-1272-65c61cfbf961).
	"""
end

# ╔═╡ b201cb56-60e3-11eb-302c-4180510aacf8
md"""
# Getting twitter data with `twint`
"""

# ╔═╡ e4dcc0a6-60e3-11eb-2717-5347187c73c0
md"""
First we specify what data we want to have.
"""

# ╔═╡ bdc32cf2-6611-11eb-080c-6fd828280754
md"""
!!! note "Note"
    If you get an error here, ask your group members to send you their `twtter-data.csv` and upload it here. In this case make sure that you still put the right `keyword` above. 

    If you don't have an error message, you don't need to upload a file!
"""

# ╔═╡ 02509edc-6611-11eb-2451-0fa79effbee7
@bind file_data FilePicker()

# ╔═╡ ea8bc558-620d-11eb-24e8-57cd8d41e912
md"""
!!! note "Note"
    If you want to change the parameters of your query you can specify some optional keyword arguments in the cell above. E.g. `tweet_df0 = twitter_data(keyword, language = "dutch")` or `tweet_df0 = twitter_data(keyword, n_tweets = 1000)`.
"""

# ╔═╡ c76895aa-620e-11eb-3da2-b572953e6d34
md"""
If you are curious how the data are downloaded, look at the following function. You shouldn't change these two functions below unless you are absolutely sure what you are doing. The underlying Python package `twint` is very fragile and might hang forever if you don't specify the inputs correctly.
"""

# ╔═╡ 85838053-8aa3-4e56-ae9d-17293937fe4f
"Download tweets that contain `keyword` and save to csv file `filename`"
function download_twitter_data(keyword::String;
							   filename = joinpath(".", "twitter-data.csv"),
							   n_tweets::Int = 500,
							   language = missing,
							   min_likes = 2
							   )
	# Configure twint query object
	c = twint.Config()
	c.Search = keyword
	if !ismissing(language)
		@assert language isa String
		c.Lang = language
	end
	#c.Geo = "52.377956,4.897070,5km"
	c.Limit = n_tweets
	c.Output = filename
	c.Store_csv = true
	c.Min_likes = min_likes
	
	# if file exists, overwrite it
	isfile(filename) && rm(filename)
	try
		twint.run.Search(c)
	catch e
		if isfile(filename)
			DataFrame(CSV.File(filename))
		else
			rethrow(e)
		end
	end
	
	filename
end

# ╔═╡ 32d55286-620c-11eb-2910-fd3e5b3fd78a
"Download twitter data to csv and load data into a DataFrame"
function twitter_data(file_data, args...; kwargs...)
	# check if file was uploaded using the file picker
	file_uploaded = !isnothing(file_data) 
	
	if file_uploaded
		csv = CSV.File(file_data["data"])
	else
		filename = download_twitter_data(args...; kwargs...)
		csv = CSV.File(filename)
	end
	DataFrame(csv)
end

# ╔═╡ 14e6dece-60dc-11eb-2d5a-275b8c9e382d
tweet_df0 = twitter_data(file_data, keyword)

# ╔═╡ f998e4fc-60e3-11eb-0533-1717bea29668
md"""
# Constructing a network
"""

# ╔═╡ 46021976-60e4-11eb-3797-33b6ff7755d4
md"""
There is more than one way to define a network using this data. One way is to define twitter users to be connected if they use common hashtags in their tweets. Let's ceate such a network.
"""

# ╔═╡ 87f77baa-60e4-11eb-24e2-019e317451f6
md"First select some interesting variables."

# ╔═╡ 97337aec-60e4-11eb-0b15-99ffcf8376fa
md"Then aggregate the list of hashtags for each user."

# ╔═╡ edc6da66-60e4-11eb-1aeb-fb9dbb7ccc88
md"Create a list of edges."

# ╔═╡ 0b70f90c-60e5-11eb-18da-25e3302a74a8
md"""
# Analyzing the network
"""

# ╔═╡ 01e4ac58-60e5-11eb-39f3-b5f613ecee35
md"Create the graph."

# ╔═╡ 4df1e8ae-60ef-11eb-3772-1154f708eecb
md"""
## Highlighting some nodes
"""

# ╔═╡ eea5accc-60db-11eb-3889-c992db2ec8ec
md"""
# Appendix
"""

# ╔═╡ d07dc2ac-67b1-11eb-1bee-c52695fb4f28
md"""
## Package environment
"""

# ╔═╡ a1d99d9e-60dc-11eb-391c-b52c2e16aedd
md"""
## Install Python and the package `twint`
"""

# ╔═╡ 1f927f3c-60e5-11eb-0304-f1639b68468d
md"""
## Useful functions
"""

# ╔═╡ 620c76e4-60de-11eb-2c82-d364f55fbe4d
function parse_hashtags(hashtags)
	# start from "['r', 'julialang', 'programming']"
	str = replace(hashtags, "'" => '"')
	# get """["r", "julialang", "programming"]"""::String
	vec_of_strings = eval(Meta.parse(str))
	# get ["r", "julialang", "programming"]::Vector{String}
	
	vec_of_strings
end

# ╔═╡ 5401181c-60dd-11eb-0844-9b4b7b35693c
tweet_df = @select(tweet_df0, 
	 # "parse_hashtags" is defined in the appendix
	:hashtags = parse_hashtags(:hashtags),
    :user_id,
	:username = @bycol(categorical(:username)),
	:language = @bycol(categorical(:language))
)

# ╔═╡ 9d5c72ca-60df-11eb-262d-6f0803d386f5
user_df = @chain tweet_df begin
	groupby(:username) # group the data by user. Each group consists of all tweets of one user
	@combine(:hashtags = [∪(:hashtags...)]) # for each group, take the union (∪) of hashtags
end

# ╔═╡ 241b8206-60e0-11eb-08bd-f748c90e49c7
begin
	edge_list = DataFrame(user1 = String[], user2 = String[], common_hashtags = Int[])

	for (i, (user₁, hashtags₁)) in enumerate(eachrow(user_df))
		for (user₂, hashtags₂) in eachrow(user_df[i+1:end,:])
			
			common = hashtags₁ ∩ hashtags₂

			if length(common) > 1
				push!(edge_list, [user₁, user₂, length(common)])
			end
		end
	end

	node_names = edge_list.user1 ∪ edge_list.user2 

	@transform!(edge_list, :user1 = @bycol categorical(:user1; levels = node_names))
	@transform!(edge_list, :user2 = @bycol categorical(:user2; levels = node_names))
	
	edge_list
end

# ╔═╡ 15ecf0aa-60e2-11eb-1ef4-ebfc215e5ca7
graph = @chain edge_list begin
	sparse(refarray(_.user1), refarray(_.user2), _.common_hashtags, length(node_names), length(node_names))
	Symmetric
	SimpleWeightedGraph
end

# ╔═╡ 41f4f6cc-6173-11eb-104f-69c755afd266
graphplot(graph, node_color="orange")

# ╔═╡ dc41336a-647f-11eb-3ca3-cb3ab8a6a024
# some dummy analysis
begin
	n_edges = ne(graph)
	n_nodes = nv(graph)
end

# ╔═╡ dfc92f56-647f-11eb-3038-15e225cb4d22
answer2_2 = md"""
... Continue here ... The twitter network with $keyword has $n_nodes nodes and $n_edges edges. ...
"""

# ╔═╡ 5ceea932-60ef-11eb-3c13-37ddf8e09f6f
begin
	all_hashtags = vcat(tweet_df.hashtags...)
	freqs = freqtable(all_hashtags)
	
	df_hashtags = DataFrame(hashtag = names(freqs)[1], freqs = freqs)
	sort!(df_hashtags, :freqs, rev = true)
end

# ╔═╡ c103db75-a5bd-4836-9137-f42bce1bf86d
highlighted_hashtag = df_hashtags.hashtag[5]

# ╔═╡ 76c50e74-60f3-11eb-1e25-cdcaeae76c38
node_df = @chain user_df begin
	@subset(:username ∈ node_names)
	@transform!(:highlighted_nodes = highlighted_hashtag ∈ :hashtags)
	@transform!(:node_color = :highlighted_nodes == true ? colorant"red" : colorant"blue")
end

# ╔═╡ eb9773ea-c66f-4079-b625-9e483413171a
node_df

# ╔═╡ 94e542c2-a3f0-453f-a40c-545a412510b9
graphplot(graph; node_color=node_df.node_color)

# ╔═╡ 91ccdec2-60f3-11eb-2d0e-a59ba5392e65
sum(node_df.highlighted_nodes)

# ╔═╡ e18dc43b-156c-456b-9261-18cc1abee5cc
md"""
## Assignment infrastructure
"""

# ╔═╡ 57008096-21b5-4971-a58a-6f54e090e9b8
members = let
	names = map(group_members) do (; firstname, lastname)
		firstname * " " * lastname
	end
	join(names, ", ", " & ")
end

# ╔═╡ da51e362-6176-11eb-15b2-b7bcebc2cbb6
md"""
# Assignment 1: A Twitter Network

*submitted by* **$members** (*group $(group_number)*)

In this assignment you will download a set of *tweets* from social network *Twitter* that share a common keyword. For a start let's use the keyword **$(keyword)**. 

This network consists of twitter users that have used the keyword *$(keyword)* in on of their recent tweets. Two nodes (users) are connected if they have used another hashtag in common. See the plot below.
"""

# ╔═╡ db650af6-4214-490b-a7a1-eb06a7de4116
function wordcount(text)
	stripped_text = strip(replace(string(text), r"\s" => " "))
   	words = split(stripped_text, (' ', '-', '.', ',', ':', '_', '"', ';', '!', '\''))
   	length(filter(!=(""), words))
end

# ╔═╡ 9b3dc668-1fd1-46f2-b93c-7efc7c4787f0
show_words(answer) = md"_approximately $(wordcount(answer)) words_"

# ╔═╡ 6a100e4d-31b9-4eb3-a7ae-bae844a247ff
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
end

# ╔═╡ 09d66db0-617c-11eb-1b92-b3ed2e5f68f6
if keyword == "#econtwitter"
	keep_working(md""" *#econtwitter* is a bit boring. Replace it with a keyword of your choice.""")
else
	correct(md"Go and analyse the tweets on *$(keyword)*!")
end

# ╔═╡ a36f6492-617f-11eb-2bb8-1ded14d9f438
if answer1 == md"Your answer goes here ..."
	keep_working(md"Place your cursor in the code cell and replace the dummy text, and evaluate the cell.")
else
	correct(md"Great, we are looking forward to reading your answer!")
end

# ╔═╡ f1c8a53a-6180-11eb-2e05-179bfab97223
if answer3 == md"Your answer goes here ..."
	keep_working(md"Place your cursor in the code cell and replace the dummy text, and evaluate the cell.")
else
	correct(md"Great, we are looking forward to reading your answer!")
end

# ╔═╡ effe32c3-47e8-4389-9de3-250d251d4828
function show_words_limit(answer, limit)
	count = wordcount(answer)
	if count < 1.02 * limit
		return show_words(answer)
	else
		return almost(md"You are at $count words. Please shorten your text a bit, to get **below $limit words**.")
	end
end

# ╔═╡ d7046f24-617e-11eb-0571-ebcacb3a39e9
show_words_limit(answer1, 150)

# ╔═╡ 163ef7aa-6480-11eb-2ead-e9fb9a35f490
show_words_limit(join([answer2_1, answer2_2, answer2_3], " "), 500)

# ╔═╡ 0cbb406e-6181-11eb-015d-d582e3a9b175
show_words_limit(answer3, 250)

# ╔═╡ af4b0571-e522-4d00-963b-5f1f13adc619
TableOfContents()

# ╔═╡ bef961a8-caa3-4360-8b35-d945b7e030d9
md"""
## Acknowledgement
"""

# ╔═╡ 052ab5c3-51a9-43ca-9d95-37f41e283a31
Markdown.MD(
	Markdown.Admonition("warning", "The design of this notebook is based on", 
[md"""
		
_**Computational Thinking**, a live online Julia/Pluto textbook._ [(computationalthinking.mit.edu)](https://computationalthinking.mit.edu)
"""]
	))

# ╔═╡ Cell order:
# ╟─849cd5bc-617b-11eb-12eb-a7f0907fc718
# ╟─8493134e-6183-11eb-0059-6d6ecf0f17bf
# ╟─da51e362-6176-11eb-15b2-b7bcebc2cbb6
# ╠═41f4f6cc-6173-11eb-104f-69c755afd266
# ╟─39feff38-617d-11eb-0682-874b2f747ff8
# ╠═8c5a33dc-6174-11eb-397a-43d67c7773e0
# ╟─09d66db0-617c-11eb-1b92-b3ed2e5f68f6
# ╟─574747d4-617e-11eb-20e7-5760a3a3f3e9
# ╠═cc8bb4e6-617c-11eb-10ed-a316641c78f7
# ╟─d7046f24-617e-11eb-0571-ebcacb3a39e9
# ╟─3ba06884-6481-11eb-20ea-69d7baf86fff
# ╟─a36f6492-617f-11eb-2bb8-1ded14d9f438
# ╟─b2975790-617f-11eb-3dad-ab030c5213ec
# ╠═82b31aea-6180-11eb-0281-c512bdd2f667
# ╠═dc41336a-647f-11eb-3ca3-cb3ab8a6a024
# ╠═f947607e-647f-11eb-2758-2f931b208406
# ╠═fc185e8e-647f-11eb-3351-910d651cf077
# ╠═dfc92f56-647f-11eb-3038-15e225cb4d22
# ╠═f5e4f31a-647f-11eb-11c0-87221d14576e
# ╠═05854c34-6480-11eb-021a-07c21ae697ba
# ╠═0ee478fe-6480-11eb-3d3d-1bc21388754f
# ╠═163ef7aa-6480-11eb-2ead-e9fb9a35f490
# ╟─840f84aa-6180-11eb-03bb-71fa9a6e9d17
# ╠═e96b54dc-6180-11eb-027f-a9db3a83aa99
# ╟─0cbb406e-6181-11eb-015d-d582e3a9b175
# ╟─f1c8a53a-6180-11eb-2e05-179bfab97223
# ╟─3fcf627c-6182-11eb-3a6c-851a6f96bd4a
# ╠═235bcd50-6183-11eb-1272-65c61cfbf961
# ╠═f021cb3e-6177-11eb-20f6-b5f9c69ed186
# ╟─b201cb56-60e3-11eb-302c-4180510aacf8
# ╟─e4dcc0a6-60e3-11eb-2717-5347187c73c0
# ╟─14e6dece-60dc-11eb-2d5a-275b8c9e382d
# ╟─bdc32cf2-6611-11eb-080c-6fd828280754
# ╠═02509edc-6611-11eb-2451-0fa79effbee7
# ╟─ea8bc558-620d-11eb-24e8-57cd8d41e912
# ╟─c76895aa-620e-11eb-3da2-b572953e6d34
# ╠═85838053-8aa3-4e56-ae9d-17293937fe4f
# ╠═32d55286-620c-11eb-2910-fd3e5b3fd78a
# ╟─f998e4fc-60e3-11eb-0533-1717bea29668
# ╟─46021976-60e4-11eb-3797-33b6ff7755d4
# ╟─87f77baa-60e4-11eb-24e2-019e317451f6
# ╠═5401181c-60dd-11eb-0844-9b4b7b35693c
# ╟─97337aec-60e4-11eb-0b15-99ffcf8376fa
# ╠═9d5c72ca-60df-11eb-262d-6f0803d386f5
# ╟─edc6da66-60e4-11eb-1aeb-fb9dbb7ccc88
# ╠═241b8206-60e0-11eb-08bd-f748c90e49c7
# ╟─0b70f90c-60e5-11eb-18da-25e3302a74a8
# ╟─01e4ac58-60e5-11eb-39f3-b5f613ecee35
# ╠═15ecf0aa-60e2-11eb-1ef4-ebfc215e5ca7
# ╟─4df1e8ae-60ef-11eb-3772-1154f708eecb
# ╠═5ceea932-60ef-11eb-3c13-37ddf8e09f6f
# ╠═c103db75-a5bd-4836-9137-f42bce1bf86d
# ╠═76c50e74-60f3-11eb-1e25-cdcaeae76c38
# ╠═eb9773ea-c66f-4079-b625-9e483413171a
# ╠═94e542c2-a3f0-453f-a40c-545a412510b9
# ╠═91ccdec2-60f3-11eb-2d0e-a59ba5392e65
# ╟─eea5accc-60db-11eb-3889-c992db2ec8ec
# ╟─d07dc2ac-67b1-11eb-1bee-c52695fb4f28
# ╠═400cc04e-4784-11eb-11a2-ff8e245cad27
# ╟─a1d99d9e-60dc-11eb-391c-b52c2e16aedd
# ╠═6535e16c-6146-11eb-35c0-31aef62a631c
# ╟─1f927f3c-60e5-11eb-0304-f1639b68468d
# ╠═620c76e4-60de-11eb-2c82-d364f55fbe4d
# ╟─e18dc43b-156c-456b-9261-18cc1abee5cc
# ╠═57008096-21b5-4971-a58a-6f54e090e9b8
# ╠═db650af6-4214-490b-a7a1-eb06a7de4116
# ╠═9b3dc668-1fd1-46f2-b93c-7efc7c4787f0
# ╠═effe32c3-47e8-4389-9de3-250d251d4828
# ╠═6a100e4d-31b9-4eb3-a7ae-bae844a247ff
# ╠═ba5e6141-9927-41e4-8688-cbbb17b8093c
# ╠═af4b0571-e522-4d00-963b-5f1f13adc619
# ╟─bef961a8-caa3-4360-8b35-d945b7e030d9
# ╟─052ab5c3-51a9-43ca-9d95-37f41e283a31
