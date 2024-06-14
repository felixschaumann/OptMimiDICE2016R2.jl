module OptMimiDICE2016R2

using Mimi
using XLSX: readxlsx

include("helpers.jl")
include("parameters.jl")

include("marginaldamage.jl")

include("components/totalfactorproductivity_component.jl")
include("components/grosseconomy_component.jl")
include("components/emissions_component.jl")
include("components/co2cycle_component.jl")
include("components/radiativeforcing_component.jl")
include("components/climatedynamics_component.jl")
include("components/damages_component.jl")
include("components/neteconomy_component.jl")
include("components/welfare_component.jl")
include("optimise.jl")

export constructdice, get_model, optimise_model, compute_scc

const model_years = 2015:5:2510

function constructdice(params)

    m = Model()
    set_dimension!(m, :time, model_years)

    #--------------------------------------------------------------------------
    # Add components in order
    #--------------------------------------------------------------------------

    add_comp!(m, totalfactorproductivity, :totalfactorproductivity)
    add_comp!(m, grosseconomy, :grosseconomy)
    add_comp!(m, emissions, :emissions)
    add_comp!(m, co2cycle, :co2cycle)
    add_comp!(m, radiativeforcing, :radiativeforcing)
    add_comp!(m, climatedynamics, :climatedynamics)
    add_comp!(m, damages, :damages)
    add_comp!(m, neteconomy, :neteconomy)
    add_comp!(m, welfare, :welfare)

    #--------------------------------------------------------------------------
    # Make internal parameter connections
    #--------------------------------------------------------------------------
    
    # Socioeconomics
    connect_param!(m, :grosseconomy, :AL, :totalfactorproductivity, :AL)
    connect_param!(m, :grosseconomy, :I, :neteconomy, :I)
    connect_param!(m, :emissions, :YGROSS, :grosseconomy, :YGROSS)

    # Climate
    connect_param!(m, :co2cycle, :E, :emissions, :E)
    connect_param!(m, :radiativeforcing, :MAT, :co2cycle, :MAT)
    connect_param!(m, :climatedynamics, :FORC, :radiativeforcing, :FORC)

    # Damages
    connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMAGES, :damages, :DAMAGES)
	connect_param!(m, :neteconomy, :SIGMA, :emissions, :SIGMA)
    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    #--------------------------------------------------------------------------
    # Set external parameter values 
    #--------------------------------------------------------------------------
    # Set unshared parameters - name is a Tuple{Symbol, Symbol} of (component_name, param_name)
    for (name, value) in params[:unshared]
        update_param!(m, name[1], name[2], value)
    end
    
    # Set shared parameters - name is a Symbol representing the param_name, here
    # we will create a shared model parameter with the same name as the component
    # parameter and then connect our component parameters to this shared model parameter
    add_shared_param!(m, :fco22x, params[:shared][:fco22x]) #Forcings of equilibrium CO2 doubling (Wm-2)
    connect_param!(m, :climatedynamics, :fco22x, :fco22x)
    connect_param!(m, :radiativeforcing, :fco22x, :fco22x)

    add_shared_param!(m, :l, params[:shared][:l], dims = [:time]) #Level of population and labor (millions)
    connect_param!(m, :grosseconomy, :l, :l)
    connect_param!(m, :neteconomy, :l, :l)
    connect_param!(m, :welfare, :l, :l)

    add_shared_param!(m, :MIU, params[:shared][:MIU], dims = [:time]) #Optimized emission control rate results from DICE2016R (base case)
    connect_param!(m, :neteconomy, :MIU, :MIU)
    connect_param!(m, :emissions, :MIU, :MIU)
    
    return m

end

function getdiceexcel(;datafile = joinpath(dirname(@__FILE__), "..", "data", "DICE2016R-090916ap-v2-REVISEDtoR2.xlsm"))
    params = getdice2016r2excelparameters(datafile)

    m = constructdice(params)

    return m
end

# get_model function for standard Mimi API: use the Excel version
"""
    get_model -> m::Model

Gets model as in standard Mimi API.
"""
get_model = getdiceexcel

include("mcs.jl")

