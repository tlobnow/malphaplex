#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
if (length(args) >= 2) {
    LOC_OUT    <- args[1]
    OUT_NAME   <- args[2]
} else {
    LOC_OUT    <- dirname(getwd())
    OUT_NAME   <- basename(LOC_OUT)
}
cat("LOC_OUT: ", LOC_OUT, "\n")
cat("OUT_NAME: ", OUT_NAME, "\n")

OVERWRITE_CSV = FALSE
unlink(".RData")

# Load required libraries
pacman::p_load(tidyr,stringr,jsonlite,janitor,fs,purrr,utils,data.table,dplyr)
#cat("Libraries loaded.\n")

# Function to extract information from JSON files
jsonExtract <- function(jsonFile, outFile, fileName) {
	# Read the JSON file
	jsonData <- fromJSON(jsonFile)

	# Extract relevant information using pivot_longer function
	model <- strsplit(jsonData$order[[1]], "_", fixed = TRUE)[[1]][2]
	#model <- jsonData$order %>% as.data.frame() %>% rename(RECYCLE = 1) %>% mutate(MODEL = as.numeric(str_extract(RECYCLE, "(?<=model_)[0-5]")))
	tolData <- jsonData$tol_values %>% as.data.frame() %>% pivot_longer(everything(), names_to = "RECYCLE", values_to = "TOL") 
	pLDDTData <- jsonData$plddts %>% as.data.frame() %>% pivot_longer(everything(), names_to = "RECYCLE", values_to = "pLDDT") 
	pTMData <- jsonData$ptms %>% as.data.frame() %>% pivot_longer(everything(), names_to = "RECYCLE", values_to = "pTM") 
	piTMData <- jsonData$pitms %>% as.data.frame() %>% pivot_longer(everything(), names_to = "RECYCLE", values_to = "piTM") 
	iScoreData <- jsonData$`interface score` %>% as.data.frame() %>% pivot_longer(everything(), names_to = "RECYCLE", values_to = "iScore") 
	iResData <- jsonData$`interfacial residue number` %>% as.data.frame() %>% pivot_longer(everything(), names_to = "RECYCLE", values_to = "iRes") 
	iCntData <- jsonData$`interficial contact number` %>% as.data.frame() %>% pivot_longer(everything(), names_to = "RECYCLE", values_to = "iCnt") 
	fileModel <- paste(fileName, "MODEL", model, sep = "_")
	numClusters <- jsonData$clusters[[iScoreData$RECYCLE[1]]]$num_clusters
	numMonomers <- length(jsonData$chains)

	# Combine the extracted data into a data frame
	extractedData <- cbind(fileName, model, tolData, pLDDTData, pTMData, piTMData, iScoreData, iResData, iCntData, fileModel, numClusters, numMonomers)

	# Remove duplicated column names, if any
	extractedData <- extractedData[, !duplicated(colnames(extractedData))]

	# Write the extracted data to the output file
	write.table(extractedData, file = paste0(outFile, "_withRecycles.csv"), sep = ",", append = TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE)

	# Filter out recycled data and write to a separate file
	extractedDataNoRecycle <- extractedData %>% filter(!str_detect(RECYCLE, "_recycled_"))
	write.table(extractedDataNoRecycle, file = paste0(outFile, ".csv"), sep = ",", append = TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE)
}

# retrieve the files of interest, for now only one file, but loop can be used for folder structures containing subfolders
files <- OUT_NAME

# Iterate over each file
for (fileName in files) {
	# Get the complete path of the output folder
	folder <- LOC_OUT

	dir_create(folder,"CSV")

	csv_WithRecycles <- file.path(folder, "CSV", paste0(fileName, "_withRecycles.csv"))
	csv <- file.path(folder, "CSV", paste0(fileName, ".csv"))

	# Check if CSV files already exist
	if (file.exists(csv_WithRecycles) && file.exists(csv)) {
		# If OVERWRITE_CSV is TRUE, remove existing files and create new ones
		if (OVERWRITE_CSV) {
			file.remove(csv_WithRecycles)
			file.remove(csv)
		} else {
			# If OVERWRITE is FALSE, print a message and skip the current iteration
			cat(">>> PIPELINE FINISHED! CSV files for", fileName, "already exist.\n")
			next
		}
	}

	# Get the JSON folder and the latest JSON file
	# Check in the JSON folder
	jsonFolder <- file.path(folder, "JSON")
	#jsonFilesInJSONFolder <- list.files(path = jsonFolder, pattern = "\\.json$", full.names = TRUE, recursive = TRUE)
	#jsonFilesInOrigFolder <- list.files(path = folder, pattern = "\\.json$", full.names = TRUE, recursive = FALSE)
	#jsonFiles <- c(jsonFilesInJSONFolder, jsonFilesInOrigFolder)
	jsonFiles <- dir_ls(jsonFolder, regexp = "\\.json$", recurse = TRUE)

	# Skip the iteration if no JSON files found
	if (is_empty(jsonFiles)) {
		next
	}

	# Modify JSON files to replace "Infinity" with "9999"
	for (jsonFile in jsonFiles) {
		jsonContent <- readLines(jsonFile, warn = FALSE)
		jsonContent <- str_replace_all(jsonContent, "Infinity", "9999")
		writeLines(jsonContent, jsonFile)
	}

	# Process each JSON file
	for (jsonFile in jsonFiles) {
		outFile <- file.path(folder, "CSV", fileName)
		jsonExtract(jsonFile = jsonFile, outFile = outFile, fileName = fileName)
	}

	# Get the list of CSV files
	csvFiles <- c(csv_WithRecycles, csv)

	# Process each CSV file
	for (csvFile in csvFiles) {
		# Read the CSV file and perform required transformations
		jsonExtractData <- data.table::fread(csvFile, header = FALSE) %>%
			dplyr::mutate(ORIGIN = fileName) %>%
			dplyr::rename(
						  FILE = V1,
						  MODEL = V2,
						  RECYCLE = V3,
						  TOL = V4,
						  pLDDT = V5,
						  pTM = V6,
						  piTM = V7,
						  iScore = V8,
						  iRes = V9,
						  iCnt = V10,
						  FILE_MODEL = V11,
						  NUM_CLUSTERS = V12,
						  N_MONOMERS = V13
			)
			# Add ranking based on descending iScore within each file
			jsonExtractData <- jsonExtractData %>%
				dplyr::mutate(
							  FILE_RECYCLE = paste0(FILE_MODEL, "_RECYCLE_", RECYCLE),
							  RANK = frank(desc(iScore), ties.method = "min")
							  ) %>%
			dplyr::distinct(FILE_RECYCLE, .keep_all = TRUE) %>%
			dplyr::group_by(FILE) %>%
			dplyr::mutate(RANK = frank(desc(iScore), ties.method = "min"))

		# Write the updated data back to the CSV file
		data.table::fwrite(jsonExtractData, csvFile, row.names = FALSE)
		cat(">>> PIPELINE FINISHED!", csvFile, "was created.\n")

	}
}
