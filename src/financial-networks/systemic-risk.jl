### A Pluto.jl notebook ###
# v0.20.0

#> [frontmatter]
#> chapter = 5
#> section = 2
#> order = 1
#> title = "Systemic risk in financial networks"
#> layout = "layout.jlhtml"
#> tags = ["financial-networks"]
#> description = ""

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

# ╔═╡ 8ada8545-243e-4922-a306-ffff866a6135
using SparseArrays

# ╔═╡ 5f8c9ead-7598-452f-84b0-9189866aa200
using Makie: LinePattern, Pattern

# ╔═╡ 74262581-3c64-4e5b-9328-416c4e1efc91
using MarkdownLiteral: @markdown, @mdx

# ╔═╡ 103babf9-bbc3-4c77-9185-72f792a09706
using LinearAlgebra: dot

# ╔═╡ bb0e41cf-66fb-4cae-8cd9-6ad771d1acf4
using HypertextLiteral

# ╔═╡ 935da683-a4e2-4ddc-999f-55cb61390f39
using StructArrays

# ╔═╡ 2d1da571-0561-4c28-bb63-35ca5f9538d5
using PlutoUI: PlutoUI, TableOfContents, details,
	Slider, CheckBox, Select, NumberField

# ╔═╡ 7c068d65-f472-44c2-af56-581bf9309bd5
using StatsBase: weights

# ╔═╡ 631ce85b-db76-4f3b-bda5-0c51ffb3bc43
using CategoricalArrays

# ╔═╡ fa01788e-7585-4f3f-93b2-a44541065820
using DataAPI: refarray

# ╔═╡ 6a89953d-310b-49c9-89e1-8d51c8b75be0
using Graphs, SimpleWeightedGraphs

# ╔═╡ 50ac0182-32fe-4e21-8c6d-895ffc67ec27
using NetworkLayout

# ╔═╡ 8b75bc15-e07b-43e5-adb3-c5d6481ee9d8
using LinearAlgebra: I

# ╔═╡ 954d2dde-8088-4e91-bed3-f8339090b77b
using PlutoTeachingTools

# ╔═╡ 2872c686-8e4f-4230-a07a-5d988aba39b7
using Chain: @chain

# ╔═╡ 3198bb79-f0c7-4b01-8dce-ef7629e8d7e6
using GeometryBasics: Rect, Vec2f0

# ╔═╡ e9365f8d-6f58-458c-855d-c0444c6f409f
using DataFrames, DataFrameMacros

# ╔═╡ 955c190a-1d00-4c78-bdfb-daac31edf76f
using Roots: find_zero

# ╔═╡ fc01674e-73de-4cbf-9c80-fa1ea47fcb21
using Colors: @colorant_str

# ╔═╡ 00a4054a-dd10-4c5c-ae20-c0dc176e8e18
using Statistics: mean

# ╔═╡ 7d2d3618-7810-444d-90c0-0d592f8eba8c
using GraphMakie

# ╔═╡ 12968f5e-6e75-4429-bff8-0d1c644330a7
using NamedTupleTools

# ╔═╡ 8f15ccf5-860a-47ca-b5c2-842c4e6f861a
using CairoMakie: @key_str, @lift, @L_str

# ╔═╡ 3758f272-297c-4325-9a7c-042b4f41d615
using CairoMakie, AlgebraOfGraphics, Colors

# ╔═╡ a349099a-64aa-4e86-9bf2-b6157feff394
using LaTeXStrings

# ╔═╡ c4032c7a-73f4-4342-a5a7-19fd14017402
begin
fonts = (; regular = CairoMakie.Makie.MathTeXEngine.texfont(), bold = CairoMakie.Makie.MathTeXEngine.texfont())
set_theme!(; fonts)

using Makie
	
#using Makie.LaTeXStrings
	
using Makie: automatic, compute_x_and_width, barplot_labels, bar_rectangle, generate_tex_elements, TeXChar, FreeTypeAbstraction, GlyphExtent, height_insensitive_boundingbox_with_advance, origin, GlyphCollection, stack_grouped_from_to, ATTRIBUTES, theme, bar_label_formatter, bar_default_fillto
	
function Makie.plot!(p::BarPlot)

    labels = Observable(Tuple{Union{String,LaTeXStrings.LaTeXString}, Point2f}[])
    label_aligns = Observable(Vec2f[])
    label_offsets = Observable(Vec2f[])
    label_colors = Observable(RGBAf[])
	
    function calculate_bars(xy, fillto, offset, transformation, width, dodge, n_dodge, gap, dodge_gap, stack,
                            dir, bar_labels, flip_labels_at, label_color, color_over_background,
                            color_over_bar, label_formatter, label_offset, label_rotation, label_align)

        in_y_direction = get((y=true, x=false), dir) do
            error("Invalid direction $dir. Options are :x and :y.")
        end

        x = first.(xy)
        y = last.(xy)

        # by default, `width` is `minimum(diff(sort(unique(x)))`
        if width === automatic
            x_unique = unique(filter(isfinite, x))
            x_diffs = diff(sort(x_unique))
            width = isempty(x_diffs) ? 1.0 : minimum(x_diffs)
        end

        # compute width of bars and x̂ (horizontal position after dodging)
        x̂, barwidth = compute_x_and_width(x, width, gap, dodge, n_dodge, dodge_gap)

        # --------------------------------
        # ----------- Stacking -----------
        # --------------------------------

        if stack === automatic
            if fillto === automatic
                y, fillto = bar_default_fillto(transformation, y, offset, in_y_direction)
            end
        elseif eltype(stack) <: Integer
            fillto === automatic || @warn "Ignore keyword fillto when keyword stack is provided"
            if !iszero(offset)
                @warn "Ignore keyword offset when keyword stack is provided"
                offset = 0.0
            end
            i_stack = stack

            from, to = stack_grouped_from_to(i_stack, y, (x = x̂,))
            y, fillto = to, from
        else
            ArgumentError("The keyword argument `stack` currently supports only `AbstractVector{<: Integer}`") |> throw
        end

        # --------------------------------
        # ----------- Labels -------------
        # --------------------------------

        if !isnothing(bar_labels)
            oback = color_over_background === automatic ? label_color : color_over_background
            obar = color_over_bar === automatic ? label_color : color_over_bar
            label_args = barplot_labels(x̂, y, 0, bar_labels, in_y_direction,
                                        flip_labels_at, to_color(oback), to_color(obar),
                                        label_formatter, label_offset, label_rotation, label_align)
            labels[], label_aligns[], label_offsets[], label_colors[] = label_args
        end

        return bar_rectangle.(x̂, y .+ offset, barwidth, fillto, in_y_direction)
    end

	bars = lift(calculate_bars, p, p[1], p.fillto, p.offset, p.transformation.transform_func, p.width, p.dodge, p.n_dodge, p.gap,
                p.dodge_gap, p.stack, p.direction, p.bar_labels, p.flip_labels_at,
                p.label_color, p.color_over_background, p.color_over_bar, p.label_formatter, p.label_offset, p.label_rotation, p.label_align; priority = 1)

	kwargs_df = DataFrame(; 
		color=p.color[], #colormap = p.colormap[], colorrange = p.colorrange[],
        strokewidth = p.strokewidth[], strokecolor = p.strokecolor[],
		#visible = p.visible[],
        #inspectable = p.inspectable[], transparency = p.transparency[],
        #highclip = p.highclip[], lowclip = p.lowclip[], nan_color = p.nan_color[]
		alpha = p.alpha
	)
	#for (bar, kwargs) ∈ zip(bars[], eachrow(kwargs_df))	
	map(zip(bars[], eachrow(kwargs_df))) do (bar, kwargs)
		poly!(p, bar; kwargs...)
	end

    if !isnothing(p.bar_labels[])
		#@info p.label_size[]
        text!(p, labels; align=label_aligns, offset=label_offsets, color=label_colors, font=p.label_font, fontsize=p.label_size,
		rotation=p.label_rotation)
    end
end

end

# ╔═╡ c9775558-94f2-4c8c-9d0e-ab948fa5ead4
using PlutoTest: @test

# ╔═╡ 52052d98-0c41-45ec-95bf-d936b1c43e81
md"""
`systemic-risk.jl` | **Version 2.5+** | *last updated: November 25, 2024*
"""

# ╔═╡ ab239918-1cde-4d6b-ac7f-716aaba5f39b
ChooseDisplayMode()

# ╔═╡ 248909ee-2312-4e28-928a-ec65c0eec8a2
md"""
need space? $(@bind need_space CheckBox(default=false))
"""

# ╔═╡ 94e1ac76-3099-4e33-b987-e7f0cf365399
space = need_space * 10;

# ╔═╡ cdfc35e1-5082-4959-9d30-3abb2dc8a7ac
md"""
# Systemic Risk in Financial Networks

based on _[Acemoglu, Ozdaglar & Tahbaz-Salehi, 2015](https://www.aeaweb.org/articles?id=10.1257/aer.20130456), American Economic Review_
"""

# ╔═╡ 944b07ed-20e5-4068-ac5e-8a48f866fdd2
md"""
## Overview: Contagion on Financial Networks
"""

# ╔═╡ 8347ab1d-f45e-4434-a8b7-60fa3918c97c
nisl_str = "number of components:"

# ╔═╡ cd766ddf-e5a9-4c72-b884-413eae45c4c5
md"""
## Plan for the lecture

> **_Goal_**: Understand model and key results of Acemoglu, Ozdaglar & Tahbaz-Salehi (2015)
"""

# ╔═╡ eba94b09-f061-432a-80ce-a68be83e6a99
md"""
# I. Model Setup

## Model I: Banks
"""

# ╔═╡ acfdf348-e8bf-41ee-aa19-fe7ec29087cc
md"""
## Model II: Firms

* fixed initial size
* dividend ``\delta = a - ε`` paid to bank (``ε`` is a shock)
* fraction ``\tilde ℓ`` can be liquidated (recover ``\tilde ℓ ζ A``)
* final pay-off ``(1-\tilde ℓ) A``

"""

# ╔═╡ 2f69a836-7fed-42e6-a509-096bc8cabbc2
dividend((; a), ε) = max(a - ε, 0.0)

# ╔═╡ 26a5c4f4-75c1-4a4c-a813-5fad0c571da1
recovery((; ζ, A), ℓ) = ℓ * ζ   * A

# ╔═╡ 5d283f89-4419-4b14-81ba-9826b4f1689e
function cashflow₁(firm, ε, ℓ)
	div = dividend(firm, ε)
	rec = recovery(firm, ℓ)
	cf = div + rec
	(; cf, div, rec)
end

# ╔═╡ a0ac4092-cd27-4523-85f9-f4a4d81456b3
md"""
# II. Payment equilibrium
"""

# ╔═╡ 523e177c-f74d-4805-8a2b-9c27a4b0bc63
md"""
* size of shock $(@bind ε_cash Slider(0.0:0.05:1.0, show_value = true, default = 0.0))
* show illiquid firm value ``A`` $(@bind show_illiquid CheckBox(default = false))
* recovery rate ``ζ`` $(@bind recovery_rate Slider(0:0.1:0.5, show_value = true, default = 0.0))
"""

# ╔═╡ 7f058e4a-9b12-41c9-9fd7-4ad023058a14
md"""
# III. Financial Contagion
"""

