library(png)
library(RCurl)

pngurl = "http://fitnesshubzone.com/wp-content/uploads/2018/10/instagram-social-icon.png"
imgcol =  readPNG(getURLContent(pngurl))
imggray=as.matrix(imgcol[,,1]) # Get only grayscale value
imggray=t(apply(imggray, 2, rev))
# image(imggray) # Check the image

for(i in 1:nrow(imggray)){
  for(j in 1:ncol(imggray)){
    if(i == 1 && j == 1){
      plot(x=j, 
           y=i, 
           cex=imggray[i,j]*2, 
           pch=19,
           xlim = c(0,ncol(imggray)),
           ylim = c(0,nrow(imggray))
      )
    } else {
      points(x=j, 
             y=i, 
             cex=imggray[i,j]*2, 
             add=T,
             pch=19,
             xlim = c(0,ncol(imggray)),
             ylim = c(0,nrow(imggray))
      )
    }
  }
}
