# Matrix size and number of loops
size <- 300 # Divisível por 4
loops <- 2000

# Consequence
m <- matrix(rep(0, size^2), nrow=size)
m[ceiling(size/2), ceiling(size/2)] <- 1 # Set precipitation particle
columns <- ncol(m)
rows <- nrow(m)
inv_i <- seq(1:ncol(m)) * rev(seq(1:ncol(m)))
inv_j <- seq(1:nrow(m)) * rev(seq(1:nrow(m)))

# S T A R T

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
  # Reset probabilities
  updown <- c(1,1,1)
  riglef <- c(1,1,1)

  # Move
  #count <- 1
  repeat{
    # If count is too large, reset probabilities
    #if(count >= 10*size){
    #  updown <- c(1,1,1)
    #  riglef <- c(1,1,1)
    #}
    # Sniff farther
    if(all(atual_i >= (size*1/4), atual_i <= (size*3/4), atual_j >= (size*1/4), atual_j <= (size*3/4))){
      if(any(m[(atual_i-(size*1/4)):(atual_i+(size*1/4)), (atual_j-(size*1/4)):(atual_j+(size*1/4))]==1)){
        # Sniff upper left
        if(any(m[(atual_i-(size*1/4)):(atual_i), (atual_j-(size*1/4)):(atual_j)]==1)){
          updown <- c(updown[1]+1, 1, 1)
          riglef <- c(riglef[1]+1, 1, 1)
        }
        # Sniff upper right
        if(any(m[(atual_i-(size*1/4)):(atual_i), (atual_j):(atual_j+(size*1/4))]==1)){
          updown <- c(updown[1]+1, 1, 1)
          riglef <- c(1, 1, riglef[3]+1)
        }
        # Sniff down left
        if(any(m[(atual_i):(atual_i+(size*1/4)), (atual_j-(size*1/4)):(atual_j)]==1)){
          updown <- c(1, 1, updown[3]+1)
          riglef <- c(riglef[1]+1, 1, 1)
        }
        # Sniff down right
        if(any(m[(atual_i):(atual_i+(size*1/4)), (atual_j):(atual_j+(size*1/4))]==1)){
          updown <- c(1, 1, updown[3]+1)
          riglef <- c(1, 1, riglef[3]+1)
        }
      }
    }
    
    # Sniff closer
    if(all(atual_i >= ceiling(size*1/10), atual_i <= ceiling(size*9/10), atual_j >= ceiling(size*1/10), atual_j <= ceiling(size*9/10))){
      if(any(m[(atual_i-ceiling(size*1/10)):(atual_i+ceiling(size*1/10)), (atual_j-ceiling(size*1/10)):(atual_j+ceiling(size*1/10))]==1)){
        # Sniff upper left
        if(any(m[(atual_i-ceiling(size*1/10)):(atual_i), (atual_j-ceiling(size*1/10)):(atual_j)]==1)){
          updown <- c(updown[1]+1, 1, 1)
          riglef <- c(riglef[1]+1, 1, 1)
        }
        # Sniff upper right
        if(any(m[(atual_i-ceiling(size*1/10)):(atual_i), (atual_j):(atual_j+ceiling(size*1/10))]==1)){
          updown <- c(updown[1]+1, 1, 1)
          riglef <- c(1, 1, riglef[3]+1)
        }
        # Sniff down left
        if(any(m[(atual_i):(atual_i+ceiling(size*1/10)), (atual_j-ceiling(size*1/10)):(atual_j)]==1)){
          updown <- c(1, 1, updown[3]+1)
          riglef <- c(riglef[1]+1, 1, 1)
        }
        # Sniff down right
        if(any(m[(atual_i):(atual_i+ceiling(size*1/10)), (atual_j):(atual_j+ceiling(size*1/10))]==1)){
          updown <- c(1, 1, updown[3]+1)
          riglef <- c(1, 1, riglef[3]+1)
        }
      }
    }
    
    # Up or down
    sample_i <- sample(c(-1,0,1), 1, prob = updown)
    # Right or left
    sample_j <- sample(c(-1,0,1), 1, prob = riglef)
    # Repeat if out of bounds
    if((atual_i + sample_i) %in% 1:size == F){
      updown[sample_i+2] <- 0.5
      next
    }
    if((atual_j + sample_j) %in% 1:size == F){
      riglef[sample_j+2] <- 0.5
      next
    }
    # Bonus if within bounds
    #if((atual_i + sample_i) %in% 1:size == T){
    #  updown[sample_i+2] <- 5
    #}
    #if((atual_j + sample_j) %in% 1:size == T){
    #  riglef[sample_j+2] <- 5
    #}
    # Move randomly
      atual_i <- atual_i + sample_i
      atual_j <- atual_j + sample_j

    # Mark spot if got to the center, or if got next to previously taken cell
    if(all(atual_i != 1, atual_i != size, atual_j != 1, atual_j != size)){
      if(any(m[(atual_i-1):(atual_i+1), (atual_j-1):(atual_j+1)]==1)) {
         #|| inv_i[atual_i] + inv_j[atual_j] == 2*max(inv_i)){
        m[atual_i, atual_j] <- 1
      break
      }
    }
      #count <- count + 1
  }
}

# Print
image(t(apply(m, 2, rev)), asp = 1, axes=FALSE, col = c("azure3", "midnightblue"))



