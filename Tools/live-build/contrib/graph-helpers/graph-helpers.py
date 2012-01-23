#!/usr/bin/env python

"""
    live-helper simulated execution graph generator.
    Copyright (C) 2007  Chris Lamb <chris@chris-lamb.co.uk>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import sys, re
import pygraphviz

groups = {
    'lh_bootstrap' : 'orange',
    'lh_chroot' : 'red',
    'lh_source' : 'blue',
    'lh_binary' : 'green',
    'lh_build' : 'brown'
}
pattern = re.compile(r'^(lh_.+?) ')

def main(start):
    global prev
    G = pygraphviz.AGraph(directed=True)
    G.graph_attr['label'] = 'Simulated execution trace for live-helper.'

    def helper(filename):
        global prev
        for line in gen_matches(filename):
            G.add_edge(prev, line)
            style(G.get_node(prev), prev)
            prev = line
            helper(line)

    prev = start
    helper(start)
    G.layout(prog='dot')
    print G.draw(format='svg')

def style(node, name):
    if name in groups.keys():
        node.attr['shape'] = 'box'
        node.attr['style'] = 'bold'
    else:
        node.attr['fontsize'] = '11'
    for group_name, color in groups.iteritems():
        if name.startswith(group_name):
            node.attr['color'] = color
    return node

def gen_matches(filename):
    f = open('/usr/bin/%s' % filename, 'r')
    for line in f.xreadlines():
        match = pattern.match(line)
        if match:
            yield match.group(1)
    f.close()

if __name__ == "__main__":
    if len(sys.argv) == 2:
        main(sys.argv[1])
    else:
        main('lh_build')
