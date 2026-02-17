# Número de luas para serem criadas
luas <- 10
for(k in 1:luas){
  
  tamanho.quadro <- 1000
  
png(paste0("Lua_", k, ".png"), width = tamanho.quadro, height = tamanho.quadro)
par(mar=c(0,0,0,0)) # Borderless

# PRIMEIRA CAMADA DE PRÉDIOS

# Altura de partida
y = 0
# Ponto mais à esquerda
x = 0
# Resetar vetores
vy = 0
vx = 0
# Fator de ajuste (para distanciamento e altura dos prédios, diferente de camada para camada)
# A intenção é dar a sensação de proximidade das camadas mais baixas
fator <- 1

# Preenchimento aleatório dos dados de ALTURA e DISTÂNCIA dos prédios entre si
for(i in 1:(100/fator)){
  
  # Altura
  y = rnorm(n = 1, mean = 0, sd = 1*fator)
  
  # Distância
  x = x + rnorm(n = 1, mean = 4*fator, sd = 1*fator)
  
  vy[i] <- y
  vx[i] <- x
}

# A altura dos prédios é nivelada a partir do ponto mais baixo
# Auxilia na hora de colorir a área abaixo do gráfico, tendo essa linha basal de referência
vy <- c(min(vy)-(5-fator), vy, min(vy)-(5-fator))

# Declara o ponto mais baixo em uma variável
# Isso será usado posteriormente para nivelar as camadas,
# Para que todas coincidam em seus pontos mínimos
min.atual <- min(vy)

# Cria dois pontos a mais aleatórios no eixo x, para coincidir com os pontos criados no eixo y (vy acima)
vx <- c(vx[1] - rnorm(n = 1, mean = 4*fator, sd = 1*fator), vx, x + rnorm(n = 1, mean = 4*fator, sd = 1*fator))

# Cria o primeiro plot, estilo escada
plot(x = vx, y = vy, type="s", ylim=c(min.atual+1, (3*max(vy)-2)), xlim=c(30,390), axes = F, xlab = "", ylab = "")

#Tela preta de fundo
polygon(x = c(0,0,450,450), y = c(min.atual, (3*max(vy)), (3*max(vy)), min.atual), col=c(rgb(0,0,0)))

# Estrelas
points(x = sample(seq(30,390, by=((390-30)/200)), 50, replace = T), y = sample(seq((min.atual+1),(3*max(vy)), by=((3*max(vy)-(min.atual+1))/200)), 50, replace = T), col="white", pch=8, cex = tamanho.quadro*exp(seq(0.05,(0.05*50), by = 0.05))/4000)

# Lua
points(x = sample(1:450, 1, replace = T), y = sample(min.atual:(3*max(vy)), 1, replace = T), col="white", pch=19, cex = tamanho.quadro/40)

# Cria estrutura para que o polígono possa preencher a escada (área abaixo da curva) adequadamente
vx2 <- rep(vx, each = 2)
vy2 <- rep(vy, each = 2)
polygon(x = vx2[-1], y = vy2[-length(vy2)], col=c(rgb(0.3,0.3,0.3)))

# Plota janelas
janx <- rep(vx2[-1], each = 20)
janx <- janx + rep(c(rep(-10, 20), rep(0, 20))/(10/fator), ceiling(length(vx2[-1])/2))[-((length(vx2)-19):length(vx2))]
janx <- janx + rep(c(rep(0, 20), rep(10, 20))/(10/fator), ceiling(length(vx2[-1])/2))[-((length(vx2)-19):length(vx2))]
jany <- rep(vy2[-length(vy2)], each = 20)
jany <- jany + rep(c(-1:-20)/(10/fator), length(vy2[-length(vy2)]))
points(x = janx, y = jany, col=sample(c(rgb(1,1,1,0), 
                                        rgb(1,1,1,0.1), 
                                        rgb(1,1,1,0.2), 
                                        rgb(1,1,1,0.3), 
                                        rgb(1,1,1,0.4), 
                                        rgb(1,1,1,0.5), 
                                        rgb(1,1,1,0.6), 
                                        rgb(1,1,1,0.7), 
                                        rgb(1,1,1,0.8), 
                                        rgb(1,1,1,0.9), 
                                        rgb(1,1,1,1)), 50, 
                                      replace = T,
                                      prob = 2^c(11,10,9,8,7,6,5,4,3,2,1)), pch=15, cex = fator*tamanho.quadro/4000)

# SEGUNDA CAMADA DE PRÉDIOS

x = 0
vy = 0
vx = 0
fator <- 2
for(i in 1:(100/fator)){
  y = rnorm(n = 1, mean = 0, sd = 1*fator/2)
  x = x + rnorm(n = 1, mean = 4*fator, sd = 1*fator)
  vy[i] <- y
  vx[i] <- x
}
vy <- c(min(vy)-(5-fator), vy, min(vy)-(5-fator))
vy <- vy - (min(vy) - min.atual)
vx <- c(vx[1] - rnorm(n = 1, mean = 4*fator, sd = 1*fator), vx, x + rnorm(n = 1, mean = 4*fator, sd = 1*fator))
vx2 <- rep(vx, each = 2)
vy2 <- rep(vy, each = 2)
polygon(x = vx2[-1], y = vy2[-length(vy2)], col=c(rgb(0.1,0.1,0.1)))

# Plota janelas
janx <- rep(vx2[-1], each = 20)
janx <- janx + rep(c(rep(-10, 20), rep(0, 20))/(10/fator), ceiling(length(vx2[-1])/2))[-((length(vx2)-19):length(vx2))]
janx <- janx + rep(c(rep(0, 20), rep(10, 20))/(10/fator), ceiling(length(vx2[-1])/2))[-((length(vx2)-19):length(vx2))]
jany <- rep(vy2[-length(vy2)], each = 20)
jany <- jany + rep(c(-1:-20)/(10/fator), length(vy2[-length(vy2)]))
points(x = janx, y = jany, col=sample(c(rgb(1,1,1,0), 
                                        rgb(1,1,1,0.1), 
                                        rgb(1,1,1,0.2), 
                                        rgb(1,1,1,0.3), 
                                        rgb(1,1,1,0.4), 
                                        rgb(1,1,1,0.5), 
                                        rgb(1,1,1,0.6), 
                                        rgb(1,1,1,0.7), 
                                        rgb(1,1,1,0.8), 
                                        rgb(1,1,1,0.9), 
                                        rgb(1,1,1,1)), 50, 
                                      replace = T,
                                      prob = 2^c(11,10,9,8,7,6,5,4,3,2,1)), pch=15, cex = fator*tamanho.quadro/4000)

# TERCEIRA CAMADA DE PRÉDIOS

x = 0
vy = 0
vx = 0
fator <- 3
for(i in 1:(100/fator)){
  y = rnorm(n = 1, mean = 0, sd = 1*fator/2)
  x = x + rnorm(n = 1, mean = 4*fator, sd = 1*fator)
  vy[i] <- y
  vx[i] <- x
}
vy <- c(min(vy)-(5-fator), vy, min(vy)-(5-fator))
vy <- vy - (min(vy) - min.atual)
vx <- c(vx[1] - rnorm(n = 1, mean = 4*fator, sd = 1*fator), vx, x + rnorm(n = 1, mean = 4*fator, sd = 1*fator))
vx2 <- rep(vx, each = 2)
vy2 <- rep(vy, each = 2)
polygon(x = vx2[-1], y = vy2[-length(vy2)], col=c(rgb(0.2,0.2,0.2, 1)))

# Plota janelas
janx <- rep(vx2[-1], each = 20)
janx <- janx + rep(c(rep(-10, 20), rep(0, 20))/(10/fator), ceiling(length(vx2[-1])/2))[-((length(vx2)-19):length(vx2))]
janx <- janx + rep(c(rep(0, 20), rep(10, 20))/(10/fator), ceiling(length(vx2[-1])/2))[-((length(vx2)-19):length(vx2))]
jany <- rep(vy2[-length(vy2)], each = 20)
jany <- jany + rep(c(-1:-20)/(10/fator), length(vy2[-length(vy2)]))
points(x = janx, y = jany, col=sample(c(rgb(1,1,1,0), 
                                        rgb(1,1,1,0.1), 
                                        rgb(1,1,1,0.2), 
                                        rgb(1,1,1,0.3), 
                                        rgb(1,1,1,0.4), 
                                        rgb(1,1,1,0.5), 
                                        rgb(1,1,1,0.6), 
                                        rgb(1,1,1,0.7), 
                                        rgb(1,1,1,0.8), 
                                        rgb(1,1,1,0.9), 
                                        rgb(1,1,1,1)), 50, 
                                      replace = T,
                                      prob = 2^c(11,10,9,8,7,6,5,4,3,2,1)), pch=15, cex = fator*tamanho.quadro/4000)

# Grava a imagem PNG
dev.off()
}
