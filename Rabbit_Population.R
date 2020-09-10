# Plot a fractal

crazy_num <- function(x, r){
  return(x*r*(1-x))
}

nrank <- 100
p <- data.frame(matrix(nrow = nrank))
count <- 1

for (j in seq(2.6, 4, 0.0001)) {
  
  v <- c()
  first <- 0.2
  v[1] <- first
  
  for (i in 2:(nrank+30)) {
    v[i] <- crazy_num(first, j)
    first <- v[i]
  }
  
  p[,count] <- rev(v)[1:nrank]
  count <- count+1
}

# p <- matrix(p)
# plot(y = p, 
#      pch=".", col = rgb(0,0,0, 0.2), 
#      axes = F)

m <- as.matrix(p)
matplot(x = seq(2.6, 4, 0.0001), y = t(m),
        pch = ".", col = rgb(0,0,0, 0.2),
        ylab = "Platô populacional (em % do máximo)",
        xlab = "Taxa de replicação")

