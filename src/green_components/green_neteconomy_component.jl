@defcomp green_neteconomy begin

	PBACKTIME	= Variable(index=[time])	#Backstop price
	COST1		= Variable(index=[time])	#Adjusted cost for backstop
    ABATECOST   = Variable(index=[time])    #Cost of emissions reductions (trillions 2010 USD per year)
    C           = Variable(index=[time])    #Consumption (trillions 2010 US dollars per year)
    CPC         = Variable(index=[time])    #Per capita consumption (thousands 2010 USD per year)
    CPRICE      = Variable(index=[time])    #Carbon price (2010$ per ton of CO2)
    I           = Variable(index=[time])    #Investment (trillions 2010 USD per year)
    MCABATE     = Variable(index=[time])    #Marginal cost of abatement (2010$ per ton CO2)
    Y           = Variable(index=[time])    #Gross world product net of abatement and damages (trillions 2010 USD per year)
    YNET        = Variable(index=[time])    #Output net of damages equation (trillions 2010 USD per year)

    ESPC        = Variable(index=[time])    #Per capita consumption of ES (thousands 2010 USD per year)
    InvNC       = Variable(index=[time])    #GreenDICE Investment in natural capital (trillions 2005 USD per year)
    benefitsNC  = Variable(index=[time])    #GreenDICE Benefits of the Investment in natural capital 
    YGreen      = Variable(index=[time])    #GreenDICE: a middle step from gross economy to consumption, to subtract investments in NC
    NCcost      = Variable(index=[time])    #GreenDICE: a middle step from gross economy to consumption, to subtract investments in NC

	SIGMA		= Parameter(index=[time])	#CO2-equivalent-emissions output ratio
    DAMAGES     = Parameter(index=[time])   #Damages (Trillion $)
    l           = Parameter(index=[time])   #Level of population and labor
    MIU         = Parameter(index=[time])   #Emission control rate GHGs
    S           = Parameter(index=[time])   #Gross savings rate as fraction of gross world product
    YGROSS      = Parameter(index=[time])   #Gross world product GROSS of abatement and damages (trillions 2010 USD per year)
    expcost2    = Parameter()               #Exponent of control cost function
	pback		= Parameter()				#Cost of backstop 2010$ per tCO2 2015
	gback		= Parameter()				#Initial cost decline backstop cost per period

    ES          = Parameter(index=[time])   #Gross world Ecosystem Services
    invNCfrac   = Parameter(index=[time])    #GreenDICE - investment control
    ExtraC      = Parameter(index=[time])    #GreenDICE: Year to add an extra aggregated consumption, to compute SCC
    # a4      = Parameter()               #GreenDICE: Damage coefficient for NC
    # gama3   = Parameter()               #GreenDICE: natural Capital elasticity in production function
    # NC      = Parameter(index=[time])   #GreenDICE: NC
    # K      = Parameter(index=[time])   #Capital stock
    # priceNC      = Parameter(index=[time])   #exogenous price of NC
    # w      = Parameter()   #exogenous cost of abatement

    function run_timestep(p, v, d, t)
		#Define function for PBACKTIME
        if is_first(t)
            v.PBACKTIME[t] = p.pback
        else
            v.PBACKTIME[t] = v.PBACKTIME[t - 1] * (1 - p.gback)
        end
		
		#Define function for COSTL
		v.COST1[t] = v.PBACKTIME[t] * p.SIGMA[t] / p.expcost2 / 1000

        #Define function for YNET
        v.YNET[t] = p.YGROSS[t] - p.DAMAGES[t]
        
        #Define function for ABATECOST
        v.ABATECOST[t] = p.YGROSS[t] * v.COST1[t] * (p.MIU[t]^p.expcost2)
        
        #Define function for MCABATE (equation from GAMS version)
        v.MCABATE[t] = v.PBACKTIME[t] * p.MIU[t]^(p.expcost2 - 1)
        
        #Define function for Y
        v.YGreen[t] = v.YNET[t] - v.ABATECOST[t]
    
        #Define function for Investments in natural capital
        v.InvNC[t] = v.YGreen[t] * p.invNCfrac[t]
        
        #Define function for Y
        v.Y[t] = v.YGreen[t] - v.InvNC[t]
    
        #Define function for I
        v.I[t] = p.S[t] * v.Y[t]
    
        v.benefitsNC[t] =  p.invNCfrac[t]

        #Define function for C
        v.C[t] = v.Y[t] - v.I[t] + p.ExtraC[t]
    
        #Define function for CPC
        v.CPC[t] = 1000 * v.C[t] / p.l[t]
    
        #Define function for CPRICE (equation from GAMS version of DICE2016)
        v.CPRICE[t] = v.PBACKTIME[t] * (p.MIU[t]^(p.expcost2 - 1))

        v.ESPC[t] = 1000 * p.ES[t] / p.l[t] #ES per capita
    end
end