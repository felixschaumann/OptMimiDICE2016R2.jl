
#Defining the component of natural capital
@defcomp green_naturalcapital begin
    NC       = Variable(index=[time])   #Natural capital
    nonUV       = Variable(index=[time])   #non Use Value
    
    DAMAGES_NC = Parameter(index=[time])   #GreenDICE: total damages to NC 
    k0         = Parameter()               #Initial capital value (trill 2010 USD)
    ratioNC    = Parameter()               #GreenDICE: ratio of NC to K0
    benefitsNC = Parameter(index=[time])   #GreenDICE: fraction of investment in NC
    ExtraN = Parameter(index=[time])          #GreenDICE: Year to add an extra asset of N, to compute investments 
    g4 = Parameter()                        #gamma4, elasticity of natural capital
    invNCfrac   = Parameter(index=[time])    #GreenDICE - investment control
    w = Parameter()                  #damage reduction parameter
    
    function run_timestep(p, v, d, t)
    
        if is_first(t)
            v.NC[t] = p.k0 / p.ratioNC + p.ExtraN[TimestepIndex(1)]
            v.nonUV[t] = v.NC[t] ^ p.g4 
        else
            v.NC[t] = v.NC[t-1] - (v.NC[t-1] - v.NC[t-1] * p.DAMAGES_NC[t])* (1 - (p.benefitsNC[t-1])^(1/p.w))
            v.nonUV[t] = v.NC[t] ^ p.g4
        end
    end
end