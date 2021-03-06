make_frootc_treatment_abs_effect_statistics <- function(inDF, 
                                                        var.col, 
                                                       return.outcome) {
    
    ### Pass in covariate values (assuming 1 value for each ring)
    inDF$Ring <- as.numeric(inDF$Ring)
    
    cov2 <- lai_variable[lai_variable$Date<="2013-02-06",]
    covDF2 <- summaryBy(lai_variable~Ring, data=cov2, FUN=mean, keep.names=T)
    
    for (i in 1:6) {
        inDF$Cov2[inDF$Ring==i] <- covDF2$lai_variable[covDF2$Ring==i]
    }
    
    #### Assign amb and ele factor
    for (i in (1:length(inDF$Ring))) {
        if (inDF$Ring[i]==2|inDF$Ring[i]==3|inDF$Ring[i]==6) {
            inDF$Trt[i] <- "amb"
        } else {
            inDF$Trt[i] <- "ele"
        }
    }
    
    #### Assign factors
    inDF$Trt <- as.factor(inDF$Trt)
    inDF$Ring <- as.factor(inDF$Ring)
    inDF$Datef <- as.factor(inDF$Date)
    
    #### Update variable name so that this function can be used across different variables
    colnames(inDF)[var.col] <- "Value"
    
    #### dataframe 
    tDF <- inDF
    
    ### add annual average LAI for each year and ring
    tDF$Yr <- as.numeric(year(tDF$Date))
    
    
    ### Analyse the variable model
    ## model 1: no interaction, year as factor, ring random factor, include pre-treatment effect
    int.m1 <- "non-interative_with_covariate"
    #modelt1 <- lmer(Value~Trt + Datef + Cov6 + (1|Ring),data=tDF)
    modelt1 <- lmer(Value~Trt + Datef + Cov2 + (1|Ring),data=tDF)
    
    ## anova
    m1.anova <- Anova(modelt1, test="F")
    
    ## Check ele - amb diff
    summ1 <- summary(glht(modelt1, linfct = mcp(Trt = "Tukey")))
    
    ## average effect size
    eff.size1 <- coef(modelt1)[[1]][1,2]
    
    ## confidence interval 
    eff.conf1 <- confint(modelt1,"Trtele")
    
    
    out <- list(int.state=int.m1,
                mod = modelt1, 
                anova = m1.anova,
                diff = summ1,
                eff = eff.size1,
                conf = eff.conf1)
    
    ### Predict the model with a standard LAI value
    newDF <- tDF
    newDF$Cov2 <- mean(covDF2$lai_variable)
    
    newDF$predicted <- predict(out$mod, newdata=newDF)
    
    
    if (return.outcome == "model") {
        return(out)
    } else if (return.outcome == "predicted") {
        return(newDF)
    }
}
