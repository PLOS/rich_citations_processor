# Copyright (c) 2014 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'net/http'
require 'net/http/persistent'
require 'uri'
require 'multi_json'
require 'nokogiri'

module RichCitationsProcessor

  module HTTPUtilities
    extend self

    REDIRECT_LIMIT = 3

    def self.get(url, headers={})
      headers   = parse_headers(headers)
      make_request( url, headers) do |request_uri|
        # puts "GET #{request_uri}"
        Net::HTTP::Get.new(request_uri, headers)
      end
    end

    def self.post(url, content, headers={})
      headers   = parse_headers(headers)
      make_request( url, headers) do |request_uri|
        # puts "POST #{request_uri}"
        req = Net::HTTP::Post.new(request_uri, headers)
        req.body = content
        req
      end
    end

    private

    def self.make_request(url, headers={}, &block)
      redirects      = []
      retry_count    = 0
      http      = Net::HTTP::Persistent.new
      # http.debug_output = $stdout

      loop do
        uri      = ::URI.parse(url)
        request  = yield(uri.request_uri)
        response = http.request uri, request

        # Handle redirects
        location = response.header['location']
        if location
          raise Net::HTTPFatalError.new("Recursive redirect", 508) if redirects.include?(location)
          raise Net::HTTPFatalError.new("Too many redirects", 508) if redirects.length >= REDIRECT_LIMIT
          redirects << location
          url = location

        # Retry for certain response codes
        elsif (response.code.to_i == 502)
          response.value if retry_count > 2
          retry_count +=1
          # slow it down
          http.shutdown
          sleep 5 * retry_count

        else
          response.value
          return parse_response( response, headers )
        end

      end
    end

    def self.parse_headers(headers)
      case headers
        when Symbol
          { 'Accept' => "application/#{headers}" }
        when String
          { 'Accept' => headers }
        when Hash
          headers.each { |k,v| headers[k] = v.to_s }
        else
          headers
      end
    end

    # Parse response intelligently

    def self.parse_response(response, sent_headers)
      body = response.body
      return nil if body.blank?

      # Try parsing using the returned type then the requested type
      parsed_resoonse_for(response.content_type, body) ||
      parsed_resoonse_for(sent_headers['Accept'], body) ||
      body
    end

    def self.parsed_resoonse_for(content_type, body)
      if ['text/xml', 'application/xml'].include?(content_type)
        Nokogiri::XML.parse(body)

      elsif ['application/json'].include?(content_type)
        MultiJson.load(body, symbolize_names:true)

      else
        nil

      end
    end

  end

end