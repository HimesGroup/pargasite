.run_idw <- function(x, base_grid, nmax) {
  pollutant_standard <- unique(x$pollutant_standard) # supposed to be length 1
  if (is.numeric(nmax) && length(nmax) > 1) {
    nmax <- .nmax_loocv(x, nmax)
  }
  setNames(
    idw(arithmetic_mean ~ 1, x, base_grid,
        nmax = nmax, debug.level = 0)["var1.pred"],
    .make_names(pollutant_standard)
  )
}

## Can allow `idp` optimization as well but may be too much
.nmax_loocv <- function(x, nmax_vec) {
  message("optimizing 'nmax' with LOOCV...")
  ## pb <- utils::txtProgressBar(min = 0, max = length(nmax_vec), style = 3)
  cli::cli_progress_bar(
         format = "nmax = {nmax_vec[i]} {cli::pb_bar} {cli::pb_percent}",
         total = length(nmax_vec)
       )
  rmse_vec <- c()
  for (i in seq_along(nmax_vec)) {
    res <- gstat::krige.cv(arithmetic_mean ~ 1, x, nmax = nmax_vec[i],
                           verbose = FALSE)
    rmse_vec <- append(rmse_vec, sqrt(mean(res$residual^2)))
    ## utils::setTxtProgressBar(pb, i)
    cli::cli_progress_update()
  }
  ## close(pb)
  cli::cli_progress_done()
  nmax_optim <- nmax_vec[which.min(rmse_vec)]
  message("set nmax = ", nmax_optim)
  nmax_optim
}
