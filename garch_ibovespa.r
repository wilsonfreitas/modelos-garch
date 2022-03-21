
library(fGarch)
library(xts)
library(quantmod)
library(purrr)
library(readr)
library(stringr)
library(dplyr)
library(ggplot2)
library(forcats)

df <- read_delim("IBOVDia_21-03-22.csv",
  skip = 1,
  delim = ";",
  locale = locale(decimal_mark = ",", grouping_mark = ".", encoding = "latin1"),
  col_types = cols(
    `Código` = col_character(),
    `Ação` = col_character(),
    Tipo = col_character(),
    `Qtde. Teórica` = col_character(),
    `Part. (%)` = col_character()
  )
)

df <- df |>
  rename(
    Qtde = `Qtde. Teórica`, `Percent` = `Part. (%)`,
    Symbol = `Código`
  ) |>
  mutate(
    Qtde = str_replace_all(Qtde, "\\.", "") |> as.numeric(),
    Percent = str_replace(Percent, ";", "") |>
      str_replace(",", ".") |>
      as.numeric(),
  ) |>
  dplyr::filter(!is.na(`Ação`))

symbols <- paste0(df$Symbol, ".SA")

series <- map(symbols, function(x) {
  cat(x, "\n")
  x <- getSymbols(x, auto.assign = FALSE, from = "2019-01-01")
  Ad(x)
})

series <- set_names(series, symbols)

rets <- series |> map(function(x) {
  rets <- log(x) |> diff()
  na.trim(rets)
})

rets <- set_names(rets, symbols)

params <- map(symbols, function(x) {
  data <- series[[x]]
  rets <- log(data) |>
    diff() |>
    na.trim()
  rets <- (rets - mean(rets, na.rm = TRUE)) # / sd(rets, na.rm = TRUE)
  mod <- garchFit(
    data = rets, include.mean = FALSE, cond.dist = "QMLE",
    trace = FALSE
  )
  params <- coef(mod)
  ltv <- params["omega"] / (1 - params["alpha1"] - params["beta1"])
  # v0 <- 
  tibble(
    symbol = x,
    omega = params["omega"],
    alpha1 = params["alpha1"],
    beta1 = params["beta1"],
    ltv = 100 * sqrt(ltv * 252),
    usd = 100 * sqrt(var(rets, na.rm = FALSE) * 252)
  )
})

params <- do.call(rbind, params)

params |>
  ggplot(aes(y = fct_reorder(symbol, beta1), x = beta1)) +
  geom_point()


params <- params |> mutate(check = alpha1 + beta1)

params |> dplyr::filter(check >= 1)

bad_symbols <- params |> dplyr::filter(beta1 < 0.75) |> pull(symbol)

bad_symbols |> map(function(x) {
  tibble(
    symbol = x,
    length = length(series[[x]]),
    nas = sum(is.na(series[[x]]))
  )
})
