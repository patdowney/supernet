SuperNet
========

'super' as in 'inclusive' and not 'sensational, smashing, superb, outstanding'.

A totally non-egotistical name for a possibly not very useful library.

I think it works with both IPv4 and IPv6 networks/subnets.

Notes
-----
The `overlaps?` method needs optimising. Operations using large address spaces
may take a long time. I need to get a better idea about the performance
characteristics of it and spend some times with `1`s and `0`s.

Dependencies
------------
- `ipaddress 0.8.0`

Usage
-----
Add it to your `Gemfile` and give it a good `bundle install` to pull down the `ipaddress` dependancy


    > require 'supernet'
    >
    > s = SuperNet.new("192.168.0.0/24")
    >
    > s.reserve("192.168.0.0/28")
    >
    > s.reserve("192.168.0.0/29")
    RuntimeError: 192.168.0.0/29 already allocated.
        from /.../supernet/supernet.rb:39:in `reserve'
        from (irb):5
        from /.../.rvm/rubies/ruby-1.9.3-p194/bin/irb:16:in `<main>'
    > s.reserve("192.168.0.0/27")
    RuntimeError: 192.168.0.0/27 already allocated.
        from /.../supernet/supernet.rb:39:in `reserve'
        from (irb):6
        from /.../.rvm/rubies/ruby-1.9.3-p194/bin/irb:16:in `<main>'
    >
    > s.allocated
     => #<Set: {192.168.0.0}> 
    >
    > n1 = s.allocate_for_hosts( 4 )
    > n1.hosts
     => [192.168.0.17, 192.168.0.18, 192.168.0.19, 192.168.0.20, 192.168.0.21, 192.168.0.22] 
    > s.allocated
     => #<Set: {192.168.0.0, 192.168.0.16}> 
    > 

Copyright/Licensing
------------------
Copyright 2012 Pat Downey, see `LICENSE` file for license details.
