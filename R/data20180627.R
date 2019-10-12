## dfClassify20180627 ####
#' @title dfClassify20180627
#'
#' @name dfClassify20180627
#'
#' @description A single data frame of the study data.
#' Each row corresponds to a candidate mitotic figure and modality
#' (155 candidates * 5 modalities = 775 rows)
#'
#' @details A data frame with 14 columns:
#'   \itemize{
#'     \item \code{targetID} [Factor] Target cell ID = (candidate mitotic figure ID)
#'     \item \code{cell.mark} [Factor] ROI ID, "dash", Cell ID in the ROI
#'     \item \code{wsiName} [Factor] WSI file name
#'     \item \code{roiID} [Factor] ROI ID
#'     \item \code{cellID.mskcc20171103} [Factor] Descriptive target cell ID,
#'       including ROI ID, WSI file name, x position of target cell, y position of target cell
#'     \item \code{xCell} [Factor] x position of target cell
#'     \item \code{yCell} [Factor] y position of target cell
#'     \item \code{observer.1} [num] Observer1 modality-specific decision on the candidate MF
#'     \item \code{observer.2} [num] Observer2 modality-specific decision on the candidate MF
#'     \item \code{observer.3} [num] Observer3 modality-specific decision on the candidate MF
#'     \item \code{observer.4} [num] Observer4 modality-specific decision on the candidate MF
#'     \item \code{observer.5} [num] Observer5 modality-specific decision on the candidate MF
#'     \item \code{truth} [num] Truth panel decision on the candidate MF
#'     \item \code{modalityID} [Factor] modality ID (scanner or microscope)
#'   }
#'   
#'   Some of this data is missing location information.
#'
#'
"dfClassify20180627"

## dfCountROI20180627 ####
#' dfCountROI20180627
#'
#' @description A single data frame of the mitotic figure counts per ROI and modality (40 ROIs x 5 modalities = 200 rows). There is a column for each observer and the truth.
#'
#' @details A data frame with 9 columns:
#'    \itemize{
#'     \item \code{wsiName} [Factor] WSI file name
#'     \item \code{roiID} [Factor] ROI ID
#'     \item \code{modalityID} [Factor] modality, scanner ID
#'     \item \code{observer.1} [num] Observer1 modality-specific count for the ROI
#'     \item \code{observer.2} [num] Observer2 modality-specific count for the ROI
#'     \item \code{observer.3} [num] Observer3 modality-specific count for the ROI
#'     \item \code{observer.4} [num] Observer4 modality-specific count for the ROI
#'     \item \code{observer.5} [num] Observer5 modality-specific count for the ROI
#'     \item \code{truth} [num] Truth panel count for the ROI
#'    }
#'
"dfCountROI20180627"

## dfCountWSI20180627 ####
#' dfCountWSI20180627

#' @name dfCountWSI20180627
#'
#' @description A single data frame of the mitotic figure counts per WSI and modality (4 WSIs x 5 modalities = 20 rows). There is a column for each observer and the truth.
#'
#' @details A data frame with 8 columns: \cr
#'   \itemize{
#'     \item \code{wsiName} [Factor] WSI file name
#'     \item \code{modalityID} [Factor] modality, scanner ID
#'     \item \code{observer.1} [num] Observer1 modality-specific count for the WSI
#'     \item \code{observer.2} [num] Observer2 modality-specific count for the WSI
#'     \item \code{observer.3} [num] Observer3 modality-specific count for the WSI
#'     \item \code{observer.4} [num] Observer4 modality-specific count for the WSI
#'     \item \code{observer.5} [num] Observer5 modality-specific count for the WSI
#'     \item \code{truth} [num] Truth panel count for the WSI
#'   }
#'
"dfCountWSI20180627"

## aucMRMCcluster ####
#' aucMRMCcluster
#' @name aucMRMCcluster
#'
#' @description
#' The results of a multi-reader multi-case (MRMC) analysis of the auc for each scanner.
#' The MRMC analysis is accomplished by the OR method (Obuchowski and Rockette:
#' Obuchowski1995_Commun-Stat-Simulat_v24p285). Since the data is binary,
#' auc is the average of sensitivity and specificity or half of (Youden's index + 1).
#' Sensitivity is defined as the number of MFs 
#' detected by an observer divided by the number of true MFs. 
#' Specificity is defined as one minus the false-positive fraction, 
#' where the false-positive fraction is the number of false MFs that were positively marked, 
#' divided by the total number of false MFs.
#' Furthermore, we account for the fact that there are multiple observations 
#' per case (multiple ROIs per WSI, clustered data: Obuchowski1997_Biometrics_v53p567) 
#' when calculating the reader by modality covariances that are used in the OR method.
#' 
#' @details 
#' 
#' The results of this script are a list of MRMC AUC analysis results for 4 scanners.
#' \itemize{
#'   \item Scanner.A,
#'   \item Scanner.B, 
#'   \item Scanner.C, 
#'   \item Scanner.D
#' }
#'   
#' Each scanner results is itself a list contains the MRMC analysis results
#' for the null hypothesis that the scanner accuracy is the same as the microscope accuracy:
#' \itemize{
#'   \item \code{F_stat}, F-statistic
#'   \item \code{df.H}, Degrees of freedom
#'   \item \code{p}, p-value
#'   \item \code{theta.i}, [2] Accuracy of the microscope and scanner
#'   \item \code{df.sgl}, [2] Degrees of freedom for the microscope and the scanner
#'   \item \code{se.i}, [2] Standard error of the microscope and scanner accuracy
#'   \item \code{se.dif}, Standard erro of the microscope and scanner accuracy difference 
#'   \item \code{covOR}, [12] Obuchowski and Rockette covariances:
#'     varR, varTR, cov1, cov2, cov3, varE, varR.1, varR.2, cov2.1, cov2.2, varE.1, varE.2
#'   \item \code{theta.hat}, [2x5] Accuracy of each reader for the microscope (row 1)
#'     and accuracy of each reader for the scanner (row 2)
#'   \item \code{cov.hat}, [10x10] Reader by modality (microscope and scanner) covariance matrix
#'   \item \code{botCI}, [2] Bottom 95% confidence interval limit for the microscope and scanner
#'   \item \code{topCI}, [2] Top 95% confidence interval limit for the microscope and scanner
#' }
#' 
#' #' The analysis results are used to produce:
#' \itemize{
#'   \item{Table 4: Accuracy for all readers and observation methods}
#'   \item{Figure 3: Accuracy (average of sensitivity and specificity) for each viewing mode 
#'     averaged over all the readers with 95% confidence intervals. 
#'     The asterisks indicate that the difference in accuracy of the viewing mode
#'     compared to that of microscopy is statistically significant. 
#'     All analyses account for the correlations and variability from the readers 
#'     reading the same ROIs.}
#' }
#' 
#'
"aucMRMCcluster"