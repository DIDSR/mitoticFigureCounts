library(xlsx)
library(iMRMC)

# * Creating `data-raw`. ####
# * Adding `data-raw` to `.Rbuildignore`.
# Next:
#   * Add data creation scripts in data-raw
# * Use usethis::use_data() to add data to package

# Create usethis::use_data_raw()

# Open and read source data file ####

# We know that the study has 5 participants and 157 candidate mitotic figures
nReaders <- 5
readers <- c("observer.1", "observer.2", "observer.3", "observer.4", "observer.5")
nCases <- 157
cases <- 1:157
nModalities <- 5
modalities <- c("scanner.A", "scanner.B", "scanner.C", "scanner.D", "microscope")

# The source data file is an excel file with 10 sheets:
#   one set of 5 sheets for each scanner and
#   one set of 5 sheets for each reader.
# The data is redundant across these two sets
fileName <-   file.path("data-raw", "mskcc20180627withLoc.xlsx")

# Read each sheet into different data frames
df.scanner.A <- read.xlsx(fileName, sheetIndex = 1)
df.scanner.B <- read.xlsx(fileName, sheetIndex = 2)
df.scanner.C <- read.xlsx(fileName, sheetIndex = 3)
df.scanner.D <- read.xlsx(fileName, sheetIndex = 4)
df.microscope <- read.xlsx(fileName, sheetIndex = 5)
# df.observer.1 <- read.xlsx(fileName, sheetIndex = 6)
# df.observer.2 <- read.xlsx(fileName, sheetIndex = 7)
# df.observer.3 <- read.xlsx(fileName, sheetIndex = 8)
# df.observer.4 <- read.xlsx(fileName, sheetIndex = 9)
# df.observer.5 <- read.xlsx(fileName, sheetIndex = 10)
masterRawWithLoc <- list(
  df.scanner.A = df.scanner.A,
  df.scanner.B = df.scanner.B,
  df.scanner.C = df.scanner.C,
  df.scanner.D = df.scanner.D,
  df.microscope = df.microscope
  # df.observer.1 = df.observer.1,
  # df.observer.2 = df.observer.2,
  # df.observer.3 = df.observer.3,
  # df.observer.4 = df.observer.4,
  # df.observer.5 = df.observer.5
)

# Check the truth across all data frames
if (!all(df.scanner.A$Ground.truth == df.scanner.B$Ground.truth)) browser()
if (!all(df.scanner.A$Ground.truth == df.scanner.C$Ground.truth)) browser()
if (!all(df.scanner.A$Ground.truth == df.scanner.D$Ground.truth)) browser()
if (!all(df.scanner.A$Ground.truth == df.microscope$Ground.truth)) browser()
# if (!all(df.scanner.A$Ground.truth == df.observer.1$Ground.truth)) browser()
# if (!all(df.scanner.A$Ground.truth == df.observer.2$Ground.truth)) browser()
# if (!all(df.scanner.A$Ground.truth == df.observer.3$Ground.truth)) browser()
# if (!all(df.scanner.A$Ground.truth == df.observer.4$Ground.truth)) browser()
# if (!all(df.scanner.A$Ground.truth == df.observer.5$Ground.truth)) browser()

# Concatenate the list of data frames to create one master data frame ####
dfMaster <- data.frame()
iModality <- 1
for (iModality in 1:5) {

  df.current <- masterRawWithLoc[[iModality]]
  df.current$modalityID <- modalities[iModality]
  dfMaster <- rbind(dfMaster, df.current)

}

# Rename columns (misspellings)
dfMaster <- iMRMC::renameCol(dfMaster, "figure..", "targetID")
dfMaster <- iMRMC::renameCol(dfMaster, "ROI_ID", "roiID")
dfMaster <- iMRMC::renameCol(dfMaster, "Obeserver.1", "observer.1")
dfMaster <- iMRMC::renameCol(dfMaster, "Obeserver.2", "observer.2")
dfMaster <- iMRMC::renameCol(dfMaster, "Obeserver.3", "observer.3")
dfMaster <- iMRMC::renameCol(dfMaster, "Obeserver.4", "observer.4")
dfMaster <- iMRMC::renameCol(dfMaster, "Obeserver.5", "observer.5")
dfMaster <- iMRMC::renameCol(dfMaster, "Ground.truth", "truth")

# Make targetID a factor
dfMaster$targetID <- factor(dfMaster$targetID)
dfMaster$modalityID <- factor(dfMaster$modalityID)

# dfClassify: dfMaster includes rows corresponding to ROIs with no marks ####
# If there are no marks, then there are no candidates to classify.
# These rows need to be deleted ... "by hand"
dfClassify <- dfMaster
dfClassify <- dfClassify[dfClassify$targetID != 77, ]
dfClassify <- dfClassify[dfClassify$targetID != 114, ]
dfClassify$targetID <- factor(dfClassify$targetID)

# dfCountROI: Create df of counts per ROI and modality: including five readers and one truth ####
# Split the data by ROI and modality
dfMasterSplitByROIandModality <- split(dfMaster, list(dfMaster$roiID, dfMaster$modalityID))

iROI <- 1
dfCountROI <- data.frame()
for (iROI in 1:length(dfMasterSplitByROIandModality)) {

  df.current <- dfMasterSplitByROIandModality[[iROI]]
  dfCountROI <- rbind(
    dfCountROI, data.frame(
      wsiName = df.current[1, "wsiName"],
      roiID = df.current[1, "roiID"],
      modalityID = df.current[1, "modalityID"],
      observer.1 = sum(df.current[ , "observer.1"]),
      observer.2 = sum(df.current[ , "observer.2"]),
      observer.3 = sum(df.current[ , "observer.3"]),
      observer.4 = sum(df.current[ , "observer.4"]),
      observer.5 = sum(df.current[ , "observer.5"]),
      truth = sum(df.current[ , "truth"])
    )
  )

}

# dfCountWSI: Create df of counts per WSI and modality: including five readers and one truth ####
# Split the data by ROI and modality
dfCountROIsplitByWSI <- split(dfCountROI, list(dfCountROI$wsiName, dfCountROI$modalityID))

iWSI <- 1
dfCountWSI <- data.frame()
for (iWSI in 1:length(dfCountROIsplitByWSI)) {

  df.current <- dfCountROIsplitByWSI[[iWSI]]
  dfCountWSI <- rbind(
    dfCountWSI, data.frame(
      wsiName = df.current[1, "wsiName"],
      modalityID = df.current[1, "modalityID"],
      observer.1 = sum(df.current[ , "observer.1"]),
      observer.2 = sum(df.current[ , "observer.2"]),
      observer.3 = sum(df.current[ , "observer.3"]),
      observer.4 = sum(df.current[ , "observer.4"]),
      observer.5 = sum(df.current[ , "observer.5"]),
      truth = sum(df.current[ , "truth"])
    )
  )

}

# Save data ####
dfClassify20180627 = dfClassify
dfCountWSI20180627 = dfCountWSI
dfCountROI20180627 = dfCountROI

usethis::use_data(dfClassify20180627, overwrite = TRUE)
usethis::use_data(dfCountWSI20180627, overwrite = TRUE)
usethis::use_data(dfCountROI20180627, overwrite = TRUE)

write.csv(dfClassify20180627, row.names = FALSE, file.path("data", "dfClassify20180627.csv"))
write.csv(dfCountWSI20180627, row.names = FALSE, file.path("data", "dfCountWSI20180627.csv"))
write.csv(dfCountROI20180627, row.names = FALSE, file.path("data", "dfCountROI20180627.csv"))
