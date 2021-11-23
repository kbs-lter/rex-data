# rex-data
This repository contains data scripts for the KBS LTER Rain Exclusion Experiment, located at Michigan State University's (MSU) Kellogg Biological Station Long Term Ecological Research Site (KBS LTER).

## Funding
Support for this research was provided by the NSF Long-term Ecological Research Program (DEB 1832042) at the Kellogg Biological Station and by Michigan State University AgBioResearch. Please contact KBS LTER Principal Investigator Prof. Nick Haddad with notice of your publications or for questions on appropriate site, experiment, or acknowledgement language. Contact info & more details: https://lter.kbs.msu.edu/research/conducting-research/acknowledgements/.

## PIs involved in REX
Nick Haddad (MSU, KBS)

Sarah Evans (MSU, KBS)

Phil Robertson (MSU, KBS)

Jennifer Lau (Indiana University)

Steve Hamilton (MSU, KBS)

Christine Sprunger (Ohio State)

Phoebe Zarnetske (MSU)


## Overview
Data cleaning and prep = R scripts in this repistory (separated into appropriate folders: /L0, /L1, /L2, etc.)

Analysis = code & Rmarkdown-produced results on https://github.com/kbs-lter/rex-analysis 

Results = e.g., Rmarkdown-produced PDFs on KBS_LTER_REX Google Shared Drive

If non-R users want to analyze data, we will work with you to ensure you’re using the correct data.


## Location of data
Data location = “KBS_LTER_REX/Data” Google Shared Drive (accessible by project members). 

*Do not store data on or copy data into this repository.*


## Workflow
We are following the Environmental Data Initiative’s (EDI; https://environmentaldatainitiative.org/) data management guidelines for analysis-ready data: https://environmentaldatainitiative.org/dataset-design/.

![EDI Workflow Diagram](https://environmentaldatainitiative.files.wordpress.com/2019/04/harmonization_procedure_general.png)

In this repository, R scripts are used to convert L0 Data to L1 Data, L1 Data to L2 Data, etc. (these are Step 1, Step 2 in figure above). 

*Where do scripts go?*

Folder names in the Google Shared Drive are the same as in this GitHub repository. 

Scripts used to create L1 Data go in L1 folder in this rex_data repository in the subdirectory appropriate to the data theme. 


Example: 

L0 script to check plant phenology data in T7 would go here: https://github.com/kbs-lter/rex-data/T7_warmx_plant_phenology/L0

L1 Script to clean L0 plant phenology data in T7, creating the L1 Data, would go here: https://github.com/kbs-lter/rex-data/T7_warmx_plant_phenology/L1 

All Scripts used to analyze REX data go in GitHub rex_analysis repository in folder appropriate to analysis topic.


*What do scripts contain?*

- All scripts have a standard header - here’s an example: https://space-lab-msu.github.io/r_guide/documentation.html 
- Follow .R script template (load packages at start, read in data from Google Drive location after setting .Renviron)
- Commented code
- Exporting data (for L1, L2, L3 scripts) to KBS_LTER_REX Google Shared Drive at end of script; note the outputs in the header.

## R code

Below are lists of parent folders in this repository that match the same folder name in the KBS_LTER_REX Google Shared Drive. Each of these folders contains L0, L1, L2, etc. folders with the appropriate R scripts. 

**T7**
- T7_warmx_plant_phenology
- T7_warmx_plantCN
- T7_ANPP
- T7_warmx_VOC
- T7_warmx_SLA
- T7_warmx_plant_comp

(Enter other folders here as they are added)

*Nested inside each parent folder above are the following folders:*

**L0**: 
- The L0 folder in this repository contains scripts to check L0 data. *L0 Data* are raw data (unedited)- entered from datasheet or directly entered/logged electronically in field. *L0 Scripts* are scripts for checking raw data (reporting missing observations, number of observations, list of column headers and unique , etc.). 
- Once raw data (*L0 Data*) are entered or downloaded from an instrument, do not change raw data directly in a spreadsheet (No manual fixing of data in Excel or other spreadsheet program) - all editing occurs in R scripts located in L1, L2, etc. folders for track record and subsequent editing.


**L1**: 
- The L1 folder in this repository contains scripts to convert L0 data to L1 data. 
- *L1 Data* are cleaned/modified L0 Data that are cleaned via *L1 Scripts*. 
- *L1 Data* could be data that are derived data products that are gap filled.
- *L1 Data* could be data that are merged data products, as a result of merging multiple L1 Data, pre-analysis.
- The script to generate L1 data is very important, and anyone contributing should refer to someone who is knowledgeable about these data (PI) and the decisions to edit it.
- We will provide example scripts to go from L0 to L1. After an individual works on their first L1 script, they should meet with Sven / Nameer to go over it and get feedback.
- The **resolution** of *L1 Data* is the same as *L0 Data* (meaning each record reflects same temporal and spatial resolution as *L0 Data*)


**L2**: 
- *L2 Data* are derived data products that are aggregated L1 Data to a summary statistic (e.g., mean, variation) or a metric (e.g., diversity measure for plant community data). Aggregation is by a group or treatment and results in some coarser level L2 data product that usually results in fewer rows than the corresponding L0, L1 (e.g., subplot, or plot, treatment, species, etc.). 
- The **resolution** of *L2 Data* is coarser than L0, L1, meaning each record is an aggregate measure of data at lower level.
- The L2 folder in this repository contains scripts to convert L1 data to L2 data. 


## Code names
**Treatment**:	
- Conventional ag	T1
- Continuous no-till	T2
- Early successional	T7
	
**Replicates**:	R1-6
	
**Footprint locations**:	1-5
	
**Footprint**:	
- Y1 Drought (soy)	D1
- Y2 Drought (wheat)	D2
- Y3 Drought (corn)	D3
- Variable Rainfall	VR
- Control (irrigated)	IR
- OTC under rainout	OR
- OTC controls (ambient)	OC
	
**Subplot location**:	locations are always lower-case
- Northwest	a
- Northeast	b
- Southwest	c
- Southeast	d
	
**Subplot**:	
- Control	C
- Sorghum	S
- Switchgrass	G
- Biochar	B
- Fungicide	F
- Nematicide	N
- Insecticide	I
- Warming	W
- Insecticide + Warming	X
	
**Sample types**	
- Fresh soil	S
- Flash-frozen soil	F
- Leaf tissue	L


## Analysis
All analyses (including most plots) are performed in the separate repository: https://github.com/kbs-lter/rex-analysis
