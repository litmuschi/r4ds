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
  tryCatch({
    install.packages(missing_packages, repos = "https://cloud.r-project.org")
  }, error = function(e) {
    stop("Failed to install packages: ", e$message, "\nPlease install them manually.")
  })
}

# Step 1: Build the book as HTML using Quarto
cat("\n=== Step 1: Building HTML book with Quarto ===\n")
exit_code <- system("quarto render --to html")
if (exit_code != 0) {
  stop("Quarto HTML build failed with exit code ", exit_code)
}

# Verify HTML build produced output
if (!dir.exists("_book") || length(list.files("_book")) == 0) {
  stop("HTML build did not produce expected output in _book/ directory")
}

# Step 2: Install htmlbook package for O'Reilly conversion
cat("\n=== Step 2: Installing htmlbook package ===\n")
if (!requireNamespace("htmlbook", quietly = TRUE)) {
  tryCatch({
    if (!requireNamespace("pak", quietly = TRUE)) {
      install.packages("pak", repos = "https://cloud.r-project.org")
    }
    pak::pak("hadley/htmlbook")
  }, error = function(e) {
    stop("Failed to install htmlbook package: ", e$message)
  })
}

# Step 3: Convert to O'Reilly format
cat("\n=== Step 3: Converting to O'Reilly format ===\n")
if (!requireNamespace("htmlbook", quietly = TRUE)) {
  stop("htmlbook package is not available. Please install it manually with: pak::pak('hadley/htmlbook')")
}

tryCatch({
  htmlbook::convert_book()
}, error = function(e) {
  stop("Failed to convert book to O'Reilly format: ", e$message)
})

# Step 4: Optionally create PDF from HTML
cat("\n=== Step 4: Creating PDF ===\n")
cat("O'Reilly conversion complete. HTML files are in the 'oreilly' directory.\n")
cat("\nTo create a PDF, you can use one of these options:\n")
cat("1. Use Quarto: quarto render --to pdf\n")
cat("2. Use wkhtmltopdf (requires proper file ordering):\n")
cat("   wkhtmltopdf oreilly/index.html oreilly/ch01.html ... r4ds-oreilly.pdf\n")
cat("3. Submit to O'Reilly Atlas for official PDF generation\n")

# List output files
if (dir.exists("oreilly")) {
  cat("\nGenerated O'Reilly files:\n")
  html_files <- list.files("oreilly", pattern = "\\.html$", full.names = TRUE)
  cat(paste(html_files, collapse = "\n"), "\n")
}

cat("\n=== Build complete ===\n")
