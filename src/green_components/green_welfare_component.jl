@defcomp green_welfare begin
    CEMUTOTPER      = Variable(index=[time])    #Period utility
    CUMCEMUTOTPER   = Variable(index=[time])    #Cumulative period utility
    PERIODU         = Variable(index=[time])    #One period utility function
    UTILITY         = Variable()                #Welfare Function
    Consumption_subs   = Variable(index=[time]) #GreenDICE: Internal variable for computing utility
    Environmental_subs = Variable(index=[time]) #GreenDICE: Internal variable for computing utility
    

    CPC             = Parameter(index=[time])   #Per capita consumption (thousands 2010 USD per year)
    l               = Parameter(index=[time])   #Level of population and labor
    rr              = Parameter(index=[time])   #Average utility social discount rate
    elasmu          = Parameter()               #Elasticity of marginal utility of consumption
    scale1          = Parameter()               #Multiplicative scaling coefficient
    scale2          = Parameter()               #Additive scaling coefficient
    share           = Parameter()               #GreenDICE: share of utility produced by ES
    share2           = Parameter()               #GreenDICE: share of utility produced by nonUV
    theta      = Parameter()               #GreenDICE: Elasticity of substitution for ES and C
    theta2      = Parameter()               #GreenDICE: Elasticity of substitution for UV and nonUV
    ESPC              = Parameter(index=[time])               
    nonUV             = Parameter(index=[time])
    ES              = Parameter(index=[time])                              



    function run_timestep(p, v, d, t)
        
        v.PERIODU[t] = ((((1)*((1-p.share)*p.CPC[t]^p.theta)+(p.share*p.ESPC[t]^p.theta))^(p.theta2/p.theta)+p.share2*(p.nonUV[t])^p.theta2)^((1-p.elasmu)/p.theta2)-1)/(1-p.elasmu)-1 #nested utility function with constant elasticities of substiution


        v.CEMUTOTPER[t] = v.PERIODU[t] * p.l[t] * p.rr[t]

        v.CUMCEMUTOTPER[t] = v.CEMUTOTPER[t] + (!is_first(t) ? v.CUMCEMUTOTPER[t-1] : 0)

        # Define function for UTILITY
        if is_last(t)
            v.UTILITY = 5 * p.scale1 * v.CUMCEMUTOTPER[t] + p.scale2
        end
    end
end