# ╔═╡ 5012c275-8157-4488-b868-f45c92d43100
md"""
#### Notable insights

1. Let ``\tilde y`` and ``\hat y`` be two regular financial networks with ``(y, n)``. Let ``\varepsilon`` be big enough to wipe out all banks in ``\tilde y``. Then ...

3. Let's start with an ``\varepsilon`` small enough, so that no bank defaults. What will happen to the number of defaults as we increase ``\varepsilon``?

Ring: step-wise increase in defaults, Complete: bang-bang
"""

# ╔═╡ da7c558d-a2b5-41a8-9c78-3e39a00dfd31
md"""
# IV. Stability and Resilience
"""

# ╔═╡ bf719f30-72c1-488e-ba77-c183effb7c60
md"""
## Result 1: More interbank lending leads to less stability and less resilience

Formally, for a given regular financial network ``(y_{ij})`` let ``\tilde y_{ij} = \beta y_{ij}`` for ``\beta > 1``. Financial network ``\tilde y`` is less resilient and less stable *(see __Proposition 3__)*.

* _Proposition 3_: More interbank lending leads to a more fragile system. (For a given network topology, the defaults are increasing in ``\bar y``.)
"""

# ╔═╡ a0767d80-0857-47ef-90a1-72bc34064716
md"""
## Result 2: Densely connected networks are _robust, yet fragile_

> Our results thus confirm a conjecture of Andrew Haldane (2009, then Executive Director for Financial Stability at the Bank of England), who suggested that highly interconnected financial networks may be “robust-yet-fragile” in the sense that “within a certain range, connections serve as shock-absorbers [and] connectivity engenders robustness.” However, beyond that range, interconnections start to serve as a mechanism for the propagation of shocks, “the system [flips to] the wrong side of the knife-edge,” and fragility prevails.

* Upto some ``\varepsilon^*``, the shock does not spread
* Above this value, all banks default
* This is an example for a _phase transition_: it flips from being the most to the least stable and resilient network

__Compare *Propositions 4 and 6*__:
* _Proposition 4_: For small shocks and big ``\bar y``, the complete network ist the most resilitient and most stable financial network and the ring is the least resilient and least stable.

* _Proposition 6_: For big shocks, the ring and complete networks are the least resilient and least stable.

"""

# ╔═╡ c920d82c-cfe9-462a-bacd-436f01c314cf
A = 0.5

# ╔═╡ 72e5f4d3-c3e4-464d-b35c-2cf19fa9d4b5
md"""
# Assignment
"""

# ╔═╡ d6345a8b-6d8f-4fd2-972b-199412cbdc26
md"""
## Task 1 (6 Points)
"""

# ╔═╡ 51bfc57f-7b06-4e27-af32-51df38af30a1
md"""
👉 (1.1 | 2 points) Consider financial network ``\tilde y``. What is the minimal number of shocks ``\tilde p`` that have to occur to wipe out the whole financial system. Which banks have to be hit? How big would the shocks ``\tilde \varepsilon`` have to be?
"""

# ╔═╡ b817cdf6-dfe6-4607-98da-2299a33d4906
answer11 = md"""
Your answer goes here ... You can type math like this: ``\tilde p = 17``, ``\tilde \varepsilon = 1.1``
"""

# ╔═╡ 07e9c77f-e05e-452c-8c47-cdd9dfc8e2fc
md"""
👉 (1.2 | 2 points) Consider financial network ``\hat y``. What is the minimal number of shocks ``\hat p`` that have to occur to wipe out the whole financial system. Which banks have to be hit? How big would the shocks ``\hat \varepsilon`` have to be?
"""

# ╔═╡ f5293bee-9413-4507-8568-54836eb6d4a2
answer12 = md"""
Your answer goes here ... You can type math like this: ``\hat p = 17``, ``\hat \varepsilon = 1.1``
"""

# ╔═╡ 49c2fb2d-de6e-4ab2-a558-59fb153cf703
md"""
👉 (1.3 | 2 points) Now consider ``\varepsilon > \max\{\tilde \varepsilon, \hat \varepsilon \}`` and ``p = 1``. Which network is more stable? Which network is more resilient?
"""

# ╔═╡ c0c711de-6916-4ab9-ab73-c476654332c4
answer13 = md"""
Your answer goes here ... You can type math like this: ``\hat p = 17``, ``\tilde \varepsilon = 1.1``
"""

# ╔═╡ a95431eb-14a0-4dc3-bbe6-9c409f6cc596
md"""
## Task 2 (4 Points)

Consider the model of systemic risk by _Acemoglu, Ozdaglar & Tahbaz-Salehi (2015)_ with $n = 5$ banks. There are two scenarios that differ by the structure of the financial network ($\tilde y$ vs. $\hat y$).  Both $\tilde y$ and $\hat y$ are regular financial networks with parameter $y$.
"""

# ╔═╡ f00d9e1a-b111-4b6a-95f5-b9736329befe
md"""
Each bank owns a project that pays $z_i = a - \varepsilon_i$ in the intermediate period. $\varepsilon_i > 0$ is a shock. Let $\tilde p$ be the minimal number of shocks, and $\tilde \varepsilon$  be the minimal shock size that can wipe out the whole system (that is, a simultaneous default of all banks) under the financial network $\tilde y$.
"""

# ╔═╡ f8eb242f-a974-48aa-9173-b0bc7ff697d5
md"""
👉 (2.1 | 2 points) What is $\tilde p$? Explain which banks would have to be hit to wipe out the whole system.
"""

# ╔═╡ c2633df1-2e30-4387-8749-de3280b0602d
answer21 = md"""
Your answer goes here ... You can type math like this: ``p = 17``, ``\varepsilon = 1.1``
"""

# ╔═╡ 253ab06f-6284-4cbf-b2a2-232ff99548c9
md"""
👉 (2.2 | 2 points) Let $\delta > 0$ be very small and shock size $\varepsilon' \in (\tilde \varepsilon - \delta, \tilde \varepsilon)$. Conditional on $p' = 1$ and $\varepsilon'$, which network is more resilient and which network is more stable? Explain.
"""

# ╔═╡ 1d058f8b-16f5-4744-8425-452876006c47
answer22 = md"""
Your answer goes here ... You can type math like this: ``p = 17``, ``\varepsilon = 1.1``
"""

# ╔═╡ 27fadf93-0b17-446e-8001-d8394b7befaa
md"""
### Before you submit ...

👉 Make sure you have added **your names** and **your group number** in the cells below.

👉 Make sure that that **all group members proofread** your submission (especially your little essays).

👉 Go to the very top of the notebook and click on the symbol in the very top-right corner. **Export a static html file** of this notebook for submission. (The source code is embedded in the html file.)
"""

# ╔═╡ aed99485-cec3-4bf3-b05d-4d20572ec907
group_members = ([
	(firstname = "Ella-Louise", lastname = "Flores"),
	(firstname = "Padraig", 	lastname = "Cope"),
	(firstname = "Christy",  	lastname = "Denton")
	]);

# ╔═╡ db841316-9106-40bb-9ca3-ae6f8b975404
group_number = 99

# ╔═╡ 639f04a2-0979-41e2-b465-a4f52049166d
if group_number == 99 || (group_members[1].firstname == "Ella-Louise" && group_members[1].lastname == "Flores")
	md"""
!!! danger "Note!"
    **Before you submit**, please replace the randomly generated names above by the names of your group and put the right group number in the appropriate cell.
	"""
end

# ╔═╡ 900a4b24-04dc-4a1b-9829-a166cf9eb7fb
md"""
## Task 3 (not graded): Avoiding a bank run

_see notebook `risk-sharing.jl`_
"""

# ╔═╡ eda3fdcc-a3b4-47d2-bdab-8c1c673a7a15
md"""
## Objects for Task 2
"""

# ╔═╡ 4e9b785f-ad74-4aa8-ad48-89fa8b236939
md"""
# Appendix
"""

# ╔═╡ 1a997e44-f29c-4c55-a953-a9039f096d47
TableOfContents()

# ╔═╡ 78bedfcc-3671-4852-985b-3e1b5aaade5a
md"""
## Helpers
"""

# ╔═╡ 25e84f19-9cd8-43ad-ae6a-d500b8ac74b6
md"""
## Packages
"""

# ╔═╡ 6172ebbe-8a27-4c1c-bf5c-5a6e7357447a
PlutoUI.details

# ╔═╡ 11d6ac4f-e910-4a9f-9ee4-bdd270e9400b
md"""
## HTML Helpers
"""

