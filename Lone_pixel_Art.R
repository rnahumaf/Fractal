# Matrix size and number of loops
size <- 600 # This was the maximum size I could get, before the pixel got "too lost".
loops <- 1

# Consequence
m <- matrix(rep(0, size^2), nrow=size)
mt <- matrix(rep(0, size^2), nrow=size)
m[(size/2), (size/2)] <- 1 # Set precipitation particle
columns <- ncol(m)
rows <- nrow(m)

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
  mt[atual_i, atual_j] <- 1
  
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
      updown[sample_i+2] <- updown[sample_i+2]*0.99
      next
    }
    if((atual_j + sample_j) %in% 1:size == F){
      riglef[sample_j+2] <- riglef[sample_j+2]*0.99
      next
    }

    # Move randomly
    atual_i <- atual_i + sample_i
    atual_j <- atual_j + sample_j
    
    color_rep <- color_rep + 1
    mt[atual_i, atual_j] <- color_rep
    
    # Mark spot if got to the center, or if got next to previously taken cell
    if(all(atual_i != 1, atual_i != size, atual_j != 1, atual_j != size)){
      if(any(m[(atual_i-1):(atual_i+1), (atual_j-1):(atual_j+1)]==1)) {
        m[atual_i, atual_j] <- 1
        break
      }
    }
  }
}

# Print
# colfunc <- colorRampPalette(c("azure3", "midnightblue", rgb(0.5,0,0,0.8)), alpha=TRUE, bias = 1)
 colfunc <- colorRampPalette(c(rgb(1,1,1,0.4), rgb(1,0,0,0.7), rgb(0,0,0,0.8)), alpha=TRUE, bias = 1)
image(t(apply(mt, 2, rev)), asp = 1, axes=FALSE, col = colfunc(2000))



