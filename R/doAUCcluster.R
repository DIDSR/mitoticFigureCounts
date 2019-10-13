# Sub functions ####
kern = function(x1, x0) {
  if (x1  > x0)      return(1.0)
  else if (x1 == x0) return(0.5)
  else if (x1  < x0) return(0.0)
}

V10 = function(Xi, Ys) {
  sum(sapply(Ys, FUN = kern, x1 = Xi)) / length(Ys)
}

V01 = function(Xs, Yi) {
  sum(sapply(Xs, FUN = kern, x0 = Yi)) / length(Xs)
}

getAUC = function(Xs, Ys) {
  sum(sapply(Xs, function(Xi) {
    sapply(Ys, FUN = kern, x1 = Xi)
  })) / (length(Xs)*length(Ys))
}


#### doAUCcluster ####
#' doAUCcluster
#'
#' @description Do AUC analysis of clustered data.
#'
#' This function is based on the analysis described in:
#' Obuchowski NA. "Nonparametric analysis of clustered ROC curve data."
#' Biometrics. 1997: 567-578.
#'
#' This function is an adaptation of a function downloaded from the
#' Cleveland Clinic Lerner Research Institute
#' Department of Quantitative Health Sciences Software web page.
#' 
#' FILE: \url{https://www.lerner.ccf.org/qhs/software/lib/funcs_clusteredROC.R}
#' 
#' WEBPAGE: \url{https://www.lerner.ccf.org/qhs/software/roc_analysis.php}
#'
#' @details 
#' iMRMC users shared the links during a discussion with questions about
#' how to analyze MRMC data that was clustered.
#' \url{https://github.com/DIDSR/iMRMC/issues/147}
#
#' There is a short pdf tutorial a
#' \url{https://www.lerner.ccf.org/qhs/software/lib/clusteredROC_help.pdf.}
#' It exists in the inst/extra/docs folder of the repository.
#' It exists in the extra/docs folder of the installed package.
#'
#' @param predictor1 a vector containing the predictor for ROC curve 1
#' @param predictor2 a vector containing the predictor for ROC curve 2
#' @param response a vector containing the response for both ROC curves
#' @param clusterID a vector containing IDs for the clusters
#' @param alpha the type I error rate
#' @param level can be used to specify the response level considered positive
#'    (if omitted, the second level of the response is selected)
#' @param print.all if TRUE, intermediate estimates are printed
#'
#' @return [list] auc, auc.se, ci.for.auc
#' 
#' @import stats
#' 
#' @export
#'
# @examples
doAUCcluster = function(predictor1, predictor2=NULL,
                        response, clusterID, alpha=0.05,
                        level=NULL, print.all=F) {

  # Establish which response variable is disease-present and disease absent
  if (is.null(level))
  {
    absent  = levels(as.factor(response))[1]
    present = levels(as.factor(response))[2]
  } else
  {
    absent  = levels(as.factor(response))[levels(as.factor(response)) != level]
    present = level
  }

  # One ROC curve ####
  if (is.null(predictor2) == T) {

    # Find and remove rows with missing data
    missings = which(is.na(predictor1) == T)
    if (length(missings) > 0) {
      predictor1 = predictor1[-missings]
      response   = response[-missings]
      clusterID  = clusterID[-missings]
    }

    # Determine the number of clusters
    I   = length(unique(clusterID))
    # Determine the number of clusters with a sig-present observation
    I01 = length(unique(clusterID[response == absent]))
    # Determine the number of clusters with a sig-absent observation
    I10 = length(unique(clusterID[response == present]))

    # Determine the number of sig-present observations in each cluster
    m   = sapply(1:I, function(i)
      sum(clusterID == unique(clusterID)[i] & response == present))
    # Determine the number of sig-absent observations in each cluster
    n   = sapply(1:I, function(i)
      sum(clusterID == unique(clusterID)[i] & response == absent))
    # Determine the number of observations in each cluster
    s   = m + n
    # Determine the number of sig-present and sig-absent observations
    M   = sum(m)
    N   = sum(n)

    # Calculate AUC
    AUC1 = getAUC(predictor1[response == present],
                  predictor1[response == absent])

    # Loop over all cases
    Xcomps.1 = rep(NA, I)
    Ycomps.1 = rep(NA, I)
    for (i in 1:I) {
      # If there are sig-present observations in the cluster_i,
      # compare each to all sig-absent observations to get V10(Xij),
      # and then sum over sig-present cluster_i observations to get V10(xi.)
      if (m[i] == 0) {
        Xcomps.1[i] = 0
      }  else {
        Xcomps.1[i] = sum(sapply(1:m[i], function(j)
          V10(Xi = predictor1[
            clusterID == unique(clusterID)[i] & response == present][j],
            Ys = predictor1[response == absent])))
      }
      # If there are sig-absent observations in the cluster_i,
      # compare each to all sig-present observations to get V01(Yik),
      # and then sum over sig-absent cluster_i observations to get V01(Yi.)
      if (n[i] == 0) {
        Ycomps.1[i] = 0
      } else {
        Ycomps.1[i] = sum(sapply(1:n[i], function(j)
          V01(Yi = predictor1[
            clusterID == unique(clusterID)[i] & response == absent][j],
            Xs = predictor1[response == present])))
      }
    }

    # Calculate the sum of squares of the X components
    S10_1 = (I10/((I10 - 1)*M)) * sum((Xcomps.1 - m*AUC1) * (Xcomps.1 - m*AUC1))
    # Calculate the sum of squares of the Y components
    S01_1 = (I01/((I01 - 1)*N)) * sum((Ycomps.1 - n*AUC1) * (Ycomps.1 - n*AUC1))
    # Calculate the cross-product between units within the same cluster
    S11_1 = (I/(I - 1))         * sum((Xcomps.1 - m*AUC1) * (Ycomps.1 - n*AUC1))
    # Calculate the variance and standard error
    # given the sums of squares and the cross-prodcut
    var_1 = S10_1/M + S01_1/N + (2*S11_1)/(M*N)
    AUC1.SE = sqrt(round(var_1, digits = 15))

    # Calculate the confidence limits under a normal approximation
    AUC1.CIlo = AUC1 - qnorm(1 - alpha/2)*AUC1.SE
    AUC1.CIhi = AUC1 + qnorm(1 - alpha/2)*AUC1.SE

    if (print.all) {
      cat("\n")
      cat("Total # of clusters: ", I, "\n", sep = '')
      cat("Total # of observations: ", length(clusterID), "\n", sep = '')
      cat("Min # of observations per cluster: ", min(s), "\n", sep = '')
      cat("Max # of observations per cluster: ", max(s), "\n", sep = '')
      cat("AUC (SE) for ROC curve: ", round(AUC1,4),
          " (", round(AUC1.SE,4), ")\n", sep = '')
      cat((100*(1 - alpha)),"% CI for AUC: ",
          "(", round(AUC1.CIlo,4), ", ", round(AUC1.CIhi,4), ")\n\n",
          sep = '')

      name = c("I", "I10", "I01", "M", "N", "S10", "S01", "S11")
      value = c(I, I10, I01, M, N, S10_1, S01_1, S11_1)
      print(data.frame(name, value))
    }
  }

  # Two correlated ROC curves ####
  if (is.null(predictor2) == F) {

    # Find and remove rows with missing data
    missings = which(is.na(predictor1) == T | is.na(predictor2) == T)
    if (length(missings) > 0) {
      predictor1 = predictor1[-missings]
      predictor2 = predictor2[-missings]
      response   = response[-missings]
      clusterID  = clusterID[-missings]
    }

    # Determine the number of clusters
    I   = length(unique(clusterID))
    # Determine the number of clusters with a sig-present observation
    I01 = length(unique(clusterID[response == absent]))
    # Determine the number of clusters with a sig-absent observation
    I10 = length(unique(clusterID[response == present]))

    # Determine the number of sig-present observations in each cluster
    m   = sapply(1:I, function(i)
      sum(clusterID == unique(clusterID)[i] & response == present))
    # Determine the number of sig-abssent observations in each cluster
    n   = sapply(1:I, function(i)
      sum(clusterID == unique(clusterID)[i] & response == absent))
    # Determine the number of observations in each cluster
    s   = m + n
    # Determine the number of sig-present and sig-absent observations
    M   = sum(m)
    N   = sum(n)

    # Calculate AUC
    AUC1 = getAUC(predictor1[response == present],
                  predictor1[response == absent])
    AUC2 = getAUC(predictor2[response == present],
                  predictor2[response == absent])

    # Loop over all clusters
    Xcomps.1 = rep(NA, I)
    Xcomps.2 = rep(NA, I)
    Ycomps.1 = rep(NA, I)
    Ycomps.2 = rep(NA, I)
    for (i in 1:I) {

      # If there are sig-present observations in the cluster_i,
      # compare each to all sig-absent observations to get V10(Xij),
      # and then sum over sig-present cluster_i observations to get V10(xi.)
      if (m[i] == 0) {
        Xcomps.1[i] = 0
        Xcomps.2[i] = 0
      }  else {
        Xcomps.1[i] = sum(sapply(1:m[i], function(j)
          V10(
            Xi = predictor1[
              clusterID == unique(clusterID)[i] & response == present][j],
            Ys = predictor1[response == absent])))
        Xcomps.2[i] = sum(sapply(1:m[i], function(j)
          V10(
            Xi = predictor2[
              clusterID == unique(clusterID)[i] & response == present][j],
            Ys = predictor2[response == absent])))
      }

      # If there are sig-absent observations in the cluster_i,
      # compare each to all sig-present observations to get V01(Yik),
      # and then sum over sig-absent cluster_i observations to get V01(Yi.)
      if (n[i] == 0) {
        Ycomps.1[i] = 0
        Ycomps.2[i] = 0
      }  else {
        Ycomps.1[i] = sum(sapply(1:n[i], function(j)
          V01(
            Yi = predictor1[
              clusterID == unique(clusterID)[i] & response == absent][j],
            Xs = predictor1[response == present])))
        Ycomps.2[i] = sum(sapply(1:n[i], function(j)
          V01(
            Yi = predictor2[
              clusterID == unique(clusterID)[i] & response == absent][j],
            Xs = predictor2[response == present])))
      }
    }

    # Calculate the sum of squares of the X components
    S10_1  = (I10/((I10 - 1)*M)) * sum((Xcomps.1 - m*AUC1) * (Xcomps.1 - m*AUC1))
    S10_2  = (I10/((I10 - 1)*M)) * sum((Xcomps.2 - m*AUC2) * (Xcomps.2 - m*AUC2))
    S10_12 = (I10/((I10 - 1)*M)) * sum((Xcomps.1 - m*AUC1) * (Xcomps.2 - m*AUC2))

    # Calculate the sum of squares of the Y components
    S01_2  = (I01/((I01 - 1)*N)) * sum((Ycomps.2 - n*AUC2) * (Ycomps.2 - n*AUC2))
    S01_1  = (I01/((I01 - 1)*N)) * sum((Ycomps.1 - n*AUC1) * (Ycomps.1 - n*AUC1))
    S01_12 = (I01/((I01 - 1)*N)) * sum((Ycomps.1 - n*AUC1) * (Ycomps.2 - n*AUC2))

    # Calculate the cross-product between units within the same cluster
    S11_1  = (I/(I - 1))         * sum((Xcomps.1 - m*AUC1) * (Ycomps.1 - n*AUC1))
    S11_2  = (I/(I - 1))         * sum((Xcomps.2 - m*AUC2) * (Ycomps.2 - n*AUC2))
    S11_12 = (I/(I - 1))         * sum((Xcomps.1 - m*AUC1) * (Ycomps.2 - n*AUC2))
    S11_21 = (I/(I - 1))         * sum((Xcomps.2 - m*AUC2) * (Ycomps.1 - n*AUC1))

    # Calculate the (co)variances
    # given the sums of squares and the cross-prodcut
    var_1  = S10_1/M  + S01_1/N  + (2*S11_1)/(M*N)
    var_2  = S10_2/M  + S01_2/N  + (2*S11_2)/(M*N)
    cov_12 = S10_12/M + S01_12/N +    S11_12/(M*N) + S11_21/(M*N)

    AUC1.SE = sqrt(round(var_1, digits = 15))
    AUC2.SE = sqrt(round(var_2, digits = 15))

    # Calculate the confidence limits under a normal approximation
    AUC1.CIlo = AUC1 - qnorm(1 - alpha/2)*AUC1.SE
    AUC1.CIhi = AUC1 + qnorm(1 - alpha/2)*AUC1.SE
    AUC2.CIlo = AUC2 - qnorm(1 - alpha/2)*AUC2.SE
    AUC2.CIhi = AUC2 + qnorm(1 - alpha/2)*AUC2.SE

    DIFF      = abs(AUC1 - AUC2)
    var.AminusB = var_1 + var_2 - 2*cov_12
    DIFF.SE   = sqrt(round(var.AminusB, digits = 15))
    DIFF.CIlo = DIFF - qnorm(1 - alpha/2)*DIFF.SE
    DIFF.CIhi = DIFF + qnorm(1 - alpha/2)*DIFF.SE
    p = 2*(1 - pnorm(DIFF/DIFF.SE))

    if (print.all) {
      cat("\n")
      cat("Total # of clusters: ", I, "\n", sep = '')
      cat("Total # of observations: ", length(clusterID), "\n", sep = '')
      cat("Min # of observations per cluster: ", min(s), "\n", sep = '')
      cat("Max # of observations per cluster: ", max(s), "\n", sep = '')
      cat("AUC (SE) for ROC curve 1: ", round(AUC1,4),
          " (", round(AUC1.SE,4), ")\n", sep = '')
      cat("AUC (SE) for ROC curve 2: ", round(AUC2,4),
          " (", round(AUC2.SE,4), ")\n", sep = '')
      cat("Difference (SE): ", round(DIFF,4),
          " (", round(DIFF.SE,4), ")\n", sep = '')
      cat((100*(1 - alpha)),"% CI for difference: ",
          "(", round(DIFF.CIlo,4), ", ", round(DIFF.CIhi,4), ")\n", sep = '')
      cat("Associated p-value: ", format(p,digits = 4), "\n\n", sep = '')

      name = c("I", "I10", "I01", "M", "N",
               "reader 1 S10", "reader 1 S01", "reader 1 S11",
               "reader 2 S10", "reader 2 S01", "reader 2 S11",
               "S10_12", "S01_12", "S11_12", "S11_21")
      value = c(I, I10, I01, M, N,
                S10_1, S01_1, S11_1,
                S10_2, S01_2, S11_2,
                S10_12, S01_12, S11_12, S11_21)
      print(data.frame(name, value))
    }
  }
  if (is.null(predictor2) == T) {
    invisible(data.frame(auc = AUC1,
                   auc.var = var_1,
                   auc.se = AUC1.SE,
                   ci.bot = AUC1.CIlo,
                   ci.top = AUC1.CIhi))
  } else {
    invisible(data.frame(auc.A = AUC1,
                   auc.var.A = var_1,
                   auc.se.A = AUC1.SE,
                   ci.bot.A = AUC1.CIlo,
                   ci.top.A = AUC1.CIhi,

                   auc.B = AUC2,
                   auc.var.B = var_2,
                   auc.se.B = AUC2.SE,
                   ci.bot.B = AUC2.CIlo,
                   ci.top.B = AUC2.CIhi,

                   auc.AminusB = DIFF,
                   auc.var.AminusB = var.AminusB,
                   auc.se.AminusB = DIFF.SE,
                   ci.bot.AminusB = DIFF.CIlo,
                   ci.top.AminusB = DIFF.CIhi,
                   p.value = p))
  }
}