# ╔═╡ c1b1a22b-8e18-4d19-bb9b-14d2853f0b72
@htl("
<style>
.blurry-text {
	color: transparent;
	text-shadow: 0 0 5px rgba(0,0,0,0.5);
	white-space: nowrap;
}

.blurry-text:hover {
	color: transparent;
	text-shadow: 0 0 0px rgba(0,0,0.5);
	white-space: nowrap;
}

</style>
")

# ╔═╡ cc1ff1e6-2968-4baf-b513-e963ab2ff1b4
blur(text) = @htl("""<span class="blurry-text">$text</span>""")

# ╔═╡ 1d5d8c8a-8d86-426f-bb17-bd2279d91ff1
md_fig = @htl("""
$(md"
> _Financial network_:  banks linked by interbank lending

1. _How do shocks propagate_ on a financial network?
2. _How should a network look_ so that shocks don't spread?
")

$(md"
* ring vs complete ``(γ)``: $(@bind _γ_ Slider(0:0.1:1.0, show_value = true, default = 0.5))
* shock to bank ``1`` ``(ε)``: $(@bind _ε_ Slider(0.0:0.05:1, show_value = true, default = 0.0))
*  $(blur(nisl_str)) $(@bind n_components Slider(1:3, show_value = true, default = 1))
")
""")

# ╔═╡ c65323f5-211d-4a95-aed3-d6129bdd083e
strike(text) = @htl("<s>$text</s>")

# ╔═╡ 5d263432-856b-4e9b-a303-a476222e8963
vertical_space(space=space) = @htl("""
<p style="line-height:$(space)cm;"><br></p>
""")

# ╔═╡ e11a99df-d0f2-4838-b325-473d3043be98
vertical_space()

# ╔═╡ ba39c037-c4e1-465e-a232-e5194caa14ba
vertical_space()

# ╔═╡ 834ff5a0-3bae-44ca-a413-f45d3394b511
vertical_space()

# ╔═╡ 4ae1b6c2-bb63-4ca8-b8ec-057c8d2a371f
vertical_space()

# ╔═╡ aaffd333-3aa1-48ee-b5db-d577bd7da830
vertical_space()

# ╔═╡ 73c87a80-8bd9-4040-8a09-519f1a73f7c0
function TwoColumns(a, b, α=50, β=100-α)
	PlutoUI.ExperimentalLayout.Div([
		PlutoUI.ExperimentalLayout.Div([a]; style=Dict("flex" => "0 0 $α%"))
		PlutoUI.ExperimentalLayout.Div([b]; style=Dict("flex" => "0 0 $β%"))
	]; style=Dict("display" => "flex", "flex-direction" => "row"))
end

# ╔═╡ 44ee4809-64ba-40dc-89ec-ae4f852535a8
TwoColumns(
	md"""
* default on interbank market 
* ``\implies`` lower interbank receivables for other banks
* ``\implies`` reduces distance to default

	""",
	md"""
| variable            | value                                                        |
|:------------------- | :----------------------------------------------------------- |
| ring vs complete ``γ`` | $(@bind γ2 Slider(0:0.01:1, default=0.5, show_value=true))|
| shock ``ε``         | $(@bind ε Slider(0:0.1:2, default=0.0, show_value=true))     |


$(details("Change parameters ...", md"
| variable            | value                                                        |
|:------------------- | :----------------------------------------------------------- |
| dividend ``a``      | $(@bind a Slider(0:0.01:1, default=0.7, show_value=true))    |
| recovery rate ``ζ`` | $(@bind ζ Slider(0:0.01:1, default=0.3, show_value=true))    |
| **external**        | |
| cash ``c``          | $(@bind c Slider(0:0.1:2, default=1.2, show_value=true))     |
| deposits ``ν``      | $(@bind ν Slider(0.0:0.1:2, default=1.8, show_value=true))   |
| **internal**        | |
| interbank ``y``     | $(@bind y Slider(0:0.1:2, default=1.0, show_value=true))     |

"))
""",
45)

# ╔═╡ 76482e5e-418a-4102-8a62-cae3c0cb88d4
function OneColumn(a, α=60)
	PlutoUI.ExperimentalLayout.Div([
		PlutoUI.ExperimentalLayout.Div([a]; style=Dict("flex" => "0 0 $α%"))
	]; style=Dict("display" => "flex", "flex-direction" => "row"))
end

# ╔═╡ 25a01039-25e9-44b0-afd0-c3df37c7598f
md"""
## Theorems, etc
"""

# ╔═╡ 71231141-c2f5-4695-ade0-548a0039f511
function theorem_header(type, number, title)
	out = type
	if !isnothing(number) && length(number) > 0
		out = out * " " * string(number)
	end
	if !isnothing(title) && length(title) > 0
		out = out * ": " * string(title)
	end
	out
end

# ╔═╡ c993c1d8-8823-4db4-bf6e-bf2c21ea3d39
begin
	admonition(kind, title, text) = Markdown.MD(Markdown.Admonition(kind, title, [text]))
	proposition(text; number = nothing, title = nothing) = 
		admonition("correct", theorem_header("Proposition", number, title), text)
	corollary(text; number = nothing, title = nothing) =
		admonition("note", theorem_header("Corollary", number, title), text)
	definition(text; number = nothing, title = nothing) =
		admonition("warning", theorem_header("Definition", number, title), text)
	assumption(text; number = nothing, title = nothing) =
		admonition("danger", theorem_header("Assumption", number, title), text)
#	danger(text, title="Danger")   = admonition("danger",  title, text)
#	correct(text, title="Correct") = admonition("hint", title, text)

end

# ╔═╡ 7b876239-8ddc-4929-ad52-752edb72c0eb
Foldable("Take-away", 
	proposition(md"""
**Small Shocks:** more complete ``\implies`` fewer defaults

**Large shocks:** split up network ``\implies`` fewer defaults $(Foldable("in their words", md"> Not all financial systems, however, are as fragile in the presence of large shocks. In fact, as part ``(ii)`` shows, for small enough values of ``δ``, any ``δ``-connected financial network is strictly more stable and resilient than both the complete and the ring networks. The presence of such _weakly connected_ components in the network guarantees that the losses—rather than being transmitted to all other banks—are borne in part by the distressed bank’s senior creditors."
	))
""",
title = "Acemoglu, Ozdaglar & Tahbaz-Salehi (2015)", )
)

# ╔═╡ f24387ee-c1cf-4ec0-a34e-4b4f33ee9010
md"""
## Packages
"""

# ╔═╡ fbf40f06-f63a-40ca-bbe3-78104d39ee71
md"""
## Line patterns in AlgebraOfGraphics
"""

# ╔═╡ f863066f-270f-4972-8046-7f51cb697ac5
hatch_dict = Dict(
	:/ => Vec2f0(1),
	:\ => Vec2f0(1, -1),
	:- => Vec2f0(1, 0),
	:| => Vec2f0(0, 1),
	:x => [Vec2f0(1), Vec2f0(1, -1)],
	:+ => [Vec2f0(1, 0), Vec2f0(0, 1)]
)

# ╔═╡ d285879a-bdfd-4efa-aa5d-9dacf08a2dc6
hatches = [:\, :/, :-, :|, :x, :+]

# ╔═╡ 70bbb90e-06f1-4b60-a952-275866945c58
line_pattern(hatch; width=1.5, tilesize=(10,10), linecolor=:black, color=:white) = Makie.LinePattern(; direction=hatch_dict[Symbol(hatch)], width, tilesize, linecolor, background_color=color)

# ╔═╡ 3040803d-e95a-40bc-aa72-92c7d158e226
md"""
# FinancialNetworks.jl
"""

# ╔═╡ f13e010a-d394-4e40-9535-c5e2e3e226aa
md"""
## Payments and Equilibrium
"""

# ╔═╡ 7871b479-2aaf-42c1-ad84-42ac17cfc6e1
function repay((; c, ν), (; x, y), firm, ε)
	
	assets(ℓ) = x + c + cashflow₁(firm, ε, ℓ).cf

	if ν + y ≤ assets(0.0)
		out = (; ℓ=0, y_pc=1.0, ν_pc=1.0)
	elseif assets(0.0) < ν + y ≤ assets(1.0)
		ℓ = find_zero(ℓ_ -> ν + y - assets(ℓ_), (0.0, 1.0))
		out = (; ℓ,   y_pc=1.0, ν_pc=1.0)
	else
		ℓ = 1.0
		ass = assets(ℓ)
		if ν ≤ ass < ν + y
			out = (; ℓ, y_pc = (ass - ν)/y, ν_pc = 1.0)
		else # assets < ν
			out = (; ℓ, y_pc = 0.0, ν_pc = ass/ν)
		end
	end		

	(; out..., assets = assets(out.ℓ), cashflow₁(firm, ε, out.ℓ)..., firm_pc = 1 - out.ℓ, x, y = y * out.y_pc)
	
end

# ╔═╡ 7c026a42-1c05-4968-b068-c8561ca5a2db
md"""
## Visualize bank-firm-network
"""

# ╔═╡ 78965848-8694-4665-80c6-94191a95f95d
function edge_attr_df(g)
	A = adjacency_matrix(g)
	n = size(A, 1)

	df = map(edges(g)) do (; src, dst, weight)
		(; src, dst, weight)
	end |> DataFrame

	norm_const = sum(A) / n
	
	@chain df begin
		@transform!(
			:edge_width = √(:weight / norm_const) * 1.5,
			:arrow_size = √(:weight / norm_const) * 14
		)
	end

	df
end

# ╔═╡ 1016a42f-cd4c-40f5-b359-186df8440c37
function edge_attrs(g)
	df = edge_attr_df(g)
	(; df.edge_width, df.arrow_size)
end

# ╔═╡ 3998e822-d7e0-40f2-a866-71a3d81c4ca3
function add_legend!(figpos; cols, kwargs...)
	dict = [:lightgray => "solvent bank"]
	if :orange ∈ cols
		push!(dict, :orange => "insolvent")
	end
	if :red ∈ cols
		push!(dict, :red => "bankrupt")
	end
	
	elements = [
		MarkerElement(marker = :circle, strokewidth=1, markersize = 20, color = c) for c in first.(dict)
	]

	Legend(figpos, elements, last.(dict); kwargs...)

	figpos
end

# ╔═╡ 0d207cbe-5b97-4bd7-accf-fc49ce4522e9
md"""
## Visualize bank balance sheet
"""

# ╔═╡ 3033ae5a-bada-4041-858d-a61c62bdc8b8
#balance_sheet_palette()

# ╔═╡ 5104f0a5-a551-4f4c-8f89-2b8f834b3587
function balance_sheet_palette()
	palette_df = DataFrame(
		label = ["external", "interbank", "firm", "liquidated", "shortfall"],
		color = [Makie.wong_colors()[[5, 2, 4, 3, ]]..., Makie.Pattern("/")]
	)
	
	palette_df.label .=> palette_df.color
end

# ╔═╡ f63aee78-1209-40dd-9c9d-2699194807d8
function _balance_sheet_df_((; c, x, div, ill, rec, ν_paid, y_paid, shortfall))
	receivable = DataFrame([
		(color = "external",   val=c,   lab=L"cash $c$"),
		(color = "interbank",  val=x,   lab=L"IB deposit $x$"),
		(color = "firm",       val=div, lab=L"dividend $δ$"),
		(color = "firm",       val=ill, lab="illiquid"),
		(color = "liquidated", val=rec, lab=L"recovered $ρ$"),
	])

	payable = DataFrame([
		(color = "external",  val=ν_paid,    lab=L"deposits $ν$"),
		(color = "interbank", val=y_paid,    lab=L"IB debt $y$"),
		(color = "shortfall", val=shortfall, lab=""),
	])

	nt = (; receivable, payable)

	vcat(nt..., source = :side => collect(string.(keys(nt))))
end

# ╔═╡ 6a2b3b9c-df52-41c3-908b-5dbf052ad107
function balance_sheet_df_new(bank, firm, (; x, y); ε_cash=get(bank, :ε, 0.0))
	c₀ = bank.c
	c = max(c₀ - ε_cash, 0.0)
	bank = (; c, bank.ν)
	
	(; y_pc, ν_pc, ℓ, rec, div) = 
		repay(bank, (; x, y), firm, ε)

	(; a, A) = firm
	(; ν, c) = bank
	y_paid = y_pc * y
	ν_paid = ν_pc * ν
	shortfall = (1-ν_pc) * ν + (1-y_pc) * y
	ill = (1-ℓ) * A
	
	df = _balance_sheet_df_((; c, x, div, ill, rec, ν_paid, y_paid, shortfall))

	bs_max = max((A + a) + x + c₀, y + ν)
	
	(; df, bs_max, ℓ, shortfall)
end

# ╔═╡ 1b9c8f2b-8011-46f1-b46d-479031eb9ac3
function _visualize_simple_balance_sheet_(bank, firm, (; x, y); show_illiquid=true, fontsize=15)

	(; df, bs_max, ℓ, shortfall) = balance_sheet_df_new(bank, firm, (; x, y))

	@transform!(df, :stack = :lab == "illiquid" ? :lab : :color)
	
	if !show_illiquid || ℓ ≈ 1
		@subset!(df, :lab ≠ "illiquid")
	end
	if ℓ * firm.ζ ≈ 0
		@subset!(df, :color ≠ "liquidated")
	end
	@subset!(df, :val > 0)
	@transform!(df, @subset(:val < 0.3), :lab = "")

	df.color = categorical(df.color)
	
	ordered = @chain begin
		["external", "interbank", "firm", "liquidated", "shortfall"]
		filter(∈(unique(df.color)), _)
	end
	levels!(df.color, ordered)

	df.stack = categorical(df.stack)
	ordered = @chain begin
		["external", "interbank", "firm", "liquidated", "illiquid", "shortfall"]
		filter(∈(unique(df.stack)), _)
	end
	levels!(df.stack, ordered)
	
	plt = data(df) * mapping(
		:side => sorter("receivable", "payable") => "", 
		:val => "",
		stack=:stack, color=:color => "",
		bar_labels=:lab => verbatim
	) * visual(BarPlot, flip_labels_at = 0, label_size=fontsize, strokewidth=0.5)

	(; plt, bs_max)
end

# ╔═╡ ebf41ae2-3985-439b-b193-eabfab701d16
function visualize_simple_balance_sheet(args...; figure=(;), legend=(;), kwargs...)
	(; plt, bs_max) = _visualize_simple_balance_sheet_(args...; kwargs...)

	if isempty(legend)
		legend = (; position = :top, titleposition=:left, framevisible=false)
	end
	
	fg = draw(
		plt;
		axis = (limits = (nothing, nothing, 0, 1.05 * bs_max),),
		figure,
		palettes = (; color=balance_sheet_palette()),
		legend,
	)

	rowgap!(fg.figure.layout, 1)

	fg
end

# ╔═╡ efbc1a42-ecc2-4907-a981-bd1d29ca0803
balance_sheet = let
	c = 0.7
	ν = 1.2
	x = 1.0
	a = 0.7
	y = 1.0
	A = 1.0
	ζ = recovery_rate
	shortfall = max(y + ν - (c - ε_cash + x + a), 0)

	figure = (; size = 0.8 .* (400, 350), fontsize=15, figure_padding=3)

	firm = (; a, A, ζ)
	visualize_simple_balance_sheet((; c, ν, ε=ε_cash), firm, (; x, y); figure, show_illiquid)
end	

# ╔═╡ bafc7db1-ac1d-4314-be83-0b9f6c63b5fc
TwoColumns(md"""
### Bank

* external debt (deposits) ``ν``
* external assets (cash) ``c``
* borrowing and lending on _**financial network**_ (see below)
* investment in $(strike("loan to")) _**firm**_ (see below)

### Financial network

* ``n`` banks
* ``y_{ij} > 0 ⟺`` bank ``i`` has debt with bank ``j``
* the network is **_regular_** \
  ``\forall i \sum_{j} y_{ij} = \sum_{j} y_{ji} = \bar y``
""",
balance_sheet, 62)

# ╔═╡ 01eb57fd-a815-41f2-9e25-7730bff7917d
TwoColumns(
	@mdx("""
<br>
	
### Banks' choice

1. payables > receivables: repay all debt (**_solvent_**)
2. not enough? liquidate (part) of the firm ``ℓ > 0`` (**_insolvent_**)
3. still not enough? (partially) default on interbank debt (**_bankrupt_**)
4. still not enough? (partially) default on external liabilities ``ν`` (**_bankrupt_**)
"""),
	balance_sheet, 65)

# ╔═╡ b7d74679-904c-44c4-bedd-89f1b68a5e42
function visualize_simple_balance_sheet!(figpos, legpos, args...; legend=(;), kwargs...)
	(; plt, bs_max) = _visualize_simple_balance_sheet_(args...; kwargs...)

	fg = draw!(
		figpos,
		plt,
		palettes = (; color=balance_sheet_palette())
	)
	
	legend!(legpos, fg; legend...)
end

# ╔═╡ ab1cf7ab-80fb-4423-a924-1d6e24e9c9bc
function balance_sheet_df((; ν, c), (; a, A, ζ), (; ℓ, y_pc, ν_pc, x, y, div, rec))

	y_paid = y
	y = y / y_pc
	ν_paid = ν_pc * ν
	shortfall = (1-ν_pc) * ν + (1-y_pc) * y
	ill = (1-ℓ) * A
	
	df = _balance_sheet_df_((; c, x, div, ill, rec, ν_paid, y_paid, shortfall))

	@subset!(df, :lab ≠ "illiquid")
	
	bs_max = max(a + x + c, y + ν) * 1.05

	(; df, bs_max = isfinite(bs_max) ? bs_max : zero(bs_max))
end

# ╔═╡ 0ff81eb8-d843-49a4-af93-ec2414797e87
function visualize_balance_sheets!(figpos, bank_df, banks, firm; use_palettes=true)
	
	bank_dfs = [
		balance_sheet_df(banks[i], firm, bank_df[i,:]) for i ∈ 1:length(banks)
	] |> StructArray

	combined_bank_df = vcat(
		bank_dfs.df..., source = :bank
	)

	@transform!(combined_bank_df, :bank = "bank $(:bank)")
	
	bs_max = maximum(bank_dfs.bs_max)

	plt = @chain combined_bank_df begin
		data(_) * mapping(
			:side => sorter("receivable", "payable") => "",
			:val => "",
			color = :color => "", stack = :color,
			col = :bank
		) * visual(BarPlot, strokewidth=0.5)
	end

	palettes = use_palettes ? (; color=balance_sheet_palette()) : (;)
	fg = draw!(figpos[2,1], plt; 
		axis = (limits = (nothing, nothing, 0, 1.05 * bs_max),),
		palettes
	)
	legend!(figpos[1,1], fg, orientation=:horizontal, titleposition=:left, framevisible=false)

	nothing
end

# ╔═╡ 0f03f537-f589-4abd-9587-0bb18835d9b9
function visualize_balance_sheets(out, banks, firms, shares)
	fig = Figure()
	visualize_balance_sheets!(fig[1,1], out, banks, firms, shares)
	fig
end

# ╔═╡ ffe50130-a9cb-4ba9-a861-c247bf688873
md"""
# NetworkUtils.jl
"""

# ╔═╡ d3e5b8f2-51b1-4ba4-97b4-2be156a74643
md"""
## Regular interbank market
"""

# ╔═╡ d5c128e0-6371-4ad2-8bfc-c17faadc520b
weighted_adjacency_matrix(graph) = Graphs.weights(graph) .* (adjacency_matrix(graph) .> 0)

# ╔═╡ 38a1f960-7178-4968-89e4-6b659b64baa2
function payments_received((; promises, pc_served))
	Y = weighted_adjacency_matrix(promises)
	vec(pc_served' * Y)
end

# ╔═╡ f689810f-8f43-4368-a822-0ee4f3015271
function payments_promised((; promises))
	Y = weighted_adjacency_matrix(promises)
	dropdims(sum(Y, dims=2), dims=2)
end

# ╔═╡ 601b1453-20bd-4e93-abb7-4fad4f5adf8c
function iterate_payments(banks, promises, pc_served, firm, εs_firm, ℓs = zeros(length(banks)))
	ys = payments_promised((; promises))
	
	x_new = copy(y)
	out = map(enumerate(banks)) do (i, bank)
		# compute repayment
		xs = payments_received((; promises, pc_served))
		internal = (; x=xs[i], y=ys[i])
		
		rpy = repay(bank, internal, firm, εs_firm[i])
		(; y_pc, ℓ) = rpy
	
		ℓs[i] = ℓ
		pc_served[i] = y_pc
		# return bank's choices
		(; bank = i, rpy...)
	end

	(; pc_served, out, ℓs)
end

# ╔═╡ 9cdc97e5-67f8-4e71-97d8-9cda5e9d7bd8
function equilibrium(banks, promises, firm, ε_firms; maxit = 100)
	n_banks = length(banks)
	
	pc_served = ones(n_banks)
	ℓs = zeros(n_banks)

	for it ∈ 1:maxit
		ℓs_old = copy(ℓs)
		pc_served_old = copy(pc_served)
		
		(; pc_served, out, ℓs) = iterate_payments(banks, promises, pc_served, firm, ε_firms, ℓs)
		converged = pc_served_old ≈ pc_served && ℓs_old ≈ ℓs
		
		if converged || it == maxit
			bank_df = DataFrame(out)
			
			return (; bank_df, it, success = it != maxit, banks)
		end
	end
	
end

# ╔═╡ 5bde1113-5297-4e93-b052-7a0f93f4ea84
function is_regular(Y)
	vec(sum(Y, dims=1)) ≈ vec(sum(Y, dims=2))
end

# ╔═╡ 73456a8f-8534-4b55-8af6-ff7952bd3a3a
function is_regular(Y, ȳ)
	is_regular(Y) && mean(sum(Y, dims=1)) ≈ ȳ
end

# ╔═╡ e6def365-4438-4591-acbd-60d9de466b0a
initial_network(interbank_market) = adjacency_matrix(interbank_market.network)

# ╔═╡ 055a811c-bc4a-4959-88f1-bc71e8749313
updated_network(interbank_market) = interbank_market.payments

# ╔═╡ 3c211dad-73b0-4715-b066-e10005f8f3a7
function complete_network(n, ȳ)
	Y = fill(ȳ/(n-1), n, n)
		
	for i in 1:n
		Y[i,i] = 0.0
	end
	
	Y
end

# ╔═╡ e2045a53-21d3-4c7c-ad95-3fc8d2444821
function CompleteNetwork(n, ȳ)
	SimpleWeightedDiGraph(complete_network(n, ȳ))
end

# ╔═╡ 2a5f02e7-fec1-41b3-b8b4-b33b1cc1232c
function ring_network(n, ȳ)
	Y = zeros(n, n)
	
	for i in 1:(n-1)
		Y[i, i+1] = ȳ
	end
	if n > 1
		Y[n, 1] = ȳ
	end
	
	Y
end

# ╔═╡ ee10e134-84be-41f8-9e7e-c1cd68227977
function RingNetwork(n, ȳ)
	SimpleWeightedDiGraph(ring_network(n, ȳ))
end

# ╔═╡ 47118d1b-8471-4288-85fe-d3e94667dc96
function γ_network(n, ȳ, γ)
	Y = γ * ring_network(n, ȳ) + (1-γ) * complete_network(n, ȳ)
end

# ╔═╡ dffce961-6844-4a44-beea-ab085c2f9f3f
function γNetwork(n, ȳ, γ)
	SimpleWeightedDiGraph(γ_network(n, ȳ, γ))
end

# ╔═╡ f708e6c0-cfac-4b4d-a3ed-69b98883294a
function component_network(n_components, n_banks_per_component, ȳ, γ)
	blocks = (γ_network(n_banks_per_component, ȳ, γ) for _ in 1:n_components)
	
	cat(blocks...,dims=(1,2))
end

# ╔═╡ d6cb95c1-a075-4544-9031-58aef65c7577
function component_network(n_banks::AbstractVector, ȳ, γ)
	blocks = (γ_network(n, ȳ, γ) for n ∈ n_banks)
	
	cat(blocks...,dims=(1,2))
end

# ╔═╡ 1bb841e0-ddd2-4571-83a5-d929e0a8a69c
function ComponentNetwork(n_components, n_banks_per_component, ȳ; γ=0.0)
	Y = component_network(n_components, n_banks_per_component, ȳ, γ)	
	SimpleWeightedDiGraph(Y)
end

# ╔═╡ 7fbcfbde-0b5e-4bf2-9eda-9b15a4dd6bec
function ComponentNetwork(n_banks::AbstractVector, ȳ; γ=0.0)
	Y = component_network(n_banks, ȳ, γ)	
	SimpleWeightedDiGraph(Y)
end

# ╔═╡ 8a2f3e4d-9c61-4a21-a229-58f731964181
initial_analysis = let
	n_banks = 6
	n_firms = n_banks

	ν = 2.3
	c = 2.4

	banks = [(; ν, c = max(c - (i==1)*_ε_, 0)) for i ∈ 1:n_banks]

	firm = (; ζ=0.0, a=0.0, A=0.5)
	εs = zeros(n_banks)

	ȳ = 1.2
	promises = ComponentNetwork(n_components, n_banks ÷ n_components, ȳ; γ=_γ_)
	
	(; bank_df) = equilibrium(banks, promises, firm, εs)

	(; promises, banks, firm, bank_df)
end;

# ╔═╡ a8a8a197-d54d-4c67-b7ce-19bdc8b64401
transmission_analysis = let
	n_components = 1
	n_banks = 3
	
	banks = [(; ν, c = max(c - (i==1)*ε, 0)) for i ∈ 1:n_banks]

	firm = (; ζ, a, A)
	εs = zeros(n_banks)

	ȳ = y
	IM = ComponentNetwork(n_components, n_banks ÷ n_components, ȳ; γ=γ2)

	(; bank_df) = equilibrium(banks, IM, firm, εs)

	(; banks, firm, IM, bank_df)
end

# ╔═╡ ff77f7b4-52d1-4fc8-abfc-e623f7bcd423
md"""
## Layout
"""

# ╔═╡ c7c8581c-e82c-428e-a599-3c003cc0151c
begin
	function points_on_circle(n; c = Point(0, 0), r = 1, start = 0)
		if n == 0
			Point2[]
		else
			x = range(0, 2, n + 1) .+ start # .- 0.5
			x = x[begin:end-1]
		
			Point2.(r * sinpi.(x), r * cospi.(x)) .+ Ref(c)
		end
	end

	function nested_circles(inner; r=1.5, start = 0)
		function (g)
			n_nodes = nv(g)
			outer = n_nodes - inner
			[
				points_on_circle(inner);
				points_on_circle(outer; r, start)
			]
		end
	end
	function componentwise_circle(g::AbstractGraph; kwargs...)
		components = connected_components(g)
		componentwise_circle(components; kwargs...)
	end
			
	function componentwise_circle(components; scale=2.5)
		nodes = Int[]
		node_locs = Point2f[]

		N = length(components)
		ncol = ceil(Int, sqrt(N))

		for (i, component) in enumerate(components)
			(row, col) = fldmod1(i, ncol)
			n = length(component)
			append!(nodes, component)
			append!(node_locs, points_on_circle(n, c = Point(scale * (col-1), scale * (1 - row))))
		end

		node_locs[sortperm(nodes)]
	end
end

# ╔═╡ 222665dc-397b-4e58-b3ee-935b115cf13d
function visualize_bank_firm_network!(ax, IM, bank_df; r = 1.4, start = Makie.automatic, layout=Makie.automatic, show_firms=true, kwargs...)

	A = adjacency_matrix(IM)
	n_banks = nv(IM)

	if show_firms
		n_firms = n_banks
		shares = I(n_firms)
		big_A = [A       shares';
	    	     0 * shares 0 * I]
		
	else
		big_A = A
		
	end
	
	g = big_A |> SimpleWeightedDiGraph

	n_banks = Base.size(A, 1)

	edge_df = @chain g begin
		edge_attr_df
		@transform!(
			@subset(:src ≤ n_banks, :dst ≤ n_banks),
			:linestyle = Makie.automatic
		)
		@transform!(
			@subset(:dst > n_banks),
			:edge_width = 0.5,
			:arrow_size = 0.0,
			:linestyle = "--"
		)
	end
	
	arrow_attr = (; markersize = edge_df.arrow_size)
	edge_attr = (; linewidth = edge_df.edge_width, edge_df.linestyle)

	node_color = ifelse.(bank_df.y_pc .< 1.0, :red, ifelse.(bank_df.ℓ .> 0.0, :orange, :lightgray))
	nlabels = string.(1:n_banks)
	node_marker = fill(Circle, n_banks)
	
	if show_firms
		nlabels = [nlabels; ["F$i" for i ∈ 1:n_firms]]
		node_marker = [node_marker; fill(Rect, n_firms)]
		
		node_color = [
			node_color;
			fill(colorant"limegreen", n_firms)
		]
	end
	
	start = start === Makie.automatic ? 1/n_banks : start
	layout = layout === Makie.automatic ? nested_circles(n_banks; start, r) : layout

	graphplot_attr = (; 
		layout, edge_attr, arrow_attr,
		edge_plottype = :beziersegments,
		kwargs...
	)
	graphplot!(ax, g;
		ilabels=nlabels,
		node_marker,
		node_color,
		graphplot_attr...
	)

	unique(node_color)
end

# ╔═╡ 2c22e86e-1139-4f66-8992-093d38f4c6cb
md"""
## Plotting helpers
"""

# ╔═╡ 60293fac-4d20-409b-bfd2-d5283f189320
attr(; kwargs...) = (; arrow_size = 10, elabels_distance = 15, edge_width=1, nlabels_distance = 10, kwargs...)

# ╔═╡ bef59a5b-6952-42aa-b700-4ad81d848fe4
minimal(; extend_limits=0.1, hidespines=true, kwargs...) = (; 
	xgridvisible=false, xticksvisible=false, xticklabelsvisible=false,
	ygridvisible=false, yticksvisible=false, yticklabelsvisible=false, 
	leftspinevisible=!hidespines, rightspinevisible=!hidespines, topspinevisible=!hidespines, bottomspinevisible=!hidespines,
	xautolimitmargin = (extend_limits, extend_limits),
	yautolimitmargin = (extend_limits, extend_limits),
	kwargs...
)

# ╔═╡ e2041c57-0e3d-4dad-9bab-d70434f18509
let
	(; IM, firm, banks, bank_df) = transmission_analysis

	fig = Figure(size = (650, 180), figure_padding=3)
		
	visualize_bank_firm_network!(
		Axis(fig[1,1]; minimal(extend_limits=0.1)..., aspect = DataAspect()),
		IM, bank_df; 
		start = 1/8, show_firms=false
	)

	visualize_balance_sheets!(fig[1,2:4], bank_df, banks, firm)

	rowgap!(content(fig[1,2:4]), 0)
#	rowgap!(fig[1,2:4[.layout, 0)
	fig
end

# ╔═╡ ce563ab5-6324-4a86-be61-7a107ff0e3b3
fig_attr(xscale=1, yscale=xscale) = (; figure_padding=3, size = (xscale * 200, yscale * 200))

# ╔═╡ c99e52e2-6711-4fb6-bcc0-8e4f378ed479
out_T1 = let
	y = 2.1
	γ = 0
	n1 = 6
	ỹ = ComponentNetwork([3, n1-3, 5], y; γ)
	ŷ = ComponentNetwork([n1, 2, 1, 1, 1], y; γ)
	 
	@assert nv(ỹ) == nv(ŷ)
	n = nv(ỹ)

	layout(n) = (_) -> componentwise_circle([1:n, n .+ (1:5)])

	fig = Figure(; fig_attr(3.0, 1.0)...)
	ax1 = Axis(fig[1,1]; minimal(hidespines=false, title = L"interbank market $\tilde{y}$")...)
	ax2 = Axis(fig[1,2]; minimal(hidespines=false, title = L"interbank market $\hat{y}$")...)

	graphplot!(ax1, ỹ; layout=layout(n1), ilabels=vertices(ỹ), edge_attrs(ỹ)...)
	graphplot!(ax2, ŷ; layout=layout(n1), ilabels=vertices(ŷ), edge_attrs(ŷ)...)

	(; ỹ, ŷ, fig, n, y)
end; out_T1.fig

# ╔═╡ 15f45669-516b-4f3f-9ec1-f9e2c1d2e71a
@markdown("""
Consider the interbank networks ``\\tilde y`` and ``\\hat y`` of $(out_T1.n) banks as depicted above. For all non-isolated banks the sum of interbank liabilities equal the sum of interbank claims (``y = $(out_T1.y)``).
""")

# ╔═╡ d7111001-f632-4d0d-a2c7-7bbfd67bf87d
md"""
For this exercise you can use the tool below, to simulate the payment equilibrium for a given interbank market, shock size, and the bank that is hit by the shock.

* Which bank is hit? ``i`` $(@bind i_T1 Slider(1:out_T1.n, default = 1, show_value = true))
* Size of the shock ``\varepsilon``  $(@bind ε_T1 Slider(0.0:0.1:3.0, show_value = true, default = 1.0))
* Select ``\tilde y`` or ``\hat y`` $(@bind IM_T1 Select([out_T1.ỹ => "ỹ", out_T1.ŷ => "ŷ"]))
"""

# ╔═╡ c7b99d3c-5d32-45e6-84fa-8a6513e6beb9
out_T2 = let
	ȳ = 2.1
	IM1 = ComponentNetwork([3, 2], ȳ; γ=0.0)
	IM2 = ComponentNetwork([3, 2], ȳ; γ=1.0)

	n1 = nv(IM1)
	n2 = nv(IM2)
	if n1 == n2
		n = n1
	else
		n = (n1, n2)
	end
	layout = Shell()

	fig = Figure(; fig_attr(2, 1)...)
	ax1 = Axis(fig[1,1]; minimal(hidespines=false, title = L"interbank market $\tilde{y}$", extend_limits=0.1)...)
	ax2 = Axis(fig[1,2]; minimal(hidespines=false, title = L"interbank market $\hat{y}$", extend_limits=0.1)...)

	graphplot!(ax1, IM1; ilabels=vertices(IM1), layout, edge_attrs(IM1)...)
	graphplot!(ax2, IM2; ilabels=vertices(IM2), layout, edge_attrs(IM2)...)

	(; IM1, IM2, fig, n)
end; out_T2.fig

# ╔═╡ 2c839d92-183a-4077-b7d6-39ac485ae06e
tool_text = md"""
If you have understood the mechanics of the model, you should be able to solve these tasks without simulations. You can use the given tool to verify your answer.

* Which bank is hit? ``i`` $(@bind i_bank_T2 Slider(1:out_T2.n, default = 1, show_value = true))
* Size of the shock ``\varepsilon``  $(@bind ε_T2 Slider(0.0:0.1:3.0, show_value = true, default = 1.0))
* Select ``\tilde y`` or ``\hat y`` $(@bind IM_T2 Select([out_T2.IM1 => "ỹ", out_T2.IM2 => "ŷ"]))
"""

# ╔═╡ 7b70a862-faf4-4c42-917c-238718c43708
function visualize_bank_firm_network(IM, bank_df; figure = fig_attr(), add_legend=false, hidespines=true, kwargs...)
	fig = Figure(; figure...)
	ax = Axis(fig[1,1]; minimal(; hidespines, extend_limits=0.1)...)
	cols = visualize_bank_firm_network!(ax, IM, bank_df; kwargs...)

	if add_legend == :vertical
		add_legend!(fig[:,end+1]; cols, orientation=:vertical, framevisible=false)
		colgap!(fig.layout, 1)
	elseif add_legend
		add_legend!(fig[0,:]; cols, orientation=:horizontal, framevisible=false)
		rowgap!(fig.layout, 1)
	end
	fig # |> as_svg
end

# ╔═╡ 073982c7-6333-43f6-866a-91a49f8ba7eb
fig = let
	(; promises, bank_df) = initial_analysis
	
	visualize_bank_firm_network(promises, bank_df; figure=fig_attr(1, 1.1), start = 1/6, show_firms=false, add_legend=true)
end

# ╔═╡ 82f1b9c3-306d-416a-bb2f-7171c93693dc
TwoColumns(md_fig, fig, 62)

# ╔═╡ 73ba4210-d8f6-4a74-bf4d-d7bc0902bb5e
TwoColumns(md"""
* I. Model setup
* II. **insolvency** and **bankruptcy** in the payment equilibrium
* III. **financial contagion**
* IV. **stability** and **resilience** of financial networks
  * more interbank lending leads to higher fragility
  * densely connected networks are **robust, yet fragile**
  * with **big shocks**, we want to have **disconnected components**
* V. Empirical relevance, Outlook

""", fig, 65)

# ╔═╡ 0d18cdf0-441e-4ca9-98e3-50bc3efa837f
let
	i = i_T1
	IM = IM_T1
	ε = ε_T1
	
	n_banks = nv(IM)

	ν = 3.0
	c = 0.0
	ζ = 0.1
	A = 3.5
	a = 3.0

	
	shares = I(n_banks)
	
	banks = [(; ν, c = c) for i ∈ 1:n_banks]

	firm = (; ζ, a, A)
	εs = zeros(n_banks)
	εs[i] = min(ε, a)
	
	(; bank_df) = equilibrium(banks, IM, firm, εs)

	layout = (_) -> componentwise_circle([1:6, 6 .+ (1:5)])
	
	fig = visualize_bank_firm_network(IM, bank_df; figure=fig_attr(1.6, 1.0), hidespines=false, start = 1/6, layout, add_legend=true, show_firms=false)

	rowgap!(fig.layout, 1)
	
	fig
end

# ╔═╡ a9d27019-72b7-4257-b72a-12952b516db9
tool_fig = let
	i = i_bank_T2
	#_ε4 = 0.4
	IM = IM_T2
	n_banks = nv(IM)

	ν = 3.0
	c = 0.0
	ζ = 0.0
	A = 0.0
	a = 3.5
	ε = ε_T2
	
	shares = I(n_banks)
	
	banks = [(; ν, c) for i ∈ 1:n_banks]

	firm = (; ζ, a, A)
	εs = zeros(n_banks)
	εs[i] = min(ε, a)
	
	(; bank_df) = equilibrium(banks, IM, firm, εs)

	layout = Shell()
	
	visualize_bank_firm_network(IM, bank_df; figure=fig_attr(1.4, 0.8), hidespines=false, start = 1/6, layout, add_legend=:vertical, show_firms=false)
end

# ╔═╡ 0fb4d187-f03a-435b-b9fc-188925e058f1
TwoColumns(tool_text, tool_fig, 60)

# ╔═╡ 3496c181-c4c3-4b1b-a5e5-83df27182c99
md"""
## `LaTeXStrings` as `bar_labels`
"""

# ╔═╡ b54dc329-7764-41e6-8716-ef20bef0b29b
md"""
## Assignment infrastructure
"""

# ╔═╡ cc9d4ea3-4d1b-4f6e-8d49-77fec05e2804
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
end

# ╔═╡ 1d8be056-aa73-4491-8d6e-57502ccc48be
members = let
	names = map(group_members) do (; firstname, lastname)
		firstname * " " * lastname
	end
	join(names, ", ", " & ")
end

# ╔═╡ 048d7ac7-204c-4bb4-aea0-612af18bb6d2
md"""
*Assignment submitted by* **$members** (*group $(group_number)*)
"""

# ╔═╡ 5ef89a83-8c7c-4fcd-8498-9c2f452a13c8
function wordcount(text)
	stripped_text = strip(replace(string(text), r"\s" => " "))
   	words = split(stripped_text, (' ', '-', '.', ',', ':', '_', '"', ';', '!', '\''))
   	length(filter(!=(""), words))
end

# ╔═╡ 0a0c51ec-9443-4901-a3db-f205c4e94e99
@test wordcount("  Hello,---it's me.  ") == 4

# ╔═╡ 01f0e271-acb6-44f8-85c5-ada44f8d401b
@test wordcount("This;doesn't really matter.") == 5

# ╔═╡ 8ed4dff0-c0b5-4247-a779-59ef7aa500a1
show_words(answer) = md"_approximately $(wordcount(answer)) words_"

# ╔═╡ b5a91cd7-6e0b-4690-9dfa-36a2986ac8db
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
DataAPI = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
DataFrameMacros = "75880514-38bc-4a95-a458-c2aea5a3a702"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
GraphMakie = "1ecd5474-83a3-4783-bb4f-06765db800d2"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
NamedTupleTools = "d9ec5142-1e00-5aa0-9d6a-321866360f50"
NetworkLayout = "46757867-2c16-5918-afeb-47bfcb05e46a"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Roots = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"

[compat]
AlgebraOfGraphics = "~0.6.18"
CairoMakie = "~0.11.8"
CategoricalArrays = "~0.10.8"
Chain = "~0.5.0"
Colors = "~0.12.10"
DataAPI = "~1.16.0"
DataFrameMacros = "~0.4.1"
DataFrames = "~1.6.1"
GeometryBasics = "~0.4.10"
GraphMakie = "~0.5.9"
Graphs = "~1.9.0"
HypertextLiteral = "~0.9.5"
LaTeXStrings = "~1.3.1"
Makie = "~0.20.7"
MarkdownLiteral = "~0.1.1"
NamedTupleTools = "~0.14.3"
NetworkLayout = "~0.4.6"
PlutoTeachingTools = "~0.2.14"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.58"
Roots = "~2.1.2"
SimpleWeightedGraphs = "~1.4.0"
StatsBase = "~0.34.2"
StructArrays = "~0.6.17"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.1"
manifest_format = "2.0"
project_hash = "b109112e619bbe1d886583b3949f6c890f570483"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "InverseFunctions", "LinearAlgebra", "MacroTools", "Markdown"]
git-tree-sha1 = "b392ede862e506d451fc1616e79aa6f4c673dab8"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.38"

    [deps.Accessors.extensions]
    AccessorsAxisKeysExt = "AxisKeys"
    AccessorsDatesExt = "Dates"
    AccessorsIntervalSetsExt = "IntervalSets"
    AccessorsStaticArraysExt = "StaticArrays"
    AccessorsStructArraysExt = "StructArrays"
    AccessorsTestExt = "Test"
    AccessorsUnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    Requires = "ae029012-a4dd-5104-9daa-d747884805df"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "50c3c56a52972d78e8be9fd135bfb91c9574c140"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.1.1"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AdaptivePredicates]]
git-tree-sha1 = "7e651ea8d262d2d74ce75fdf47c4d63c07dba7a6"
uuid = "35492f91-a3bd-45ad-95db-fcad7dcfedb7"
version = "1.2.0"

[[deps.AlgebraOfGraphics]]
deps = ["Colors", "Dates", "Dictionaries", "FileIO", "GLM", "GeoInterface", "GeometryBasics", "GridLayoutBase", "KernelDensity", "Loess", "Makie", "PlotUtils", "PooledArrays", "PrecompileTools", "RelocatableFolders", "StatsBase", "StructArrays", "Tables"]
git-tree-sha1 = "215a2dc9a286831bdad694475357619a9d99698d"
uuid = "cbdf2221-f076-402e-a563-3d30da359d67"
version = "0.6.20"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e092fa223bf66a3c41f9c022bd074d916dc303e7"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Automa]]
deps = ["PrecompileTools", "SIMD", "TranscodingStreams"]
git-tree-sha1 = "a8f503e8e1a5f583fbef15a8440c8c7e32185df2"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "1.1.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "8873e196c2eb87962a2048b3b8e08946535864a1"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+2"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"
version = "1.11.0"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "71aa551c5c33f1a4415867fe06b7844faadb0ae9"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.1.1"

[[deps.CairoMakie]]
deps = ["CRC32c", "Cairo", "Colors", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "PrecompileTools"]
git-tree-sha1 = "d69c7593fe9d7d617973adcbe4762028c6899b2c"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.11.11"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "1568b28f91293458345dabba6a5ea3f183250a61"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.8"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.Chain]]
git-tree-sha1 = "8c4920235f6c561e401dfe569beb8b924adad003"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.5.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "3e4b134270b372f2ed4d4d0e936aabaefc1802bc"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "7eee164f122511d3e4e1ebadb7956939ea7e1c77"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.6"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "c785dfb1b3bfddd1da557e861b919819b82bbe5b"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.27.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.CommonMark]]
deps = ["Crayons", "PrecompileTools"]
git-tree-sha1 = "3faae67b8899797592335832fccf4b3c80bb04fa"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.15"

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrameMacros]]
deps = ["DataFrames", "MacroTools"]
git-tree-sha1 = "5275530d05af21f7778e3ef8f167fb493999eea1"
uuid = "75880514-38bc-4a95-a458-c2aea5a3a702"
version = "0.4.1"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DelaunayTriangulation]]
deps = ["AdaptivePredicates", "EnumX", "ExactPredicates", "PrecompileTools", "Random"]
git-tree-sha1 = "ffc2e0358599a6a0db3a5c0142a9fa3dc5694f65"
uuid = "927a84f5-c5f4-47a5-9785-b46e178433df"
version = "1.6.2"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "61ab242274c0d44412d8eab38942a49aa46de9d0"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.4.3"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "c7e3a542b999843086e2f29dac96a618c105be1d"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.12"
weakdeps = ["ChainRulesCore", "SparseArrays"]

    [deps.Distances.extensions]
    DistancesChainRulesCoreExt = "ChainRulesCore"
    DistancesSparseArraysExt = "SparseArrays"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "3101c32aab536e7a27b1763c0797dba151b899ad"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.113"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.ExactPredicates]]
