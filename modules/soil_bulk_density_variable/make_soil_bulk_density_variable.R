make_soil_bulk_density <- function() {
    # return ring-specific soil density data for top 3 depths
    
    # download the data
    df <- read.csv("data/EucFACE_data/FACE_P0088_RA_BULKDENSITY_L1_20170914.csv")
    
    df <- df[,1:7]
    names(df)[7] <- "bulk_density"
    df$bulk_density <- as.character(df$bulk_density)
    df <- subset(df, bulk_density != "na")
    df$bulk_density <- as.numeric(df$bulk_density)
    
    # average across rings and depths, unit: g/cm3
    df.m <- summaryBy(bulk_density~ring+Depth,
                      data=df,FUN=c(mean,se),keep.names=T,na.rm=T)
    
    # unit conversion: g/cm3 to kg/m3
    df.m$bulk_density_kg_m3 <- df.m$bulk_density.mean * g_to_kg / cm3_to_m3
    df.m$bulk_density_kg_m3_se <- df.m$bulk_density.se * g_to_kg / cm3_to_m3
    
    # only include depths at 0-10, 10-20 and 20-30
    df.out <- subset(df.m, Depth == "0-10" | Depth == " 10-20" | Depth == "20-30")
    
    # update variables to output
    out <- df.out[,c("ring", "Depth", "bulk_density_kg_m3", "bulk_density_kg_m3_se")]
    
    # change factor names to match with soil factor names
    out$Depth <- plyr::revalue(out$Depth, c("0-10"="0-10cm", " 10-20"="10-20cm", "20-30"="20-30cm"))
    
    return(out)
    
}