function addGreen(model; time_steps=length(Mimi.dimension(model, :time)), share1=0.1, share2=0.1)
    include("./src/green_components/green_grosseconomy_component.jl")
    include("./src/green_components/green_damages_component.jl")
    include("./src/green_components/green_naturalcapital_component.jl")
    include("./src/green_components/green_welfare_component.jl")
    include("./src/green_components/green_neteconomy_component.jl")

    # include components and connect parameters
    replace!(model, :grosseconomy => green_grosseconomy)
    replace!(model,:damages=>green_damages)
    
    add_comp!(model, green_naturalcapital,:green_naturalcapital, before=:neteconomy)
    connect_param!(model, :grosseconomy, :NC, :green_naturalcapital, :NC)
    connect_param!(model, :damages, :NC, :green_naturalcapital, :NC)
    connect_param!(model, :green_naturalcapital, :DAMAGES_NC, :damages, :DAMAGES_NC)
    
    replace!(model,:welfare=>green_welfare)
    connect_param!(model, :welfare, :nonUV, :green_naturalcapital, :nonUV)
    connect_param!(model, :welfare, :ES, :grosseconomy, :ES)

    replace!(model,:neteconomy=>green_neteconomy)
    
    connect_param!(model, :green_naturalcapital, :benefitsNC, :neteconomy, :benefitsNC)
    connect_param!(model, :neteconomy, :ES, :grosseconomy, :ES)
    connect_param!(model, :welfare, :ESPC, :neteconomy, :ESPC)
    connect_param!(model, :green_naturalcapital, :invNCfrac, :neteconomy, :benefitsNC)
    
    # set parameters of specification
    set_param!(model,:grosseconomy,:ExtraK,fill(0.,time_steps)) # HERE PARAMETER SET

    set_param!(model,:green_naturalcapital,:ExtraN,fill(0.,time_steps)) # HERE PARAMETER SET
    set_param!(model,:green_naturalcapital,:invNCfrac,fill(0.,time_steps)) # HERE PARAMETER SET
    set_param!(model,:green_naturalcapital,:w,2.8) # HERE PARAMETER SET
    
    set_param!(model,:invNCfrac,fill(0.,time_steps)) # HERE PARAMETER SET
    set_param!(model,:neteconomy,:ExtraC,fill(0.,time_steps)) # HERE PARAMETER SET
    RR = [1/(1+0.015)^(t*5) for t in 0:time_steps-1] # HERE PARAMETER SET
    set_param!(model,:rr,RR) # HERE PARAMETER SET
    set_param!(model,:w,2.8) # HERE PARAMETER SET
    
    set_param!(model,:k0,223) # HERE PARAMETER SET
    
    # Preferred parameters
    share1_param = share1    # for eliminating NC effect, was originally 0.1 # HERE PARAMETER SET
    share2_param = share2    # for eliminating NC effect, was originally 0.1 # HERE PARAMETER SET
    k_nc_param = 3.87 # HERE PARAMETER SET
    gamma4_param = 0.5 # HERE PARAMETER SET
    elasmu_param = 1.45 # HERE PARAMETER SET
    
    theta1_i = [0.74, 0.86, 0.68, 0.69, 0.32, 0.58, -0.16, 0.41, -0.1, 0.73, 0.79, 0.76, 0.80]
    theta2_i = [0.63,0.78,0.62,0.27]
    theta1_param = mean(theta1_i) # HERE PARAMETER SET
    theta2_param = mean(theta2_i) # HERE PARAMETER SET
    
    update_param!(model, :welfare, :elasmu, elasmu_param)
    update_param!(model,:welfare,:share2,share2_param)
    set_param!(model,:share,share1_param)
    update_param!(model,:welfare,:theta,theta1_param) 
    update_param!(model,:welfare,:theta2,theta2_param)
    K_NC = k_nc_param
    update_param!(model,:grosseconomy,:ratioNC,K_NC) 
    update_param!(model,:green_naturalcapital,:ratioNC,K_NC)  
    
    atfp_param = 1.05 # taken from `Interaction_atfp_damage.jl` file --> how justified? # HERE PARAMETER SET
    Adjusted_tfp = atfp_param
    zero_gama3 = 0. # HERE PARAMETER SET
    elasticity_nc = log(Adjusted_tfp)/log(K_NC)
    update_param!(model,:grosseconomy,:gama3, elasticity_nc)
    
    a_d = 0.00227 #Corresponding to total aggregated damages of DICE2016R2 (see Excel)
    update_param!(model, :damages, :a_d, a_d) # HERE PARAMETER SET
    k_perc = 0.32  #Percentage Corresponding to market damages only, Howard and Sterner (2017)
    mortality_perc = 0.2 #Percentage corresponding to mortality damages
    a_k = a_d * (k_perc + mortality_perc)
    update_param!(model, :damages, :a2, a_k) # HERE PARAMETER SET

    # outcome from damage_param optmisation (in Functions_GreenDICE.jl and Setup_GreenDICE_mainSpecification.jl)
    a4_optimised = 0.009263 # HERE PARAMETER SET
    update_param!(model,:damages,:a4,a4_optimised) # HERE PARAMETER SET
    
    g4 = gamma4_param
    update_param!(model,:green_naturalcapital,:g4,g4) #gamma4 # HERE PARAMETER SET

    return model
end

end # module