deps = ["IntervalArithmetic", "Random", "StaticArrays"]
git-tree-sha1 = "b3f2ff58735b5f024c392fde763f29b057e4b025"
uuid = "429591f6-91af-11e9-00e2-59fbe8cec110"
version = "2.2.8"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc5231d52eb1771251fbd37171dbc408bcc8a1b6"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.4+0"

[[deps.Extents]]
git-tree-sha1 = "81023caa0021a41712685887db1fc03db26f41f5"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.4"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "8cc47f299902e13f90405ddb5bf87e5d474c0d38"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "6.1.2+0"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "4820348781ae578893311153d69049a93d05f39d"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.8.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4d81ed14783ec49ce9f2e168208a12ce1815aa25"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+1"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "2dd20384bf8c6d411b5c7370865b1e9b26cb2ea3"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.6"

    [deps.FileIO.extensions]
    HTTPExt = "HTTP"

    [deps.FileIO.weakdeps]
    HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "7878ff7172a8e6beedd1dea14bd27c3c6340d361"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.22"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "db16beca600632c95fc8aca29890d83788dd8b23"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.96+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "907369da0f8e80728ab49c1c7e09327bf0d6d999"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.1.1"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "fa8e19f44de37e225aa0f1695bc223b05ed51fb4"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.3+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "d52e255138ac21be31fa633200b65e4e71d26802"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.6"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1ed150b39aebcc805c26b93a8d0122c940f64ce2"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.14+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "273bd1cd30768a2fddfa3fd63bbc746ed7249e5f"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.9.0"

