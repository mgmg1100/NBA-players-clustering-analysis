players = read.csv("players_clustering.csv")
players = players#[players$Min > 10&players$GP>30,]

mnorm = function(x)
{z= ((x-min(x))/(max(x)-min(x)))
return(z)
}

attach(players)


players_norm = data.frame(Name = Name,
                          mnorm(GP),mnorm(Min),mnorm(ASTR),mnorm(Assited.FGM),mnorm(TOR),
                          mnorm(ORR),mnorm(DRR),mnorm(rim_FGA_p40),
                          mnorm(X5_9_FGA_p40),mnorm(X10_14_FGA_p40),
                          mnorm(X15_19_FGA_p40),mnorm(X20_24_FGA_p40),
                          mnorm(X25_29_FGA_p40),mnorm(BLK_p40),mnorm(STL_p40)
)
players_z = data.frame(Name = Name,
                       scale(GP),scale(Min),scale(ASTR),scale(Assited.FGM),
                       scale(TOR),scale(ORR),scale(DRR),scale(rim_FGA_p40),
                       scale(X5_9_FGA_p40),scale(X10_14_FGA_p40),
                       scale(X15_19_FGA_p40),scale(X20_24_FGA_p40),
                       scale(X25_29_FGA_p40),scale(BLK_p40),scale(STL_p40)
  
)

detach(players)

NbClust(data = players_z[,5:16], diss = NULL, distance = "euclidean", min.nc = 2, max.nc = 15, 
        
        method = "complete", index = "all", alphaBeale = 0.1)

NbClust(data = players_norm[,5:16], diss = NULL, distance = "euclidean", min.nc = 2, max.nc = 15, 
        
        method = "complete", index = "all", alphaBeale = 0.1)

#KMEANS:
players_clusters_k1 = kmeans(players_norm[,2:16], 10)
players_clusters_k2 = kmeans(players_z[,2:16], 10)

players_clusters_k1
players_clusters_k2
#library(cluster)
#library(HSAUR)
#dissE=?daisy(players_norm[,2:16]) 
#dE2 = dissE^2
#sk2 = silhouette(players_clusters1$cl, dE2)
#plot(sk2)



#Hclustering:
players_clusters_h1 = hclust(dist(players_norm[,2:16]), method = "ward.D")
players_clusters_h2 = hclust(dist(players_z[,2:16]), method = "ward.D")


plot(players_clusters_h1)
plot(players_clusters_h2)



#EM:
library(EMCluster)
set.seed(123)
emobj1 = simple.init(players_norm[,2:16], nclass = 10)
#Sys.sleep(5)
emobj1 = shortemcluster(players_norm[,2:16] , emobj1)
#Sys.sleep(5)
#summary(emobj1)
players_clusters_em1 = emcluster(players_norm[,2:16],emobj1,assign.class = TRUE)

set.seed(123)
emobj2 = simple.init(players_z[,2:16], nclass = 10)
#Sys.sleep(5)
emobj2 = shortemcluster(players_z[,2:16] , emobj2)
#summary(emobj2)
#Sys.sleep(5)
players_clusters_em2 = emcluster(players_z[,2:16],emobj2,assign.class = TRUE)


library(mclust)
BIC1 = mclustBIC(players_norm[,2:16])
summary(BIC1)
BIC2 = mclustBIC(players_z[,2:16])
summary(BIC2)

mod1 = Mclust(players_z[,2:16], x = BIC2)
summary(mod1, parameters = TRUE)




library(fpc)
#######normalize
plotcluster(players_norm[,2:16], players_clusters_k1$cluster)
plotcluster(players_norm[,2:16], cutree(players_clusters_h1, k=10))
plotcluster(players_norm[,2:16], players_clusters_em1$class)
clusplot(players_norm[,2:16], players_clusters_k1$cluster, color=TRUE, shade=TRUE,
         labels=0, lines=0)
clusplot(players_norm[,2:16], cutree(players_clusters_h1, k = 10), color=TRUE, shade=TRUE,
         labels=0, lines=0)
clusplot(players_norm[,2:16], players_clusters_em1$class, color=TRUE, shade=TRUE,
         labels=0, lines=0)


players_norm$class1=players_clusters_k1$cluster
players_norm$class2=cutree(players_clusters_h1 , k = 10)
players_norm$class3=players_clusters_em1$class

players_clusters_em1$Mu
players_clusters_k1$centers




#######z_score
plotcluster(players_z[,2:16], players_clusters_k2$cluster)
plotcluster(players_z[,2:16], cutree(players_clusters_h2, k = 10))
plotcluster(players_z[,2:16], players_clusters_em2$class)
clusplot(players_z[,2:16], players_clusters_k2$cluster, color=TRUE, shade=TRUE,
         labels=0, lines=0)
clusplot(players_z[,2:16], cutree(players_clusters_h2, k = 10), color=TRUE, shade=TRUE,
         labels=0, lines=0)
clusplot(players_z[,2:16], players_clusters_em2$class, color=TRUE, shade=TRUE,
         labels=0, lines=0)

players_z$class3=players_clusters_em2$class
players_z$class2=cutree(players_clusters_h2, k = 10)
players_z$class1=players_clusters_k2$cluster

players_clusters_em2$Mu
players_clusters_k2$centers




###plot hclust using z-score
library(colorspace)
players_groups = rev(levels(players_z$class2))
cluster_col = rev(rainbow_hcl(10))[as.numeric(players_z$class2)]

par(las = 1, mar = c(4.5, 3, 3, 2) + 0.1, cex = .8)
MASS::parcoord(players_z[,2:16], col = cluster_col, var.label = TRUE, lwd = 2)

par(xpd = TRUE)
legend(x = 1.75, y = -.25, cex = 1, legend = 10,fill = unique(cluster_col), horiz = TRUE)
par(xpd = NA)




library(dendextend)
dend = as.dendrogram(players_clusters_h2)
dend = rotate(dend, 1:150)
dend = color_branches(dend, k=3)

labels_colors(dend) = rainbow_hcl(10)[sort_levels_values(as.numeric(players_z$class2)[order.dendrogram(dend)])]
labels(dend) = paste(as.character(players_z$Name)[order.dendrogram(dend)],"(",labels(dend),")", sep = "")

dend = hang.dendrogram(dend,hang_height=0.1)
dend = set(dend, "labels_cex", 0.5)
par(mar = c(3,3,3,7))

plot(dend, main = "Players Clusters", horiz =  TRUE,  nodePar = list(cex = .007))
legend("topleft", legend = players_groups, fill = rainbow_hcl(10))

library(globalOptTests)
library(circlize)
par(mar = rep(0,4))
circlize_dendrogram(dend)


