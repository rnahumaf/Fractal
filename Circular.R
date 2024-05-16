# Tamanho da matriz e número de iterações
size <- 300
loops <- 10000

# Inicializando a matriz com zeros
m <- matrix(0, nrow=size, ncol=size)

# Variáveis para facilitar cálculos de "centralidade" das células
columns <- ncol(m)
rows <- nrow(m)
inv_i <- seq(1, columns) * rev(seq(1, columns))
inv_j <- seq(1, rows) * rev(seq(1, rows))

# Loop principal para adicionar brotos
for (i in 1:loops) {
  # Escolhendo uma posição aleatória na borda
  random <- sample(1:(size^2 - (size - 2)^2), 1)
  
  # Definindo a posição inicial do broto
  if (random <= size) {
    atual_i <- 1
    atual_j <- random
  } else if (random < 2 * size) {
    atual_i <- random - size + 1
    atual_j <- size
  } else if (random < 3 * size - 1) {
    atual_i <- size
    atual_j <- 3 * size - random - 1
  } else {
    atual_i <- 4 * size - random - 2
    atual_j <- 1
  }
  
  # Resetando as probabilidades de movimento
  updown <- c(1, 1, 1)
  riglef <- c(1, 1, 1)
  
  # Loop para mover o broto
  repeat {
    # Escolhendo direção de movimento
    sample_i <- sample(c(-1, 0, 1), 1, prob=updown)
    sample_j <- sample(c(-1, 0, 1), 1, prob=riglef)
    
    # Verificando se o movimento é dentro dos limites da matriz
    novo_i <- atual_i + sample_i
    novo_j <- atual_j + sample_j
    
    if (novo_i < 1 || novo_i > size) {
      updown[sample_i + 2] <- updown[sample_i + 2] * 0.8
      next
    }
    if (novo_j < 1 || novo_j > size) {
      riglef[sample_j + 2] <- riglef[sample_j + 2] * 0.8
      next
    }
    
    # Movendo o broto se a nova célula estiver mais próxima do centro
    if ((inv_i[novo_i] + inv_j[novo_j]) >= (inv_i[atual_i] + inv_j[atual_j])) {
      atual_i <- novo_i
      atual_j <- novo_j
    }
    
    # Marcando a posição se estiver no centro ou próximo a uma célula marcada
    if (atual_i > 1 && atual_i < size && atual_j > 1 && atual_j < size) {
      if (any(m[(atual_i - 1):(atual_i + 1), (atual_j - 1):(atual_j + 1)] == 1) || (inv_i[atual_i] + inv_j[atual_j]) == 2 * max(inv_i)) {
        m[atual_i, atual_j] <- 1
        break
      }
    }
  }
}

# Visualização da matriz
image(t(apply(m, 2, rev)), asp=1, axes=FALSE, col=c("azure3", "midnightblue"))
