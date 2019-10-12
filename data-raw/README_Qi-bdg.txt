FDA mitosis data_detection_for FDA.xlsx was first received on 6/27/2018.
* Five modality-specific sheets of data containing scores from 5 readers + truth
** Columns are figure #, Obeserver 1, Obeserver 2, Obeserver 3, Obeserver 4, Obeserver 5, Ground truth
* Five reader-specific sheets of data containing scores given each modality + truth
** Columns are figure #, Scanner A, Scanner B, Scanner C, Scanner D, Microscope, Ground truth
* The data in the first five sheets is identical to the second five sheets. The difference is partitioning and formating by modality or reader.

MSK uploaded 3 files: to https://nciphub.org/projects/eedapdevelop/files/browse?subdir=/MSK on 3/13/2019
1. FDA mitosis data_detection.xlsx
2. FDA mitosis_annonymized.xlsx
3. mitotic candidates.pdf 

FDA mitosis data_detection.xlsx
* Five modality-specific sheets of data containing scores from 5 readers + truth + concordant 
** Columns are Series, Pict#, figure #, Obs 1, Obs 2, Obs 3, Obs 4, Obs 5, GT, concordant #, Obs 1, Obs 2, Obs 3, Obs 4, Obs 5, GT
* Five reader-specific sheets of data containing scores given each modality + truth
** Columns are Series, Pict#, figure #, S1, S2, S3, S4, Micro, GT, Scanner A, Scanner B, Scanner C, Scanner D, Microscope, GT
* Concordance sheet: Concordance between readers
** Columns are Series, Pict#, figure #, S1, S2, S3, S4, Micro
* The data in the first five sheets is identical to the second five sheets. The difference is partitioning and formating by modality or reader.

FDA mitosis_annonymized.xlsx
* Decision sheet: Part of cells evaluation result and screen shot
** Columns are Series, Pict #, figure #, Pict_FDA aperio, Pict_MSK_NDP, A, B, C, D, E, F, G, observer counts, concordant #	
** BDG: I thought this sheet was incomplete? It seems to have 40 ROIs!?
* Kappa sheet: Kappa analysis between different modalities. 

mitotic candidates.pdf
* 40 ROIs screen shot with marked cell. 

Using previous 14-head microscope cell mark data (mskcc20171103/data/dfMark.rda), Qi Gong created "FDA mitosis data_detection_for FDA-report.xlsx"
Brandon Gallas renamed this file to point to its origins and additions (see below): mskcc20180627withLoc.xlsx"
This file has the following old and new columns:
* <old> figure #
* <new> cellMark
* <new> wsiName
* <new> ROI_ID
* <new> cellID.mskcc20171103
* <new> xCell
* <new> yCell
* <old> Scanner A
* <old> Scanner B
* <old> Scanner C
* <old> Scanner D
* <old> Microscope
* <old> Ground truth



