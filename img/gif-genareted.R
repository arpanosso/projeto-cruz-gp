library(gifski)

gerar_gif <- function(pasta, var, saida = NULL, fps = 2, largura = 1000) {
  arquivos <- list.files(pasta, pattern = paste0("^", var, "_\\d{4}_\\d{2}\\.png$"),
                         full.names = TRUE) |> sort()
  if (length(arquivos) == 0) stop("Nenhum PNG encontrado em ", pasta)

  if (is.null(saida)) saida <- file.path(pasta, paste0(var, "_animacao.gif"))

  gifski(arquivos, gif_file = saida,
         width  = largura,
         height = round(largura * 6 / 8),   # mantém a proporção 8x6
         delay  = 1 / fps)
  invisible(saida)
}

gerar_gif("img/xco2", "xco2", fps = 2)
gerar_gif("img/sif",  "sif",  fps = 2)
