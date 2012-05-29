require 'spec_helper'
require 'supernet'
require 'ipaddress'

describe "SuperNet" do
  it "should be able to pre-allocate an ip address" do
    super_net = SuperNet.new("192.168.0.0/24")

    super_net.preallocate("192.168.0.16/28")
    super_net.allocated?("192.168.0.16/28").should be_true
   end

  it "should not allocate the same network more than once" do
    super_net = SuperNet.new("192.168.0.0/24")
    super_net.preallocate("192.168.0.16/28").should be_true

    expect { super_net.preallocate("192.168.0.16/28") }.to raise_error("192.168.0.16/28 already allocated.")
  end

  it "should return false if a network hasn't been allocated yet" do
    super_net = SuperNet.new("192.168.0.0/24")
    super_net.allocated?("192.168.0.32/28").should be_false
  end

  it "should raise an error if requested network is larger than supernet" do
    super_net = SuperNet.new("192.168.0.0/24")
    expect { super_net.preallocate("192.168.0.0/23") }.to raise_error( "192.168.0.0/23 is larger than supernet 192.168.0.0/24." )
  end
 
  it "overlap? should return true if requested net would overlap an already allocated smaller nets" do
    super_net = SuperNet.new("192.168.0.0/24")
    super_net.preallocate("192.168.0.16/29").should be_true
    
    net = IPAddress.parse("192.168.0.16/28")
    super_net.net_overlap?(net).should be_true

    net = IPAddress.parse("192.168.0.16/30")
    super_net.net_overlap?(net).should be_true
  end

  it "overlap? should return truee if requested net would overlap an already allocated larger net" do
    super_net = SuperNet.new("192.168.0.0/24")
    super_net.preallocate("192.168.0.16/29").should be_true
    
    net = IPAddress.parse("192.168.0.20/28")
    super_net.net_overlap?(net).should be_true
  end

  it "overlap? should return false if requested net would not overlap an already allocated net" do
    super_net = SuperNet.new("192.168.0.0/24")
    super_net.preallocate("192.168.0.16/29").should be_true
    
    net = IPAddress.parse("192.168.0.20/29")
    super_net.net_overlap?(net).should be_false
  end

  it "should not allocate two networks that overlap" do
    super_net = SuperNet.new("192.168.0.0/24")
    super_net.preallocate("192.168.0.16/29").should be_true
    expect { super_net.preallocate("192.168.0.16/30") }.to raise_error("192.168.0.16/30 already allocated.")
  end

  it "should allocate a network with the requested netmask" do
    super_net = SuperNet.new("192.168.0.0/24")

    new_net = super_net.allocate(25)

    new_net.prefix.to_i.should  == 25
    new_net.network.address.should == "192.168.0.0"
  end

  it "should allocate consecutive network with the requested netmask" do
    super_net = SuperNet.new("192.168.0.0/24")

    new_net = super_net.allocate(25)
    new_net.should == IPAddress.parse("192.168.0.0/25")

    new_net_2 = super_net.allocate(25)
    new_net_2.should == IPAddress.parse("192.168.0.128/25")
   end

  it "should error if all networks have been allocated" do
    super_net = SuperNet.new("192.168.0.0/24")

    super_net.allocate(25)
    super_net.allocate(25)
    expect {super_net.allocate(25)}.to raise_error( "Unable to allocate /25 network." )
   end

  it "should allocate networks of different sizes" do
    super_net = SuperNet.new("192.168.0.0/24")

    super_net.allocate(25)
    new_net = super_net.allocate(30)
    new_net.should == IPAddress.parse("192.168.0.128/30")
  end

  it "should be able to allocate the entire supernet as a subnet" do
    super_net = SuperNet.new("192.168.0.0/24")

    new_net = super_net.allocate(24)
    new_net.should == IPAddress.parse("192.168.0.0/24")
  end

# the same as the one above except with the larger network first
  it "should allocate networks of different sizes" do
    super_net = SuperNet.new("192.168.0.0/24")

    super_net.allocate(30)
    new_net = super_net.allocate(25)
    new_net.should == IPAddress.parse("192.168.0.128/25")
  end

  it "should allocate a network big enough to contain a number of hosts" do
    super_net = SuperNet.new("192.168.0.0/24")

    net_new = super_net.allocate_for_hosts(2)
    net_new.should == IPAddress.parse("192.168.0.0/30")
  end

  it "should work out an appropriate netmask for a given number of hosts" do
    super_net = SuperNet.new("192.168.0.0/24")

    super_net.netmask_for_hosts(2).should == 30
    super_net.netmask_for_hosts(3).should == 29
    super_net.netmask_for_hosts(4).should == 29
    super_net.netmask_for_hosts(253).should == 24
    super_net.netmask_for_hosts(257).should == 23
    
    expect { super_net.netmask_for_hosts(0) }.to raise_error("Number of hosts requested is out of bounds (should be between 1 and 4294967296")
  end

  # this test against a silly mistake that I don't want to happen again.
  it "should test against all previous allocations", :fail=> true do
    super_net = SuperNet.new("192.168.0.0/24")
    super_net.preallocate("192.168.0.0/28").should be_true
    super_net.preallocate("192.168.0.16/30").should be_true
    expect { super_net.preallocate("192.168.0.0/30") }.to raise_error("192.168.0.0/30 already allocated.")
  end

  it "should overlap with these networks that differ only by netmask" do
    super_net = SuperNet.new("192.168.0.0/24")
    super_net.preallocate("192.168.0.0/28").should be_true
    
    net = IPAddress.parse("192.168.0.0/30")
    super_net.net_overlap?(net).should be_true

    net = IPAddress.parse("192.168.0.0/28")
    super_net.net_overlap?(net).should be_true

    net = IPAddress.parse("192.168.0.0/29")
    super_net.net_overlap?(net).should be_true
  end

  it "should deallocate a network if it exists" do
    super_net = SuperNet.new("192.168.0.0/24")
    super_net.preallocate("192.168.0.0/28").should be_true
    super_net.deallocate("192.168.0.0/28").should be_true

    # test that I can add it again
    # (if the deallocation has failed, this should blow up
    super_net.preallocate("192.168.0.0/28").should be_true
  end
end

