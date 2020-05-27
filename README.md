# Pollution-Associated Risk Geospatial Analysis SITE (pargasite)

Pollution-Associated Risk Geospatial Analysis SITE (PARGASITE) is an online web-application and R package that can be used to estimate levels of pollutants in the U.S. for 1997 through 2019 at user-defined geographic locations and time ranges. Measures correspond to monthly and yearly raster files (Jan 2005 to Dec 2019) for PM2.5, Ozone, NO2, SO2, and CO covering the US and Puerto Rico that were created from United States Environmental Protection Agency (EPA) regulatory monitor data. The R package allows the user to obtain more customized output as well as work with the raster layers directly.

In this folder you will find a shiny app (/app), a version of which is also hosted on pargasite.org. 

You will also find an R package (/pkg) that can be downloaded with devtools::install_github("HimesGroup/pargasite", subdir = "pkg"). You can refer to files in the examples folder which help illustrate the use of all functions in this package. 

Lastly, you will find code we used to generate the data used in both the website and the package.

Pargasite uses publicly available data from the United States Environmental Protection Agency (EPA). We have no affiliation with the EPA. 
From this data, we generated the monthly and yearly raster files (Jan 2005 to Dec 2017) for PM2.5, Ozone, NO2, SO2, and CO using inverse distance weighted interpolation from the 5 nearest EPA monitoring stations.

The website and R package provide similar functionality. Their specific contributions include:
- the website provides visualization of the raster layers as well as the ability to upload a geocoded dataset then download one with pargasite estimates without interfacing with R.  
- the R package allows the user to obtain more customized output as well as work with the raster layers directly 

Both tools were made to assist with analyses of geocoded health data to study the association between pollution exposure and health outcomes.

Notes:
- the raster layers accessible in the R package are not cropped to fit the United States, and instead are in the shape of a rectangle covering the region. 
- unit of measurement is displayed in the shiny app once a pollutant is selected. In the package, use getUnits() to display a list of the units.
- the first time a raster brick is loaded in the package, it will take a while because the data has to be retrieved from online. However, the raster layer will be stored in a temporary file, so it will load much more quickly thereafter.

Reference: Greenblatt RE, Himes BE. Facilitating Inclusion of Geocoded Pollution Data into Health Studies. AMIA Jt Summits Transl Sci Proc. 2019;2019:553–561.(PMID: 31259010)
