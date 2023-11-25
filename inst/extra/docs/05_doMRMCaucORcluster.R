
# In this script we do an MRMC analysis of the auc for each scanner
# (OR method: Obuchowski and Rockette, Obuchowski1995_Commun-Stat-Simulat_v24p285).
# Since the data is binary, auc is the average of sensitivity and specificity
# or half of (Youden's index + 1). Sensitivity is defined as the number of
# MFs detected by an observer divided by the number of true MFs.
# Specificity is defined as one minus the false-positive fraction,
# where the false-positive fraction is the number of false MFs that were positively marked,
# divided by the total number of false MFs.
# Furthermore, we account for the fact that there are multiple observations per case
# (multiple ROIs per WSI, clustered data: Obuchowski1997_Biometrics_v53p567)
# when calculating the reader by modality covariances that are used in the OR method.
# 
# The results of this script yield:
#     Table 4: Accuracy for all readers and observation methods
#     Figure 3: Accuracy (average of sensitivity and specificity) for each viewing mode
# averaged over all the readers with 95% confidence intervals. The asterisks indicate
# that the difference in accuracy of the viewing mode compared to that of microscopy
# is statistically significant. All analyses account for the correlations and variability
# from the readers reading the same ROIs.

# Initialize functions ####

library(mitoticFigureCounts)

doMRMCaucORcluster <- function(df) {
  modalities <- levels(df$modalityID)
  nModalities <- nlevels(df$modalityID)
  readers <- levels(df$readerID)
  nReaders <- nlevels(df$readerID)

  # Split the data frame by readers and modalities
  df.byModalityReader <- split(df, list(df$readerID, df$modalityID))

  # Calculate covariances for each reader/modality combination ####
  auc <- vector(mode = "numeric", nModalities*nReaders)
  cov <- matrix(-1.0,
                nrow = nModalities*nReaders,
                ncol = nModalities*nReaders)
  for (i in 1:(nModalities*nReaders)) {
    for (j in i:(nModalities*nReaders)) {

      print(i)
      print(j)
      df.merge <- merge(df.byModalityReader[[i]],
                        df.byModalityReader[[j]],
                        by = "targetID", all = TRUE)

      result <- doAUCcluster(
        predictor1 = df.merge$score.x,
        predictor2 = df.merge$score.y,
        response   = df.merge$truth.x,
        clusterID  = df.merge$wsiName.x,
        alpha      = 0.05)

      cov[i,j] <- (result$auc.var.A + result$auc.var.B
                   - result$auc.var.AminusB)/2
      cov[j,i] <- cov[i,j]
    }
    auc[i] <- result$auc.A
  }

  # mrmcAnalysisOR ####
  auc <- matrix(auc, nrow = 2, ncol = nReaders, byrow = TRUE)

  aucMTG.OR.new <- mrmcAnalysisOR(auc, cov)

  aucMTG.OR.new$botCI <- aucMTG.OR.new$theta.i - qt(0.975, df = aucMTG.OR.new$df.sgl) * aucMTG.OR.new$se.i
  aucMTG.OR.new$topCI <- aucMTG.OR.new$theta.i + qt(0.975, df = aucMTG.OR.new$df.sgl) * aucMTG.OR.new$se.i

  print(aucMTG.OR.new)
}

# Initialize data ####

df.orig <- mitoticFigureCounts::dfClassify20180627

# Convert data to list-mode
readers <- c(
  "observer.1",
  "observer.2",
  "observer.3",
  "observer.4",
  "observer.5"
)

df.convert <- convertDF(df.orig, "matrixWithTruth", "listWithTruth", readers, nameTruth)
df.convert$caseID <- df.convert$targetID
df.convert$readerID <- factor(df.convert$readerID)
df.convert$locationID <- df.convert$roiID
df.convert$modalityID <- factor(df.convert$modalityID)

# Split the data by modality
df.convert <- split(df.convert, df.convert$modalityID)

# Analyze modality.A ####
start <- proc.time()

df.A <- rbind(df.convert$microscope, df.convert$scanner.A)
df.A$modalityID <- factor(df.A$modalityID)
result.A <- doMRMCaucORcluster(df.A)

finish <- proc.time()
print(finish - start)

# Analyze modality.B ####
start <- proc.time()

df.B <- rbind(df.convert$microscope, df.convert$scanner.B)
df.B$modalityID <- factor(df.B$modalityID)
result.B <- doMRMCaucORcluster(df.B)

finish <- proc.time()
print(finish - start)

# Analyze modality.C ####
start <- proc.time()

df.C <- rbind(df.convert$microscope, df.convert$scanner.C)
df.C$modalityID <- factor(df.C$modalityID)
result.C <- doMRMCaucORcluster(df.C)

finish <- proc.time()
print(finish - start)

# Analyze modality.D ####
start <- proc.time()

df.D <- rbind(df.convert$microscope, df.convert$scanner.D)
df.D$modalityID <- factor(df.D$modalityID)
result.D <- doMRMCaucORcluster(df.D)

finish <- proc.time()
print(finish - start)

aucMRMCcluster <- list(result.A, result.B, result.C, result.D)
names(aucMRMCcluster) <- c("ScannerA", "ScannerB", "ScannerC", "ScannerD")
usethis::use_data(aucMRMCcluster, overwrite = TRUE)
