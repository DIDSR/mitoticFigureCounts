#' convertDF
#'
#' @description 
#' This function converts a "matrixWithTruth" data frame to a "listWithTruth" data frame.
#' The "matrix" part of the input data frame is understood to contain scores from readers:
#' One column for each reader. Column names are the reader names. The reader names (column names) need
#' to be specified in the "readersVector" input parameter.
#' 
#' @param inDF Counting data frame: dfClassify: \code{\link{dfClassify20180627}}
#' @param inDFtype Type of input data frame 
#' @param outDFtype Type of output data frame
#' @param readers Vector of reader IDs
#' @param nameTruth Column name of truth
#'
#' @return Output data frame with 11 column 
#'       targetID, cell.mark, wsiName, roiID, cellID.mskcc20171103, xCell, yCell, truth, modalityID, readerID, score
#' @export
#'
#' @examples
#' dfClassify <- mitoticFigureCounts::dfClassify20180627
#' readersVector <- names(dfClassify)[8:12]
#' nameTruth <- names(dfClassify)[13]
#' df.convert <- convertDF(dfClassify, "matrixWithTruth", "listWithTruth", readersVector, nameTruth)
#' head(dfClassify)
#' head(df.convert)
convertDF <- function(inDF, inDFtype, outDFtype, readers, nameTruth){

  if (inDFtype == "matrixWithTruth" & outDFtype == "listWithTruth"){

    # Split the data frame by columns, with and without the readers
    dfReaders <- inDF[ , (colnames(inDF) %in% readers)]
    dfNoReaders <- inDF[ , !(colnames(inDF) %in% readers)]

    # Replicate the data without readers while adding the data for each reader
    outDF <- data.frame()
    for (iReader in readers) {

      # Start with the data frame with no readers
      tempDF <- dfNoReaders
      # Add a column "readerID" and assign it the reader name
      tempDF$readerID <- iReader
      # Add a column "score" and assign it the scores of the current reader
      tempDF$score <- dfReaders[ , iReader]
      # Aggregate the reader data into the output data frame
      outDF <- rbind(outDF, tempDF)

    }

    return(outDF)

  }

}
