D <- 400 # Diâmetro do círculo
loops <- 10000 # Pontos no círculo
passo <- 1 # Distância percorrida por cada passo do ponto em direção ao centro gravitacional.

# Consequence
m <- matrix(rep(0, D^2), nrow=D)
#m2 <- matrix(rep(0, D^2), nrow=D) # matrix auxiliar
r <- D*0.4
atual_i <- D/2
atual_j <- D/2
m[atual_i, atual_j] <- 1 # Indica o primeiro centro de massa
vetor_i <- 0
vetor_j <- 0
blow <- 1

for(counts in 1:loops){
  
  # Armazena as coordenadas do ponto em uma lista cumulativa, para cálculo do centro de massa
  #vetor_i[counts] <- atual_i
  #vetor_j[counts] <- atual_j
  
  # Determina posição no círculo, em graus radianos adaptados (/pi)
  posic <- runif(1)*2
  
  # Calcula posição relativa, em relação ao centro do círculo
  #atual_i <- sinpi(posic)*r 
  #atual_j <- cospi(posic)*r 
  # Posiciona o ponto no local aproximado (ceiling)
  # m2[(atual_i <- D/2 - sinpi(posic)*r), (atual_j <- D/2 - cospi(posic)*r)] <- 1
  atual_i <- D/2 - sinpi(posic)*r
  atual_j <- D/2 - cospi(posic)*r
  
  # Centro de massa ---> i = sum(vetor_i)/length(vetor_i); j = sum(vetor_j)/length(vetor_j)
  # m2[ceiling(sum(vetor_i)/length(vetor_i)), ceiling(sum(vetor_j)/length(vetor_j))] <- 1 # Centro de massa
  
  repeat{
    
    # Anda um passo de "passo" unidades em direção ao centro de massa
    # Fórmula de plano cartesiano: ix = i1 + (i2-i1)*passo/sqrt((j2-j1)^2 + (i2-i1)^2) // Considerar i2,j2 = centro de massa
    #atual_i <- atual_i + (sum(vetor_i)/length(vetor_i)-atual_i)*passo/sqrt((sum(vetor_j)/length(vetor_j)-atual_j)^2 + (sum(vetor_i)/length(vetor_i)-atual_i)^2)
    #atual_j <- atual_j + (sum(vetor_j)/length(vetor_j)-atual_j)*passo/sqrt((sum(vetor_i)/length(vetor_i)-atual_i)^2 + (sum(vetor_j)/length(vetor_j)-atual_j)^2)
    
    atual_i <- atual_i + (D/2 - atual_i)*passo/sqrt((D/2-atual_j)^2 + (D/2-atual_i)^2)
    atual_j <- atual_j + (D/2 - atual_j)*passo/sqrt((D/2-atual_i)^2 + (D/2-atual_j)^2)
      
    # Registrar o passo na matriz auxiliar
    #m2[(atual_i), (atual_j)] <- 1
    
    # Parar se chegar próximo a um ponto adjacente e registrar na matrix original
    if(any(m[(atual_i-1):(atual_i+1), (atual_j-1):(atual_j+1)]>=1)){
      twist <- sample(c(0,1), 1, prob=c(100, 1))
      if(twist == 0){
        m[(atual_i), (atual_j)] <- max(m[(atual_i-1):(atual_i+1), (atual_j-1):(atual_j+1)])
      } else {
        m[(atual_i), (atual_j)] <- sample(2:200, 1)
        # m[(atual_i), (atual_j)] <- 10^blow; blow <- blow + 1 # Usar em conjunto com a gravidade ativada
      }
      break
    }
  }
}

colfunc <- colorRampPalette(c("black", "white", "red"), bias = 7.5)
#image(t(apply(m, 2, rev)), asp = 1, axes=FALSE, col = c("black", "white"))
image(t(apply(m, 2, rev)), asp = 1, axes=FALSE, col = colfunc(300))
