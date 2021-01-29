### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 400cc04e-4784-11eb-11a2-ff8e245cad27
begin
	import Pkg
	Pkg.activate(temp = true)
	Pkg.add(["PlutoUI", "CSV", "LightGraphs", "DataFrames", "GraphPlot", "CategoricalArrays", "GraphDataFrameBridge", "FreqTables", "Colors"])
	
	using PlutoUI: TableOfContents, with_terminal
	import CSV
	using DataFrames: DataFrames, DataFrame, groupby, select, select!, combine, transform, transform!, ByRow, leftjoin
	using CategoricalArrays: CategoricalArrays, categorical
	using LightGraphs
	using GraphPlot, Colors
	using GraphDataFrameBridge
	using FreqTables

	_a_ = 1 # make sure that this is cell #1
	nothing
end

# ╔═╡ 8493134e-6183-11eb-0059-6d6ecf0f17bf
md"""
!!! danger "Preliminary version"
	Nice that you've found this notebook on github. We appreciate your engagement. Feel free to have a look. Please note that the assignment notebook is subject to change until it is uploaded to *Canvas*.
"""

# ╔═╡ 235bcd50-6183-11eb-1272-65c61cfbf961
group_number = 99

# ╔═╡ f021cb3e-6177-11eb-20f6-b5f9c69ed186
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Maeve", 		lastname = "Reed"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ 849cd5bc-617b-11eb-12eb-a7f0907fc718
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the randomly generated names above by the names of your group and put the right group number in the top cell.
	"""
end

# ╔═╡ 39feff38-617d-11eb-0682-874b2f747ff8
md"""
Now, it's your turn. Think of an interesting keyword or hashtag. And insert your keyword below. You will see that the graph above will update as soon as you evaluate the new keyword.
"""

# ╔═╡ 8c5a33dc-6174-11eb-397a-43d67c7773e0
keyword = "#econtwitter"

# ╔═╡ 574747d4-617e-11eb-20e7-5760a3a3f3e9
md"""
#### Task 1: Explain your choice

👉 Describe in <150 words why *$(keyword)* is an interesting keyword to search for.
"""

# ╔═╡ cc8bb4e6-617c-11eb-10ed-a316641c78f7
answer1 = md"""
Your answer goes here ...
"""

# ╔═╡ b2975790-617f-11eb-3dad-ab030c5213ec
md"""
#### Task 2: Analyze the network
👉 

You can look at the section *Analyzing the network* for some inspiration.

"""

# ╔═╡ 82b31aea-6180-11eb-0281-c512bdd2f667


# ╔═╡ 840f84aa-6180-11eb-03bb-71fa9a6e9d17
md"""
#### Task 3: Look under the hood

Now look at sections **A first glance at the data** and **Making a network** of this notebook. Make sure you understand what data are available to us and how we created the network from the data. 

👉 We want to read your critical thoughts in <150 words. You might tell us about an idea how to generate a different network from the data. Or what twist you would add to our network to make it more interesting. 
"""

# ╔═╡ e96b54dc-6180-11eb-027f-a9db3a83aa99
answer3 = md"""
Your answer goes here ...
"""

# ╔═╡ 3fcf627c-6182-11eb-3a6c-851a6f96bd4a
md"""
#### Before you submit ...

👉 Make sure you have added your names and your group nummber at the top.

👉 Make sure that that **all group members proofread** your submission (especially your little essays).

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. In addition, **upload the source code** of the notebook (the .jl file).
"""

# ╔═╡ b201cb56-60e3-11eb-302c-4180510aacf8
md"""
# Getting twitter data with `twint`
"""

# ╔═╡ e4dcc0a6-60e3-11eb-2717-5347187c73c0
md"""
First we specify what data we want to have.
"""

# ╔═╡ ea8bc558-620d-11eb-24e8-57cd8d41e912
md"""
!!! note "Note"
	If you want to change the parameters of your query you can specify some optional keyword arguments in the cell above. E.g. `tweet_df0 = twitter_data(keyword, language = "dutch")` or `tweet_df0 = twitter_data(keyword, n_tweets = 1000)`.
