# Matrix size and number of loops
size <- 300
loops <- 10

# Consequence
mt <- matrix(rep(0, size^2), nrow=size)
m3 <- cbind(mt, mt, mt)
m3 <- rbind(m3, m3, m3)

m <- m3
sizem3 <- size*3
m[(sizem3/2), (sizem3/2)] <- 1 # Set precipitation particle

# S T A R T (create bud, move around, calculate probability of next steps and move until reach the center)

for(i in 1:loops){
  # First bud
  random <- sample(1:(size^2-(size-2)^2), 1)
  # Trace i,j from bud
  if(random <= size){
    atual_i = 1
    atual_j = random
  } else {
    if(random < 2*size){
      atual_i = random - size + 1
      atual_j = size
    } else {
      if(random < (3*size - 1)){
        atual_i = size
        atual_j = size*3 - random - 1
      } else {
        atual_i = size*4 - random - 2
        atual_j = 1
      }
    }
  }
  
  # Path (auxiliary matrix)
  m3[(atual_i + size), (atual_j + size)] <- 1
  
  # Set/Reset probabilities
  updown <- c(1,1,1)
  riglef <- c(1,1,1)
  color_rep <- 0
  repeat{

    # Up or down
    sample_i <- sample(c(-1,0,1), 1, prob = updown)
    # Right or left
    sample_j <- sample(c(-1,0,1), 1, prob = riglef)
    # Repeat if out of bounds
    if((atual_i + sample_i) %in% 1:size == F){
      #updown[sample_i+2] <- updown[sample_i+2]*0.99 # Tempo ótimo até size = 600
      #updown[sample_i+2] <- 0.5
      next
    }
    if((atual_j + sample_j) %in% 1:size == F){
      #riglef[sample_j+2] <- riglef[sample_j+2]*0.99 # Tempo ótimo até size = 600
      #riglef[sample_j+2] <- 0.5
      next
    }

    # Move randomly
    atual_i <- atual_i + sample_i # + sample_i*2 for dot effect
    atual_j <- atual_j + sample_j # + sample_j*2 for dot effect
    
    color_rep <- color_rep + 1
    m3[(atual_i + size), (atual_j + size)] <- color_rep

    # Mark spot if got to the center, or if got next to previously taken cell
    if(any(m[(atual_i + size -1):(atual_i + size+1), (atual_j + size-1):(atual_j + size+1)]==1)) { 
        break
    }
  }
  print(i)
}

# Print
# colfunc <- colorRampPalette(c("azure3", "midnightblue", rgb(0.5,0,0,0.8)), alpha=TRUE, bias = 1)
 colfunc <- colorRampPalette(c(rgb(0,0,0,1),rgb(0,0,0.2,0.9), rgb(0,0,0,0.8), rgb(0.5,0,0,0.8)), alpha=TRUE, bias = 2)
#image(t(apply(m3[(1+size):(2*size), (1+size):(2*size)], 2, rev)), asp = 1, axes=FALSE, col = colfunc(256))

#library(spatialfil)
m3kern <- convKernel(sigma = 0.6, k = "gaussian")
m3con <- applyFilter(m3[(1+size):(2*size), (1+size):(2*size)], m3kern)

png("test.jpg", width = 1000, height = 1000)
# 2. Create the plot
par(mar=c(0,0,0,0)) # Borderless
image(t(apply(m3con, 2, rev)), asp = 1, axes=FALSE, col = colfunc(256))
# 3. Close the file
dev.off()

