Modelos GARCH
================

Introdução
----------

O objetivo é apresentar os modelos da família GARCH demonstrando a formulação básica e chegando até a estimação de parâmetros. Na prática estes modelos tem origem no modelo ARCH proposto por Engle, onde GARCH é uma evolução proposta por Bollerslev, aqui todos estes modelos serão chamados de GARCH. Uma coisa curiosa sobre estes modelos é que eles são citados como modelos de volatilidade, no entanto, a volatilidade de uma série temporal não é observada. Na prática os modelos GARCH são aplicados a séries retornos financeiros (tipicamente estacionárias de primeira ordem) onde a volatilidade da série tem um componente autoregressivo e daí é que vem a referência a modelagem de volatilidade para estes modelos. Dessa forma, ao longo do texto os modelos serão aplicados a séries \(r_t\) que tipicamente são séries de retorno.

Modelo ARCH
-----------

O modelo ARCH segue

\[
r_t = \mu_t + \sqrt{\h_t} e_t
\]

e

\[
\h_t = \omega + \sum_{i=1}^p \alpha_i r^2_{t-i}
\]

onde \(\mu_t\) é a média de \(r_t\) e \(h_t\) é a variância. \(e_t\) representa os incrementos aleatórios, que como veremos podem assumir diferentes distribuições. Para essa definição temos que:

\[
\begin{align}
E[\e_t] & = 0 \\\\
E[\e_t] & = 0 \\\\
\end{align}
\]

GitHub Documents
----------------

This is an R Markdown format used for publishing markdown documents to GitHub. When you click the **Knit** button all R code chunks are run and a markdown file (.md) suitable for publishing to GitHub is generated.

Including Code
--------------

You can include R code in the document as follows:

``` r
summary(cars)
```

    ##      speed           dist       
    ##  Min.   : 4.0   Min.   :  2.00  
    ##  1st Qu.:12.0   1st Qu.: 26.00  
    ##  Median :15.0   Median : 36.00  
    ##  Mean   :15.4   Mean   : 42.98  
    ##  3rd Qu.:19.0   3rd Qu.: 56.00  
    ##  Max.   :25.0   Max.   :120.00

Including Plots
---------------

You can also embed plots, for example:

![](garch_files/figure-markdown_github/pressure-1.png)<!-- -->

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
