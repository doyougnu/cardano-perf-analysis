library("ggridges")
library("tidyverse")
library("rstatix")

options(scipen = 999)

data_dir <- "./data/"

load_data <- function(filename, ghc, branch) {
  read_tsv(paste(data_dir, filename, sep = "")) %>%
    mutate(GHC = as.factor(ghc), Branch = as.factor(branch))
}

##### Some comments
## we have paired data because each slot no. is unique and repeats in each
## dataset. This is due to the fact that beacon and db analyzer re-run the
## ledger. Thus we have to use pairwise statistical tests.
##
## Essentially, each slotNo is an observation and these are not independant
## between samples of different GHC versions and branches

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
) %>%
  mutate(TestCase = paste(GHC, Branch, sep = "_")) %>%
  arrange(slot)

p <- df %>%
  ggplot(aes(x = totalTime / 1000000, fill = Branch)) + ## convert time to milliseconds from nanoseconds
  geom_histogram(alpha = 0.3) +
  scale_x_log10() +
  labs(x = "TotalTime [ms]") +
  facet_grid(GHC ~ Branch)


p2 <- ggplot(df, aes(totalTime,
                     y = TestCase,
                     fill = GHC)) +
  geom_density_ridges(alpha = .6) +
  scale_x_log10() +
  theme_minimal()



p3 <- ggplot(df, aes(mut_blockApply,
                     y = TestCase,
                     fill = GHC)) +
  geom_density_ridges(alpha = .6) +
  scale_x_log10() +
  theme_minimal()


boxplots <- ggplot(df, aes(x = Branch, y = totalTime / 1000)) +
  geom_boxplot() +
  scale_y_log10()

# now the kruskall wallace test
kruskal.test(totalTime ~ Branch, data = df)

## Kruskal-Wallis rank sum test

## data:  totalTime by Branch
## Kruskal-Wallis chi-squared = 1.1145, df = 2, p-value = 0.5728

kruskal.test(totalTime ~ GHC, data = df)

## as we expected GHC explains most of the variance
## Kruskal-Wallis rank sum test

## data:  totalTime by GHC
## Kruskal-Wallis chi-squared = 70.109, df = 2, p-value =
## 0.0000000000000005969

##################### Test within each GHC
kruskal.test(totalTime ~ Branch, data = df %>% filter(GHC == 96))

##  Kruskal-Wallis rank sum test

## data:  totalTime by Branch
## Kruskal-Wallis chi-squared = 12.293, df = 2, p-value = 0.00214

## and we have a significant difference! Let's check 92 and 810

kruskal.test(totalTime ~ Branch, data = df %>% filter(GHC == 92))
## 	Kruskal-Wallis rank sum test

## data:  totalTime by Branch
## Kruskal-Wallis chi-squared = 14.716, df = 2, p-value = 0.0006376

kruskal.test(totalTime ~ Branch, data = df %>% filter(GHC == 810))

## 	Kruskal-Wallis rank sum test

## data:  totalTime by Branch
## Kruskal-Wallis chi-squared = 7.9877, df = 2, p-value = 0.01843

##################### and now determining the factors

pairwise.wilcox.test(df$totalTime, filter(df,GHC == 96)$Branch, p.adjust.method = "holm", paired = TRUE)

df %>%
  filter(GHC == 96) %>%
  group_by(Branch) %>%
  select(totalTime) %>%
  get_summary_stats(type = "median_iqr")

pairwise.wilcox.test(df$totalTime, filter(df,GHC == 92)$Branch, p.adjust.method = "holm", paired = TRUE)

pairwise.wilcox.test(df$totalTime, filter(df,GHC == 810)$Branch, p.adjust.method = "holm", paired = TRUE)

