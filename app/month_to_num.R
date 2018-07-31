month_to_num <- function(month){
  
  months <- c("Jan", "Feb", "March", "April", "May","June", "July", "Aug", "Sept", "Oct", "Nov", "Dec")
  
  month_str <- paste0(0, grep(month, months))
  n <- nchar(month_str)
  return(substr(month_str, n-1, n+1))
  
}