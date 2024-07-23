library("miniCRAN")

setwd("/Users/alan.sepulveda/Documents/GitHub/Dataproc-Demo/R-Packages")

# define CRAN mirror
mirror <- c(CRAN = "https://cloud.r-project.org")

# Specify list of packages to download
pkgs <- c("bigrquery","dplyr","ggplot2","randomForest")

pkgList <- pkgDep(pkgs, repos = mirror, type = "source", suggests = FALSE, enhances = FALSE)
pkgList

# Create a local CRAN-like repository
dir.create(pth <- file.path(getwd(), "miniCRAN"))

makeRepo(pkgList, path = pth, repos = mirror, type = "source")
