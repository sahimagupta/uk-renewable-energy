# =============================================================================
# UK Renewable Energy Dashboard — Data Cleaning Script
# =============================================================================
# Author: Sahima Gupta (gupta.sahima@gmail.com)
# Date: February 2026
# Description: Extracts and cleans UK renewable electricity data from the
#   Department for Energy Security & Net Zero (DESNZ) Energy Trends tables.
#   Covers installed capacity, electricity generation, and load factors
#   for all renewable energy sources across the UK (2009-2024).
# Source: https://www.gov.uk/government/statistics/energy-trends-section-6-renewables
# =============================================================================

# Load required packages
library(tidyverse)
library(readxl)
library(janitor)

cat("=== UK Renewable Energy Data Cleaning ===\n\n")

# =============================================================================
# STEP 1: Read the Annual sheet from ET 6.1
# =============================================================================

raw_file <- "data/raw/ET_6.1_DEC_25.xlsx"
cat("Reading:", raw_file, "\n")

# The Annual sheet has 3 tables stacked vertically:
# 1. Cumulative Installed Capacity (MW) — rows 7-22
# 2. Electricity Generated (GWh) — rows 25-39
# 3. Load Factors (%) — rows 42-55

annual_raw <- read_excel(raw_file, sheet = "Annual", col_names = FALSE, .name_repair = "minimal")

# =============================================================================
# STEP 2: Extract years from header row
# =============================================================================

years <- as.character(annual_raw[7, 2:ncol(annual_raw)])
years <- years[!is.na(years)]
years <- as.integer(as.numeric(years))
cat("Years found:", paste(years, collapse = ", "), "\n")

# =============================================================================
# STEP 3: Extract Installed Capacity data
# =============================================================================

extract_section <- function(data, start_row, end_row, years, metric_name) {
  # Extract the section
  section <- data[start_row:end_row, ]
  
  # First column is the energy source name
  sources <- as.character(section[[1]])
  
  # Remove notes references like [note 1], [note 8], etc.
  sources <- str_replace_all(sources, "\\s*\\[note \\d+\\]", "")
  sources <- str_trim(sources)
  
  # Extract numeric values
  n_years <- length(years)
  values <- section[, 2:(n_years + 1)]
  
  # Convert to long format
  result <- tibble(source = sources)
  for (i in seq_along(years)) {
    col_vals <- as.character(values[[i]])
    # Replace [x] and other non-numeric values with NA
    col_vals <- ifelse(col_vals %in% c("[x]", "x", "-", ".."), NA, col_vals)
    result[[as.character(years[i])]] <- as.numeric(col_vals)
  }
  
  # Pivot to long format
  result_long <- result %>%
    pivot_longer(cols = -source, names_to = "year", values_to = "value") %>%
    mutate(
      year = as.integer(year),
      metric = metric_name
    ) %>%
    filter(!is.na(source), source != "")
  
  return(result_long)
}

# Extract each section
# Row indices are 0-based in the raw data, +1 for R
capacity_data <- extract_section(annual_raw, 8, 22, years, "Installed Capacity (MW)")
cat("Capacity data extracted:", nrow(capacity_data), "rows\n")

generation_data <- extract_section(annual_raw, 26, 40, years, "Electricity Generated (GWh)")
cat("Generation data extracted:", nrow(generation_data), "rows\n")

loadfactor_data <- extract_section(annual_raw, 43, 56, years, "Load Factor (%)")
cat("Load factor data extracted:", nrow(loadfactor_data), "rows\n")

# =============================================================================
# STEP 4: Combine and clean the UK-level data
# =============================================================================

