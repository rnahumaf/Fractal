# Configurações iniciais
size <- 300       # Tamanho da matriz (quadrado de 300 x 300)
loops <- 30000    # Número de iterações

# Inicializando a matriz com zeros
m <- matrix(0, nrow = size, ncol = size)

# Coordenadas do centro do quadrado
centro_i <- 150
centro_j <- 150

# Marcando o ponto fixo inicial no centro do quadrado
m[centro_i, centro_j] <- 1

# Função para randomizar um ponto na borda do quadrado
randomizar_borda <- function(size) {
  pos <- sample(1:(4 * size - 4), 1)
  if (pos <= size) {
    return(c(1, pos))
  } else if (pos <= 2 * size - 1) {
    return(c(pos - size + 1, size))
  } else if (pos <= 3 * size - 2) {
    return(c(size, 3 * size - pos - 1))
  } else {
    return(c(4 * size - pos - 2, 1))
  }
}

# Loop principal para adicionar pontos fixos
for (i in 1:loops) {
  # Randomizando um ponto na borda do quadrado
  ponto <- randomizar_borda(size)
  atual_i <- ponto[1]
  atual_j <- ponto[2]
  
  # Loop para mover o ponto em direção ao centro do quadrado
  repeat {
    # Movendo o ponto em direção ao centro
    delta_i <- centro_i - atual_i
    delta_j <- centro_j - atual_j
    distancia <- sqrt(delta_i^2 + delta_j^2)
    
    if (distancia > 0) {
      atual_i <- atual_i + (delta_i / distancia)
      atual_j <- atual_j + (delta_j / distancia)
    }
    
    # Verificando se o ponto encontrou um ponto fixo a uma distância <= 1
    if (any(m[(atual_i - 1):(atual_i + 1), (atual_j - 1):(atual_j + 1)] == 1)) {
      m[atual_i, atual_j] <- 1
      break
    }
  }
}

# Transformando os pontos fixos em uma imagem e imprimindo na tela
image(t(apply(m, 2, rev)), asp = 1, axes = FALSE, col = c("azure3", "midnightblue"))