"""

# ╔═╡ c76895aa-620e-11eb-3da2-b572953e6d34
md"""
If you are curious how the data are downloaded, look at the following function. You shouldn't change these two functions below unless you are absolutely sure what you are doing. The underlying Python package `twint` is very fragile and might hang forever if you don't specify the inputs correctly.
"""

# ╔═╡ f998e4fc-60e3-11eb-0533-1717bea29668
md"""
# Making a network
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

# ╔═╡ 01e4ac58-60e5-11eb-39f3-b5f613ecee35
md"Create the graph."

# ╔═╡ 0b70f90c-60e5-11eb-18da-25e3302a74a8
md"""
# Analyzing the network
"""

# ╔═╡ 4df1e8ae-60ef-11eb-3772-1154f708eecb
md"""
## Highlighting some nodes
"""

# ╔═╡ eea5accc-60db-11eb-3889-c992db2ec8ec
md"""
# Appendix
"""

# ╔═╡ 87b7bc86-60df-11eb-3f9f-2375449c77f6
begin
	Base.show(io::IO, ::MIME"text/html", x::CategoricalArrays.CategoricalValue) = print(io, get(x))
end

# ╔═╡ a1d99d9e-60dc-11eb-391c-b52c2e16aedd
md"""
## Install Python and the package `twint`
"""

# ╔═╡ 6535e16c-6146-11eb-35c0-31aef62a631c
begin
	# Make sure Python is available - install if necessary
	ENV["PYTHON"] = ""
	Pkg.add(["PyCall", "Conda"])
	Pkg.build("PyCall")
	
	import Conda
	run(`$(Conda._pip(Conda.ROOTENV)) install --user --upgrade -e "git+https://github.com/twintproject/twint.git@origin/master#egg=twint"`)
	
	import PyCall
	
	twint = PyCall.pyimport("twint")
	
	_b_ = _a_ + 1 # make sure this is cell #2
	nothing
end

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
	twint.run.Search(c)
	
	filename
end

# ╔═╡ 32d55286-620c-11eb-2910-fd3e5b3fd78a
"Download twitter data to csv and load data into a DataFrame"
function twitter_data(args...; kwargs...)
	filename = download_twitter_data(args...; kwargs...)
	
	csv = CSV.File(filename)
	
	DataFrame(csv)
end

# ╔═╡ 14e6dece-60dc-11eb-2d5a-275b8c9e382d
tweet_df0 = twitter_data(keyword)

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
tweet_df = select(tweet_df0, :hashtags => ByRow(parse_hashtags),
				 # "parse_hashtags" is defined in the appendix
	   		     :user_id,
				 :username => categorical,
				 :language => categorical,
			renamecols = false)

# ╔═╡ 9d5c72ca-60df-11eb-262d-6f0803d386f5
user_df = combine(
		groupby(tweet_df, :username), # group the data by user. Each group consists of all tweets of one user
		:hashtags => ∪ # for each group, take the union (∪) of hashtags
		)

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
	
	edge_list
end

# ╔═╡ 15ecf0aa-60e2-11eb-1ef4-ebfc215e5ca7
graph = MetaGraph(edge_list, :user1, :user2, weight = :common_hashtags)

# ╔═╡ 41f4f6cc-6173-11eb-104f-69c755afd266
gplot(graph)

# ╔═╡ 76c50e74-60f3-11eb-1e25-cdcaeae76c38
begin
	node_df = DataFrame(
		username = GraphDataFrameBridge.MetaGraphs.get_prop.(Ref(graph), vertices(graph), :name)
		)
	
	node_df = leftjoin(node_df, user_df, on = :username)
	
	transform!(node_df, :hashtags_union => ByRow(x -> "covid19" in x) => :highlighted_nodes)
	
	transform!(node_df, :highlighted_nodes => ByRow(x -> x ? colorant"red" : colorant"blue") => :node_color)
	
	node_df
