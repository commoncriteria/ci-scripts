#!/usr/bin/env python3
import sys
from bs4 import BeautifulSoup
contents = ""

with open('../commoncriteria.github.io/index.html.bak', 'r') as fp:
    contents = fp.read()

soup = BeautifulSoup(contents, 'html.parser')
for div in soup.find_all('div', class_="collapsible-header"):
    #Print PP name
    if (div.next_element.contents[0].next_sibling == sys.argv[1].strip()):
        # Print the PP name (debug only)
        #print(div.next_element.contents[0].next_sibling)
        # Prints the date/time the last time the PP was built.
        print(div.next_sibling.next_sibling.next_element.next_element.contents[0].next_sibling.next_sibling.next_sibling.next_element.next_element.next_element.next_element.next_sibling.next_sibling.next_sibling.string.strip())
