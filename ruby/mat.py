#!/usr/bin/python

import re

f = open('bjsim.rb')

for line in f:
    if re.match('\$actmatrix',line):
        break

for line in f:
    if re.match('\}',line):
        break
    line = re.sub("[\ \t]","",line)
    line = line.rstrip()
    [key,array] = line.split('=>')
    if key[0] == "'":
        key = re.sub("'",'"',key)
    else:
        key = '"%s"' % key
    array = re.sub("\%w\{","",array)
    array = re.sub("\}","",array)
    print '.put(%s,"%s".toCharArray())' % (key,array)
    
    
