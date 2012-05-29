require 'ipaddress'
require 'set'

class SuperNet
  attr_reader :network
  attr_reader :allocated

  def initialize(network_string)
    @network = IPAddress.parse(network_string)
    @allocated = Set.new
  end

  def preallocate_net(net)
    if net_overlap?(net)
      raise "#{net.address}/#{net.prefix} already allocated."
    else
      if net.prefix >= @network.prefix
        @allocated.add net
      else
        raise "#{net.address}/#{net.prefix} is larger than supernet #{@network.address}/#{@network.prefix}."
      end
    end
    return net
  end

  def preallocate(network)
    net = IPAddress.parse(network)
    return preallocate_net(net)
  end

  def deallocate(network)
    net = IPAddress.parse(network)
    return deallocate_net(net)
  end

  def deallocate_net(net)
    deleted = @allocated.delete?(net)
    return deleted != nil
  end

  def net_prefix_overlap?(net_a,net_b)
    if net_a.prefix < net_b.prefix
      return net_a.subnet(net_b.prefix).include?(net_b)
    else
      return net_b.subnet(net_a.prefix).include?(net_a)
    end
  end

  def net_overlap?(net_a)
    overlap_found = false
    @allocated.each do |net_b|
      overlap_found ||= net_prefix_overlap?(net_a, net_b)
    end
    return overlap_found
  end

  def allocated?(network)
    net = IPAddress.parse(network)
    return net_allocated?(net)
  end

  def net_allocated?(net)
    return @allocated.include?(net)
  end

  def allocate(netmask)
    all_subnets = @network.subnet(netmask)
    allocated_net = nil
    all_subnets.each do |net|
      if not net_allocated?(net)
        if not net_overlap?(net)
          allocated_net = net
          break
        end
      end
    end

    if allocated_net.nil?
      raise "Unable to allocate /#{netmask} network."
    end

    return preallocate_net(allocated_net)
  end

  def allocate_for_hosts(num_hosts)
    netmask = netmask_for_hosts(num_hosts)
    return allocate(netmask)
  end

  def max_hosts
    return 2**max_bits
  end

  def max_bits
    return 32
  end

  def netmask_for_hosts(num_hosts)
    if num_hosts > max_hosts or num_hosts < 1
      raise "Number of hosts requested is out of bounds (should be between 1 and #{max_hosts}"
    end

    num_hosts_with_net_and_bcast = num_hosts + 2

    # this bit of magic creates a list of possible netmasks that can contain
    # num_hosts_with_net_and_bcast hosts and returns the smallest one found
    #
    # it's sorted by it's nature, which is why .first gives us what we want
    host_bits = ((0..max_bits).select {|i| num_hosts_with_net_and_bcast <= 2**i}).first

    netmask = max_bits - host_bits
    return netmask
  end

end
