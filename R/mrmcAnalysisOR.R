# mrmcAnalysisOR ####
#' MRMC analysis by Obuchowski and Rockette ( Obuchowski1995_Commun-Stat-Simulat_v24p285)
#'
#' @description OR's method to estimate the MRMC variance for a given theta.
#' This function requires an nModalities by nReaders covariance matrix to estimate
#' covOR = (cov1, cov2, cov3), as described by Hillis (2014, SIM, Section 2.2)

#'
#' @param theta.hat [2, nReaders]: Performance estimates for two modalities by all readers
#' @param cov.hat [2 * nReaders, 2 * nReaders]: Covariance matrix between each reader x modality
#' @param sgl ch: Flat indicating whether or not to do single modality analysis only using single modality data
#'
#' @return  list
#' \itemize{
#'   \item  \code{F}             : F statistic
#'   \item  \code{df.H}          : degrees of freedom difference of concordance
#'   \item  \code{p}             : P value
#'   \item  \code{se.dif}        : difference of variance
#'   \item  \code{theta.i}   [2] : reader-averaged HarrellsC form modality A & B
#'   \item  \code{df.sgl}    [2] : degrees of freedom for modality A & B
#'   \item  \code{se.i}      [2] : Variance form modality A & B
#'   \item  \code{covOR}     [6] : Components of variance of the Obuchowski and Rockette method
#'   \itemize{
#'     \item                           cov1, cov2(pooled over modalities), cov3,
#'     \item                           varC, cov2(modalityA only), cov2(modalityB only)
#'   }
#' }
#'
#' @export
#'
mrmcAnalysisOR = function(theta.hat, cov.hat, sgl="corres") {

  nModalities <- dim(theta.hat)[1];
  nReaders <- dim(theta.hat)[2]

  #Cov.1 and Cov.3
  # subV12 is the off-diagonal submatrix
  subV12 <- cov.hat[(nReaders + 1):(2*nReaders), 1:nReaders]
  Cov.1 <- mean(diag(subV12))
  Cov.3 <- mean(subV12[row(subV12) != col(subV12)])

  #Cov2 and VarE from the first-modality data
  # subV11 is the on-diagonal submatrix for modality 1
  subV11 <- cov.hat[1:nReaders,1:nReaders]
  Cov21 <- mean(subV11[row(subV11) != col(subV11)])
  VarE1 <- mean(diag(subV11))

  #Cov2 and VarE from the second-modality data
  # subV11 is the on-diagonal submatrix for modality 2
  subV22 <- cov.hat[(nReaders + 1):(2*nReaders), (nReaders + 1):(2*nReaders)]
  Cov22 <- mean(subV22[row(subV22) != col(subV22)])
  VarE2 <- mean(diag(subV22))

  #Cov2 and VarE averaged over the two modalities
  Cov.2 <- mean(c(Cov21, Cov22))
  VarE <- mean(c(VarE1, VarE2))

  theta.i <- rowMeans(theta.hat, na.rm = TRUE)
  theta.j <- colMeans(theta.hat, na.rm = TRUE)
  theta.d <- mean(theta.j, na.rm = TRUE)
  theta.ii <- matrix(rep(theta.i, times = nReaders),nrow = nModalities)
  theta.jj <- matrix(rep(theta.j, each = nModalities),nrow = nModalities)
  theta.dd <- matrix(theta.d,nModalities,nReaders)
  MS.T <- nReaders*var(theta.i, na.rm = TRUE)
  MS.R <- nModalities*var(theta.j, na.rm = TRUE)
  MS.TR <- sum((theta.hat - theta.ii - theta.jj + theta.dd) ^ 2, na.rm = TRUE)/(nModalities - 1)/(nReaders - 1)

  #inference of performance difference
  F_stat <- MS.T/(MS.TR + max(nReaders*(Cov.2 - Cov.3),0))
  df.H <- (nModalities - 1)*(nReaders - 1)*(MS.TR + max(nReaders*(Cov.2 - Cov.3),0)) ^ 2/(MS.TR ^ 2)
  p <- 1 - pf(F_stat,nModalities - 1, df.H)
  # std err for the difference between 2 elements of theta.hat
  se.dif <- sqrt(2*(MS.TR + max(nReaders*(Cov.2 - Cov.3), 0))/nReaders)

  # inference on a single modality
  # if sgl == "corres" then only use modality-specific data
  #   else pool data across modalities
  if (sgl == "corres") {
    MSR.i <- c(var(theta.hat[1, ], na.rm = TRUE), var(theta.hat[2, ], na.rm = TRUE))
    Cov.2i <- c(Cov21, Cov22)
    Cov.2i[Cov.2i < 0] <- 0
    MSden.i <- MSR.i + nReaders*Cov.2i
    df.sgl <- (nReaders - 1)*MSden.i ^ 2/MSR.i ^ 2
    se.i <- sqrt(MSden.i/nReaders)
  }
  else {
    df.sgl <- (nReaders - 1)*((MS.R + (nModalities - 1)*MS.TR + nModalities*nReaders*max(Cov.2,0)) ^ 2)/((MS.R ^ 2) + (nModalities - 1)*(MS.TR ^ 2))
    se.i <- sqrt((MS.R + (nModalities - 1)*MS.TR + nModalities*nReaders*max(Cov.2,0))/nModalities/nReaders) # std err for a single element of theta.hat
  }

  covOR <- rep(NA, 12)
  covOR[1] <- (MS.R - MS.TR)/2 - Cov.1 + Cov.3
  covOR[2] <- MS.TR - VarE + Cov.1 + Cov.2 - Cov.3
  covOR[3] <- Cov.1;
  covOR[4] <- Cov.2;
  covOR[5] <- Cov.3;
  covOR[6] <- VarE;
  covOR[7] <- MSR.i[1] + Cov21 - VarE1;
  covOR[8] <- MSR.i[2] + Cov22 - VarE2;
  covOR[9] <- Cov21;
  covOR[10] <- Cov22;
  covOR[11] <- VarE1;
  covOR[12] <- VarE2;

  names(covOR) <- c("varR", "varTR", "cov1", "cov2", "cov3", "varE",
                    "varR.1", "varR.2", "cov2.1", "cov2.2", "varE.1", "varE.2")

  list(F_stat = F_stat, df.H = df.H, p = p, theta.i = theta.i, df.sgl = df.sgl,
       se.i = se.i, se.dif = se.dif, covOR = covOR, theta.hat = theta.hat, cov.hat = cov.hat)
}

