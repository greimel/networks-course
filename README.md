# Economic and Financial Network Analysis (Spring 2021)

This repository hosts some of the material for the course "Economic and Financial Network Analysis" at the University of Amsterdam.

## Material

### Week 1
* Basic Julia ([preview](https://greimel.github.io/networks-course/notebooks/basic-julia.html), [download](https://greimel.github.io/networks-course/notebooks/basic-julia.jl))
* First Networks ([preview](https://greimel.github.io/networks-course/notebooks/first-networks.html), [download](https://greimel.github.io/networks-course/notebooks/first-networks.jl))
* TI Network (see Canvas)
* **Assignment 1**: A Twitter Network ([preview](https://greimel.github.io/networks-course/notebooks/assignment-twitter.html), [download](https://greimel.github.io/networks-course/notebooks/assignment-twitter.jl))

### Week 2
* Diffusion on Networks: Modeling Transmission of Disease (contains **Assignment 2**) ([preview](https://greimel.github.io/networks-course/notebooks/disease.html), [download](https://greimel.github.io/networks-course/notebooks/disease.jl))

## Software and setup

For this course we will use the modern programming language [Julia](https://www.julialang.org). It is a very young language that is gaining popularity pretty fast. Here are the reasons why we use it.

* it is easy to use 
* it is suitable for high performance computing [(see this TEDx talk by co-creator and MIT professor Alan Edelman)](https://www.youtube.com/watch?v=qGW0GT1rCvs&list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ&index=6&t=0s)
* it features Pluto notebooks, which are an excellent tool for learning and teaching

### How you get started

1. You can try it out here. Click on one of the links to run a notebook in the browser. No need to install anything. You get an instant preview of the notebook. Making the notebook runnable takes a while.

    *  [basic julia](https://greimel.github.io/networks-course/notebooks/basic-julia.html) (instant preview, 1:30 min until interactivity)
    *  [first networks](https://greimel.github.io/networks-course/notebooks/basic-julia.html) (instant preview, 7 min until interactivity)
       
<details> <summary> details ...  </summary>

* **Step 1: Preview.** After clicking on the link above you will see a preview of the notebook. 
* **Step 2: Make it runnable.** If you want to make it runnable click on the `run on binder` button.

![image](https://user-images.githubusercontent.com/6280307/105686842-04c74280-5ef8-11eb-8b3b-6d38bc35152c.png)

* **Step 3: Wait.**
  - For about a minute you'll see this status. In the background a julia environment is set up for you in the cloud. 

    ![image](https://user-images.githubusercontent.com/6280307/105684936-d8aac200-5ef5-11eb-840d-3a00cf06bbd1.png)

  - Then, the code is executed in cloud. This includes installing and loading all packages that are used in the nodebook. While this happens you see these vertical progress bars next to each code cell.
 
    ![image](https://user-images.githubusercontent.com/6280307/105687502-d138e800-5ef8-11eb-85bf-b77161a01e9e.png)

* **Step 4: Edit the code.** Place your cursor in a code cell, edit it, and execute. See how all dependent cells automatically update.

    ![image](https://user-images.githubusercontent.com/6280307/105688456-e82c0a00-5ef9-11eb-8325-0d806e77739d.png)

</details>

2. Install Julia and Pluto on your computer

    * Find a video with instructions [here](https://www.youtube.com/watch?v=OOjKEgbt8AI)
    * Find written instructions [here](https://computationalthinking.mit.edu/Fall20/installation/)
    * when you're done, open Pluto from Julia and paste https://github.com/greimel/networks-course/blob/main/notebooks/basic-julia.jl into the at Pluto welcome page as shown below.
    
      ![image](https://user-images.githubusercontent.com/6280307/105691049-09dac080-5efd-11eb-964c-8b78b9b86bc7.png)
