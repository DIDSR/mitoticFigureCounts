# mitoticFigureCounts

The [Mitotic Figure Counts repository](https://github.com/DIDSR/RDataPackages/tree/master/mitoticFigureCounts) contains the data, functions, and markdown files for a study comparing mitotic figure counting performance based on whole slide images (WSI images) from four scanners to the counts from a miscroscope.

Please cite the following article if data from this repository are used for your research. The article contains the details about this study.
* _Citation_: Tabata, K., N. Uraoka, J. Benhamida, M. G. Hanna, S. J. Sirintrapun, B. D. Gallas, Q. Gong, R. G. Aly, K. Emoto and K. M. J. D. P. Matsuda (2019). "Validation of mitotic cell quantification via microscopy and multiple whole-slide scanners."  14(1): 65.

All materials may be downloaded from this repository, or as an R package.
* [R package for download (source) - mitoticFigureCounts_1.0.tar.gz.](https://github.com/DIDSR/mitoticFigureCounts/releases/download/1.0/mitoticFigureCounts_1.0.tar.gz)
* [R package for download (binary) - mitoticFigureCounts_1.0.zip.](https://github.com/DIDSR/mitoticFigureCounts/releases/download/1.0/mitoticFigureCounts_1.0.zip)

## Study Design

* __5 modalities__ : 4 whole slide imaging (WSI) scanners and 1 miscroscope. 

* __5 observers__ : 5 pathologists.

* __4 slides==WSI images__ : HE-stained slides prepared from canine oral melanoma tissues that were scanned by the WSI scanners.

* __40 ROIs (Regions of Interest)__ : Ten (10) ROIs per slide. Each ROI was 200 x 200 um^2 (0.04 mm^2).

* __155 "candidate" mitotic figures (MF)__: 155 target cells from 40 ROIs.

* Study is fully crossed. 


## Main Assets

#### [dfClassify.csv](https://github.com/DIDSR/mitoticFigureCounts/releases/download/1.0/dfClassify20180627.csv)

A single data frame of the study data. Each row corresponds to a candidate mitotic figure and modality (155 candidates x 5 modalities = 775 rows). There is a column for each observer and the truth. This data is also included as an R object (data frame) in the R package. See [Documentation](https://didsr.github.io/mitoticFigureCounts/inst/extra/man/dfClassify20180627.html) for more details.

#### [dfCountROI.csv](https://github.com/DIDSR/mitoticFigureCounts/releases/download/1.0/dfCountROI20180627.csv)

A single data frame of the mitotic figure counts per ROI and modality (40 ROIs x 5 modalities = 200 rows). There is a column for each observer and the truth. This data is also included as an R object (data frame) in the R package. See [Documentation](https://didsr.github.io/mitoticFigureCounts/) for more details.

#### [dfCountWSI.csv](https://github.com/DIDSR/mitoticFigureCounts/releases/download/1.0/dfCountWSI20180627.csv)

A single data frame of the mitotic figure counts per WSI and modality (4 WSIs x 5 modalities = 20 rows). There is a column for each observer and the truth. This data is also included as an R object (data frame) in the R package. See [Documentation](https://didsr.github.io/mitoticFigureCounts/) for more details.

## Additional Assets

#### R stat script: [05_doMRMCaucORcluster.R](https://github.com/DIDSR/mitoticFigureCounts/raw/master/inst/extra/docs/05_doMRMCaucORcluster.R)

In this script we do an multi-reader multi-case (MRMC) analysis of the auc for each scanner. The MRMC analysis is accomplished by the OR method (Obuchowski and Rockette: Obuchowski1995_Commun-Stat-Simulat_v24p285). Since the data is binary, auc is the average of sensitivity and specificity or half of (Youden's index + 1). Sensitivity is defined as the number of MFs detected by an observer divided by the number of true MFs. Specificity is defined as one minus the false-positive fraction, where the false-positive fraction is the number of false MFs that were positively marked, divided by the total number of false MFs. Furthermore, we account for the fact that there are multiple observations per case (multiple ROIs per WSI) when calculating the reader by modality covariances that are used in the OR method (clustered data: Obuchowski1997_Biometrics_v53p567).

The script produces an R object '''aucMRMCcluster''' (a list of analyis results, 
[Documentation](https://didsr.github.io/mitoticFigureCounts/)). The analysis results are used to produce:
* Table 4 of the Tabata paper: Accuracy for all readers and observation methods
* Figure 3 of the Tabata paper: Accuracy (average of sensitivity and specificity) for each viewing mode averaged over all the readers with 95% confidence intervals. The asterisks indicate that the difference in accuracy of the viewing mode compared to that of microscopy is statistically significant. All analyses account for the correlations and variability from the readers reading the same ROIs.

#### R markdown file: [Tabata2019comparingScannersMFcounting-BlandAltman.Rmd](https://github.com/DIDSR/mitoticFigureCounts/raw/master/inst/extra/docs/Tabata2019comparingScannersMFcounting-BlandAltman.Rmd), [PDF](https://didsr.github.io/mitoticFigureCounts/inst/extra/docs/Tabata2019comparingScannersMFcounting-BlandAltman.pdf)

This R-markdown file combines text and R statistical analysis code for the Bland-Altman analysis and accuracy assessment performed in the paper. Both of these are MRMC analyses. The Bland-Altman analsysis makes use of U-statistics of degree 1,1 (One reader and one case). The U-statistics tools are found in the iMRMC package ([CRAN package](https://cran.r-project.org/web/packages/iMRMC/index.html), [GitHub repository](https://github.com/DIDSR/iMRMC))
