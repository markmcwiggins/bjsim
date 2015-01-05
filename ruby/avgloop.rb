#!/usr/bin/ruby

f = open('/tmp/loops','r')

sum = 0
nline = 0
highest = 0
lowest = 1000000000
for line in f
  puts line
  (nloop,n,ig,nore) = line.split
  nline += 1
  nx = n.to_i
  sum += nx
  highest = nx if nx > highest
  lowest = nx if nx < lowest
    
end
avg = sum.to_f / nline
printf("avg bust: %f\n",avg)
printf("highest: %d lowest %d\n",highest,lowest)



