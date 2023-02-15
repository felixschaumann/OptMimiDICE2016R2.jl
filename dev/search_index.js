var documenterSearchIndex = {"docs":
[{"location":"usage/#Using-OptMimiDICE2016R2","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"","category":"section"},{"location":"usage/#Software-Requirements","page":"Using OptMimiDICE2016R2","title":"Software Requirements","text":"","category":"section"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"You need to install Julia 1.1.0 or newer to run this model. You can download Julia from http://julialang.org/downloads/.","category":"page"},{"location":"usage/#Preparing-the-Software-Environment","page":"Using OptMimiDICE2016R2","title":"Preparing the Software Environment","text":"","category":"section"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"To install OptMimiDICE2016R2.jl, you need to run the following command at the julia package REPL:","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"pkg> add https://github.com/felixschaumann/OptMimiDICE2016R2.jl","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"Note: This will only work if you have not previously installed MimiDICE2016R2.jl, as they share the same package ID.","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"You probably also want to install the Mimi package into your julia environment, so that you can use some of the tools in there:","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"pkg> add Mimi","category":"page"},{"location":"usage/#Running-the-model","page":"Using OptMimiDICE2016R2","title":"Running the model","text":"","category":"section"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"The model uses the Mimi framework and it is highly recommended to read the Mimi documentation first to understand the code structure. For starter code on running the model just once, see the code in the file examples/main.jl.","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"The basic way to access a copy of the default OptMimiDICE2016R2 model is the following:","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"using OptMimiDICE2016R2\n\nm = OptMimiDICE2016R2.get_model()\nrun(m)","category":"page"},{"location":"usage/#Optimising-the-model","page":"Using OptMimiDICE2016R2","title":"Optimising the model","text":"","category":"section"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"work in progress","category":"page"},{"location":"usage/#Modifying-the-model","page":"Using OptMimiDICE2016R2","title":"Modifying the model","text":"","category":"section"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"work in progress","category":"page"},{"location":"usage/#Calculating-the-Social-Cost-of-Carbon","page":"Using OptMimiDICE2016R2","title":"Calculating the Social Cost of Carbon","text":"","category":"section"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"Here is an example of computing the social cost of carbon with OptMimiDICE2016R2. Note that the units of the returned value are 2010US/tCO2.","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"using Mimi\nusing OptMimiDICE2016\n\n# Get the social cost of carbon in year 2020 from the default OptMimiDICE2016 model:\nscc = OptMimiDICE2016.compute_scc(year = 2020)\n\n# You can also compute the SCC from a modified version of a OptMimiDICE2016 model:\nm = OptMimiDICE2016.get_model()    # Get the default version of the OptMimiDICE2016 model\nupdate_param!(m, :t2xco2, 5)    # Try a higher climate sensitivity value\nscc = OptMimiDICE2016.compute_scc(m, year = 2020)    # compute the scc from the modified model by passing it as the first argument to compute_scc","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"The first argument to the compute_scc function is a OptMimiDICE2016 model, and it is an optional argument. If no model is provided, the default OptMimiDICE2016 model will be used.  There are also other keyword arguments available to compute_scc. Note that the user must specify a year for the SCC calculation, but the rest of the keyword arguments have default values.","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"compute_scc(m = get_model(),  # if no model provided, will use the default OptMimiDICE2016 model\n    year = nothing,  # user must specify an emission year for the SCC calculation\n    last_year = 2510,  # the last year to run and use for the SCC calculation. Default is the last year of the time dimension, 2510.\n    prtp = 0.03,  # pure rate of time preference parameter used for constant discounting\n)","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"There is an additional function for computing the SCC that also returns the MarginalModel that was used to compute it. It returns these two values as a NamedTuple of the form (scc=scc, mm=mm). The same keyword arguments from the compute_scc function are available for the compute_scc_mm function. Example:","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"using Mimi\nusing OptMimiDICE2016\n\nresult = OptMimiDICE2016.compute_scc_mm(year=2030, last_year=2300, prtp=0.025)\n\nresult.scc  # returns the computed SCC value\n\nresult.mm   # returns the Mimi MarginalModel\n\nmarginal_temp = result.mm[:climatedynamics, :TATM]  # marginal results from the marginal model can be accessed like this","category":"page"},{"location":"usage/#Pulse-Size-Details","page":"Using OptMimiDICE2016R2","title":"Pulse Size Details","text":"","category":"section"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"By default, OptMimiDICE2016 will calculate the SCC using a marginal emissions pulse of 5 GtCO2 spread over five years, or 1 GtCO2 per year for five years.  The SCC will always be returned in $ per ton CO2 since is normalized by this pulse size. This choice of pulse size and duration is a decision made based on experiments with stability of results and moving from continuous to discretized equations, and can be found described further in the literature around DICE.","category":"page"},{"location":"usage/","page":"Using OptMimiDICE2016R2","title":"Using OptMimiDICE2016R2","text":"For a deeper dive into the machinery of this function, see the forum conversation here, which is focused on MimiFUND but has similar internal machinery to OptMimiDICE2016, and the docstrings in marginaldamage.jl.","category":"page"},{"location":"#Introduction","page":"Introduction","title":"Introduction","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"This repository is a fork of the MimiDICE2016R2.jl project by anthofflab. As the name suggests, this version adds an optimisation routine to MimiDICE2016R2, which is located in src/optimise.jl. Due to package compatibility issues, I do not use the OptiMimi framework, but instead I work with the NLOpt package. This implementation is inspired by the code for Budolfson et al. (2021).","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"This version is still provisional and untested. The documentation and testing is still work in progress.","category":"page"},{"location":"#Background-on-DICE","page":"Introduction","title":"Background on DICE","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"work in progess","category":"page"},{"location":"API/#API","page":"API","title":"API","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"OptMimiDICE2016R2 is an expanded version of MimiDICE2016R2. This means that every piece of code that works with MimiDICE should also work with OptMimiDICE - it is backwards-compatible. The introduced changes are merely additions that concern the optimisation of the DICE model.","category":"page"},{"location":"API/#Getting-the-model","page":"API","title":"Getting the model","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"The function OptMimiDICE2016R2.get_model is essentially unchanged, but listed here because it is central to using OptMimiDICE2016R2.","category":"page"},{"location":"API/","page":"API","title":"API","text":"OptMimiDICE2016R2.get_model","category":"page"},{"location":"API/#Main.OptMimiDICE2016R2.get_model","page":"API","title":"Main.OptMimiDICE2016R2.get_model","text":"get_model -> m::Model\n\nGets model as in standard Mimi API.\n\n\n\n\n\n","category":"function"},{"location":"API/#Optimising-the-model","page":"API","title":"Optimising the model","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"The two entirely new functions are listed below. optimise_model is exported by OptMimiDICE2016R2 and can hence be called from outside the module. construct_objective is called by optimise_model and is not exported.","category":"page"},{"location":"API/","page":"API","title":"API","text":"optimise_model\nconstruct_objective","category":"page"},{"location":"API/#optimise_model","page":"API","title":"optimise_model","text":"optimise_model(m::Model=get_model(); kwargs) -> (m::Model, diagnostic::Dict)\n\nOptimise DICE2016R2 model instance m and return the optimised and updated model together with diagnostic optimisation output.\n\nThe model instance m is not a mandatory argument. In case it is not provided, the function will use a newly constructed model from OptMimiDICE2016R2.get_model. It is worth manually passing a model instance if one wishes to optimise a modified version of DICE, e.g. with updated parameters or updated components.\n\nKeyword arguments:\n\nn_objectives::Int=length(model_years): number of objectives, which corresponds to the number of time steps in the model\nstop_time::Int=640: time in seconds after which optimisation routine stops, passed to NLopt.ftol_rel!\ntolerance::Float64=1e-6: tolerance requirement passed to NLopt.ftol_rel!\noptimization_algorithm::Symbol=:LN_SBPLX: algorithm passed to NLopt.ftol_rel!\nbackup_timesteps::Int=0: amount of time steps in model's time dimension before optimisation sets in\n\nNotes\n\nThis version of DICE only allows for NETs after 2150, and it immediately allows for a 120% emissions reduction rate (:MIU=1.2, meaning 20% NETs) in 2155. This constraint can be modified by changing the first half of the upper_bound vector.\nThe second return value is purely for diagnostic purposes and comes directly from the NLopt optimisation. In normal usage, it can be ignored.\n\nSee also construct_objective.\n\n\n\n\n\n","category":"function"},{"location":"API/#construct_objective","page":"API","title":"construct_objective","text":"construct_objective(m::Model, optimised_mitigation::Array{Float64,1}, backup_timesteps::Int=0, n_objectives::Int=length(model_years)) -> m[:welfare, :UTILITY]\n\nUpdates emissions control rate :MIU and savings rate :S in model m and returns the resulting utility vector. This function is called by optimise_model. optimised_mitigation_savings is a vector of :MIU and :S values that is being optimised.\n\nbackup_timesteps gives the amount of timesteps that are part of the model's time dimension without being optimised. For example, the FaIR climate module runs since 1765, but DICE only optimises starting in 2015. n_objectives gives the amount of timesteps that are being optimised, such that there are n_objectives for :MIU and n_objectives for :S. \n\nSee also optimise_model.\n\n\n\n\n\n","category":"function"},{"location":"API/#Index","page":"API","title":"Index","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"","category":"page"}]
}
