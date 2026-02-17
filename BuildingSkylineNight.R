# Número de luas para serem criadas
luas <- 10
for(k in 1:luas){
png(paste0("Lua_", k, ".png"), width = 1000, height = 1000)
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
  y = y + rnorm(n = 1, mean = 0, sd = 1*fator)
  
  # Distância
  x = x + rnorm(n = 1, mean = 4*fator, sd = 1*fator)
  
  vy[i] <- y
  vx[i] <- x
}

# A altura dos prédios é nivelada a partir do ponto mais baixo
# Auxilia na hora de colorir a área abaixo do gráfico, tendo essa linha basal de referência
vy <- c(min(vy), vy, min(vy))

# Declara o ponto mais baixo em uma variável
# Isso será usado posteriormente para nivelar as camadas,
# Para que todas coincidam em seus pontos mínimos
min.atual <- min(vy)

# Cria dois pontos a mais aleatórios no eixo x, para coincidir com os pontos criados no eixo y (acima)
vx <- c(vx[1] - rnorm(n = 1, mean = 4*fator, sd = 1*fator), vx, x + rnorm(n = 1, mean = 4*fator, sd = 1*fator))

# Cria o primeiro plot, estilo escada
plot(x = vx, y = vy, type="s", ylim=c(min.atual, (3*max(vy))), xlim=c(0,450), axes = F, xlab = "", ylab = "")

#Tela preta de fundo
polygon(x = c(0,0,450,450), y = c(min.atual, (3*max(vy)), (3*max(vy)), min.atual), col=c(rgb(0,0,0)))

# Estrelas
points(x = sample(1:450, 50, replace = T), y = sample(min.atual:(3*max(vy)), 50, replace = T), col="white", pch=20, cex = c(0.05:(0.05*50)))

# Lua
points(x = sample(1:450, 1, replace = T), y = sample(min.atual:(3*max(vy)), 1, replace = T), col="white", pch=19, cex = 10)

# Cria estrutura para que o polígono possa preencher a escada (área abaixo da curva) adequadamente
vx2 <- rep(vx, each = 2)
vy2 <- rep(vy, each = 2)
polygon(x = vx2[-1], y = vy2[-length(vy2)], col=c(rgb(0.3,0.3,0.3)))

# SEGUNDA CAMADA DE PRÉDIOS
y = 0
x = 0
vy = 0
vx = 0
fator <- 2
for(i in 1:(100/fator)){
  y = y + rnorm(n = 1, mean = 0, sd = 1*fator/2)
  x = x + rnorm(n = 1, mean = 4*fator, sd = 1*fator)
  vy[i] <- y
  vx[i] <- x
}
vy <- c(min(vy), vy, min(vy))
vy <- vy - (min(vy) - min.atual)
vx <- c(vx[1] - rnorm(n = 1, mean = 4*fator, sd = 1*fator), vx, x + rnorm(n = 1, mean = 4*fator, sd = 1*fator))
vx2 <- rep(vx, each = 2)
vy2 <- rep(vy, each = 2)
polygon(x = vx2[-1], y = vy2[-length(vy2)], col=c(rgb(0.1,0.1,0.1)))

# TERCEIRA CAMADA DE PRÉDIOS

y = 0
x = 0
vy = 0
vx = 0
fator <- 3
for(i in 1:(100/fator)){
  y = y + rnorm(n = 1, mean = 0, sd = 1*fator/2)
  x = x + rnorm(n = 1, mean = 4*fator, sd = 1*fator)
  vy[i] <- y
  vx[i] <- x
}
vy <- c(min(vy), vy, min(vy))
vy <- vy - (min(vy) - min.atual)
vx <- c(vx[1] - rnorm(n = 1, mean = 4*fator, sd = 1*fator), vx, x + rnorm(n = 1, mean = 4*fator, sd = 1*fator))
vx2 <- rep(vx, each = 2)
vy2 <- rep(vy, each = 2)
polygon(x = vx2[-1], y = vy2[-length(vy2)], col=c(rgb(0.2,0.2,0.2, 1)))

# Grava a imagem PNG
dev.off()
}
