require "docker/env/link/version"

module Docker
  module Env
    class Link
      VAR_PATTERN = /\A(?:(\w+?)(?:_(\d+))?)_PORT_(\d+)_TCP\z/
      VAL_PATTERN = /\A(\w+):\/\/([^:]+):(\d+)\z/

      attr_accessor *%i(service service_port service_instance proto addr port)

      def initialize service, service_port, service_instance, proto, addr, port
        @service = service
        @service_port = service_port
        @service_instance = service_instance.nil? ? nil : service_instance.to_i
        @proto = proto
        @addr = addr
        @port = port.nil? ? nil : port.to_i
      end

      def self.find service = nil, port = nil, default = nil, &formatter
        formatter ||= -> (link) { "#{link.addr}:#{link.port}" }

        accept_service = -> (s) { service.nil? || s =~ /\A#{service}\z/i || s === service }
        accept_port    = -> (p) { port.nil?    || p =~ /\A#{port}\z/     || p === port }

        instances = ENV.map do |k,v|
          m = k.match(VAR_PATTERN) or next

          # Check the port and service; extract the captured service name and
          # instance number from any successful match
          s, n, p = m.captures

          next unless accept_service.call(s)
          next unless accept_port.call(p)

          # Match against the value to extract PROTO, ADDR, and PORT
          m = v.match(VAL_PATTERN) or next

          new(s, p, n, *m.captures)
        end.compact

        found = if instances.nil? || instances.empty?
          default
        else
          instances.map(&formatter)
        end

        Array(found)
      end
    end
  end
end
