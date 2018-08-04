cacheEnv <- new.env()

download <- function(getvar){
  
  var <- deparse(substitute(getvar))
  
  if (exists(var, envir=cacheEnv)){
    
    return(get(var, envir=cacheEnv))
    
  }
  
  else {
    
    getvar <- tempfile()
    
    url <- paste0("http://public.himeslab.org/pargasite_data/", var, ".tif")
    
    download.file(url, getvar, mode = "wb")
    
    ras <- raster::brick(getvar)
    
    assign(var, ras, envir=cacheEnv)
    
    return(ras)
  }
}

