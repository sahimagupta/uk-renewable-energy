# ⚡ UK Renewable Energy Dashboard

### 🔗 [📊 View Live Dashboard](https://sahimagupta.github.io/uk-renewable-energy/)

[![R](https://img.shields.io/badge/R-4.5+-blue.svg)](https://www.r-project.org/)
[![Quarto](https://img.shields.io/badge/Quarto-1.3+-green.svg)](https://quarto.org/)

---

## 📖 The Story Behind This Project

The United Kingdom has been at the forefront of the global renewable energy transition. From the windswept coasts of Scotland to the solar farms of southern England, the UK's energy landscape has been transformed over the past 15 years.

This dashboard analyzes **official government data** from the **Department for Energy Security & Net Zero (DESNZ)**, tracking every megawatt of renewable electricity installed and every gigawatt-hour generated across the UK from **2009 to 2024**. The data covers all major renewable sources  wind (onshore and offshore), solar PV, hydropower, bioenergy, and marine energy and breaks down performance across England, Scotland, Wales, and Northern Ireland.

The story that emerges is one of **remarkable growth**: the UK has more than quadrupled its renewable electricity generation in just 15 years, driven primarily by the explosive expansion of offshore wind and solar PV.

---
## ❓ Questions & Considerations

### Data & Methodology
- **Missing Data Handling**: How are gaps in quarterly data treated? Is interpolation used?
- **Seasonality**: Are wind/solar outputs adjusted for seasonal variations?
- **Capacity Factors**: Are these calculated using nameplate capacity or derated values?
- **Confidence Intervals**: What's the uncertainty range for generation estimates?

### Technical Setup
- **Local Development**: How to run the dashboard locally?
  ```r
  # Install dependencies
  install.packages(c("readxl", "tidyverse", "plotly", "DT", "quarto"))
  
  # Preview dashboard
  quarto preview dashboard.qmd

## 🔍 Key Findings

### 📈 Explosive Growth
- UK renewable generation grew from **~25 TWh in 2009 to over 135 TWh in 2024**  a 5x increase
- Installed capacity expanded from **8 GW to over 60 GW** in the same period
- Renewables now account for over **40% of UK electricity generation**

### 🌊 Wind Dominates
- **Wind energy** (onshore + offshore combined) is the single largest renewable source
- **Offshore wind** has grown from just 1.7 TWh in 2009 to over 45 TWh  a 25x increase
- The UK has one of the world's largest offshore wind fleets, with over 14 GW installed
- Offshore wind load factors consistently exceed 35%, making it highly productive

### ☀️ Solar Surge
- Solar PV capacity grew from a mere **27 MW in 2009 to over 17 GW in 2024**
- Generation increased from 20 GWh to over 15 TWh effectively from zero to a major contributor
- Most growth occurred between 2011-2016 during the feed-in tariff era

### 🏴󠁧󠁢󠁳󠁣󠁴󠁿 Scotland Punches Above Its Weight
- Despite having only ~8% of UK population, **Scotland generates ~30% of UK renewable electricity**
- Scotland's energy mix is heavily wind-dominated, with significant hydro contribution
- Wales and Northern Ireland have smaller but growing renewable sectors

### 🔋 Bioenergy's Quiet Contribution
- Plant biomass, landfill gas, and anaerobic digestion collectively generate over 30 TWh
- While less glamorous than wind and solar, bioenergy provides **baseload renewable power** producing electricity regardless of weather conditions

### 📉 Declining Load Factors for Legacy Sources
- Landfill gas load factors have steadily declined from ~58% to ~46% as sites mature
- Offshore wind load factors have improved over time, reflecting better turbine technology

---

## 📊 Dashboard Pages

### Page 1: ⚡ Overview
The big picture  total generation and capacity growth over 15 years, generation mix breakdown, top 6 source trends, and capacity vs generation scatter plot.

### Page 2: 🌊 Wind & Solar
Deep dive into the UK's two fastest-growing sources  onshore vs offshore wind comparison, solar PV capacity and generation growth (dual-axis chart), load factor trends, and efficiency analysis.

### Page 3: 🏴󠁧󠁢󠁥󠁮󠁧󠁿 Nations
Country-level breakdown renewable generation by UK nation (stacked area), nation share pie chart, and energy mix comparison showing how each nation's renewable portfolio differs.

### Page 4: 📋 Data Explorer
Full dataset with generation, capacity, and load factors searchable, sortable, and exportable to CSV/Excel.

---

## 📁 Project Structure

```
uk-renewable-energy/
├── dashboard.qmd                  # Interactive Quarto dashboard (4 pages)
├── scripts/
│   └── 01-data-cleaning.R        # Data extraction & cleaning (300+ lines)
│                                    - Multi-sheet Excel parsing
│                                    - Stacked table extraction
│                                    - Source name standardization
│                                    - Energy category classification
│                                    - Country-level data extraction
├── data/
│   ├── raw/                       # Original DESNZ Excel files
│   │   ├── ET_6.1_DEC_25.xlsx     # Renewable electricity (17 sheets)
│   │   └── ET_6.2_DEC_25.xlsx     # Liquid biofuels
│   └── cleaned/                   # Processed datasets
│       ├── uk_generation_by_source.csv
│       ├── uk_capacity_by_source.csv
│       ├── uk_load_factors.csv
│       ├── country_generation_comparison.csv
│       └── uk_annual_totals.csv
├── docs/                          # Rendered dashboard (GitHub Pages)
│   └── index.html
└── README.md
```

---

## 🛠️ Technologies & Methods

| Tool | Purpose |
|------|---------|
| **R 4.5+** | Data extraction, cleaning, visualization |
| **readxl** | Parsing complex multi-sheet government Excel files |
| **tidyverse** | Data wrangling (dplyr, tidyr, stringr, forcats) |
| **Plotly** | Interactive charts (area, line, pie, scatter, dual-axis) |
| **DT (DataTables)** | Searchable/filterable/exportable data tables |
| **Quarto** | Reproducible dashboard framework |
| **GitHub Pages** | Live deployment |

### Data Cleaning Highlights
- **Complex Excel parsing**: Extracted 3 stacked tables (capacity, generation, load factors) from a single sheet with 6 header rows
- **Multi-sheet extraction**: Parsed 17 sheets covering UK-level and 4 country-level data
- **Source standardization**: Mapped 15+ raw source names (with note references) to clean categories
- **Category classification**: Grouped sources into Wind, Solar, Hydro, Bioenergy, Marine, and Waste
- **Non-numeric handling**: Converted `[x]` markers and missing values gracefully

---

## 📊 Data Source

**Energy Trends: UK Renewables (ET 6.1 & ET 6.2)**
Published by the **Department for Energy Security & Net Zero (DESNZ)**, UK Government.

- Source: [GOV.UK — Energy Trends Section 6: Renewables](https://www.gov.uk/government/statistics/energy-trends-section-6-renewables)
- Published: December 2025 (latest available)
- Coverage: 2009-2024 (quarterly and annual)
- Accredited Official Statistics

---

## 💡 Policy Insights

1. **Offshore wind is the UK's renewable powerhouse** continued investment in seabed leasing and grid connection is critical
2. **Solar PV growth has plateaued** since the end of feed-in tariffs  new incentive mechanisms may be needed
3. **Scotland's dominance** in renewable generation creates opportunities for green hydrogen production and energy export
4. **Bioenergy provides baseload stability** that variable sources (wind/solar) cannot  its role in grid balancing deserves recognition
5. **Marine energy (wave/tidal)** remains negligible despite the UK's coastline advantage breakthrough technology needed

---

## 👩‍💻 Author

**Sahima Gupta**  
📧 gupta.sahima@gmail.com

---

## 📝 License

This project is for academic and portfolio purposes. Data sourced from UK Government open data (Crown Copyright, Open Government Licence).
