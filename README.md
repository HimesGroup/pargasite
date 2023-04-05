
# Pollution-Associated Risk Geospatial Analysis SITE (pargasite)

Contributors: Nisha Narayanan, Avantika Diwadkar, Rebecca Greenblatt, Blanca Himes

Pollution-Associated Risk Geospatial Analysis SITE (PARGASITE) is an online web application and R package that can be used to estimate levels of pollutants in the U.S. for 1997 through 2021 at user-defined geographic locations and time ranges. Measures correspond to monthly and yearly raster files for PM2.5, Ozone, NO2, SO2, and CO covering the contiguous United States and Puerto Rico that were created with U.S. Environmental Protection Agency (EPA) regulatory monitor data. The R package allows users to obtain more customized output and work with the raster layers directly. 


<img width="500" alt="Screenshot 2023-04-05 at 1 35 26 AM" src="https://user-images.githubusercontent.com/89948867/229990304-355f7493-91ea-4800-9ccc-b0279ed15591.png">   <img width="500" alt="Screenshot 2023-04-05 at 1 36 20 AM" src="https://user-images.githubusercontent.com/89948867/229990486-18315ede-a52e-44e7-a62f-37df6951b748.png"> 
<img width="500" alt="Screenshot 2023-04-05 at 1 40 22 AM" src="https://user-images.githubusercontent.com/89948867/229990848-c66410f9-1f28-4f15-8856-9e50a7268158.png">   <img width="500" alt="Screenshot 2023-04-05 at 1 45 42 AM" src="https://user-images.githubusercontent.com/89948867/229991678-9304d3f0-f9e7-4b3d-bfea-b954f1210c85.png">
  

In this repository you will first find a shiny app (/app), a version of which is also hosted on https://pargasite.org/. 

You will also find an R package (/pkg) that can be downloaded with devtools::install_github("HimesGroup/pargasite", subdir = "pkg"). 

Lastly, you will find the code we used to generate the data (/data_generation) used in both the website and the package.

## Data 

Pargasite uses publicly available data from the United States Environmental Protection Agency (EPA). We have no affiliation with the EPA. From this data, we generated the monthly and yearly raster files (Jan 2005 to Dec 2021) for PM2.5, Ozone, NO2, SO2, and CO using inverse distance weighted interpolation from the 5 nearest EPA monitoring stations.

## Additional Information

The website and R package are similar, but some of their specific functions include:

1) The website provides visualization of the raster layers as well as the ability to upload a file with geocodes to then download one with PARGASITE estimates without interfacing with R.

2) The unit of measurement is displayed in the Shiny app according to the pollutant selected. To display units with the R package, use the getUnits() function.

3)  The first time a raster layer is loaded in a user’s R environment by the R package, it will take some time to retrieve the data online. However, the raster layer will be stored in a temporary file that will improve subsequent loading times.

4)  The latest updates to the app allows the user to visualize and download the pollutant data at the MMSA and County level.

5) The latest updates to the R package allows the user to work with the raster layers and download the pollutant values at MMSA, Counties, Census Tracts, and ZIPCODE level. Example use cases can be found at /pkg/examples/.

## Reference

Greenblatt RE, Himes BE. Facilitating Inclusion of Geocoded Pollution Data into Health Studies. AMIA Jt Summits Transl Sci Proc. 2019;2019:553–561.(PMID: 31259010)
