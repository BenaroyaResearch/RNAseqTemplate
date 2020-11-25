# Perform PCA
# See also: http://www.sthda.com/english/articles/31-principal-component-methods-in-r-practical-guide/118-principal-component-analysis-in-r-prcomp-vs-princomp/
#
pcaResult = prcomp(log2(as.data.frame(t(counts_pc_norm))+1), center=TRUE, scale=FALSE)

# get the loadings - when using prcomp(), that's in the $rotation slot
loadings <- pcaResult$rotation
class(loadings) # matrix of genes by PCs

#if using princomp loadings are in $loadings slot
#loadings <- prinResults$loadings

#order the genes by their loadings
pc1 <- loadings[order(loadings[,"PC1"], decreasing = T),"PC1"]