end

# ╔═╡ 5dacc3c2-60e2-11eb-1352-0ddbe3405aec
gplot(graph, nodesize=0.1, NODESIZE=0.025, nodefillc = node_df.node_color)

# ╔═╡ 91ccdec2-60f3-11eb-2d0e-a59ba5392e65
sum(node_df.highlighted_nodes)

# ╔═╡ 5ceea932-60ef-11eb-3c13-37ddf8e09f6f
let
	all_hashtags = vcat(tweet_df.hashtags...)
	freqs = freqtable(all_hashtags)
	
	df_hashtags = DataFrame(hashtag = names(freqs)[1], freqs = freqs)
	sort!(df_hashtags, :freqs, rev = true)
end

# ╔═╡ eeb99bfe-6178-11eb-04f7-bf04d3c10eeb
members = let
	str = ""
	for (first, last) in group_members
		str *= str == "" ? "" : ", "
		str *= first * " " * last
	end
	str
end

# ╔═╡ da51e362-6176-11eb-15b2-b7bcebc2cbb6
md"""
# Assignment 1: A Twitter Network

*submitted by* **$members** (*group $(group_number)*)

In this assignment you will download a set of *tweets* from social network *Twitter* that share a common keyword. For a start let's use the keyword **$(keyword)**. 

This network consists of twitter users that have used the keyword *$(keyword)* in on of their recent tweets. Two nodes (users) are connected if they have used another hashtag in common. See the plot below.
"""

# ╔═╡ 40b2c2c6-617b-11eb-3a05-bdab1ba79ad4
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 496b1990-617b-11eb-17ba-9725950334f2
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ 50d3b41c-617b-11eb-3555-1126c30932d5
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 59833e0c-617b-11eb-36f8-3371b7483ba6
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ 5f434c54-617b-11eb-0dc3-650499285995
yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]

# ╔═╡ 873ad282-617c-11eb-2b60-6782461922fe
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ 09d66db0-617c-11eb-1b92-b3ed2e5f68f6
if keyword == "#econtwitter"
	keep_working(md""" *#econtwitter* is a bit boring. Replace it with a keyword of your choice.""")
else
	correct(md"Go and analyse the tweets on *$(keyword)*!")
end

# ╔═╡ c97c33c8-617e-11eb-31a8-e3fec23ace37
function wordcount(text)
    words=split(string(text), (' ','\n','\t','-','.',',',':','_','"',';','!'))
    length(words)
end

# ╔═╡ d7046f24-617e-11eb-0571-ebcacb3a39e9
md" ~ $(wordcount(answer1)) words"

# ╔═╡ a36f6492-617f-11eb-2bb8-1ded14d9f438
if answer1 == md"Your answer goes here ..."
	keep_working(md"Place your cursor in the code cell and replace the dummy text, and evaluate the cell.")
elseif wordcount(answer1) > 150
	almost(md"Try to shorten your text a bit, to get below 150 words.")
else
	correct(md"Great, we are looking forward to reading your answer!")
end

# ╔═╡ 0cbb406e-6181-11eb-015d-d582e3a9b175
md" ~ $(wordcount(answer3)) words"

# ╔═╡ f1c8a53a-6180-11eb-2e05-179bfab97223
if answer3 == md"Your answer goes here ..."
	keep_working(md"Place your cursor in the code cell and replace the dummy text, and evaluate the cell.")
elseif wordcount(answer3) > 150
	almost(md"Try to shorten your text a bit, to get below 150 words.")
else
	correct(md"Great, we are looking forward to reading your answer!")
end

# ╔═╡ e5a741e8-60dc-11eb-317e-cfdd650ae5f0
TableOfContents()

