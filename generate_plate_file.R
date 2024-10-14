#!/usr/bin/env Rscript
library(tidyverse)
# Generate the plate layout for a drug synergy experiment in a 96 well plate with the following experimental layout:
#   - The outer edge is empty
#   - Column 2 and 11 are controls and tests. At least 4 of those wells should be DMSO_1_1k controls
#   - Column 3 and 4 contain the column and row drug alone, respectively
#   - Column 5 to 10 contain the drug combinations, with lowest concentrations in B5 and highest in F10

# Use: ./generate_plate_file.R 241011_SKNMC_PAL_PAN.csv combinations_config.txt
args = commandArgs(trailingOnly=TRUE)
print(args)
fname = args[1]
oname = str_replace(fname,'.csv','_plate.csv')

if (length(args > 2)) { # Second argument is a config file
    config = read_csv(args[2], skip=1)
    config = config %>% filter(ID==fname)
    crange = c(0.03,0.01,0.3,0.1,0.3,1,3,10,30,100,300,1000,3000,10000,30000,100000)
    row_drug = config$row_drug
    rci = which(crange == config$row_c)
    row_c = crange[rci:(rci+6)]
    col_drug = config$col_drug
    cci = which(crange == config$col_c)
    col_c = crange[cci:(cci+6)]
    extra = config$others %>% str_split('\\|') %>% unlist %>% sapply(str_split, ':') %>% lapply(t) %>% lapply(as_tibble) %>% bind_rows %>% dplyr::rename(Well=V1, Treatment=V2) %>% column_to_rownames('Well')
} else {
    row_drug = "palbociclib" # Row drug
    row_c = c(1, 3, 10, 30, 100, 300) # Row drug concentrations tested, in nM
    col_drug = "panobinostat" # Column drug
    col_c = c(1, 3, 10, 30, 100, 300) # Column drug concentrations tested, in nM
    extra = c()
}

plate_data = tibble(
    ID=str_replace(fname, '.csv', ''),
    Well=LETTERS[2:7] %>% sapply(function(ll){ paste0(ll, 2:11) }) %>% c,
    col = str_sub(Well, 2, 3) %>% as.numeric,
    row = str_sub(Well, 1, 1),
    Treatment='unspecified',
    Ref_T = 'DMSO_1_1k'
)
# Add row drug
for (rid in 1:length(row_c)) {
    rr = row_c[rid]
    tt = paste(row_drug, rr, sep='_')
    plate_data = plate_data %>% mutate(Treatment=case_when(col==4&row==LETTERS[rid+1]~tt, col>4&col<11&row==LETTERS[rid+1]~tt, TRUE~Treatment), Ref_T=case_when(rr>1e4~paste('DMSO_1_', 1e7/rr), TRUE~'DMSO_1_1k'))
}
# Add column drug
for (cid in 1:length(col_c)) {
    cc = col_c[cid]
    tt = paste(col_drug, cc, sep='_')
    plate_data = plate_data %>% mutate(Treatment=case_when(col==3&row==LETTERS[cid+1]~paste(Treatment,tt,sep='+'), col==cid+4~paste(Treatment,tt,sep='+'), TRUE~Treatment), Ref_T=case_when(cc>1e4~paste('DMSO_1_', 1e7/cc), TRUE~'DMSO_1_1k'))
}
plate_data = plate_data %>% mutate(Treatment = str_replace(Treatment, 'unspecified\\+', ''))
plate_data = plate_data %>% mutate(Treatment=case_when(col==2~'DMSO_1_1k',TRUE~Treatment)) # DMSO column
# Add specific wells information
if (length(extra)>0) { plate_data = plate_data %>% mutate(Treatment = case_when(Well %in% rownames(extra)~extra[Well,'Treatment'], TRUE~Treatment)) }

# Visual check
# Could add colors? https://stackoverflow.com/questions/71147521/split-overlapping-tiles-by-facet-in-geom-tile
plate_data %>% mutate(Treatment=str_replace(Treatment, '\\+','\n')) %>% ggplot(aes(col, reorder(row, desc(row)), label=Treatment)) + geom_text() # Check correctness

if (file.exists(oname)) {
# Does not work in non-interactive mode...
#    oname = readline(paste('File', oname, 'already exists, specify another name (or the same to overwrite)'))
    message(paste('File', oname, 'already exists, adding timestamp'))
    oname = str_replace(oname, '.csv', now() %>% format('_%Y%m%d_%H%M%S'))
    message(oname)
}
write_csv(plate_data, oname)