[[deps.GeoFormatTypes]]
git-tree-sha1 = "59107c179a586f0fe667024c5eb7033e81333271"
uuid = "68eda718-8dee-11e9-39e7-89f7f65f511f"
version = "0.4.2"

[[deps.GeoInterface]]
deps = ["Extents", "GeoFormatTypes"]
git-tree-sha1 = "826b4fd69438d9ce4d2b19de6bc2f970f45f0f88"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.8"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "Extents", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "b62f2b2d76cee0d61a2ef2b3118cd2a3215d3134"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.11"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Giflib_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0224cce99284d997f6880a42ef715a37c99338d1"
uuid = "59f7168a-df46-5410-90c8-f2779963d0ec"
version = "5.2.2+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "674ff0db93fffcd11a3573986e550d66cd4fd71f"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.80.5+0"

[[deps.GraphMakie]]
deps = ["DataStructures", "GeometryBasics", "Graphs", "LinearAlgebra", "Makie", "NetworkLayout", "PolynomialRoots", "SimpleTraits", "StaticArrays"]
git-tree-sha1 = "bdddc4afd944ccc67afbd81791d88d944c36f410"
uuid = "1ecd5474-83a3-4783-bb4f-06765db800d2"
version = "0.5.10"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "a641238db938fff9b2f60d08ed9030387daf428c"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.3"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "01979f9b37367603e2848ea225918a3b3861b606"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+1"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "899050ace26649433ef1af25bc17a815b3db52b7"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.9.0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "6f93a83ca11346771a93bbde2bdad2f65b61498f"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.10.2"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "401e4f3f30f43af2c8478fc008da50096ea5240f"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.3.1+0"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "b1c2585431c382e3fe5805874bda6aea90a95de9"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.25"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "e12629406c6c4442539436581041d372d69c55ba"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.12"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "8c193230235bbcee22c8066b0374f63b5683c2d3"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.5"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs", "WebP"]
git-tree-sha1 = "696144904b76e1ca433b886b4e7edd067d76cbf7"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.9"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "2a81c3897be6fbcde0802a0ebe6796d0562f63ec"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.10"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0936ba688c6d201805a83da835b55c61a180db52"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.11+0"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InlineStrings]]
git-tree-sha1 = "45521d31238e87ee9f9732561bfee12d4eebd52d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.2"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "10bd689145d2c3b2a9844005d01087cc1194e79e"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2024.2.1+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "88a101217d7cb38a7b481ccd50d21876e1d1b0e0"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.15.1"

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

    [deps.Interpolations.weakdeps]
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.IntervalArithmetic]]
deps = ["CRlibm_jll", "LinearAlgebra", "MacroTools", "RoundingEmulator"]
git-tree-sha1 = "24c095b1ec7ee58b936985d31d5df92f9b9cfebb"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "0.22.19"

    [deps.IntervalArithmetic.extensions]
    IntervalArithmeticDiffRulesExt = "DiffRules"
    IntervalArithmeticForwardDiffExt = "ForwardDiff"
    IntervalArithmeticIntervalSetsExt = "IntervalSets"
    IntervalArithmeticRecipesBaseExt = "RecipesBase"

    [deps.IntervalArithmetic.weakdeps]
    DiffRules = "b552c78f-8df3-52c6-915a-8e097449b14b"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

    [deps.IntervalSets.weakdeps]
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "be3dc50a92e5a386872a493a10050136d4703f9b"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "fa6d0bcff8583bac20f1ffa708c3913ca605c611"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.5"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "25ee0be4d43d0269027024d75a24c24d6c6e590c"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.4+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "10da5154188682e5c0726823c2b5125957ec3778"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.38"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "7d703202e65efa1369de1279c162b915e245eed1"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.9"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "36bdbc52f13a7d1dcb0f3cd694e01677a515655b"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "854a9c268c43b77b0a27f22d7fab8d33cdb3a731"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.2+1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"
version = "1.11.0"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "8be878062e0ffa2c3f67bb58a595375eda5de80b"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.0+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c6ce1e19f3aec9b59186bdf06cdf3c4fc5f5f3e6"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.50.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "61dfdba58e585066d8bce214c5a51eaa0539f269"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "84eef7acd508ee5b3e956a2ae51b05024181dee0"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.2+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "b404131d06f7886402758c9ce2214b636eb4d54a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5ee6203157c120d79034c748a2acba45b82b8807"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.1+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "f749e7351f120b3566e5923fefdf8e52ba5ec7f9"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.6.4"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "688d6d9e098109051ae33d126fcfc88c4ce4a021"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "3.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "oneTBB_jll"]
git-tree-sha1 = "f046ccd0c6db2832a9f639e2c669c6fe867e5f4f"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2024.2.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Makie]]
deps = ["Animations", "Base64", "CRC32c", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "DelaunayTriangulation", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG_jll", "FileIO", "FilePaths", "FixedPointNumbers", "Format", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "InteractiveUtils", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MacroTools", "MakieCore", "Markdown", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "PrecompileTools", "Printf", "REPL", "Random", "RelocatableFolders", "Scratch", "ShaderAbstractions", "Showoff", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun"]
git-tree-sha1 = "4d49c9ee830eec99d3e8de2425ff433ece7cc1bc"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.20.10"

[[deps.MakieCore]]
deps = ["Observables", "REPL"]
git-tree-sha1 = "248b7a4be0f92b497f7a331aed02c1e9a878f46b"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.7.3"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MarkdownLiteral]]
deps = ["CommonMark", "HypertextLiteral"]
git-tree-sha1 = "0d3fa2dd374934b62ee16a4721fe68c418b92899"
uuid = "736d6165-7244-6769-4267-6b50796e6954"
version = "0.1.1"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "UnicodeFun"]
git-tree-sha1 = "96ca8a313eb6437db5ffe946c457a401bbb8ce1d"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.5.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NamedTupleTools]]
git-tree-sha1 = "90914795fc59df44120fe3fff6742bb0d7adb1d0"
uuid = "d9ec5142-1e00-5aa0-9d6a-321866360f50"
version = "0.14.3"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "StaticArrays"]
git-tree-sha1 = "0c51e19351dc1eecc61bc23caaf2262e7ba71973"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.7"
weakdeps = ["Graphs"]

    [deps.NetworkLayout.extensions]
    NetworkLayoutGraphsExt = "Graphs"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "1a27764e945a152f7ca7efa04de513d473e9542e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.14.1"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "97db9e07fe2091882c765380ef58ec553074e9c7"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.3"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "8292dd5c8a38257111ada2174000a33745b06d4e"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.2.4+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7493f61f55a6cce7325f197443aa80d32554ba10"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+1"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "67186a2bc9a90f9f85ff3cc8277868961fb57cbd"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.3"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "bc5bf2ea3d5351edf285a06b0016788a121ce92c"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.5.1"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e127b609fb9ecba6f201ba7ab753d5a605d53801"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.54.1+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "5d9ab1a4faf25a62bb9d07ef0003396ac258ef1c"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.15"

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PolynomialRoots]]
git-tree-sha1 = "5f807b5345093487f733e520a1b7395ee9324825"
uuid = "3a141323-8675-5d76-9d11-e1df1406c778"
version = "1.0.0"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "1101cd475833706e4d0e7b122218257178f48f34"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "8f6bc219586aef8baf0ff9a5fe16ee9c70cb65e4"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.2"