# ╔═╡ Cell order:
# ╟─8493134e-6183-11eb-0059-6d6ecf0f17bf
# ╠═235bcd50-6183-11eb-1272-65c61cfbf961
# ╠═f021cb3e-6177-11eb-20f6-b5f9c69ed186
# ╟─849cd5bc-617b-11eb-12eb-a7f0907fc718
# ╟─da51e362-6176-11eb-15b2-b7bcebc2cbb6
# ╠═41f4f6cc-6173-11eb-104f-69c755afd266
# ╟─39feff38-617d-11eb-0682-874b2f747ff8
# ╠═8c5a33dc-6174-11eb-397a-43d67c7773e0
# ╟─09d66db0-617c-11eb-1b92-b3ed2e5f68f6
# ╟─574747d4-617e-11eb-20e7-5760a3a3f3e9
# ╠═cc8bb4e6-617c-11eb-10ed-a316641c78f7
# ╟─d7046f24-617e-11eb-0571-ebcacb3a39e9
# ╟─a36f6492-617f-11eb-2bb8-1ded14d9f438
# ╟─b2975790-617f-11eb-3dad-ab030c5213ec
# ╠═82b31aea-6180-11eb-0281-c512bdd2f667
# ╟─840f84aa-6180-11eb-03bb-71fa9a6e9d17
# ╠═e96b54dc-6180-11eb-027f-a9db3a83aa99
# ╟─0cbb406e-6181-11eb-015d-d582e3a9b175
# ╟─f1c8a53a-6180-11eb-2e05-179bfab97223
# ╟─3fcf627c-6182-11eb-3a6c-851a6f96bd4a
# ╟─b201cb56-60e3-11eb-302c-4180510aacf8
# ╟─e4dcc0a6-60e3-11eb-2717-5347187c73c0
# ╠═14e6dece-60dc-11eb-2d5a-275b8c9e382d
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
# ╟─01e4ac58-60e5-11eb-39f3-b5f613ecee35
# ╟─0b70f90c-60e5-11eb-18da-25e3302a74a8
# ╠═15ecf0aa-60e2-11eb-1ef4-ebfc215e5ca7
# ╠═5dacc3c2-60e2-11eb-1352-0ddbe3405aec
# ╟─4df1e8ae-60ef-11eb-3772-1154f708eecb
# ╠═5ceea932-60ef-11eb-3c13-37ddf8e09f6f
# ╠═76c50e74-60f3-11eb-1e25-cdcaeae76c38
# ╠═91ccdec2-60f3-11eb-2d0e-a59ba5392e65
# ╟─eea5accc-60db-11eb-3889-c992db2ec8ec
# ╠═400cc04e-4784-11eb-11a2-ff8e245cad27
# ╠═87b7bc86-60df-11eb-3f9f-2375449c77f6
# ╟─a1d99d9e-60dc-11eb-391c-b52c2e16aedd
# ╠═6535e16c-6146-11eb-35c0-31aef62a631c
# ╟─1f927f3c-60e5-11eb-0304-f1639b68468d
# ╠═620c76e4-60de-11eb-2c82-d364f55fbe4d
# ╠═eeb99bfe-6178-11eb-04f7-bf04d3c10eeb
# ╠═40b2c2c6-617b-11eb-3a05-bdab1ba79ad4
# ╠═496b1990-617b-11eb-17ba-9725950334f2
# ╠═50d3b41c-617b-11eb-3555-1126c30932d5
# ╠═59833e0c-617b-11eb-36f8-3371b7483ba6
# ╠═5f434c54-617b-11eb-0dc3-650499285995
# ╠═873ad282-617c-11eb-2b60-6782461922fe
# ╠═c97c33c8-617e-11eb-31a8-e3fec23ace37
# ╠═e5a741e8-60dc-11eb-317e-cfdd650ae5f0
