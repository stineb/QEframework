
#### Analytical script Run 22
####
#### Assumptions:
#### 1. baseline model
#### 2. Variable wood NC
#### 3. baseline N cycle
#### 4. Medlyn and Dewar, 1996, no coupling between allocation leaf and wood
#### 5. af = 0.3
####
################################################################################
#### Functions
Perform_Analytical_Run22 <- function(f.flag = 1) {
    #### Function to perform analytical run 22 simulations
    #### eDF: stores equilibrium points
    #### cDF: stores constraint points (curves)
    #### f.flag: = 1 simply plot analytical solution and create individual pdf file
    #### f.flag: = 2 return a list consisting of two dataframes

    ######### Main program
    source("Parameters/Analytical_Run22_Parameters.R")
    
    ### create a range of nc for shoot to initiate
    nfseq <- round(seq(0.001, 0.1, by = 0.001),5)
    
    ### create nc ratio for wood, root, and allocation coefficients
    a_nf <- as.data.frame(alloc_Medlyn_Dewar_no_coupling(nfseq))
    
    ### calculate photosynthetic constraint at CO2 = 350
    P350 <- photo_constraint_full(nf=nfseq, nfdf=a_nf, CO2=CO2_1)

    ### calculate very long term NC constraint on NPP, respectively
    VL <- VL_constraint(nf=nfseq, nfdf=a_nf)
    
    ### finding the equilibrium point between photosynthesis and very long term nutrient constraints
    VL_eq <- solve_VL_Medlyn_Dewar_no_coupling(CO2=CO2_1)

    ### calculate nw and nr for VL equilibrated nf value
    a_eq <- alloc_Medlyn_Dewar_no_coupling(VL_eq$nf)
    
    ### calculate soil parameters, e.g. reburial coef.
    s_coef <- soil_coef(df=VL_eq$nf, a=a_eq)
    omega_ap <- a_eq$af*s_coef$omega_af_pass + a_eq$ar*s_coef$omega_ar_pass+ a_eq$aw*s_coef$omega_aw_pass
    omega_as <- a_eq$af*s_coef$omega_af_slow + a_eq$ar*s_coef$omega_ar_slow+ a_eq$aw*s_coef$omega_aw_slow
    
    ### Get C from very-long term nutrient cycling solution
    ### return in g C m-2 
    C_pass_VL <- omega_ap*VL_eq$NPP/s_coef$decomp_pass/(1-s_coef$qq_pass)*1000.0

    ### Calculate long term nutrient constraint
    L <- L_constraint(df=nfseq, a=a_nf, 
                      C_pass=C_pass_VL,
                      Nin_L = Nin)
    
    ### Find long term equilibrium point
    L_eq <- solve_L_Medlyn_Dewar_no_coupling(CO2=CO2_1, C_pass=C_pass_VL, Nin_L = Nin)
    
    ### Get Cslow from long nutrient cycling solution
    ### return in g C m-2
    C_slow_L <- omega_as*L_eq$NPP/s_coef$decomp_slow/(1-s_coef$qq_slow)*1000.0
    
    ### Calculate nutrient release from slow woody pool
    ### return in g N m-2 yr-1
    N_wood_L <- a_eq$aw*a_eq$nw*VL_eq$NPP*1000.0
    
    ### Calculate medium term nutrient constraint
    M <- M_constraint(df=nfseq,a=a_nf, 
                      C_pass=C_pass_VL, 
                      C_slow=C_slow_L, 
                      Nin_L = Nin+N_wood_L)
    
    ### calculate M equilibrium point
    M_eq <- solve_M_Medlyn_Dewar_no_coupling(CO2=CO2_1, 
                        C_pass=C_pass_VL, 
                        C_slow=C_slow_L, 
                        Nin_L = Nin+N_wood_L)
    

    out350DF <- data.frame(CO2_1, nfseq, P350, VL$NPP, 
                           L$NPP, M$NPP)
    colnames(out350DF) <- c("CO2", "nc", "NPP_photo", "NPP_VL",
                            "NPP_L", "NPP_M")
    equil350DF <- data.frame(CO2_1, VL_eq, L_eq, M_eq)
    colnames(equil350DF) <- c("CO2", "nc_VL", "NPP_VL", 
                              "nc_L", "NPP_L", "nc_M", "NPP_M")
    
    ##### CO2 = 700
    ### photo constraint
    P700 <- photo_constraint_full(nf=nfseq, nfdf=a_nf, CO2=CO2_2)
    
    ### VL equilibrated point with eCO2
    VL_eq <- solve_VL_Medlyn_Dewar_no_coupling(CO2=CO2_2)
    
    ### Find long term equilibrium point
    L_eq <- solve_L_Medlyn_Dewar_no_coupling(CO2=CO2_2, C_pass=C_pass_VL, Nin_L = Nin)
    
    ### Find medium term equilibrium point
    M_eq <- solve_M_Medlyn_Dewar_no_coupling(CO2=CO2_2, 
                         C_pass=C_pass_VL, 
                         C_slow=C_slow_L, 
                         Nin_L = Nin+N_wood_L)
    
    out700DF <- data.frame(CO2_2, nfseq, P700, 
                           VL$NPP, L$NPP, M$NPP)
    colnames(out700DF) <- c("CO2", "nc", "NPP_photo", "NPP_VL",
                            "NPP_L", "NPP_M")
    
    equil700DF <- data.frame(CO2_2, VL_eq, L_eq, M_eq)
    colnames(equil700DF) <- c("CO2", "nc_VL", "NPP_VL", 
                              "nc_L", "NPP_L", "nc_M", "NPP_M")
 
    ### get the point instantaneous NPP response to doubling of CO2
    df700 <- as.data.frame(cbind(round(nfseq,3), P700))
    inst700 <- inst_NPP(equil350DF$nc_VL, df700)
    equil350DF$NPP_I <- inst700$equilNPP
    equil700DF$NPP_I <- inst700$equilNPP
    
    if (f.flag == 1) {
  
        
    } else if (f.flag == 2) {
        
        my.list <- list(cDF = data.frame(rbind(out350DF, out700DF)), 
                        eDF = data.frame(rbind(equil350DF, equil700DF)))
        
        return(my.list)
    } 
}

