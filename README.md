
<!-- README.md is generated from README.Rmd. Please edit that file -->

# X<sub>CO2</sub> E SIF NA AMAZÔNIA LEGAL: UMA ANÁLISE ESPAÇO-TEMPORAL COM APRENDIZADO DE MÁQUINA

## 👨‍🔬 Autores

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

Formato dos arquivos:

> .rds (formato nativo do R para carregamento rápido)

> salve os arquivos na pasta `data` do projeto

### 🧹 Preparação de dados

``` r
library(tidyverse)
library(geobr)
```

#### Carregando os polígonos do Brasil

Carregando os polígonos para o Brasil e para a Amazônia Legal

``` r
country_br <- geobr::read_country(showProgress = FALSE)
amazon <- geobr::read_amazon(showProgress = FALSE)
```

Vizualizando o mapa da amazônia legal

``` r
amazon |> 
  ggplot() +
  geom_sf(fill="green4") +
  theme_bw()
```

#### Carregando os dados

Carregando os dados criando variáveis temporais a partir da coluna
`time` do data set original.

``` r
tictoc::tic()
data_set_xco2 <- readr::read_rds("data/data-set-xco2-amazon.rds") |> 
  dplyr::mutate(
    time = lubridate::as_datetime(time, tz = "America/Sao_Paulo"),
    year = lubridate::year(time),
    month = lubridate::month(time),
    day = lubridate::day(time),
  )
tictoc::toc()
```

Resumo rápido do banco de dados

``` r
dplyr::glimpse(data_set_xco2)
```

Resumo Completo do Banco de dados

``` r
skimr::skim(data_set_xco2)
```

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

### Filtrar o banco dados para amazônia legal

Extraindo os polígonos da amazônia e salvando as respectivas coordenadas
x - logitude e y - latitude, para posteriormente ser utilizada na função
de classificação de pontos.

``` r
pol_amazon <- amazon$geom[[1]] |> as.matrix()
pol_amazon_x <- pol_amazon[,1]
pol_amazon_y <- pol_amazon[,2]
# plot(pol_amazon_x,pol_amazon_y)
```

Criando a flag_amazon para posterior filtragem do banco de dados e
salvando essa nova versão na pasta data.

``` r
 #tictoc::tic()
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

### Ajustando para SIF

``` r
tictoc::tic()
data_set_sif <- readr::read_rds("data/data-set-sif.rds") |> 
  dplyr::mutate(
    time = lubridate::as_datetime(time, origin = "1990-01-01 00:00:00",
                                   tz = "America/Sao_Paulo"),
    year = lubridate::year(time),
    month = lubridate::month(time),
    day = lubridate::day(time),
  )
tictoc::toc()
```

Resumo rápido do banco de dados

``` r
dplyr::glimpse(data_set_sif)
```

Resumo Completo do Banco de dados

### CRIANDO FLAG SIF

Criando a flag_amazon para posterior filtragem do banco de dados e
salvando essa nova versão na pasta data.

### Baixar o Poligono da Amazonia Legal

``` r
#Amazonia Legal 
amazon <- geobr::read_amazon(showProgress = FALSE)
states <- read_state(showProgress = FALSE)
para_pol <- states$geom[5] |> purrr::pluck(1) |> as.matrix()
amazon_pol <- amazon$geom |> purrr::pluck(1) |> as.matrix()
amazonas_pol <- states$geom[3] |> purrr::pluck(1) |> as.matrix()
```

``` r

data_set_sif_amazon <- readRDS("data/data-set-sif-amazon.rds")

# Classificação de pertencimento de ponto em polígono
def_pol <- function(x, y, pol){
  as.logical(sp::point.in.polygon(point.x = x,
                                  point.y = y,
                                  pol.x = pol[,1],
                                  pol.y = pol[,2]))
}


library(sp)
library(ggplot2)



tictoc::tic()

data_set_sif_amazon <- data_set_sif |>
  dplyr::mutate(
    flag_amazon = def_pol(longitude, latitude, amazon_pol)
  ) |>
  dplyr::filter(flag_amazon == TRUE)

tictoc::toc()


write_rds(
  data_set_sif_amazon,
  "data/data-set-sif-amazon.rds"
)
```

``` r

tictoc::tic()

data_set_sif_amazon <- data_set_sif |>
  dplyr::filter(year == 2020) |>
  dplyr::mutate(
    flag_amazon = def_pol(longitude, latitude, amazon_pol)
  ) |>
  dplyr::filter(flag_amazon == TRUE)

tictoc::toc()

set.seed(123)

data_set_sif_amazon_sample <- data_set_sif_amazon |>
  dplyr::sample_n(1000)
```

``` r



tictoc::tic()
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
tictoc::toc()
```
