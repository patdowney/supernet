require 'ipaddress'

module IPAddress

  class IPv4
    def eql?(oth)
      self == oth
    end

    def hash
      [ to_u32, prefix.to_u32 ].hash
    end

    def subnet_net(subprefix)
      subnet(subprefix.to_i)
    end
  end

  class IPv6
    def eql?(oth)
      self == oth
    end

    def hash
      [ to_u128, prefix.to_u128 ].hash
    end
  end

  class Prefix
    def eql?(oth)
      self == oth
    end

    def hash
      to_i.hash
    end
  end

end
