# radius
r = 2

# Posição no eixo x
i = 0

# Posição no eixo y
j = 0

# Plot
y <- matrix(nrow=2, ncol=2*r*1000+1)

funpos = function(x, i, j){
  y <- j + sqrt(r^2 - (x-i)^2)
  return(y)
}

funneg = function(x, i, j){
  y <- j - sqrt(r^2 - (x-i)^2)
  return(y)
}

for(f in (-r*1000):(r*1000)){
  k <- f/1000
  y[,f+r*1000 + 1] <- c(funpos(k, i, j), funneg(k, i, j))
}


# Plot
matplot(seq(-r, r, by=r/(1000*2)), cbind(y[1,],y[2,]),type="l",col=c("red","red"),lty=c(1,1))
