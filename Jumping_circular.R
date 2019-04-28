D <- 800 # Diâmetro do círculo
loops <- 30000 # Pontos no círculo
passo <- 1 # Distância percorrida por cada passo do ponto em direção ao centro gravitacional.

# Consequence
m <- matrix(rep(0, D^2), nrow=D)
r <- D*0.4
atual_i <- D/2
atual_j <- D/2
m[atual_i, atual_j] <- 1 # Indica o primeiro centro de massa
vetor_i <- 0
vetor_j <- 0
novo_i <- D/2
novo_j <- D/2

for(counts in 1:loops){
  
  # Determina posição no círculo, em graus radianos adaptados (/pi)
  posic <- runif(1)*2
  
  # Calcula posição relativa, em relação ao centro do círculo
  atual_i <- D/2 - sinpi(posic)*r
  atual_j <- D/2 - cospi(posic)*r
  
  repeat{
    
    # Anda um passo de "passo" unidades em direção ao centro de massa
    # Fórmula de plano cartesiano: ix = i1 + (i2-i1)*passo/sqrt((j2-j1)^2 + (i2-i1)^2) // Considerar i2,j2 = centro de massa
    atual_i <- atual_i + (novo_i - atual_i)*passo/sqrt((novo_j-atual_j)^2 + (novo_i-atual_i)^2)
    atual_j <- atual_j + (novo_j - atual_j)*passo/sqrt((novo_i-atual_i)^2 + (novo_j-atual_j)^2)
    
    # Parar se chegar próximo a um ponto adjacente e registrar na matrix original
    if(any(m[(atual_i-1):(atual_i+1), (atual_j-1):(atual_j+1)]>=1)){
      twist <- sample(c(0,1), 1, prob=c(100, 1))
      novotwist <- sample(c(0,1), 1, prob=c(100, 1))
      
      if(novotwist == 1){
        novo_i <- atual_i
        novo_j <- atual_j
      }
      
      if(twist == 0){
        m[(atual_i), (atual_j)] <- max(m[(atual_i-1):(atual_i+1), (atual_j-1):(atual_j+1)])
      } else {
        m[(atual_i), (atual_j)] <- sample(2:200, 1)
      }
      break
    }
  }
}

colfunc <- colorRampPalette(c("black", "white", "red"), bias = 7.5)
#image(t(apply(m, 2, rev)), asp = 1, axes=FALSE, col = c("black", "white"))
image(t(apply(m, 2, rev)), asp = 1, axes=FALSE, col = colfunc(300))
