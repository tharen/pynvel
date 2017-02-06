
Volume Estimation
    - Flewelling taper functions documentation is not readily available
        + Ref: NW TAPER Coop  April, 1994
        + Maps: www.growthmodel.org/wmens/m2013/Flewelling.ppt
    
    - NVEL `F_west.f` source code defines regional "GEOSUB" codes
        + '00' - Default
        + '01' - Coastal Oregon
        + '02' - West Valley (Willamette) Oregon
        + '07' - East Valley (Willamette) Oregon
        
    - DBT & DBHBTR should be 0, Flewelling functions will estimate
        + fdbt_c1 is defined in F_west.f and called by Sf_shp.f
    
    