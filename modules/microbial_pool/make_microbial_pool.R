make_microbial_pool <- function(bk_density){
    # return ring-specific, continuous microbial C pool
    
    df <- read.csv("data/EucFACE_data/FACE_P0014_RA_MicrobialBiomassCNP_L1_20120613-20151130.csv")

    # average across rings and depths, unit: mg/kg
    df.m <- summaryBy(Cmic~ring+date,
                      data=df,FUN=mean,keep.names=T,na.rm=T)
    
    bk.r <- bk_density[which(bk_density$Depth == "0-10cm"),]

    for (i in 1:6) {
        df.m[df.m$ring == i, "bk_density"] <- bk.r$bulk_density_kg_m3[i]
    }
        
    # unit conversion: mg/kg to g/m2 for the top 0-10 cm only
    df.m$Cmic_g_m2 <- df.m$bk_density * df.m$Cmic * 0.1 / g_to_mg
    
    # update variables to output Pmic in unit g m-2
    df.out <- df.m[,c("ring", "date", "Cmic_g_m2")]
    
    df.out <- df.out[complete.cases(df.out),]
    
    df.out$date <- as.Date(as.character(df.out$date), format="%d/%m/%Y")
    
    colnames(df.out) <- c("Ring", "Date", "microbial_pool")
    
    # Only use data period 2012-2016
    df.out <- df.out[df.out$Date<="2016-12-31",]
    
    return(df.out)
    
}
