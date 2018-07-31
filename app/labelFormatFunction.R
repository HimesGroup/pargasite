myLabelFormat = function(prefix = "", suffix = "", between = " &ndash; ", digits = 3, 
                         big.mark = ",", transform = identity, t.val = Inf) {
  formatNum <- function(x) {
    format(round(transform(x), digits), trim = TRUE, scientific = FALSE, 
           big.mark = big.mark)
  }
  function(type, ...) {
    switch(type, numeric = (function(cuts) {
      cuts <- sort(cuts, decreasing = T) #just added
      paste0(prefix, formatNum(cuts), ifelse(cuts == t.val, "+", ""))
    })(...), bin = (function(cuts) {
      n <- length(cuts)
      paste0(prefix, formatNum(cuts[-n]), between, formatNum(cuts[-1]), 
             suffix)
    })(...), quantile = (function(cuts, p) {
      n <- length(cuts)
      p <- paste0(round(p * 100), "%")
      cuts <- paste0(formatNum(cuts[-n]), between, formatNum(cuts[-1]))
      paste0("<span title=\"", cuts, "\">", prefix, p[-n], 
             between, p[-1], suffix, "</span>")
    })(...), factor = (function(cuts) {
      paste0(prefix, as.character(transform(cuts)), suffix)
    })(...))
  }
}