[[deps.PtrArrays]]
git-tree-sha1 = "77a42d78b6a92df47ab37e177b2deac405e1c88f"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.2.1"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "8b3fc30bc0390abdce15f8822c889f669baed73d"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "cda3b045cf9ef07a08ad46731f5a3165e56cf3da"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.1"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "470f48c9c4ea2170fd4d0f8eb5118327aada22f5"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.6.4"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.Roots]]
deps = ["Accessors", "ChainRulesCore", "CommonSolve", "Printf"]
git-tree-sha1 = "48a7925c1d971b03bb81183b99d82c1dc7a3562f"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.1.8"

    [deps.Roots.extensions]
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"

    [deps.Roots.weakdeps]
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "52af86e35dd1b177d051b12681e1c581f53c281b"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "d0553ce4031a081cc42387a9b9c8441b7d99f32d"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.7"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "79123bc60c5507f035e6d1d9e563bb2971954ec8"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.4.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

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
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays"]
git-tree-sha1 = "4b33e0e081a825dbfaf314decf58fa47e53d6acb"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.4.0"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2da10356e31327c7096832eb9cd86307a50b1eb6"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "2f5d4697f21388cbe1ff299430dd169ef97d7e14"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.4.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "777657803913ffc7e8cc20f0fd04b634f871af8f"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.8"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"
weakdeps = ["ChainRulesCore", "InverseFunctions"]

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsAPI", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "9022bcaa2fc1d484f1326eaa4db8db543ca8c66d"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.7.4"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a6b1675a536c5ad1a60e5a5153e1fee12eb146e3"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.0"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "9537ef82c42cdd8c5d443cbc359110cbb36bae10"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.21"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = ["GPUArraysCore", "KernelAbstractions"]
    StructArraysLinearAlgebraExt = "LinearAlgebra"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "0248b1b2210285652fbc67fd6ced9bf0394bcfec"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.11.1"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WebP]]
