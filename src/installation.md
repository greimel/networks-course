---
title: "Software installation"
tags: ["welcome"]
order: 2
layout: "md.jlmd"
---

$(
    begin
        # Update together with the notebook package environment at the start of each semester.
        version = "1.13"

        nothing
    end
)

# First-time setup: Install Julia & Pluto

## Step 1: Install Julia $version

We install Julia with **juliaup**, the official Julia installer and version manager.

**Windows:** open the _Command Prompt_ and run

```
winget install --name Julia --id 9NJNWW8PVKMN -e -s msstore
```

**macOS and Linux:** open a _Terminal_ and run

```
curl -fsSL https://install.julialang.org | sh
```

Accept the default options. Then close the terminal, open a new one, and make Julia $version the version you use for this course:

<pre><code>juliaup add $(version)
juliaup default $(version)
</code></pre>

If anything goes wrong, see the instructions at [julialang.org/install](https://julialang.org/install/).

## Step 2: Run Julia

Type `julia` in a terminal and press ENTER. This starts the **Julia REPL**, the command-line interface to Julia. Make sure that you can execute `1 + 1`:

![image](https://user-images.githubusercontent.com/6933510/91439734-c573c780-e86d-11ea-8169-0c97a7013e8d.png)

*Make sure that you are able to launch Julia and calculate `1+1` before proceeding!*

## Step 3: Install [`Pluto`](https://github.com/fonsp/Pluto.jl)

Next we install [**Pluto**](https://github.com/fonsp/Pluto.jl), the notebook environment that we use during the course. Pluto is a Julia _programming environment_ designed for interactivity and quick experiments.

In the REPL you type _Julia commands_, and when you press ENTER, it runs, and you see the result.

To install Pluto, we want to run a _package manager command_. To switch from _Julia_ mode to _Pkg_ mode, type `]` (closing square bracket) at the `julia>` prompt:

<pre><code>
julia> ]

(&#64;v$(version)) pkg>
</code></pre>

The line turns blue and the prompt changes to `pkg>`, telling you that you are now in _package manager mode_. This mode allows you to do operations on **packages** (also called libraries).

To install Pluto, run the following (case sensitive) command to *add* (install) the package to your system by downloading it from the internet.
You only need to do this *once* for each installation of Julia:

<pre><code>
(&#64;v$(version)) pkg> add Pluto
</code></pre>

This might take a couple of minutes, so you can go get yourself a cup of tea!

![image](https://user-images.githubusercontent.com/6933510/91440380-ceb16400-e86e-11ea-9352-d164911774cf.png)

You can now close the terminal.

## Step 4: Use a modern browser: Mozilla Firefox or Google Chrome
We need a modern browser to view Pluto notebooks with. Firefox and Chrome work best.


# Second time: _Running Pluto & opening a notebook_
Repeat the following steps whenever you want to work on a notebook or an assignment.

## Step 1: Start Pluto

Start the Julia REPL, like you did during the setup. In the REPL, type:
```julia
julia> using Pluto

julia> Pluto.run()
```

![image](https://user-images.githubusercontent.com/6933510/91441094-eb01d080-e86f-11ea-856f-e667fdd9b85c.png)

The terminal tells us to go to `http://localhost:1234/` (or a similar URL). Let's open Firefox or Chrome and type that into the address bar.

![image](https://user-images.githubusercontent.com/6933510/199279574-4b1d0494-2783-49a0-acca-7b6284bede44.png)

If nothing happens in the browser the first time, close Julia and try again. And please let us know!

## Step 2a: Opening a notebook from the course website

This is the main menu - here you can create new notebooks, or open existing ones. The notebooks and assignments of this course are on this website. To open one of them, go to its page, and on the top right, click on the button that says "Edit or run this notebook". From these instructions, copy the notebook link, and paste it into the blue box in the Pluto main menu. Press ENTER, and select OK in the confirmation box.

![image](https://user-images.githubusercontent.com/6933510/91441968-6b750100-e871-11ea-974e-3a6dfd80234a.png)

The first time you open a notebook, Pluto installs the packages it needs. This can take several minutes.

**The first thing we will want to do is to save the notebook somewhere on our own computer; see below.**

## Step 2b: Opening an existing notebook file
When you launch Pluto for the second time, your recent notebooks will appear in the main menu. You can click on them to continue where you left off.

If you want to run a local notebook file that you have not opened before, then you need to enter its _full path_ into the blue box in the main menu. More on finding full paths in step 3.

## Step 3: Saving a notebook
We first need a folder to save our work in. Open your file explorer and create one.

Next, we need to know the _absolute path_ of that folder. Here's how you do that in [Windows](https://www.top-password.com/blog/copy-full-path-of-a-folder-file-in-windows/) and [macOS](https://www.josharcher.uk/code/find-path-to-folder-on-mac/).

For example, you might have:

- `C:\\Users\\yourname\\Documents\\networks\\` on Windows

- `/Users/yourname/Documents/networks/` on macOS

- `/home/yourname/Documents/networks/` on Linux

Now that we know the absolute path, go back to your Pluto notebook, and at the top of the page, click on _"Save notebook..."_.

![image](https://user-images.githubusercontent.com/6933510/91444741-77fb5880-e875-11ea-8f6b-02c1c319e7f3.png)

This is where you type the **new path+filename for your notebook**:

![image](https://user-images.githubusercontent.com/6933510/91444565-366aad80-e875-11ea-8ed6-1265ded78f11.png)

Click _Choose_.

Pluto saves your notebook automatically whenever you run a cell. You will find the notebook file (ending in `.jl`) in the folder you created.

## Step 4: Submitting an assignment

You submit an assignment as an **HTML export** of your notebook on Moodle.

1. Make sure that all cells have finished running and that your answers and figures are visible.
2. Click the export button on the top right of the notebook and choose **Static HTML**. Your browser downloads an `.html` file.
3. Open the downloaded file in your browser and check that it shows your answers.
4. Upload the `.html` file to the assignment on Moodle.
