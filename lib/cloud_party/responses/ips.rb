# frozen_string_literal: true

# require 'cloud_party/responses/nodes/ips'
module CloudParty
  module Responses
    #
    class IPs
      include CloudParty::Response
      def initialize(method_name, endpoint, response, options)
        @code = response.code
        @body = JSON.parse(response.body, symbolize_names: true)
        @success = @body[:success]
        unless successful?
          message = <<~MESSAGE
            Unable to #{method_name.to_s.upcase} to endpoint:
            #{endpoint}. Inspect CloudParty::APIError#response
            for further details
          MESSAGE
          raise CloudParty::APIError.new(message, response)
        end

        # @results = []
        # @body[:result].each do |res|
        #   @results << CloudParty::Responses::Result.new(res)
        # end
        @result = CloudParty::Responses::Result.new(@body[:result])
        @results = [@result]
        @errors = []
        @body[:errors].each do |err|
          @errors << CloudParty::Responses::Error.new(err)
        end
        @messages = []
        @body[:messages].each do |msg|
          @messages << CloudParty::Responses::Message.new(msg)
        end
      end

      def code
        @code
      end
      def successful?
        @success
      end
      alias success successful?
      attr_reader :messages

      def result
        @results.first
      end

      attr_reader :results

      def inspect
        wanted_methods = %i[errors messages success results result]
        our_methods    = methods.select do |m|
          wanted_methods.include? m
        end
        outputs = []
        our_methods.each do |m|
          outputs << "#{m}=#{send(m)}"
        end
        "#<Response: #{outputs.join(', ')}>"
      end

      def to_s
        inspect
      end
    end
    class Result
      attr_reader :ipv4_cidrs, :ipv6_cidrs
      def initialize(result)
        @result = result
        @result.each do |k, v|
          instance_variable_set(:"@#{k}", v)
        end
      end



      def inspect
        wanted = %i[ipv4_cidrs ipv6_cidrs]
        outputs = []
        wanted.each do |m|
          outputs << "#{m.to_s}=#{send(m)}"
        end
        "#<Result #{outputs.join(', ')}>"
      end

      def to_s
        inspect
      end
    end
    class Error
      def initialize(error)
        @error   = error
        @code    = error.fetch(:code, nil)
        @message = error.fetch(:message, nil)
      end

      attr_reader :code

      attr_reader :message

      def inspect
        to_s
      end

      def to_s
        wanted_methods = %i[code message]
        our_methods    = methods.select do |m|
          wanted_methods.include? m
        end
        outputs = []
        our_methods.each do |m|
          outputs << "#{m}=#{send(m)}"
        end
        "#<Error: #{output.join(', ')}>"
      end
    end
    class Message
      def initialize(message)
        @message = message
      end

      def inspect
        to_s
      end

      def to_s
        @messages.join(', ')
      end
    end
  end
end
