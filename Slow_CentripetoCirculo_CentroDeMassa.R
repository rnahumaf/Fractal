# Configurações iniciais
D <- 500          # Diâmetro do círculo
loops <- 15000    # Número de pontos a serem adicionados no círculo
passo <- 1        # Distância percorrida por cada passo do ponto em direção ao centro gravitacional

# Inicialização da matriz e variáveis
m <- matrix(0, nrow = D, ncol = D)  # Matriz principal
r <- D * 0.4                        # Raio do círculo
centro <- D / 2                     # Coordenada do centro do círculo
atual_i <- centro                   # Coordenada inicial i (centro do círculo)
atual_j <- centro                   # Coordenada inicial j (centro do círculo)
m[atual_i, atual_j] <- 1            # Marca o ponto inicial no centro do círculo
vetor_i <- numeric(loops)           # Vetor para armazenar coordenadas i dos pontos
vetor_j <- numeric(loops)           # Vetor para armazenar coordenadas j dos pontos

# Loop principal para adicionar pontos ao círculo
for (counts in 1:loops) {
  # Armazena as coordenadas do ponto atual
  vetor_i[counts] <- atual_i
  vetor_j[counts] <- atual_j
  
  # Determina uma posição aleatória no círculo, em radianos adaptados
  posic <- runif(1) * 2
  
  # Calcula a posição relativa do ponto em relação ao centro do círculo
  atual_i <- centro - sinpi(posic) * r
  atual_j <- centro - cospi(posic) * r
  
  # Loop interno para mover o ponto em direção ao centro de massa
  repeat {
    # Calcula o centro de massa atual
    centro_i <- mean(vetor_i[1:counts])
    centro_j <- mean(vetor_j[1:counts])
    
    # Calcula a distância do ponto atual ao centro de massa
    distancia <- sqrt((centro_j - atual_j)^2 + (centro_i - atual_i)^2)
    
    # Dá um passo em direção ao centro de massa
    atual_i <- atual_i + (centro_i - atual_i) * passo / distancia
    atual_j <- atual_j + (centro_j - atual_j) * passo / distancia
    
    # Verifica se o ponto chegou próximo a um ponto adjacente e marca na matriz principal
    if (any(m[(round(atual_i) - 1):(round(atual_i) + 1), (round(atual_j) - 1):(round(atual_j) + 1)] == 1)) {
      m[round(atual_i), round(atual_j)] <- 1
      break
    }
  }
}

# Exibe a imagem final
image(t(apply(m, 2, rev)), asp = 1, axes = FALSE, col = c("black", "white"))
