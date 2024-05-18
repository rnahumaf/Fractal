# Definindo o diâmetro do círculo e o número de pontos a serem adicionados
D <- 400
loops <- 10000
passo <- 1  # Tamanho do passo em direção ao centro gravitacional

# Inicializando a matriz que representará o círculo
m <- matrix(0, nrow=D, ncol=D)
r <- D * 0.4  # Raio do círculo (40% do diâmetro)
centro_i <- D / 2  # Coordenada i do centro do círculo
centro_j <- D / 2  # Coordenada j do centro do círculo

# Marcando o ponto inicial no centro do círculo
atual_i <- centro_i
atual_j <- centro_j
m[atual_i, atual_j] <- 1

# Loop principal para adicionar pontos
for(counts in 1:loops){
  # Gerando uma posição aleatória no círculo em radianos
  posic <- runif(1) * 2
  
  # Calculando a posição inicial do ponto na borda do círculo
  atual_i <- centro_i - sinpi(posic) * r
  atual_j <- centro_j - cospi(posic) * r
  
  # Loop para mover o ponto em direção ao centro do círculo
  repeat{
    # Calculando a diferença entre a posição atual e o centro do círculo
    delta_i <- centro_i - atual_i
    delta_j <- centro_j - atual_j
    
    # Calculando a distância até o centro do círculo
    distancia <- sqrt(delta_i^2 + delta_j^2)
    
    # Atualizando a posição do ponto, movendo-o um passo em direção ao centro
    atual_i <- atual_i + (delta_i * passo / distancia)
    atual_j <- atual_j + (delta_j * passo / distancia)
    
    # Arredondando a posição atual para os índices da matriz
    i_adj <- round(atual_i)
    j_adj <- round(atual_j)
    
    # Verificando se o ponto está próximo a um ponto existente na matriz
    if(any(m[(i_adj-1):(i_adj+1), (j_adj-1):(j_adj+1)] >= 1)){
      # Decidindo se o ponto deve ser atribuído com base no ponto adjacente ou ser um valor aleatório
      twist <- sample(c(0, 1), 1, prob=c(100, 1))
      if(twist == 0){
        # Atribuindo o valor do ponto adjacente máximo
        m[i_adj, j_adj] <- max(m[(i_adj-1):(i_adj+1), (j_adj-1):(j_adj+1)])
      } else {
        # Atribuindo um valor aleatório entre 2 e 200
        m[i_adj, j_adj] <- sample(2:200, 1)
      }
      break  # Saindo do loop repeat
    }
  }
}

# Criando uma paleta de cores para visualização
colfunc <- colorRampPalette(c("black", "white", "red"), bias = 7.5)

# Plotando a matriz resultante como uma imagem
image(t(apply(m, 2, rev)), asp=1, axes=FALSE, col=colfunc(300))
