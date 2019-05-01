cacheEnv <- new.env()

download <- function(getvar){
  
  var <- deparse(substitute(getvar))
  
  if (exists(var, envir=cacheEnv)){
    
    return(get(var, envir=cacheEnv))
    
  }
  
  else {
    
    getvar <- tempfile()
    
    url <- paste0("https://s3.amazonaws.com/pargasitedata/", var, ".tif")
    
    download.file(url, getvar, mode = "wb", method = "auto")
    
    ras <- raster::brick(getvar)
    
    assign(var, ras, envir=cacheEnv)
    
    return(ras)
  }
}

