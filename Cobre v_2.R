# A quicker and simpler version

# This script will simulate a copper solution run by an electrical field, forming deposits of copper particles in a fractal pattern.

# Function to detect number in cell surroundings
around <- function(m, num, i, j){
  
  if(any(m[(i-1):(i+1),(j-1):(j+1)]==num)){
    return(T)
  } else {
    return(F)
  }
}

# Set size of matrix
m_size <- 400
linha_inicio <- m_size*2
linha_fim <- m_size+1
coluna_inicio <- m_size+1
coluna_fim <- m_size*2

# Matrices
m2 <- matrix(rep(0, (m_size*3)^2), nrow = m_size*3)

# Set repetitions
trials <- 20000








## RUN
system.time(
for(i in 1:trials){
  # First copper particle starts to migrate
  coluna <- sample(1:m_size, 1) + m_size
  
  # Scan [i, j] positions
  ianterior <- linha_inicio
  janterior <- coluna
  
  repeat{
    # Find next direction (randomly)
    # Condition #1: Recalculate, if backwards in bottom line
    repeat{
      Indexi <- sample(c(-1,0,1), 1, prob=c(1000,3,1));
      if(Indexi == 1 && ianterior == linha_inicio){ # Recalcula
      }else{
        ianterior <<- Indexi + ianterior
        break
      }
    }
    # Condition #2: Recalculate, if left from left column, or if right from right column
    repeat{
      Indexj <- sample(c(-1,0,1), 1, prob=c(1,3,1))
      if(janterior == coluna_inicio && Indexj == -1){
        janterior <- coluna_fim
        break
      } else {
        if(janterior == coluna_fim && Indexj == 1){
          janterior <- coluna_inicio
          break
        } else {
          janterior <- Indexj + janterior
          break
        }
      }
    }
    
    # Check if particle has arriven in first row
    if(ianterior == linha_fim){
      m2[ianterior, janterior] <- 1
      break
    }
    
    # Check if surrouding m2
    if(around(m2, 1, ianterior, janterior)){
      m2[ianterior, janterior] <- 1
      break
    }
  }
  #paste(i, "in", trials, "trials")
}
)

# Crop image
m3 <- m2[(m_size+1):(m_size*2), (m_size+1):(m_size*2)]

# Resulting image
image(t(apply(m3, 2, rev)), asp = 1)
