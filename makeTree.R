library('ape')
library('Biostrings')
library('ggplot2')
library('ggtree')
library('svglite')

args <- commandArgs()

nwk <- print(paste0('./loci_alignments/loci/', args[6], '/', args[6], '.tree'))
t <- treeio::read.newick(nwk)

tips <- sub('(_.*|$)', '', t$tip.label)
t$tip.label <- tips

p <- ggtree(t, layout = 'equal_angle') + 
  geom_tiplab(align = FALSE, size = 3.6) +
  coord_cartesian(clip = 'off') +
  theme(plot.margin = unit(c(14,10,14,0), "mm")) +
  theme(plot.title = element_text(hjust = 0.075))

ggsave(paste0('./loci_alignments/loci/', args[6], '/', args[6], '_tree.svg'), width = 10, height = 10)

