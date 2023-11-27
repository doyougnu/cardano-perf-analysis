library("ggridges")
library("tidyverse")

options(scipen = 999)

data_dir <- "./data/"

load_data <- function(filename, ghc, branch) {
  read_tsv(paste(data_dir, filename, sep = "")) %>%
    mutate(GHC = as.factor(ghc), Branch = as.factor(branch))
}

## time units are nanoseconds
## smoke_test     <- load_data("ledger-ops-cost-51db69467fb2fef8829f7f62385cdaf30f68118e-haskell810-from-63-nr-blocks-100.csv", 810, "smoke_test")
df810_baseline <- load_data("ledger-ops-cost-e3917f684e8b60e7bfc453d6d8114b800bdf167d-haskell810-from-63-nr-blocks-100000.csv", 810, "baseline")
df92_baseline  <- load_data("ledger-ops-cost-e3917f684e8b60e7bfc453d6d8114b800bdf167d-haskell-from-63-nr-blocks-100000.csv", 92, "baseline")
df96_baseline  <- load_data("ledger-ops-cost-e3917f684e8b60e7bfc453d6d8114b800bdf167d-haskell96-from-63-nr-blocks-100000.csv", 96, "baseline")

df810Split_umelem <- load_data("ledger-ops-cost-a929cd7616668b61bea38486b1641d5d45f13442-haskell810-from-63-nr-blocks-100000.csv", 810, "SplitUMElem")
df92Split_umelem  <- load_data("ledger-ops-cost-a929cd7616668b61bea38486b1641d5d45f13442-haskell-from-63-nr-blocks-100000.csv", 92, "SplitUMElem")
df96Split_umelem  <- load_data("ledger-ops-cost-a929cd7616668b61bea38486b1641d5d45f13442-haskell96-from-63-nr-blocks-100000.csv", 96, "SplitUMElem")

df810_noFailT <- load_data("ledger-ops-cost-6dc508fd5c0ddb73e4a5e01877dfcd698b1c1bd0-haskell810-from-63-nr-blocks-100000.csv", 810, "NoFailT")
df92_noFailT  <- load_data("ledger-ops-cost-6dc508fd5c0ddb73e4a5e01877dfcd698b1c1bd0-haskell-from-63-nr-blocks-100000.csv", 92, "NoFailT")
df96_noFailT  <- load_data("ledger-ops-cost-6dc508fd5c0ddb73e4a5e01877dfcd698b1c1bd0-haskell96-from-63-nr-blocks-100000.csv", 96, "NoFailT")

df <- bind_rows(
  df810_baseline, df92_baseline, df96_baseline,
  df810Split_umelem, df92Split_umelem, df96Split_umelem,
  df810_noFailT, df92_noFailT, df96_noFailT
)

p <- df %>%
  ggplot(aes(x = totalTime / 1000000, fill = Branch)) + ## convert time to milliseconds from nanoseconds
  geom_histogram(alpha = 0.3) +
  scale_x_log10() +
  labs(x = "TotalTime [ms]") +
  facet_grid(GHC ~ Branch)

