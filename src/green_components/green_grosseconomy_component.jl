@defcomp green_grosseconomy begin
    K       = Variable(index=[time])    #Capital stock (trillions 2005 US dollars)
    YGROSS  = Variable(index=[time])    #Gross world product GROSS of abatement and damages (trillions 2005 USD per year)

    ES  = Variable(index=[time])    #Ecosystem services
    NC      = Parameter(index=[time])   #Natural capital; although is a variable, in this component is a parameter

    AL      = Parameter(index=[time])   #Level of total factor productivity
    I       = Parameter(index=[time])   #Investment (trillions 2005 USD per year)
    l       = Parameter(index=[time])   #Level of population and labor
    dk      = Parameter()               #Depreciation rate on capital (per year)
    gama    = Parameter()               #Standard DICE gama of K
    gama3   = Parameter()               #GreenDICE: natural Capital elasticity in production function
    k0      = Parameter()               #Initial capital value (trill 2005 USD)
    ratioNC = Parameter()               #GreenDICE: ratio of NC to K0
    k0         = Parameter()               #Initial capital value (trill 2005 USD)
    ratioNC    = Parameter()               #GreenDICE: ratio of NC to K0
    share           = Parameter()               #GreenDICE: share of ES produced by Green Production Function
    ExtraK = Parameter(index=[time])          #GreenDICE: Year to add an extra asset of K, to compute investments 
    


    function run_timestep(p, v, d, t)
         if is_first(t)
            v.K[t] = p.k0 + p.ExtraK[TimestepIndex(1)] #before: TimestepIndex(1) p.ExtraK[1]
        else
            v.K[t] = (1 - p.dk)^5 * v.K[t-1] + 5 * p.I[t-1]  + p.ExtraK[t]
        end

        #Define function for YGROSS
        if is_first(t)
            v.YGROSS[t] = (p.AL[t] * (p.l[t]/1000)^(1-p.gama)) * (v.K[t]^(p.gama - p.gama3)) * ((p.k0 / p.ratioNC)^p.gama3)
            v.ES[t] = (p.AL[t] * (p.l[t]/1000)^(1-p.gama)) * (v.K[t]^(p.gama3)) * ((p.k0 / p.ratioNC)^(p.gama - p.gama3))
        else
            v.YGROSS[t] = ((p.AL[t] * (p.l[t]/1000)^(1-p.gama)) * (v.K[t]^(p.gama - p.gama3)) * (p.NC[t-1]^p.gama3))
            v.ES[t] = ((p.AL[t] * (p.l[t]/1000)^(1-p.gama)) * (v.K[t]^(p.gama3)) * (p.NC[t-1]^(p.gama - p.gama3)))
        end
            

    end
end