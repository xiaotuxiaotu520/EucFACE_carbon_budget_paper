make_delta_soil_pool_function <- function(inDF,var.col) {
    
    ### extract start and end date
    s.date <- min(inDF$Date)
    e.date <- max(inDF$Date)
    
    ### Change column name of value variable
    colnames(inDF)[var.col] <- "Value"
    
    ### date list
    d.list <- unique(inDF$Date)
    d.list <- d.list[order(d.list)]
    
    ### create delta df
    delta <- subset(inDF, Date != d.list[1])
    delta$Start_date <- delta$Date  

    
    #### calculate differences
    for (i in 1:length(delta$Date)) {
        delta$Start_date[i] <- d.list[which(d.list == delta$Date[i]) - 1]
        delta$prev_biom[i] <- inDF$Value[inDF$Ring == delta$Ring[i] &
                                                     as.numeric(inDF$Date-delta$Start_date[i])==0]
    }
    
    ### Length of period
    delta$length <- as.numeric(delta$Date - delta$Start_date)
    
    ### annualize the difference
    delta$diff_g_yr <- (delta$Value - delta$prev_biom) / delta$length * 365
    
    #- format dataframe to return
    out <- delta[,c("Start_date", "Date", "Date", "Ring", "diff_g_yr")]
    
    names(out) <- c("Start_date", "End_date", "Date", "Ring", "delta")
    
    return(out)
}