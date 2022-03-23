
library(fGarch)
library(xts)
library(quantmod)
library(purrr)
library(readr)
library(stringr)
library(dplyr)
library(ggplot2)
library(forcats)

bvsp <- getSymbols("^BVSP",
  auto.assign = FALSE,
  from = "2015-01-01", to = "2021-12-31"
) |> Ad()

bvsp_rets <- log(bvsp) |>
  diff() |>
  na.omit()
# bvsp_rets <- (bvsp_rets - mean(bvsp_rets, na.rm = TRUE))
mod <- garchFit(
  BVSP.Adjusted ~ garch(1, 1), data = 100 * bvsp_rets, trace = FALSE
)
mod

plot(residuals(mod), type = "l")
plot(mod@residuals, type = "l", col = "red")
summary(mod)


# https://www.b3.com.br/pt_br/market-data-e-indices/indices/indices-amplos/indice-ibovespa-ibovespa-composicao-da-carteira.htm

symbols <- read_delim("IBOVDia_21-03-22.csv",
  skip = 1,
  delim = ";",
  locale = locale(encoding = "latin1"),
) |>
  filter(!is.na(`Ação`)) |>
  pull(`Código`) |>
  paste0(".SA")

# pegar dados desde 2019 para ter aprox 3 anos de dados
series <- map(symbols, function(x) {
  x <- getSymbols(x, auto.assign = FALSE, from = "2019-01-01")
  cat(x, length(x), "\n")
  Ad(x)
})

series <- set_names(series, symbols)

params <- map_dfr(symbols, function(x) {
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
  unv <- sqrt(var(rets, na.rm = FALSE) * 252) |> as.numeric()
  # v0 <-
  tibble(
    symbol = x,
    omega = params["omega"],
    alpha1 = params["alpha1"],
    beta1 = params["beta1"],
    check = alpha1 + beta1 < 1,
    ltv = 100 * sqrt(ltv * 252),
    unv = 100 * unv
  )
})

params |>
  ggplot(aes(y = fct_reorder(symbol, beta1), x = beta1, colour = check)) +
  geom_point() +
  labs(y = "Symbols")

params |> filter(!check)

bad_symbols <- params |>
  filter(beta1 < 0.6) |>
  pull(symbol)

bad_symbols |>
  map_dfr(function(x) {
    tibble(
      symbol = x,
      length = length(series[[x]]),
      nas = sum(is.na(series[[x]]))
    )
  }) |>
  arrange(length)

params |> filter(symbol %in% bad_symbols)

plot(series[["PETR3.SA"]])