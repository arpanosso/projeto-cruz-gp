
<!-- README.md is generated from README.Rmd. Please edit that file -->

# X<sub>CO2</sub> E SIF NA AMAZÔNIA LEGAL: UMA ANÁLISE ESPAÇO-TEMPORAL COM APRENDIZADO DE MÁQUINA

## 👩‍🔬 Autores

- **Gabriela Pereira da Cruz**  
  Graduanda em Engenharia Agronômica - FCAV/Unesp  
  Email: <gabriela.p.cruz@unesp.br>

- **Prof. Dr. Alan Rodrigo Panosso**  
  Coorientador — Departamento de Ciências Exatas - FCAV/Unesp  
  Email: <alan.panosso@unesp.br>

## 📁 Etapas do Projeto

### ⬇️ Aquisição dos dados brutos

- **Aquisição e download dos dados brutos** [OCO-2 e
  OCO-3](https://disc.gsfc.nasa.gov):

### 🔗 Links para Download dos dados compilados:

| Dados Processados Para Download |
|:--:|
| [data-set-xco2-amazon.rds](https://drive.google.com/file/d/1DYmiwn7E2QOcy8yiued1pF6Aw9XKoA-z/view?usp=sharing) ⬇️ |
| [data-set-sif.rds](https://drive.google.com/file/d/1Tvy4T2O3YwY9sQwvHnDD3sZWkoqvwZbw/view?usp=sharing) ⬇️ |
| [data-set-sif-amazon.rds](https://drive.google.com/file/d/1Jfkd8566EY9ZCCb8SczEwEfBDB7Pjq3W/view?usp=sharing) ⬇️ |
| [data-set-xco2-anomal.rds](https://drive.google.com/file/d/1an-4L0E7reDeRmEJ69_l1pF6TSD0SVG3/view?usp=sharing) ⬇️ |

Formato dos arquivos:

> .rds (formato nativo do R para carregamento rápido)

> salve os arquivos na pasta `data` do projeto

### 1 🧹 Preparação de dados

``` r
library(tidyverse)
library(geobr)
library(sp)
```

#### Carregando os polígonos do Brasil

Carregando os polígonos para o Brasil e para a Amazônia Legal

``` r
country_br <- geobr::read_country(showProgress = FALSE, year = 2020)
amazon <- geobr::read_amazon(showProgress = FALSE, year = 2020)
states <- read_state(showProgress = FALSE, year = 2020)
```

Vizualizando o polígono da amazônia legal

``` r
amazon |> 
  ggplot() +
  geom_sf(fill="green4") +
  theme_bw()
```

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

#### Carregando os dados

Carregando os dados criando variáveis temporais a partir da coluna
`time` do data set original.

``` r
data_set_xco2 <- read_rds("data/data-set-xco2-amazon.rds") |> 
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    year = year(time),
    month = month(time),
    day = day(time),
  )
```

Resumo rápido do banco de dados

``` r
glimpse(data_set_xco2)
#> Rows: 2,072,749
#> Columns: 16
#> $ longitude         <dbl> -57.24859, -60.25506, -60.25922, -60.26331, -60.2603…
#> $ latitude          <dbl> -16.006199, -2.370965, -2.352430, -2.333827, -2.3444…
#> $ time              <dttm> 2020-01-02 14:26:32, 2020-01-02 14:30:34, 2020-01-0…
#> $ xco2              <dbl> 408.3632, 410.4371, 411.5206, 411.4840, 413.7887, 41…
#> $ xco2_quality_flag <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ xco2_incerteza    <dbl> 0.6413727, 0.5051642, 0.5171114, 0.5131139, 0.517742…
#> $ path              <chr> "data-raw/2020/OCO2/oco2_LtCO2_200102_B11210Ar_24091…
#> $ year              <dbl> 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020…
#> $ month             <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ day               <int> 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2…
#> $ flag_norte        <lgl> FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRU…
#> $ flag_nordeste     <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ flag_sul          <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ flag_centroeste   <lgl> TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALS…
#> $ flag_suldeste     <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ flag_amazon       <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
```

Resumo Completo do Banco de dados

``` r
skimr::skim(data_set_xco2)
```

|                                                  |               |
|:-------------------------------------------------|:--------------|
| Name                                             | data_set_xco2 |
| Number of rows                                   | 2072749       |
| Number of columns                                | 16            |
| \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_   |               |
| Column type frequency:                           |               |
| character                                        | 1             |
| logical                                          | 5             |
| numeric                                          | 9             |
| POSIXct                                          | 1             |
| \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ |               |
| Group variables                                  | None          |

Data summary

**Variable type: character**

| skim_variable | n_missing | complete_rate | min | max | empty | n_unique | whitespace |
|:--------------|----------:|--------------:|----:|----:|------:|---------:|-----------:|
| path          |         0 |             1 |  63 |  63 |     0 |     2550 |          0 |

**Variable type: logical**

| skim_variable   | n_missing | complete_rate | mean | count                     |
|:----------------|----------:|--------------:|-----:|:--------------------------|
| flag_norte      |         0 |             1 | 0.56 | TRU: 1169710, FAL: 903039 |
| flag_nordeste   |         0 |             1 | 0.08 | FAL: 1916299, TRU: 156450 |
| flag_sul        |         0 |             1 | 0.00 | FAL: 2072749              |
| flag_centroeste |         0 |             1 | 0.36 | FAL: 1326132, TRU: 746617 |
| flag_suldeste   |         0 |             1 | 0.00 | FAL: 2072749              |

**Variable type: numeric**

| skim_variable | n_missing | complete_rate | mean | sd | p0 | p25 | p50 | p75 | p100 | hist |
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|:---|
| longitude | 0 | 1 | -55.49 | 6.55 | -73.97 | -59.55 | -55.12 | -50.36 | -44.00 | ▂▃▇▇▆ |
| latitude | 0 | 1 | -9.33 | 4.63 | -18.04 | -12.66 | -9.70 | -6.63 | 5.00 | ▃▇▆▂▁ |
| xco2 | 0 | 1 | 416.16 | 11.08 | 330.01 | 412.93 | 415.86 | 419.08 | 4425.28 | ▇▁▁▁▁ |
| xco2_quality_flag | 0 | 1 | 0.54 | 0.50 | 0.00 | 0.00 | 1.00 | 1.00 | 1.00 | ▇▁▁▁▇ |
| xco2_incerteza | 0 | 1 | 0.63 | 0.16 | 0.20 | 0.51 | 0.60 | 0.71 | 4.46 | ▇▁▁▁▁ |
| year | 0 | 1 | 2021.80 | 1.40 | 2020.00 | 2021.00 | 2022.00 | 2023.00 | 2024.00 | ▇▇▆▆▅ |
| month | 0 | 1 | 7.17 | 2.06 | 1.00 | 6.00 | 7.00 | 8.00 | 12.00 | ▁▂▇▆▂ |
| day | 0 | 1 | 15.34 | 9.62 | 1.00 | 6.00 | 16.00 | 24.00 | 31.00 | ▇▅▃▅▆ |
| flag_amazon | 0 | 1 | 1.00 | 0.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | ▁▁▇▁▁ |

**Variable type: POSIXct**

| skim_variable | n_missing | complete_rate | min | max | median | n_unique |
|:---|---:|---:|:---|:---|:---|---:|
| time | 0 | 1 | 2020-01-01 12:54:37 | 2024-12-31 09:32:34 | 2022-05-31 14:27:11 | 2072685 |

``` r
amazon |> 
  ggplot() +
  geom_sf(fill="green4") +
  theme_bw() +
  geom_point(data=data_set_xco2 |> 
  filter(year == 2020,
         flag_norte|flag_centroeste|flag_nordeste) |> 
  sample_n(10000), aes(longitude,latitude))
```

![](README_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

### Filtrar o banco dados para amazônia legal

Extraindo os polígonos da amazônia e salvando as respectivas coordenadas
x - logitude e y - latitude, para posteriormente ser utilizada na função
de classificação de pontos.

``` r
pol_amazon <- amazon$geometry[[1]] |> as.matrix()
pol_amazon_x <- pol_amazon[,1]
pol_amazon_y <- pol_amazon[,2]
# plot(pol_amazon_x,pol_amazon_y)
```

Criando a flag_amazon para posterior filtragem do banco de dados e
salvando essa nova versão na pasta data.

``` r
#data_set_xco2_amazon <- data_set_xco2 |>
#filter(flag_norte|flag_centroeste|flag_nordeste) |>
 #  mutate(
  #   flag_amazon = sp::point.in.polygon(longitude,latitude,
                                       # pol.x = pol_amazon_x,
                                       # pol.y = pol_amazon_y))
 #tictoc::toc()
 #data_set_xco2_amazon$flag_amazon |> unique()
 #write_rds(data_set_xco2_amazon |> 
  #           filter(flag_amazon == 1),"data/data-set-xco2-amazon.rds")
```

Lendo o data set amazon

``` r
data_set_xco2_amazon <- read_rds("data/data-set-xco2-amazon.rds")

amazon |> 
  ggplot() +
  geom_sf(fill="green4") +
  theme_bw() +
  geom_point(data=data_set_xco2_amazon |> 
  filter(year == 2024,
         flag_amazon == 1) |> 
  sample_n(1000), aes(longitude,latitude))
```

![](README_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

``` r
amazon |> 
  ggplot() +
  geom_sf(fill="green4") +
  theme_bw() +
  geom_point(data=data_set_xco2 |> 
  filter(year == 2020,
         flag_norte|flag_centroeste|flag_nordeste) |> 
  sample_n(1000), aes(longitude,latitude))
```

![](README_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

### Ajustando para SIF

``` r
data_set_sif <- read_rds("data/data-set-sif.rds") |> 
  mutate(
    time = as_datetime(time, origin = "1990-01-01 00:00:00",
                                   tz = "America/Sao_Paulo"),
    year = year(time),
    month = month(time),
    day = day(time),
  )
```

Resumo rápido do banco de dados

``` r
glimpse(data_set_sif)
#> Rows: 27,462,772
#> Columns: 17
#> $ time               <dttm> 2020-01-01 13:41:22, 2020-01-01 13:41:23, 2020-01-…
#> $ sza                <dbl> 24.44861, 24.44421, 24.43042, 24.42725, 24.41541, 2…
#> $ vza                <dbl> 0.15972900, 0.15936279, 0.36914062, 0.25946045, 0.4…
#> $ saz                <dbl> 264.3497, 264.1766, 264.1306, 263.6334, 263.6737, 2…
#> $ vaz                <dbl> 349.4449463, 349.2926025, 9.9569092, 0.1663208, 11.…
#> $ longitude          <dbl> -42.86682, -42.88593, -42.90643, -42.95166, -42.962…
#> $ latitude           <dbl> -22.83197, -22.75171, -22.72925, -22.49982, -22.517…
#> $ sif740             <dbl> 2.0291252, 1.9367952, 1.2935743, -0.2750387, 2.0776…
#> $ sif740_uncertainty <dbl> 0.4810228, 0.4750776, 0.5201931, 0.5690994, 0.62952…
#> $ daily_sif740       <dbl> 0.78077316, 0.74496078, 0.49750042, -0.10566425, 0.…
#> $ daily_sif757       <dbl> 0.51616192, 0.69380951, 0.22501564, 0.10593128, 0.3…
#> $ daily_sif771       <dbl> 0.34991264, 0.19964695, 0.29221249, -0.16454506, 0.…
#> $ quality_flag       <int> 0, 1, 0, 2, 2, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, …
#> $ path               <chr> "data-raw/2020/OCO2 SIF/oco2_LtSIF_200101_B11012Ar_…
#> $ year               <dbl> 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 202…
#> $ month              <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ day                <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
```

Resumo Completo do Banco de dados

### CRIANDO FLAG SIF

Criando a flag_amazon para posterior filtragem do banco de dados e
salvando essa nova versão na pasta data.

### Baixar o Poligono da Amazonia Legal

``` r
#Amazonia Legal 
# amazon <- geobr::read_amazon(showProgress = FALSE)
para_pol <- states$geometry[5] |> pluck(1) |> as.matrix()
amazon_pol <- amazon$geometry |> pluck(1) |> as.matrix()
amazonas_pol <- states$geometry[3] |> pluck(1) |> as.matrix()
```

``` r
# data_set_sif_amazon <- readRDS("data/data-set-sif.rds")
# # Classificação de pertencimento de ponto em polígono
# def_pol <- function(x, y, pol){
#   as.logical(sp::point.in.polygon(point.x = x,
#                                   point.y = y,
#                                   pol.x = pol[,1],
#                                   pol.y = pol[,2]))
# }
# 
# tictoc::tic()
# data_set_sif_amazon <- data_set_sif |>
#   dplyr::mutate(
#     flag_amazon = def_pol(longitude, latitude, amazon_pol)
#   ) |>
#   dplyr::filter(flag_amazon == TRUE)
# tictoc::toc()
# 
# write_rds(
#   data_set_sif_amazon,
#   "data/data-set-sif-amazon.rds"
# )

# tictoc::tic()
# data_set_sif_amazon <- data_set_sif |>
#   dplyr::filter(year == 2020) |>
#   dplyr::mutate(
#     flag_amazon = def_pol(longitude, latitude, amazon_pol)
#   ) |>
#   dplyr::filter(flag_amazon == TRUE)
# tictoc::toc()
# set.seed(123)
# data_set_sif_amazon_sample <- data_set_sif_amazon |>
#   dplyr::sample_n(1000)

data_set_sif_amazon <- read_rds("data/data-set-sif-amazon.rds")
```

``` r
data_set_sif_amazon |>
  ggplot() +
  geom_sf(data = amazon, fill = "green4") +
  theme_bw() +
  geom_point(
    data = data_set_sif_amazon |>
      dplyr::filter(
        year == 2020,
      ) |>
      dplyr::sample_n(1000),
    aes(longitude, latitude),
    size = 0.8
  )
```

![](README_files/figure-gfm/unnamed-chunk-17-1.png)<!-- -->

### 2 🔎 Análises iniciais

#### Carregando pacotes

``` r
library(ggridges)
library(ggpubr)
library(gstat)
library(vegan)
```

#### FAXINA E TRATAMENTO DOS DADOS DE SIF

``` r
# data_set_sif <- data_set_sif %>%
#   filter(quality_flag==0) |>
#   dplyr::mutate(
#     #time = lubridate:: as_datetime(time,
#                                    #origin = "1990-01-01 00:00:00",
#                                    #tz = "America/Sao_Paulo"),
#     year = lubridate:: year(time),
#     month = lubridate::month(time),
#     day = lubridate::day(time),
#     date = make_date(year, month, day),
#     sif = (daily_sif757 + 1.5*daily_sif771)/2
#     ) |>
#   select(longitude, latitude, date, sif, daily_sif757, daily_sif771, quality_flag, year, month, day)

#dplyr::glimpse(data_set_sif)
#summary(data_set_sif$date)
#write_rds(data_set_sif, "../data/data-set-sif-amazon.rds")
```

#### Visualização de Histograma SIF

``` r
data_set_sif_amazon |>
  # filter(year == 2020) |> 
  ggplot(aes(x = daily_sif757)) +
  geom_histogram(color="black",fill="gray",
                          bins = 30) +
  # coord_cartesian(xlim = c(-2, 2) , ylim = c(0, 600000))+
  facet_wrap(~year, scales = "free") +
  theme_bw()
```

![](README_files/figure-gfm/unnamed-chunk-20-1.png)<!-- --> \####
Estatistica do SIF

``` r
dados_sif_mensais <- data_set_sif_amazon %>%
  group_by(year, month) %>%
  summarise(
    sif_media = mean(sif , na.rm = TRUE),
    sif_sd = sd(sif , na.rm = TRUE),
    .groups = "drop"  
  ) %>%
  mutate(
    data = as.Date(paste(year, month, "15", sep = "-")),
    epoca = case_when(
      month %in% 1:6  ~ "1° semestre (Jan-Jun)",
      month %in% 7:12 ~ "2° semestre (Jul-Dez)"
    ),
    epoca = factor(epoca, levels = c("1° semestre (Jan-Jun)", "2° semestre (Jul-Dez)"))
  ) %>%
  arrange(data)
ggplot(dados_sif_mensais, aes(x = data, y = sif_media, color = epoca, fill = epoca)) +
  geom_ribbon(aes(ymin = sif_media - sif_sd, ymax = sif_media + sif_sd), alpha = 0.3, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c("1° semestre (Jan-Jun)" = "blue", "2° semestre (Jul-Dez)" = "orange")) +
  scale_fill_manual(values = c("1° semestre (Jan-Jun)" = "blue", "2° semestre (Jul-Dez)" = "orange")) +
  scale_x_date(
    breaks = "1 year",  
    date_labels = "%b %Y"
  ) +
  labs(
    # title = "Série Temporal Mensal de XCO₂ SEM tendencia",
    # subtitle = "Média e Desvio Padrão para cada mês, com cores por época",
    x = "Data",
    y = "Concentração Média de SIF (Wm−2 sr−1 μm−1)",
    color = "Época",
    fill = "Época"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
```

![](README_files/figure-gfm/unnamed-chunk-21-1.png)<!-- --> \####
Carregando os dados de xco2 e filtrar - CONTINUAR DAQUI

``` r
# data_set_xco2_amazon <- readr::read_rds("../data/data-set-xco2-amazon00.rds")
# 
#  data_set_xco2_amazon <- data_set_xco2_amazon %>%
#    mutate(
#      date = lubridate::make_date(year, month, day)
#    )
# # write_rds(data_set_xco2_amazon, "../data/data-set-xco2-amazon.rds")
```

``` r
## Chamando meu banco de XCO2

#  data_set_xco2_amazon <- readr::read_rds("../data/data-set-xco2-amazon.rds")
# 
#  data_set_xco2_anomal <- data_set_xco2_amazon |>
# filter(xco2_quality_flag == 0) |>
#    group_by(date) |>
#    nest() |>
#    mutate(nobs = purrr::map_int(data, nrow)) |>
#    filter(nobs >= 5) |>
#    ungroup() |>
#    mutate(data = purrr::map(data, ~ dplyr::mutate(.x, xco2_anomalia = .x$xco2 - median(.x$xco2, na.rm = TRUE)))
#    ) |>
#    unnest(data)
#  glimpse(data_set_xco2_anomal)
# 
#  #write_rds(data_set_xco2_anomal, "../data/data-set-xco2-anomal.rds")
```

#### Criando coluna de semestre

``` r
data_set_xco2_anomal <- read_rds("data/data-set-xco2-anomal.rds")
data_set_xco2_anomal <- data_set_xco2_anomal %>%
  mutate(
    epoca = case_when(
      month %in% 1:6   ~ "Jan_Jun",
      month %in% 7:12  ~ "Jul_Dez"
    )
  )
head(data_set_xco2_amazon)
#>   longitude   latitude                time     xco2 xco2_quality_flag
#> 1 -57.24859 -16.006199 2020-01-02 14:26:32 408.3632                 1
#> 2 -60.25506  -2.370965 2020-01-02 14:30:34 410.4371                 1
#> 3 -60.25922  -2.352430 2020-01-02 14:30:34 411.5206                 1
#> 4 -60.26331  -2.333827 2020-01-02 14:30:35 411.4840                 1
#> 5 -60.26037  -2.344424 2020-01-02 14:30:35 413.7887                 1
#> 6 -60.25745  -2.355058 2020-01-02 14:30:35 411.1546                 1
#>   xco2_incerteza
#> 1      0.6413727
#> 2      0.5051642
#> 3      0.5171114
#> 4      0.5131139
#> 5      0.5177423
#> 6      0.4935850
#>                                                              path year month
#> 1 data-raw/2020/OCO2/oco2_LtCO2_200102_B11210Ar_240913160615s.nc4 2020     1
#> 2 data-raw/2020/OCO2/oco2_LtCO2_200102_B11210Ar_240913160615s.nc4 2020     1
#> 3 data-raw/2020/OCO2/oco2_LtCO2_200102_B11210Ar_240913160615s.nc4 2020     1
#> 4 data-raw/2020/OCO2/oco2_LtCO2_200102_B11210Ar_240913160615s.nc4 2020     1
#> 5 data-raw/2020/OCO2/oco2_LtCO2_200102_B11210Ar_240913160615s.nc4 2020     1
#> 6 data-raw/2020/OCO2/oco2_LtCO2_200102_B11210Ar_240913160615s.nc4 2020     1
#>   day flag_norte flag_nordeste flag_sul flag_centroeste flag_suldeste
#> 1   2      FALSE         FALSE    FALSE            TRUE         FALSE
#> 2   2       TRUE         FALSE    FALSE           FALSE         FALSE
#> 3   2       TRUE         FALSE    FALSE           FALSE         FALSE
#> 4   2       TRUE         FALSE    FALSE           FALSE         FALSE
#> 5   2       TRUE         FALSE    FALSE           FALSE         FALSE
#> 6   2       TRUE         FALSE    FALSE           FALSE         FALSE
#>   flag_amazon
#> 1           1
#> 2           1
#> 3           1
#> 4           1
#> 5           1
#> 6           1
```

#### Visualização de Histograma xco2

``` r
data_set_xco2_anomal |>
  filter(year <2025) |>
  ggplot(aes(x=xco2)) +
  geom_histogram(color="black",fill="gray",
                          bins = 30) +
  coord_cartesian(xlim = c(395, 435) , ylim = c(0, 70000))+
  facet_wrap(~year, scales = "free") +
  theme_bw()
```

![](README_files/figure-gfm/unnamed-chunk-25-1.png)<!-- -->

#### Tendencia regional, r2 e plotagem de gráfico

``` r
data_set_xco2_anomal |>
 sample_n(10000) |>
 drop_na() |>
 mutate( year = year - min(year)) |>
 ggplot(aes(x=time, y=xco2)) +
 geom_point() +
 geom_point(shape=21,color="black",fill="gray") +
 geom_smooth(method = "lm") +
 stat_regline_equation(aes(
 label =  paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~~"))) +
 theme_bw() +
 labs(x="Ano",y="xco2")
```

![](README_files/figure-gfm/unnamed-chunk-26-1.png)<!-- -->

#### Análise da regressão linear simples para caracterização da tendencia XCO2

``` r
mod_trend_xco2 <- lm(xco2 ~ date,
                      data = data_set_xco2_anomal |>
                        filter(xco2_quality_flag == 0) |>
                        drop_na() |>
                        mutate( year = year - min(year),
                                date = as.numeric(date-min(date)))
 )
 mod_trend_xco2
#> 
#> Call:
#> lm(formula = xco2 ~ date, data = mutate(drop_na(filter(data_set_xco2_anomal, 
#>     xco2_quality_flag == 0)), year = year - min(year), date = as.numeric(date - 
#>     min(date))))
#> 
#> Coefficients:
#> (Intercept)         date  
#>   4.104e+02    6.915e-03

 summary.lm(mod_trend_xco2)
#> 
#> Call:
#> lm(formula = xco2 ~ date, data = mutate(drop_na(filter(data_set_xco2_anomal, 
#>     xco2_quality_flag == 0)), year = year - min(year), date = as.numeric(date - 
#>     min(date))))
#> 
#> Residuals:
#>      Min       1Q   Median       3Q      Max 
#> -24.3515  -0.8542  -0.0152   0.8325  10.8539 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) 4.104e+02  2.733e-03  150152   <2e-16 ***
#> date        6.915e-03  2.819e-06    2453   <2e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 1.395 on 945913 degrees of freedom
#> Multiple R-squared:  0.8641, Adjusted R-squared:  0.8641 
#> F-statistic: 6.017e+06 on 1 and 945913 DF,  p-value: < 2.2e-16
```

#### retirando a tendencia e separando por quadrimestre, estou retirando \# a tendencia e substituindo o arquivo que existia com tendencia, \#para o sem tendencia

``` r
 a_co2 <- mod_trend_xco2$coefficients[[1]]
 b_co2 <- mod_trend_xco2$coefficients[[2]]

 data_set_xco2_anomal_sem_tendencia <- data_set_xco2_anomal |>
   filter(xco2_quality_flag == 0,
          year >= 2020 & year <= 2025) |>
   mutate(
     year_modif = year -min(year),
     date_modif = as.numeric(date - min(date)),
     xco2_est = a_co2+b_co2*date_modif,
     delta = xco2_est-xco2,
     xco2_detrend = (a_co2-delta) - (mean(xco2) - a_co2)
   ) |>
   select(-c( time, xco2_quality_flag,xco2_incerteza,
             path,year_modif:delta)) |>
   rename(xco2_trend = xco2,
          xco2 = xco2_detrend) |>
   mutate(
     xco2_anomalia = xco2 - median(xco2, na.rm = TRUE),
     .after = xco2
   ) |>
   ungroup()
```

#### Visualização de Histograma Anomalia de XCO2

``` r
data_set_xco2_anomal_sem_tendencia |>
  filter(year <2025) |>
  ggplot(aes(x=xco2_anomalia)) +
  geom_histogram(color="black",fill="gray",
                          bins = 30) +
  #coord_cartesian(xlim = c(-2, 2) , ylim = c(0, 350000))+
  facet_wrap(~year, scales = "free")+
  theme_bw()
```

![](README_files/figure-gfm/unnamed-chunk-29-1.png)<!-- -->

#### Plotando gráfico da distribuição de xco2 com tendencia por ano

#### separado por semestre

``` r
data_set_xco2_anomal %>%

   ggplot(aes(x = xco2, y = as.factor(year))) +

   geom_density_ridges(
     rel_min_height = 0.03,
     alpha = .6,
     color = "black"
   ) +

   scale_fill_viridis_d(name = "Epoca") +
   coord_cartesian(xlim = c(405, 425)) +
   theme_ridges() +

   labs(
     # title = "Distribuição Epoca de XCO₂ por Ano",
     x = expression(paste(CO[2]," (ppm)")),
     y = "Ano"
   )
```

![](README_files/figure-gfm/unnamed-chunk-30-1.png)<!-- -->

#### Plotando gráfico da distribuição de xco2 sem tendencia por ano

#### separado por semestre

``` r
data_set_xco2_anomal_sem_tendencia %>%

   ggplot(aes(x = xco2, y = as.factor(year))) +

   geom_density_ridges(
     rel_min_height = 0.03,
     alpha = .6,
     color = "black"
   ) +

   scale_fill_viridis_d(name = "Epoca") +
   coord_cartesian(xlim = c(400, 415)) +
   theme_ridges() +

   labs(
     title = "Distribuição Epoca de XCO2 por Ano",
     x = "Concentração de XCO2 (ppm)",
     y = "Ano"
   )
```

![](README_files/figure-gfm/unnamed-chunk-31-1.png)<!-- -->

#### Anomalia de xco2, criando a coluna.

``` r
# data_set_xco2_com_tendencia <- data_set_xco2 %>%
# 
#   filter(xco2_quality_flag == 0,
#         year >= 2020 & year <= 2025) %>%
# 
#  group_by(year, month) %>% #MON
# 
#   mutate(
#     xco2_anomaly = xco2 - median(xco2, na.rm = TRUE)
#   ) %>%
# 
#  ungroup()
```

#### Anomalia de xco2 com tendencia

``` r
data_set_xco2_anomal %>%
   ggplot(aes(x = xco2_anomalia, y = as.factor(year))) +

   geom_density_ridges(
     rel_min_height = 0.03,
     alpha = .6,
     color = "black"
   ) +
     geom_vline(xintercept = 0, linetype = "dashed", color = "black") +

     scale_fill_manual(
       name = "Epoca",
       values = c(
         "Chuvosa. (Jan-Jun)" = "blue", # Tom de roxo/lilás
         "Seca. (Jul-Dez)" = "yellow"  # Tom de amarelo claro
       )
     ) +
  coord_cartesian(xlim = c(-5, 5))+
  theme_ridges()
```

![](README_files/figure-gfm/unnamed-chunk-33-1.png)<!-- -->

#### Anomalia de xco2 sem tendencia

``` r
data_set_xco2_anomal_sem_tendencia %>%
    ggplot(aes(x = xco2_anomalia, y = as.factor(year))) +

    geom_density_ridges(
      rel_min_height = 0.03,
      alpha = .6,
      color = "black"
    ) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "black") +

    scale_fill_manual(
      name = "Epoca",
      values = c(
        "Chuvosa. (Jan-Jun)" = "blue",
        "Seca. (Jul-Dez)" = "yellow"
      )
    ) +
    coord_cartesian(xlim = c(-5, 5))+
  theme_ridges()
```

![](README_files/figure-gfm/unnamed-chunk-34-1.png)<!-- -->

#### Observando dados de anomalia

``` r
 dados_temporais <- data_set_xco2_anomal %>%
  mutate(
      epoca = case_when(
        month %in% 1:6  ~ "Chuvosa (Jan-Jun)",
        month %in% 7:12 ~ "Seca (Jul-Dez)"
      )
    ) %>%
  mutate(
      epoca = factor(epoca, levels = c("Chuvosa (Jan-Jun)", "Seca (Jul-Dez)"))
    ) %>%
  group_by(year, epoca) %>%
  summarise(
      anomalia_media = mean(xco2_anomalia, na.rm = TRUE),
      desvio_padrao = sd(xco2_anomalia, na.rm = TRUE),
      .groups = "drop"
    ) %>%
  mutate(
      mes_representativo = case_when(
        epoca == "Chuvosa (Jan-Jun)" ~ 3,
        epoca == "Seca (Jul-Dez)"    ~ 9
      ),
      data = as.Date(paste(year, mes_representativo, "15", sep = "-"))
    )
print(dados_temporais)
#> # A tibble: 10 × 6
#>     year epoca        anomalia_media desvio_padrao mes_representativo data      
#>    <dbl> <fct>                 <dbl>         <dbl>              <dbl> <date>    
#>  1  2020 Chuvosa (Ja…        0.00640         1.26                   3 2020-03-15
#>  2  2020 Seca (Jul-D…        0.0184          1.01                   9 2020-09-15
#>  3  2021 Chuvosa (Ja…        0.0483          1.21                   3 2021-03-15
#>  4  2021 Seca (Jul-D…        0.0333          1.09                   9 2021-09-15
#>  5  2022 Chuvosa (Ja…        0.0627          1.13                   3 2022-03-15
#>  6  2022 Seca (Jul-D…        0.0207          1.01                   9 2022-09-15
#>  7  2023 Chuvosa (Ja…        0.0397          1.29                   3 2023-03-15
#>  8  2023 Seca (Jul-D…        0.0348          1.03                   9 2023-09-15
#>  9  2024 Chuvosa (Ja…        0.0313          1.11                   3 2024-03-15
#> 10  2024 Seca (Jul-D…        0.00856         0.902                  9 2024-09-15
```

#### Estatistica do xco2 - com tendencia

``` r
dados_xco2_mensais <- data_set_xco2_anomal %>%
  group_by(year, month) %>%
  summarise(
    xco2_media = mean(xco2, na.rm = TRUE),
    xco2_sd = sd(xco2, na.rm = TRUE),
    .groups = "drop"  
  ) %>%
  mutate(
    data = as.Date(paste(year, month, "15", sep = "-")),
    epoca = case_when(
      month %in% 1:6  ~ "Chuvosa (Jan-Jun)",
      month %in% 7:12 ~ "Seca (Jul-Dez)"
    ),
    epoca = factor(epoca, levels = c("Chuvosa (Jan-Jun)", "Seca (Jul-Dez)"))
  ) %>%
  arrange(data)

ggplot(dados_xco2_mensais, aes(x = data, y = xco2_media, color = epoca, fill = epoca)) +
  
  geom_ribbon(aes(ymin = xco2_media - xco2_sd, ymax = xco2_media + xco2_sd), alpha = 0.3, color = NA) +
  
  geom_line(linewidth = 1) +
  
  geom_point(size = 2.5) +
  
  scale_color_manual(values = c("Chuvosa (Jan-Jun)" = "blue", "Seca (Jul-Dez)" = "orange")) +
  scale_fill_manual(values = c("Chuvosa (Jan-Jun)" = "blue", "Seca (Jul-Dez)" = "orange")) +
  
  scale_x_date(
    breaks = "1 year",  
    date_labels = "%b %Y"
  ) +
  
  labs(
    title = "Série Temporal Mensal de XCO2 com tendencia",
    subtitle = "Média e Desvio Padrão para cada mês, com cores por época",
    x = "Data",
    y = "Concentração Média de XCO₂ (ppm)",
    color = "Época",
    fill = "Época"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
```

![](README_files/figure-gfm/unnamed-chunk-36-1.png)<!-- -->

#### Estatistica do xco2 - SEM tendencia

``` r
dados_xco2_mensais <- data_set_xco2_anomal_sem_tendencia %>%
  group_by(year, month) %>%
  summarise(
    xco2_media = mean(xco2, na.rm = TRUE),
    xco2_sd = sd(xco2, na.rm = TRUE),
    .groups = "drop"  
  ) %>%
  mutate(
    data = as.Date(paste(year, month, "15", sep = "-")),
    epoca = case_when(
      month %in% 1:6  ~ "1° semestre (Jan-Jun)", # Corrigido para "semestre"
      month %in% 7:12 ~ "2° semestre (Jul-Dez)"
    ),
    epoca = factor(epoca, levels = c("1° semestre (Jan-Jun)", "2° semestre (Jul-Dez)"))
  ) %>%
  arrange(data)

ggplot(dados_xco2_mensais, aes(x = data, y = xco2_media, color = epoca, fill = epoca)) +
  
  geom_ribbon(aes(ymin = xco2_media - xco2_sd, ymax = xco2_media + xco2_sd), alpha = 0.3, color = NA) +
  
  geom_line(linewidth = 1) +
  
  geom_point(size = 2.5) +
  
  scale_color_manual(values = c("1° semestre (Jan-Jun)" = "blue", "2° semestre (Jul-Dez)" = "orange")) +
  scale_fill_manual(values = c("1° semestre (Jan-Jun)" = "blue", "2° semestre (Jul-Dez)" = "orange")) + # Alterado para "lightblue" para ficar mais claro
  
  scale_x_date(
    breaks = "1 year",  
    date_labels = "%b %Y"
  ) +
  
  labs(
    x = "Data",
    y = "Concentração Média de XCO₂ (ppm)",
    color = "Época",
    fill = "Época"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
```

![](README_files/figure-gfm/unnamed-chunk-37-1.png)<!-- -->

## Agregar as bases

``` r
data_set_xco2_anomal_sem_tendencia |> glimpse()
#> Rows: 945,915
#> Columns: 17
#> $ date            <date> 2020-01-02, 2020-01-02, 2020-01-02, 2020-01-02, 2020-…
#> $ longitude       <dbl> -60.37844, -60.37955, -60.38064, -60.37898, -60.37367,…
#> $ latitude        <dbl> -1.831812, -1.823639, -1.815491, -1.818069, -1.839675,…
#> $ xco2_trend      <dbl> 411.7547, 412.6686, 411.9518, 411.3929, 411.8737, 411.…
#> $ year            <dbl> 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, …
#> $ month           <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ day             <int> 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, …
#> $ flag_norte      <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, …
#> $ flag_nordeste   <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE…
#> $ flag_sul        <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE…
#> $ flag_centroeste <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE…
#> $ flag_suldeste   <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE…
#> $ flag_amazon     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ xco2_anomalia   <dbl> 1.3588346, 2.2727751, 1.5559172, 0.9970182, 1.4778532,…
#> $ nobs            <int> 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69…
#> $ epoca           <chr> "Jan_Jun", "Jan_Jun", "Jan_Jun", "Jan_Jun", "Jan_Jun",…
#> $ xco2            <dbl> 406.0470, 406.9609, 406.2441, 405.6852, 406.1660, 406.…
```

``` r
data_set_sif_amazon |> glimpse()
#> Rows: 4,880,724
#> Columns: 10
#> $ longitude    <dbl> -45.70892, -45.71320, -45.71759, -45.83588, -45.83600, -4…
#> $ latitude     <dbl> -10.237732, -10.237305, -10.217163, -9.704224, -9.713989,…
#> $ date         <date> 2020-01-01, 2020-01-01, 2020-01-01, 2020-01-01, 2020-01-…
#> $ sif          <dbl> 0.17767024, 0.07650542, 0.15871572, -0.01399350, 0.214861…
#> $ daily_sif757 <dbl> -0.02461338, -0.01064396, 0.01721573, -0.17687321, 0.2861…
#> $ daily_sif771 <dbl> 0.25330257, 0.10910320, 0.20014381, 0.09925747, 0.0956955…
#> $ quality_flag <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
#> $ year         <dbl> 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 202…
#> $ month        <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ day          <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
```

``` r
data_set_xco2_anomal_sem_tendencia |> 
  filter(year == 2020) |> 
  ggplot(aes(longitude, latitude)) +
  geom_point(color="blue")+
  geom_point(data = data_set_sif_amazon |> filter(year == 2020) |> 
               sample_n(10000),
             aes(longitude,latitude),color="red", size=1)
```

![](README_files/figure-gfm/unnamed-chunk-40-1.png)<!-- -->

## Agregação

Criar o geadeado para a amazônia

``` r
mat_coord <- amazon$geometry[[1]] |> as.matrix()

dist <- 0.5
lon_min <-min(mat_coord[,1])
lon_max <-max(mat_coord[,1])
lat_min <-min(mat_coord[,2])
lat_max <-max(mat_coord[,2]) 
grid_am <- expand.grid(lon=seq(lon_min,lon_max,dist),
                       lat=seq(lat_min,lat_max,dist))
amazon |> 
  ggplot() +
  geom_sf(fill="aquamarine4",color="black") +
  theme_bw() +
  geom_point(data=grid_am,aes(lon,lat), color="red",size=1)
```

![](README_files/figure-gfm/unnamed-chunk-41-1.png)<!-- -->

criando a função de def_pol

``` r
def_pol <- function(x, y, pol){
  as.logical(sp::point.in.polygon(point.x = x,
                                  point.y = y,
                                  pol.x = pol[,1],
                                  pol.y = pol[,2]))
}
```

Filtrando os pontos do grid_am em função dos limites da amazônia legal

``` r
grid_am_cut <- grid_am |>
 mutate(
    flag_am = def_pol(lon,lat,mat_coord),
    )
plot(grid_am_cut$lon[grid_am_cut$flag_am],grid_am_cut$lat[grid_am_cut$flag_am])
```

![](README_files/figure-gfm/unnamed-chunk-43-1.png)<!-- --> Observado a
tabela do numero de observarções por ano e mês

``` r
table(data_set_sif_amazon$year, data_set_sif_amazon$month)
#>       
#>             1      2      3      4      5      6      7      8      9     10
#>   2020  43722  36087  64328  60429  96955 127991 169798 152372 159349 104461
#>   2021  55167  38753  61544  73699 120300 115531 145476  94815 140819  93000
#>   2022  65728  38743  57488  87831  95041 103496 173640 137748 156293  99375
#>   2023  60425  31800  66159  72825  97156 129907 188325 148389 155218  59541
#>   2024  29148  27273  26394      0      0      0  72708  99636  70805  59561
#>       
#>            11     12
#>   2020  71557  59992
#>   2021  67162  41446
#>   2022  94228  61521
#>   2023  24336  16719
#>   2024  48980  29534
```

Correção dos meses 4-6 para o ano de 2024 - SIF

``` r
# # Criando o arquivo para receber os valores calculados/observados
# sif_novo <- grid_am_cut |>
#   filter(flag_am) |>
#   select(-flag_am) |>
#   group_by(lon, lat) |>
#   reframe(mes = 4:6) |>
#   arrange(mes) |>
#   mutate(sif_est =0)
# 
# # estrutura de repetição para preencher cada um dos pontos criados
# for(k in 1:nrow(sif_novo)){
#   ## Filtrando para o mês especifico, 4, 5 ou 6
#   sif_aux <- data_set_sif_amazon |>
#     filter(month == sif_novo$mes[k])
#   
#   ## Calculando a distância entre o ponto alvo
#   d <- sqrt((sif_aux$longitude-sif_novo$lon[k])^2+
#               (sif_aux$latitude-sif_novo$lat[k])^2)
#   
#   ## organizando os dados em um data.frame
#   data_frame_aux <- data.frame(do=d[order(d)], # distância ordenadas
#                                po=order(d), # posição em relação ao auxiliar
#                                sif=sif_aux$sif[order(d)]) # sif específica
#   
#   ## Critério de preenchimento se distância for menor que 0.25, tire a média,
#   ## caso contrário, faça a média dos 7 mais póximos
#   nrow_df <- data_frame_aux |> filter(do <=.25) |> nrow()
#   
#   if(nrow_df != 0){
#     sif_novo$sif_est[k] = data_frame_aux |> 
#       filter(do <=.25) |> 
#       pull(sif) |> 
#       mean(na.rm=TRUE)
#   } else {
#     sif_novo$sif_est[k] = data_frame_aux |> 
#       slice(1:7) |> 
#       pull(sif) |> 
#       mean(na.rm=TRUE)
#   } 
# }
# 
# # Verifiando a quantidade de NAs presentes no novos valores, o esperado é 
# # zero
# sif_novo$sif_est |> is.na() |> sum()
# 
# # salvando em um novo arquvio, em data-raw
# write_rds(sif_novo,"data-raw/sif-estimada-2024.rds")

# carregando e completando as demais colunas necessárias para agrupar com o
# aquivo da sif original
sif_estimada_2024 <- read_rds("data-raw/sif-estimada-2024.rds") |> 
  rename( month = mes , longitude=lon, latitude=lat, sif = sif_est) |> 
  mutate(day = 1,
         year = 2024,
         quality_flag=0,
         daily_sif771 = NA,
         daily_sif757 = NA,
         date=make_date(year,month,day))
data_set_sif_amazon <- data_set_sif_amazon |> rbind(sif_estimada_2024)
```

Observado a tabela do número de observarções por ano e mês após correção

``` r
table(data_set_sif_amazon$year, data_set_sif_amazon$month)
#>       
#>             1      2      3      4      5      6      7      8      9     10
#>   2020  43722  36087  64328  60429  96955 127991 169798 152372 159349 104461
#>   2021  55167  38753  61544  73699 120300 115531 145476  94815 140819  93000
#>   2022  65728  38743  57488  87831  95041 103496 173640 137748 156293  99375
#>   2023  60425  31800  66159  72825  97156 129907 188325 148389 155218  59541
#>   2024  29148  27273  26394   1648   1648   1648  72708  99636  70805  59561
#>       
#>            11     12
#>   2020  71557  59992
#>   2021  67162  41446
#>   2022  94228  61521
#>   2023  24336  16719
#>   2024  48980  29534
```

## Agregação das Bases data_set_sif_amazon e data_set_xco2_anomal_sem_tendencia

``` r
# Criando o arquivo da base agregada
# base_agregada <- grid_am_cut |>
#   filter(flag_am) |>
#   select(-flag_am) |>
#   group_by(lon, lat) |>
#   reframe(
#     year = 2020:2024
#   ) |>
#   group_by(lon, lat, year) |>
#   reframe(month = 1:12) |>
#   mutate(xco2 = 0,
#          sif = 0)
# 
# # # Definindo a distância máxima de proximidade entre os pontos para agregação
# dist_max <- 0.25
# 
# for(i in 1:nrow(base_agregada)){
#   # definindo o ano e o mês e coordenadas
#   year_i <- base_agregada |> slice(i) |> pull(year)
#   month_i <- base_agregada |> slice(i) |> pull(month)
#   lon_i <- base_agregada$lon[i]
#   lat_i <- base_agregada$lat[i]
# 
#   # filtrando dados da SIF
#   sif_aux <- data_set_sif_amazon |>
#     filter(
#       year == year_i,
#       month == month_i)
#   d_sif <- sqrt((sif_aux$longitude-lon_i)^2+
#               (sif_aux$latitude-lat_i)^2)
# 
#   ## organizando os dados em um data.frame
#   data_frame_aux_sif <- data.frame(
#     do=d_sif[order(d_sif)], # distância ordenadas
#     po=order(d_sif), # posição em relação ao auxiliar
#     sif=sif_aux$sif[order(d_sif)]) # sif específica
# 
#   ## Critério de preenchimento se distância for menor que dist_max, tire a média,
#   ## caso contrário, faça a média dos 7 mais póximos
#   nrow_df_sif <- data_frame_aux_sif |> 
#     filter(do <= dist_max) |> 
#     nrow()
# 
#   if(nrow_df_sif != 0){
#     base_agregada$sif[i] = data_frame_aux_sif |>
#       filter(do <= dist_max) |>
#       pull(sif) |>
#       mean(na.rm=TRUE)
#   } else {
#     base_agregada$sif[i] = data_frame_aux_sif |>
#       slice(1:7) |>
#       pull(sif) |>
#       mean(na.rm=TRUE)
#   }
# 
#   # filtrando dados da Xco2
#   xco2_aux <- data_set_xco2_anomal_sem_tendencia |>
#     filter(
#       year == year_i,
#       month == month_i)
#   d_xco2 <- sqrt((xco2_aux$longitude-lon_i)^2+
#               (xco2_aux$latitude-lat_i)^2)
# 
#   ## organizando os dados em um data.frame
#   data_frame_aux_xco2 <- data.frame(do=d_xco2[order(d_xco2)], # distância ordenadas
#                                po=order(d_xco2), # posição em relação ao auxiliar
#                                xco2=xco2_aux$xco2[order(d_xco2)]) # xco2 específica
# 
#   ## Critério de preenchimento se distância for menor que dist_max, tire a média,
#   ## caso contrário, faça a média dos 7 mais póximos
#   nrow_df_xco2 <- data_frame_aux_xco2 |> filter(do <= dist_max) |> nrow()
# 
#   if(nrow_df_xco2 != 0){
#     base_agregada$xco2[i] = data_frame_aux_xco2 |>
#       filter(do <= dist_max) |>
#       pull(xco2) |>
#       mean(na.rm=TRUE)
#   } else {
#     base_agregada$xco2[i] = data_frame_aux_xco2 |>
#       slice(1:7) |>
#       pull(xco2) |>
#       mean(na.rm=TRUE)
#   }
# }
# 
# # # esperado zero para os dois testes abaixo
# sum(base_agregada$sif  |> is.na())
# sum(base_agregada$xco2 |> is.na())
# nrow(base_agregada)
# 
# # Salvando a base agregada
# write_rds(base_agregada, "data-raw/base-agregada.rds")

# Carregando a base agregada
base_agregada <- read_rds("data-raw/base-agregada.rds")
table(base_agregada$year,base_agregada$month)
#>       
#>           1    2    3    4    5    6    7    8    9   10   11   12
#>   2020 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648
#>   2021 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648
#>   2022 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648
#>   2023 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648
#>   2024 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648 1648
```

## Mapeando XCO2

``` r
amazon |>
   ggplot() +
     geom_sf(aes_string(), color="black",
              size=.05, show.legend = TRUE) +
  theme_minimal() +
  geom_point(
    data = base_agregada |>
      filter(year == 2020,
             month ==1),
  aes(lon,lat),
  color = "red"
  )
```

![](README_files/figure-gfm/unnamed-chunk-48-1.png)<!-- -->

``` r
library(scales) # Necessário para formatar as datas no eixo X

# 1. Agrupamento dos dados
dados_processados <- base_agregada |> 
  group_by(year, month) |> 
  summarise(
    xco2 = mean(xco2, na.rm = TRUE),
    sif  = mean(sif, na.rm = TRUE),
    .groups = "drop"
  ) |> 
  mutate(date = make_date(year, month, 1))

# 2. Descobrir os limites reais para criar a escala perfeita
min_xco2 <- min(dados_processados$xco2, na.rm = TRUE)
max_xco2 <- max(dados_processados$xco2, na.rm = TRUE)
min_sif  <- min(dados_processados$sif, na.rm = TRUE)
max_sif  <- max(dados_processados$sif, na.rm = TRUE)

# Funções matemáticas para transformar e destransformar os dados do SIF
transformar_sif <- function(sif) {
  ((sif - min_sif) / (max_sif - min_sif)) * (max_xco2 - min_xco2) + min_xco2
}

destransformar_sif <- function(xco2_escala) {
  ((xco2_escala - min_xco2) / (max_xco2 - min_xco2)) * (max_sif - min_sif) + min_sif
}

# 3. Gerar o gráfico corrigido
dados_processados |> 
  ggplot(aes(x = date)) +
  # Linha do XCO2 (Eixo Esquerdo)
  geom_line(aes(y = xco2, color = "XCO2"), size = 1.2) +
  # Linha do SIF (Transformada matematicamente para ocupar a mesma amplitude do XCO2)
  geom_line(aes(y = transformar_sif(sif), color = "SIF"), size = 1.2) +
  # Configuração dos Eixos Verticais
  scale_y_continuous(
    name = expression(paste(XCO, " (ppm)")),
    # O eixo secundário faz o caminho inverso para exibir os valores reais do SIF
    sec.axis = sec_axis(trans = destransformar_sif, name = "SIF (Fluorescência)")
  ) +
  # Eixo X das datas ajustado
  scale_x_date(
    date_labels = "%b %Y", 
    date_breaks = "3 months"
  ) +
  # Definição explícita das cores para diferenciar as duas curvas
  scale_color_manual(
    values = c("XCO2" = "#2c3e50", "SIF" = "#27ae60"),
    name = "Variáveis"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank(),
    legend.position = "top"
  ) +
  labs(
    x = "Período",
    title = expression(paste("Relação Temporal entre ", XCO, " e SIF")),
    subtitle = "Variáveis reescalonadas dinamicamente para comparação de tendências",
    caption = "Fonte: Dados da base_agregada"
  )
```

![](README_files/figure-gfm/unnamed-chunk-49-1.png)<!-- -->
