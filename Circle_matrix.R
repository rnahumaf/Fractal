# CRIAR CÍRCULO EM MATRIZ

D <- 300 # Diâmetro do círculo
loops <- 20000 # Pontos no círculo

# Consequence
m <- matrix(rep(0, D^2), nrow=D)
r <- D/2

for(counts in 1:loops){
  # Determina posição no círculo, em graus radianos adaptados (/pi)
  posic <- runif(1)*2
  
  # Calcula posição relativa, em relação ao centro do círculo
  #atual_i <- sinpi(posic)*r 
  #atual_j <- cospi(posic)*r 
  
  # Posiciona o ponto no local aproximado
  m[ceiling(atual_i <- r - sinpi(posic)*r), ceiling(atual_j <- r - cospi(posic)*r)] <- 1
}



image(t(apply(m, 2, rev)), asp = 1, axes=FALSE, col = c("azure3", "midnightblue"))
