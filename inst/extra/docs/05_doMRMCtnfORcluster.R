# Demonstrate doAUCmrmcORcluster ####

# Read data
df <- iMRMCcluster::obsMTG

start <- proc.time()

modalities <- levels(df$modalityID)
nModalities <- nlevels(df$modalityID)
readers <- levels(df$readerID)
nReaders <- nlevels(df$readerID)

# Split the data frame by readers and modalities
df.byModalityReader <- split(df, list(df$readerID, df$modalityID))


# Calculate covariances for each reader/case combination ####
tnf <- vector(mode = "numeric", nModalities*nReaders)
cov <- matrix(-1.0,
              nrow = nModalities*nReaders,
              ncol = nModalities*nReaders)
for (i in 1:(nModalities*nReaders)) {
  for (j in i:(nModalities*nReaders)) {

    df.merge <- merge(df.byModalityReader[[i]],
                      df.byModalityReader[[j]],
                      by = "locationID", all = TRUE)

    # Create tnf data.
    # Set all signal-present decisions to 0.5.
    # For all signal-absent decisions
    #     If score <= threshold then decision is signal absent = 0
    #     If score >  threshold then decision is signal absent = 1
    threshold <- 3.5
    df.merge$decision.x <- 0.5
    df.merge[df.merge$truth.x == 0 & df.merge$score.x <= threshold, "decision.x"] <- 0
    df.merge[df.merge$truth.x == 0 & df.merge$score.x >  threshold, "decision.x"] <- 1

    df.merge$decision.y <- 0.5
    df.merge[df.merge$truth.y == 0 & df.merge$score.y <= threshold, "decision.y"] <- 0
    df.merge[df.merge$truth.y == 0 & df.merge$score.y >  threshold, "decision.y"] <- 1

    result <- iMRMCcluster::doAUCcluster(
      predictor1 = df.merge$decision.x,
      predictor2 = df.merge$decision.y,
      response   = df.merge$truth.x,
      clusterID  = df.merge$wsiName.x,
      alpha      = 0.05)

    cov[i,j] <- (result$auc.var.A + result$auc.var.B
                 - result$auc.var.AminusB)/2
    cov[j,i] <- cov[i,j]
  }
  tnf[i] <- result$auc.A
}

# mrmcAnalysisOR ####
tnf <- matrix(tnf, nrow = 2, ncol = nReaders, byrow = TRUE)

tnfMTG.OR.new <- iMRMCcluster::MRMCAnalysisOR(tnf, cov)

finish <- proc.time()

print(finish - start)

botCI <- tnfMTG.OR.new$theta.i[1] - qnorm(0.975) * tnfMTG.OR.new$se.i[1]
topCI <- tnfMTG.OR.new$theta.i[1] + qnorm(0.975) * tnfMTG.OR.new$se.i[1]

print(botCI)
print(topCI)
print(tnfMTG.OR.new)

testthat::test_that(
  "The OR MRMC method based on OR AUC analysis of clustered data doesn't change.", {
    testthat::expect_equal(iMRMCcluster::tnfMTG.OR, tnfMTG.OR.new, tolerance = 1e-7)
  }
)

# END ####

# tnfMTG.OR <- tnfMTG.OR.new
# usethis::use_data(tnfMTG.OR, overwrite = TRUE)
