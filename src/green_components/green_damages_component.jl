#Redefining damages component to include natural capital and ecosystem services
@defcomp green_damages begin
    DAMAGES    = Variable(index=[time])    #Damages (trillions 2005 USD per year)
    DAMAGES_NC = Variable(index=[time])    # GreenDICE: Natural capital Damages (in a measurement of NC)
    DAMFRAC    = Variable(index=[time])    #Damages (fraction of gross output)
    DAMFRAC_NC = Variable(index=[time])    # GreenDICE: Natural Capital Damages (fraction of NC)
    
    TATM    = Parameter(index=[time])   #Increase temperature of atmosphere (degrees C from 1900)
    YGROSS  = Parameter(index=[time])   #Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    NC      = Parameter(index=[time])   #GreenDICE: NC
    a1      = Parameter()               #Damage coefficient
    a2      = Parameter()               #Damage quadratic term
    a3      = Parameter()               #Damage exponent
    a4      = Parameter()               #GreenDICE: Damage coefficient for NC
    # a5      = Parameter()               #GreenDICE: Damage coefficient for ES
    # damadj  = Parameter()               #Adjustment exponent in damage function
    # usedamadj=Parameter{Bool}()       # Only the Excel version uses the damadj parameter
    a_d = Parameter()                   #Total aggregated damages (meta paratameter, used to compute damage parameter a4, using damage_params function)
     
    function run_timestep(p, v, d, t)
        v.DAMFRAC[t] = p.a1 * p.TATM[t] + p.a2 * p.TATM[t] ^ p.a3
        
        if is_first(t)
            v.DAMFRAC_NC[t] = 1 / (1 + (p.a4 * p.TATM[t] ^ 2))
        else
            v.DAMFRAC_NC[t] = 1 / (1 + (p.a4 * p.TATM[t] ^ 2))
        end
        
        v.DAMAGES[t] = p.YGROSS[t] * v.DAMFRAC[t]
        v.DAMAGES_NC[t] = v.DAMFRAC_NC[t]
    end
end
