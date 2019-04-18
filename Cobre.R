# This script will simulate a copper solution run by an electrical field, forming deposits of copper particles in a fractal pattern.

# Function to detect number in cell surroundings
around <- function(m, num, i, j, zerotopbot = F){
  
  mm <- cbind(m, m, m)
  mm <- rbind(mm, mm, mm)
  
  # Se zerotopbot = T, linhas acima e abaixo da matriz central são zeradas
  if(zerotopbot == T){
    mm[nrow(m),] <- 0
    mm[2*nrow(m)+1,] <- 0
  }
  
  ii <- i + nrow(m)
  jj <- j + ncol(m)
  
  if(any(mm[ii+1,jj+1]==num, 
         mm[ii+1,jj]==num, 
         mm[ii+1,jj-1]==num, 
         mm[ii,jj+1]==num, 
         mm[ii,jj-1]==num, 
         mm[ii-1,jj+1]==num, 
         mm[ii-1,jj]==num, 
         mm[ii-1,jj-1]==num)){
    return(T)
  } else {
    return(F)
  }
}

# Set size of matrix
m_size <- 100

# Matrices
m1 <- matrix(rep(0, m_size*m_size), nrow = m_size)
m2 <- matrix(rep(0, m_size*m_size), nrow = m_size) # Final image

# Set repetitions
trials <- 1700








## RUN

for(i in 1:trials){
  # First copper particle starts to migrate
  linha <- sample(1:ncol(m1), 1)
  m1[nrow(m1), linha] <- 1
  
  # Scan [i, j] positions
  ianterior <- which(apply(m1, 1, sum)==1)
  janterior <- which(m1[ianterior,]==1)
  
  repeat{
  # Find next direction (randomly)
    # Condition #1: Recalculate, if backwards in bottom line
    repeat{
      Indexi <- sample(c(-1,0,1), 1, prob=c(3,2,1));
      if(Indexi == 1 && ianterior == nrow(m1)){ # Recalcula
      }else{
        ianterior <<- Indexi + ianterior
        break
      }
    }
    # Condition #2: Recalculate, if left from left column, or if right from right column
    repeat{
      Indexj <- sample(c(-1,0,1), 1)
      if(janterior == 1 && Indexj == -1){
        janterior <<- nrow(m1)
        break
      } else {
        if(janterior == nrow(m1) && Indexj == 1){
          janterior <<- 1
          break
        } else {
          janterior <<- Indexj + janterior
          break
        }
      }
    }
  
    # Mark new copper position
    m1[ianterior,janterior] <- 1
    
    # Check if particle has arriven in first row
    if(ianterior == 1){
      m2[ianterior, janterior] <- 1
      m1 <- matrix(rep(0, m_size*m_size), nrow = m_size)
      break
    }
    
    # Check if surrouding m2
    if(around(m2, 1, ianterior, janterior, T)){
      m2[ianterior, janterior] <- 1
      m1 <- matrix(rep(0, m_size*m_size), nrow = m_size)
      break
    }
  }
}


# Resulting image
image(t(apply(m2, 2, rev)), asp = 1)
