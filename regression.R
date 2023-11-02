library("tidyverse")

data_dir <- "./data/"

load_data <- function(filename, ghc, branch) {
  read_tsv(paste(data_dir, filename, sep = "")) %>%
    mutate(GHC = as.factor(ghc), Branch = as.factor(branch))
}

df810_baseline <- load_data("ledger-ops-cost-e3917f684e8b60e7bfc453d6d8114b800bdf167d-haskell810-from-63-nr-blocks-100000.csv", 810, "main")
df92_baseline  <- load_data("ledger-ops-cost-e3917f684e8b60e7bfc453d6d8114b800bdf167d-haskell-from-63-nr-blocks-100000.csv", 92, "main")
df96_baseline  <- load_data("ledger-ops-cost-e3917f684e8b60e7bfc453d6d8114b800bdf167d-haskell96-from-63-nr-blocks-100000.csv", 96, "main")

df <- bind_rows(df810_baseline, df92_baseline, df96_baseline)

p <- df %>%
  ggplot(aes(mut, color = GHC, fill = GHC)) +
  facet_wrap(GHC ~ .) +
  scale_x_log10() +
  geom_density(alpha = 0.5)


p2 <- df %>%
  ggplot(aes(x = mut, y = totalTime, color = GHC, fill = GHC)) +
  facet_wrap(GHC ~ .) +
  geom_point(alpha = 0.5)

p2
