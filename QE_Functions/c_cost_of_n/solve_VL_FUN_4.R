# Find the very-long term equilibrium nf and NPP under standard conditions - by finding the root
solve_VL_FUN_4 <- function(CO2) {
    ### CO2 is the pre-defined CO2 concentration
    
    ### Find unique solution
    fn <- function(nf) {
        photo_constraint_full(nf, alloc(nf),CO2) - VL_constraint_FUN_4(alloc(nf))$NPP_grow
    }
    equil_nf <- uniroot(fn,interval=c(0.001,0.01))$root
    
    ### calculate equilibrium NPP based on equil nf ratio
    equil_NPP <- photo_constraint_full(equil_nf, alloc(equil_nf), CO2)
    
    ans <- data.frame(equil_nf, equil_NPP)
    
    colnames(ans) <- c("nf", "NPP")
    
    return(ans)
}
