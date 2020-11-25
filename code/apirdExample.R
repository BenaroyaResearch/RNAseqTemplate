```{r setup}

library(tidyverse)
library(apird)
library(BRIRUtils) # SRP Validate

project <- "P359"
dataDir <- file.path(baseDir, "data")
dataFile <- paste(project, "data.Rdata", sep="_")

# full path of data file.
dataPath <- file.path(dataDir, dataFile)
```

```{r apirdLoading}

libpattern <- "lib[0-9]+"
fcpattern <- "[A-Z0-9]+X[23XY]$"

# would be simpler if we only have one project
 pids = "P358-1"
# pids = str_sort(c("P359-1", "P359-2", "P359-3", "P359-4", "P359-5"), numeric=T)

#file.remove(dataPath)
if (!file.exists(dataPath)) {
  #login()
  
  libraryId <- sort(getProjectLibs(pid))
#  libraryId <- sort(getProjectLibs(paste0(paste0(pids, "$"), collapse="|"), searchType = "regex"))
  length(libraryId) #219
  
  counts <- as.data.frame(t(getGeneCounts(libraryId)))
  dim(counts)
  
  metrics <- getMetrics(libraryId)
  dim(metrics)
  
  design <- getAnno(libraryId)
  dim(design)
  
  #pattern match the libID, out of the flocell id
  colnames(counts)  <- str_extract(colnames(counts), libpattern)
  metrics$flowcell_id <- str_extract(metrics$libid_fcid, fcpattern)
  rownames(metrics) <- metrics$library_id <- str_extract(metrics$libid_fcid, libpattern)
  
  # metrics comes out as snake, convert to camel - check, may nologner be necessary
  colnames(metrics) <- camelNames(colnames(metrics))
  
  # shoud be TRUE
  # (probably not necessary for single project analysis)
  #all(pids == str_sort(unique(design$project), numeric=T))
  
  # adjust any design file information...
  design <- dplyr::rename(design, libraryId = libid)
  design <- dplyr::rename(design, donorId = donorID)
  design <- design[order(design$libraryId),]
  
  design <- design %>% left_join(metrics, by="libraryId")
  
  all(validateLibraryFrame(counts, design, metrics, metricsField="rownames")) # watch for TRUE
  
  # cache our retreived, validated data.
  save(pids, libraryId, counts, metrics, tcrs, design, file=dataPath)
  
} else {
  
  load(dataPath)
  all(validateLibraryFrame(counts, design, metrics, metricsField="rownames")) # use all() and watch for TRUE
  
}

origDesign <- design
gene_key <- read.table(file.path(dataDir, "EnsemblToHGNC_GRCh38.txt"), header = TRUE, sep = "\t", na.strings = c("!?"))

```
