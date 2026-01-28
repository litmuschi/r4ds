# build-oreilly-pdf.R
# Script to build the R for Data Science book for O'Reilly as PDF
#
# ===========================================================================
# PREREQUISITES
# ===========================================================================
# 1. R (>= 4.0)         - Install from https://cran.r-project.org/
# 2. Quarto (>= 1.4)    - Install from https://quarto.org/
# 3. TinyTeX or LaTeX   - Run: quarto install tinytex
# 4. All R packages listed in DESCRIPTION file
#
# ===========================================================================
# USAGE
# ===========================================================================
# Option 1 - Run the full script:
#   Rscript build-oreilly-pdf.R
#
# Option 2 - Manual steps:
#   1. quarto render --to html    # Build HTML book
#   2. Run R and execute:
#      pak::pak("hadley/htmlbook")
#      htmlbook::convert_book()
#   3. quarto render --to pdf     # Build PDF directly
#
# ===========================================================================
# OUTPUT
# ===========================================================================
# - HTML book:      _book/ directory
# - O'Reilly format: oreilly/ directory
# - PDF:            Generated via quarto render --to pdf
# ===========================================================================

# Install required packages if not already installed
required_packages <- c(
  "arrow", "babynames", "curl", "duckdb", "gapminder",
  "ggrepel", "ggridges", "ggthemes", "hexbin", "janitor",
  "Lahman", "leaflet", "maps", "nycflights13", "openxlsx",
  "palmerpenguins", "repurrrsive", "tidymodels", "tidyverse",
  "writexl", "downlit", "knitr", "rmarkdown"
)

missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}

# Step 1: Build the book as HTML using Quarto
cat("\n=== Step 1: Building HTML book with Quarto ===\n")
system("quarto render --to html")

# Step 2: Install htmlbook package for O'Reilly conversion
cat("\n=== Step 2: Installing htmlbook package ===\n")
if (!requireNamespace("htmlbook", quietly = TRUE)) {
  if (!requireNamespace("pak", quietly = TRUE)) {
    install.packages("pak", repos = "https://cloud.r-project.org")
  }
  pak::pak("hadley/htmlbook")
}

# Step 3: Convert to O'Reilly format
cat("\n=== Step 3: Converting to O'Reilly format ===\n")
library(htmlbook)
htmlbook::convert_book()

# Step 4: Optionally create PDF from HTML
# This requires additional tools like wkhtmltopdf or prince
cat("\n=== Step 4: Creating PDF ===\n")
cat("O'Reilly conversion complete. HTML files are in the 'oreilly' directory.\n")
cat("\nTo create a PDF, you can use one of these options:\n")
cat("1. Use Quarto: quarto render --to pdf\n")
cat("2. Use wkhtmltopdf: wkhtmltopdf oreilly/*.html r4ds-oreilly.pdf\n")
cat("3. Submit to O'Reilly Atlas for official PDF generation\n")

# List output files
if (dir.exists("oreilly")) {
  cat("\nGenerated O'Reilly files:\n")
  html_files <- list.files("oreilly", pattern = "[.]html$", full.names = TRUE)
  cat(paste(html_files, collapse = "\n"), "\n")
}

cat("\n=== Build complete ===\n")
