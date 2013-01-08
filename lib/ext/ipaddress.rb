require 'ipaddress'

module IPAddress

  class IPv4
    def eql?(oth)
      self == oth
    end

    def hash
      [ to_u32, prefix.to_u32 ].hash
    end

    def self.parse_u(u32, prefix=32)
      parse_u32(u32, prefix)
    end

    def network_u
      network_u32
    end
   end

  class IPv6
    def eql?(oth)
      self == oth
    end

    def hash
      [ to_u128, prefix.to_u128 ].hash
    end

    def self.parse_u(u128, prefix=128)
      parse_u128(u128, prefix)
    end

    def network_u
      network_u128
    end

    def subnet(subprefix)
      max_bits = self.bits.length
      unless ((@prefix.to_i)..max_bits).include? subprefix
        raise ArgumentError, "New prefix(#{subprefix}) must be between #{@prefix} and #{max_bits}"
      end
      Array.new(2**(subprefix-@prefix.to_i)) do |i|
        self.class.parse_u(network_u+(i*(2**(max_bits-subprefix))), subprefix)
      end
    end
  end

# this should be included in ipaddress gem too but isn't
# needed directly in order for supernet to work
#  class Prefix
#    def eql?(oth)
#      self == oth
#    end
#
#    def hash
#      to_i.hash
#    end
#  end

end
