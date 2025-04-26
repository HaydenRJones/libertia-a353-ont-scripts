import sys
from ete3 import Tree

intree = sys.argv[1]

name = ''.join(intree.split('/')[-1].split('.')[0])[:-6]
#print(name)

tree = Tree(intree, quoted_node_names = True)

midpoint = tree.get_midpoint_outgroup()
tree.set_outgroup(midpoint)

#tree.set_outgroup('L252_{}'.format(str(name)))
#tree.resolve_polytomy(recursive=True)

print(tree.write())
