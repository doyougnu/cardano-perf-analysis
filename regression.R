library("tidyverse")

options(scipen = 999)

data_dir <- "./data/"

load_data <- function(filename, ghc, branch) {
  read_tsv(paste(data_dir, filename, sep = "")) %>%
    mutate(GHC = as.factor(ghc), Branch = as.factor(branch))
}

## time units are nanoseconds
smoke_test     <- load_data("ledger-ops-cost-51db69467fb2fef8829f7f62385cdaf30f68118e-haskell810-from-63-nr-blocks-100.csv", 810, "smoke_test")
df810_baseline <- load_data("ledger-ops-cost-e3917f684e8b60e7bfc453d6d8114b800bdf167d-haskell810-from-63-nr-blocks-100000.csv", 810, "main")
df92_baseline  <- load_data("ledger-ops-cost-e3917f684e8b60e7bfc453d6d8114b800bdf167d-haskell-from-63-nr-blocks-100000.csv", 92, "main")
df96_baseline  <- load_data("ledger-ops-cost-e3917f684e8b60e7bfc453d6d8114b800bdf167d-haskell96-from-63-nr-blocks-100000.csv", 96, "main")

df <- bind_rows(df810_baseline, df92_baseline, df96_baseline, smoke_test)

p <- df %>%
  ggplot(aes(x = totalTime / 1000000, fill = Branch)) + ## convert time to milliseconds from nanoseconds
  geom_histogram(alpha = 0.3) +
  scale_x_log10() +
  labs(x = "TotalTime [ms]") +
  facet_grid(GHC ~ Branch)

p

p2 <- df %>%
  ggplot(aes(x = mut, y = totalTime / 1000000, color = GHC, fill = GHC)) +
  facet_wrap(GHC ~ Branch) +
  geom_point()

p2

ggsave("totalTime_distribution.jpg", plot = p)

p3 <- df %>% filter(GHC == 810) %>%
  ggplot(aes(x = mut, y = totalTime, color = Branch, fill = Branch)) +
  geom_point(alpha = 0.5)

smokeDF <- df %>% filter(GHC == 810) %>% group_by(Branch)

colnames(df)