uk_data <- bind_rows(capacity_data, generation_data, loadfactor_data) %>%
  # Standardize source names
  mutate(
    source_clean = case_when(
      str_detect(source, "(?i)onshore wind") ~ "Onshore Wind",
      str_detect(source, "(?i)offshore wind.*seabed") ~ "Offshore Wind (Seabed)",
      str_detect(source, "(?i)offshore wind.*floating") ~ "Offshore Wind (Floating)",
      str_detect(source, "(?i)offshore wind") & !str_detect(source, "seabed|floating") ~ "Offshore Wind",
      str_detect(source, "(?i)wave|tidal") ~ "Wave & Tidal",
      str_detect(source, "(?i)solar") ~ "Solar PV",
      str_detect(source, "(?i)small.*hydro") ~ "Small Hydro",
      str_detect(source, "(?i)large.*hydro") ~ "Large Hydro",
      str_detect(source, "(?i)^hydro") ~ "Hydro (Total)",
      str_detect(source, "(?i)landfill") ~ "Landfill Gas",
      str_detect(source, "(?i)sewage") ~ "Sewage Gas",
      str_detect(source, "(?i)energy from waste") ~ "Energy from Waste",
      str_detect(source, "(?i)animal") ~ "Animal Biomass",
      str_detect(source, "(?i)anaerobic") ~ "Anaerobic Digestion",
      str_detect(source, "(?i)plant biomass") ~ "Plant Biomass",
      str_detect(source, "(?i)co-firing|co.firing") ~ "Co-firing",
      str_detect(source, "(?i)liquid bio") ~ "Liquid Biofuels",
      str_detect(source, "(?i)non-bio|non.bio") ~ "Non-biodegradable Waste",
      str_detect(source, "(?i)total") ~ "TOTAL",
      TRUE ~ source
    ),
    # Create broader energy categories
    energy_category = case_when(
      str_detect(source_clean, "(?i)wind") ~ "Wind",
      str_detect(source_clean, "(?i)solar") ~ "Solar",
      str_detect(source_clean, "(?i)hydro") ~ "Hydro",
      str_detect(source_clean, "(?i)wave|tidal") ~ "Marine",
      str_detect(source_clean, "(?i)biomass|anaerobic|plant|landfill|sewage|co-firing|biofuel") ~ "Bioenergy",
      str_detect(source_clean, "(?i)waste") ~ "Waste",
      str_detect(source_clean, "TOTAL") ~ "Total",
      TRUE ~ "Other"
    ),
    country = "United Kingdom"
  ) %>%
  filter(!is.na(value))

cat("UK data combined:", nrow(uk_data), "rows\n")

# =============================================================================
# STEP 5: Extract country-level data (England, Scotland, Wales, NI)
# =============================================================================

extract_country_data <- function(file, sheet_name, country_name, years_offset = 0) {
  raw <- read_excel(file, sheet = sheet_name, col_names = FALSE, .name_repair = "minimal")
  
  # Get years from row 7
  yr <- as.character(raw[7, 2:ncol(raw)])
  yr <- yr[!is.na(yr)]
  yr <- as.integer(as.numeric(yr))
  
  # Country sheets (0-indexed in Python, +1 for R):
  # Capacity: rows 8-15 (Wind to TOTAL)
  # Generation: rows 18-25 (Wind to TOTAL)
  cap <- extract_section(raw, 8, 15, yr, "Installed Capacity (MW)")
  gen <- extract_section(raw, 18, 25, yr, "Electricity Generated (GWh)")
  
  bind_rows(cap, gen) %>%
    # Remove any leaked headers like "LOAD FACTORS" or "ELECTRICITY GENERATED"
    filter(!str_detect(source, "(?i)load factor|electricity generated|cumulative|installed capacity")) %>%
    mutate(
      country = country_name,
      source_clean = case_when(
        str_detect(source, "(?i)wind") & !str_detect(source, "offshore") ~ "Onshore Wind",
        str_detect(source, "(?i)offshore") ~ "Offshore Wind",
        str_detect(source, "(?i)solar") ~ "Solar PV",
        str_detect(source, "(?i)hydro") ~ "Hydro",
        str_detect(source, "(?i)bio") ~ "Bioenergy",
        str_detect(source, "(?i)wave|tidal|marine") ~ "Marine",
        str_detect(source, "(?i)total") ~ "TOTAL",
        TRUE ~ source
      ),
      energy_category = case_when(
        str_detect(source_clean, "(?i)wind") ~ "Wind",
        str_detect(source_clean, "(?i)solar") ~ "Solar",
        str_detect(source_clean, "(?i)hydro") ~ "Hydro",
        str_detect(source_clean, "(?i)bio") ~ "Bioenergy",
        str_detect(source_clean, "(?i)marine") ~ "Marine",
        str_detect(source_clean, "TOTAL") ~ "Total",
        TRUE ~ "Other"
      )
    ) %>%
    filter(!is.na(value))
}

