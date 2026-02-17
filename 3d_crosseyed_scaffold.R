size <- 100
m <- matrix(1:(size^2), nrow=size)

for(i in 1:nrow(m)){
  for(j in 1:ncol(m)){
    if(i == 1 && j == 1){
      plot(x=j, 
           y=i, 
           cex=0, 
           pch=19,
           xlim = c(1,size),
           ylim = c(1,size),
           xaxt='n', yaxt='n', ann=FALSE
      )
    } else {
      if(i/(size/10) == round(i/(size/10)) && j/(size/10) == round(j/(size/10))){
        points(x=j, 
             y=i, 
             cex=1, 
             pch=19,
             xlim = c(1,size),
             ylim = c(1,size),
             xaxt='n', yaxt='n', ann=FALSE
             )
      }
    }
  }
}