deps = ["CEnum", "ColorTypes", "FileIO", "FixedPointNumbers", "ImageCore", "libwebp_jll"]
git-tree-sha1 = "aa1ca3c47f119fbdae8770c29820e5e6119b83f2"
uuid = "e3aaa7dc-3e4b-44e0-be63-ffb868ccd7c1"
version = "0.1.3"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c1a7aa6219628fcd757dede0ca95e245c5cd9511"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.0.0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "a2fccc6559132927d4c5dc183e3e01048c6dcbd6"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.5+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "a54ee957f4c86b526460a720dbc882fa5edcbefc"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.41+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "15e637a697345f6743674f1322beefbc5dcd5cfc"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.6.3+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d2d1a5c49fae4ba39983f63de6afcbea47194e85"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "47e45cd78224c53109495b3e324df0c37bb61fbe"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+0"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "bcd466676fef0878338c61e655629fa7bbc69d8e"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "555d1076590a6cc2fdee2ef1469451f872d8b41b"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.6+1"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1827acba325fdcdf1d2647fc8d5301dd9ba43a9d"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.9.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "b70c870239dc3d7bc094eb2d6be9b73d27bef280"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.44+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "7dfa0fd9c783d3d0cc43ea1af53d69ba45c447df"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+1"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.libwebp_jll]]
deps = ["Artifacts", "Giflib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libglvnd_jll", "Libtiff_jll", "libpng_jll"]
git-tree-sha1 = "ccbb625a89ec6195856a50aa2b668a5c08712c94"
uuid = "c5f90fcd-3b7e-5836-afba-fc50a0988cb2"
version = "1.4.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.oneTBB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7d0ea0f4895ef2f5cb83645fa689e52cb55cf493"
uuid = "1317d2d5-d96f-522e-a858-c73665f53c3e"
version = "2021.12.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "35976a1216d6c066ea32cba2150c4fa682b276fc"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.0+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "dcc541bb19ed5b0ede95581fb2e41ecf179527d2"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.6.0+0"
"""

# ╔═╡ Cell order:
# ╟─048d7ac7-204c-4bb4-aea0-612af18bb6d2
# ╟─639f04a2-0979-41e2-b465-a4f52049166d
# ╟─52052d98-0c41-45ec-95bf-d936b1c43e81
# ╟─ab239918-1cde-4d6b-ac7f-716aaba5f39b
# ╟─248909ee-2312-4e28-928a-ec65c0eec8a2
# ╟─94e1ac76-3099-4e33-b987-e7f0cf365399
# ╟─cdfc35e1-5082-4959-9d30-3abb2dc8a7ac
# ╟─944b07ed-20e5-4068-ac5e-8a48f866fdd2
# ╟─82f1b9c3-306d-416a-bb2f-7171c93693dc
# ╟─7b876239-8ddc-4929-ad52-752edb72c0eb
# ╠═e11a99df-d0f2-4838-b325-473d3043be98
# ╠═1d5d8c8a-8d86-426f-bb17-bd2279d91ff1
# ╠═8347ab1d-f45e-4434-a8b7-60fa3918c97c
# ╠═073982c7-6333-43f6-866a-91a49f8ba7eb
# ╠═8ada8545-243e-4922-a306-ffff866a6135
# ╠═8a2f3e4d-9c61-4a21-a229-58f731964181
# ╟─cd766ddf-e5a9-4c72-b884-413eae45c4c5
# ╟─73ba4210-d8f6-4a74-bf4d-d7bc0902bb5e
# ╟─eba94b09-f061-432a-80ce-a68be83e6a99
# ╟─bafc7db1-ac1d-4314-be83-0b9f6c63b5fc
# ╠═ba39c037-c4e1-465e-a232-e5194caa14ba
# ╟─acfdf348-e8bf-41ee-aa19-fe7ec29087cc
# ╠═834ff5a0-3bae-44ca-a413-f45d3394b511
# ╠═2f69a836-7fed-42e6-a509-096bc8cabbc2
# ╠═26a5c4f4-75c1-4a4c-a813-5fad0c571da1
# ╠═5d283f89-4419-4b14-81ba-9826b4f1689e
# ╟─a0ac4092-cd27-4523-85f9-f4a4d81456b3
# ╟─01eb57fd-a815-41f2-9e25-7730bff7917d
# ╟─523e177c-f74d-4805-8a2b-9c27a4b0bc63
# ╠═4ae1b6c2-bb63-4ca8-b8ec-057c8d2a371f
# ╠═5f8c9ead-7598-452f-84b0-9189866aa200
# ╠═efbc1a42-ecc2-4907-a981-bd1d29ca0803
# ╟─7f058e4a-9b12-41c9-9fd7-4ad023058a14
# ╟─44ee4809-64ba-40dc-89ec-ae4f852535a8
# ╟─e2041c57-0e3d-4dad-9bab-d70434f18509
# ╠═aaffd333-3aa1-48ee-b5db-d577bd7da830
# ╠═5012c275-8157-4488-b868-f45c92d43100
# ╠═a8a8a197-d54d-4c67-b7ce-19bdc8b64401
# ╟─da7c558d-a2b5-41a8-9c78-3e39a00dfd31
# ╟─bf719f30-72c1-488e-ba77-c183effb7c60
# ╟─a0767d80-0857-47ef-90a1-72bc34064716
# ╠═c920d82c-cfe9-462a-bacd-436f01c314cf
# ╟─72e5f4d3-c3e4-464d-b35c-2cf19fa9d4b5
# ╟─d6345a8b-6d8f-4fd2-972b-199412cbdc26
# ╟─c99e52e2-6711-4fb6-bcc0-8e4f378ed479
# ╟─15f45669-516b-4f3f-9ec1-f9e2c1d2e71a
# ╟─d7111001-f632-4d0d-a2c7-7bbfd67bf87d
# ╟─0d18cdf0-441e-4ca9-98e3-50bc3efa837f
# ╟─51bfc57f-7b06-4e27-af32-51df38af30a1
# ╠═b817cdf6-dfe6-4607-98da-2299a33d4906
# ╟─07e9c77f-e05e-452c-8c47-cdd9dfc8e2fc
# ╠═f5293bee-9413-4507-8568-54836eb6d4a2
# ╟─49c2fb2d-de6e-4ab2-a558-59fb153cf703
# ╠═c0c711de-6916-4ab9-ab73-c476654332c4
# ╟─a95431eb-14a0-4dc3-bbe6-9c409f6cc596
# ╟─c7b99d3c-5d32-45e6-84fa-8a6513e6beb9
# ╟─f00d9e1a-b111-4b6a-95f5-b9736329befe
# ╟─f8eb242f-a974-48aa-9173-b0bc7ff697d5
# ╠═c2633df1-2e30-4387-8749-de3280b0602d
# ╟─253ab06f-6284-4cbf-b2a2-232ff99548c9
# ╠═1d058f8b-16f5-4744-8425-452876006c47
# ╟─0fb4d187-f03a-435b-b9fc-188925e058f1
# ╟─27fadf93-0b17-446e-8001-d8394b7befaa
# ╠═aed99485-cec3-4bf3-b05d-4d20572ec907
# ╠═db841316-9106-40bb-9ca3-ae6f8b975404
# ╟─900a4b24-04dc-4a1b-9829-a166cf9eb7fb
# ╟─eda3fdcc-a3b4-47d2-bdab-8c1c673a7a15
# ╠═a9d27019-72b7-4257-b72a-12952b516db9
# ╟─2c839d92-183a-4077-b7d6-39ac485ae06e
# ╟─4e9b785f-ad74-4aa8-ad48-89fa8b236939
# ╠═1a997e44-f29c-4c55-a953-a9039f096d47
# ╟─78bedfcc-3671-4852-985b-3e1b5aaade5a
# ╠═0f03f537-f589-4abd-9587-0bb18835d9b9
# ╟─25e84f19-9cd8-43ad-ae6a-d500b8ac74b6
# ╠═74262581-3c64-4e5b-9328-416c4e1efc91
# ╠═103babf9-bbc3-4c77-9185-72f792a09706
# ╠═bb0e41cf-66fb-4cae-8cd9-6ad771d1acf4
# ╠═935da683-a4e2-4ddc-999f-55cb61390f39
# ╠═6172ebbe-8a27-4c1c-bf5c-5a6e7357447a
# ╠═2d1da571-0561-4c28-bb63-35ca5f9538d5
# ╠═7c068d65-f472-44c2-af56-581bf9309bd5
# ╠═631ce85b-db76-4f3b-bda5-0c51ffb3bc43
# ╠═fa01788e-7585-4f3f-93b2-a44541065820
# ╠═6a89953d-310b-49c9-89e1-8d51c8b75be0
# ╠═50ac0182-32fe-4e21-8c6d-895ffc67ec27
# ╠═8b75bc15-e07b-43e5-adb3-c5d6481ee9d8
# ╟─11d6ac4f-e910-4a9f-9ee4-bdd270e9400b
# ╠═c1b1a22b-8e18-4d19-bb9b-14d2853f0b72
# ╠═cc1ff1e6-2968-4baf-b513-e963ab2ff1b4
# ╠═c65323f5-211d-4a95-aed3-d6129bdd083e
# ╠═5d263432-856b-4e9b-a303-a476222e8963
# ╠═73c87a80-8bd9-4040-8a09-519f1a73f7c0
# ╠═76482e5e-418a-4102-8a62-cae3c0cb88d4
# ╟─25a01039-25e9-44b0-afd0-c3df37c7598f
# ╟─71231141-c2f5-4695-ade0-548a0039f511
# ╠═c993c1d8-8823-4db4-bf6e-bf2c21ea3d39
# ╟─f24387ee-c1cf-4ec0-a34e-4b4f33ee9010
# ╠═954d2dde-8088-4e91-bed3-f8339090b77b
# ╠═2872c686-8e4f-4230-a07a-5d988aba39b7
# ╠═3198bb79-f0c7-4b01-8dce-ef7629e8d7e6
# ╠═e9365f8d-6f58-458c-855d-c0444c6f409f
# ╟─fbf40f06-f63a-40ca-bbe3-78104d39ee71
# ╠═f863066f-270f-4972-8046-7f51cb697ac5
# ╠═d285879a-bdfd-4efa-aa5d-9dacf08a2dc6
# ╠═70bbb90e-06f1-4b60-a952-275866945c58
# ╟─3040803d-e95a-40bc-aa72-92c7d158e226
# ╟─f13e010a-d394-4e40-9535-c5e2e3e226aa
# ╠═9cdc97e5-67f8-4e71-97d8-9cda5e9d7bd8
# ╠═601b1453-20bd-4e93-abb7-4fad4f5adf8c
# ╠═955c190a-1d00-4c78-bdfb-daac31edf76f
# ╠═7871b479-2aaf-42c1-ad84-42ac17cfc6e1
# ╟─7c026a42-1c05-4968-b068-c8561ca5a2db
# ╠═7b70a862-faf4-4c42-917c-238718c43708
# ╠═fc01674e-73de-4cbf-9c80-fa1ea47fcb21
# ╠═78965848-8694-4665-80c6-94191a95f95d
# ╠═1016a42f-cd4c-40f5-b359-186df8440c37
# ╠═222665dc-397b-4e58-b3ee-935b115cf13d
# ╠═3998e822-d7e0-40f2-a866-71a3d81c4ca3
# ╟─0d207cbe-5b97-4bd7-accf-fc49ce4522e9
# ╠═ebf41ae2-3985-439b-b193-eabfab701d16
# ╠═b7d74679-904c-44c4-bedd-89f1b68a5e42
# ╠═1b9c8f2b-8011-46f1-b46d-479031eb9ac3
# ╠═3033ae5a-bada-4041-858d-a61c62bdc8b8
# ╠═5104f0a5-a551-4f4c-8f89-2b8f834b3587
# ╠═f63aee78-1209-40dd-9c9d-2699194807d8
# ╠═6a2b3b9c-df52-41c3-908b-5dbf052ad107
# ╠═ab1cf7ab-80fb-4423-a924-1d6e24e9c9bc
# ╠═0ff81eb8-d843-49a4-af93-ec2414797e87
# ╟─ffe50130-a9cb-4ba9-a861-c247bf688873
# ╟─d3e5b8f2-51b1-4ba4-97b4-2be156a74643
# ╠═00a4054a-dd10-4c5c-ae20-c0dc176e8e18
# ╠═d5c128e0-6371-4ad2-8bfc-c17faadc520b
# ╠═38a1f960-7178-4968-89e4-6b659b64baa2
# ╠═f689810f-8f43-4368-a822-0ee4f3015271
# ╠═5bde1113-5297-4e93-b052-7a0f93f4ea84
# ╠═73456a8f-8534-4b55-8af6-ff7952bd3a3a
# ╠═e6def365-4438-4591-acbd-60d9de466b0a
# ╠═055a811c-bc4a-4959-88f1-bc71e8749313
# ╠═e2045a53-21d3-4c7c-ad95-3fc8d2444821
# ╠═3c211dad-73b0-4715-b066-e10005f8f3a7
# ╠═ee10e134-84be-41f8-9e7e-c1cd68227977
# ╠═2a5f02e7-fec1-41b3-b8b4-b33b1cc1232c
# ╠═47118d1b-8471-4288-85fe-d3e94667dc96
# ╠═dffce961-6844-4a44-beea-ab085c2f9f3f
# ╠═f708e6c0-cfac-4b4d-a3ed-69b98883294a
# ╠═d6cb95c1-a075-4544-9031-58aef65c7577
# ╠═1bb841e0-ddd2-4571-83a5-d929e0a8a69c
# ╠═7fbcfbde-0b5e-4bf2-9eda-9b15a4dd6bec
# ╟─ff77f7b4-52d1-4fc8-abfc-e623f7bcd423
# ╠═c7c8581c-e82c-428e-a599-3c003cc0151c
# ╠═7d2d3618-7810-444d-90c0-0d592f8eba8c
# ╠═12968f5e-6e75-4429-bff8-0d1c644330a7
# ╟─2c22e86e-1139-4f66-8992-093d38f4c6cb
# ╠═60293fac-4d20-409b-bfd2-d5283f189320
# ╠═bef59a5b-6952-42aa-b700-4ad81d848fe4
# ╠═ce563ab5-6324-4a86-be61-7a107ff0e3b3
# ╟─3496c181-c4c3-4b1b-a5e5-83df27182c99
# ╠═8f15ccf5-860a-47ca-b5c2-842c4e6f861a
# ╠═3758f272-297c-4325-9a7c-042b4f41d615
# ╠═a349099a-64aa-4e86-9bf2-b6157feff394
# ╠═c4032c7a-73f4-4342-a5a7-19fd14017402
# ╟─b54dc329-7764-41e6-8716-ef20bef0b29b
# ╠═cc9d4ea3-4d1b-4f6e-8d49-77fec05e2804
# ╠═1d8be056-aa73-4491-8d6e-57502ccc48be
# ╠═5ef89a83-8c7c-4fcd-8498-9c2f452a13c8
# ╠═c9775558-94f2-4c8c-9d0e-ab948fa5ead4
# ╠═0a0c51ec-9443-4901-a3db-f205c4e94e99
# ╠═01f0e271-acb6-44f8-85c5-ada44f8d401b
# ╠═8ed4dff0-c0b5-4247-a779-59ef7aa500a1
# ╠═b5a91cd7-6e0b-4690-9dfa-36a2986ac8db
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