england <- extract_country_data(raw_file, "England - Annual", "England")
scotland <- extract_country_data(raw_file, "Scotland- Annual", "Scotland")
wales <- extract_country_data(raw_file, "Wales- Annual", "Wales")
ni <- extract_country_data(raw_file, "Northern Ireland - Annual", "Northern Ireland")

country_data <- bind_rows(england, scotland, wales, ni)
cat("Country data extracted:", nrow(country_data), "rows\n")
cat("  England:", nrow(england), "| Scotland:", nrow(scotland),
    "| Wales:", nrow(wales), "| N.Ireland:", nrow(ni), "\n")

# =============================================================================
# STEP 6: Create summary datasets for the dashboard
# =============================================================================

# --- UK Annual totals by source ---
uk_annual_summary <- uk_data %>%
  filter(source_clean != "TOTAL", metric == "Electricity Generated (GWh)") %>%
  select(year, source = source_clean, category = energy_category, generation_gwh = value)

cat("UK annual summary:", nrow(uk_annual_summary), "rows\n")

# --- UK Capacity growth ---
uk_capacity <- uk_data %>%
  filter(source_clean != "TOTAL", metric == "Installed Capacity (MW)") %>%
  select(year, source = source_clean, category = energy_category, capacity_mw = value)

cat("UK capacity data:", nrow(uk_capacity), "rows\n")

# --- UK Load factors ---
uk_loadfactors <- uk_data %>%
  filter(metric == "Load Factor (%)") %>%
  select(year, source = source_clean, load_factor_pct = value)

cat("UK load factors:", nrow(uk_loadfactors), "rows\n")

# --- Country comparison (generation by source, including TOTAL) ---
country_comparison <- country_data %>%
  filter(metric == "Electricity Generated (GWh)") %>%
  select(year, country, source = source_clean, category = energy_category, generation_gwh = value)

cat("Country comparison:", nrow(country_comparison), "rows\n")

# --- UK totals by year (for overview) ---
uk_totals <- uk_data %>%
  filter(source_clean == "TOTAL") %>%
  select(year, metric, value) %>%
  pivot_wider(names_from = metric, values_from = value) %>%
  clean_names()

cat("UK totals:", nrow(uk_totals), "rows\n")

# =============================================================================
# STEP 7: Save cleaned datasets
# =============================================================================

write_csv(uk_annual_summary, "data/cleaned/uk_generation_by_source.csv")
write_csv(uk_capacity, "data/cleaned/uk_capacity_by_source.csv")
write_csv(uk_loadfactors, "data/cleaned/uk_load_factors.csv")
write_csv(country_comparison, "data/cleaned/country_generation_comparison.csv")
write_csv(uk_totals, "data/cleaned/uk_annual_totals.csv")

cat("\n=== Data Cleaning Complete ===\n")
cat("Files saved:\n")
cat("  1. uk_generation_by_source.csv (", nrow(uk_annual_summary), "rows)\n")
cat("  2. uk_capacity_by_source.csv (", nrow(uk_capacity), "rows)\n")
cat("  3. uk_load_factors.csv (", nrow(uk_loadfactors), "rows)\n")
cat("  4. country_generation_comparison.csv (", nrow(country_comparison), "rows)\n")
cat("  5. uk_annual_totals.csv (", nrow(uk_totals), "rows)\n")
