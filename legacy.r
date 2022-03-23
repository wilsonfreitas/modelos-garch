
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
    Qtde = `Qtde. Teórica`,
    Percent = `Part. (%)`,
    Symbol = `Código`
  ) |>
  mutate(
    Qtde = str_replace_all(Qtde, "\\.", "") |> as.numeric(),
    Percent = str_replace(Percent, ";", "") |>
      str_replace(",", ".") |>
      as.numeric(),
  ) |>
  dplyr::filter(!is.na(`Ação`))
