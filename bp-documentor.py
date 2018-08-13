#!/usr/bin/env python3
from io import StringIO 
import re
import sys
import xml.etree.ElementTree as ET
from xml.sax.saxutils import escape



XSLNS="http://www.w3.org/1999/XSL/Transform"
HTMNS="http://www.w3.org/1999/xhtml"
ns={"xsl":XSLNS, "htm":HTMNS}


def warn(msg):
    log(2, msg)

def err(msg):
    sys.stderr.write(msg)
    sys.exit(1)

def debug(msg):
    log(5, msg)

def log(level, msg):
    sys.stderr.write(msg)
    sys.stderr.write("\n")





def gather_contents(elem):
    ret=""
    if elem.text:
        ret += escape(elem.text)
    for child in elem:
        if child.tag.startswith("{http://www.w3.org/1999/XSL/Transform}"):
            continue
        tagr = child.tag.split('}')
        noname=tagr[len(tagr)-1]
        if noname=="br":
            ret += "<br/>"
            continue
        elif noname=="td" or noname=='tr':
            noname="div"
        ret += "<" + noname
        for attrname in child.attrib:
            ret += " " + attrname + "='"+ escape(child.attrib[attrname])+"'"
        ret += ">"
        ret += gather_contents(child)
        ret += '</' + noname +'>'
        if child.tail:
            ret += child.tail
    return ret



if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: bp-documentor <boilerplate-xsl-file>")
        sys.exit(0)

    infile=sys.argv[1]
    if infile=="-":
        root=ET.fromstring(sys.stdin.read())
    else:
        root=ET.parse(infile).getroot()

    print("<html><head><title>Boilerplates</title></head><body><table>")
    for el in root.findall(".//xsl:template[@match]", ns):
        contents = gather_contents(el)
        if contents != "":
            print("<tr><td style='background: green;'>"+el.attrib["match"]+"</td></tr><tr><td style='background: lightblue;'>"+contents+"</td></tr>")
    print("</table>")
    print("</body></html>")

