#!/usr/bin/ruby

for k in (1..50)
  cmdline = sprintf("ruby ./bjsim.rb >/tmp/tue100k.%d",k)
  puts k
  system (cmdline)
  tailcmd = sprintf("tail /tmp/tue100k.%d | grep nloop: >>/tmp/loops",k)
  system(tailcmd)
end

