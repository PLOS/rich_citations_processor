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

require 'httpclient'
require 'multi_json'
require 'nokogiri'

module RichCitationsProcessor

  module HTTPUtilities
    extend self

    @client = HTTPClient.new
    @client.follow_redirect_count = 4

    def self.get(url, headers = {})
      retry_request(:get, url, nil, parse_headers(headers))
    end

    def self.post(url, content, headers = {})
      headers   = parse_headers(headers)
      content   = convert_content(content, headers)
      retry_request(:post, url, content, headers)
    end

    private

    def self.retry_request(method, url, content, headers)
      retry_count = 0
      while retry_count < 3
        resp = @client.request(method, url, nil, content, headers, true)
        if (resp.status == 502)
          return nil if retry_count > 2
          retry_count += 1
          sleep 5 * retry_count
        else
          return parse_response(resp, headers)
        end
      end
    end
    
    def self.parse_headers(headers)
      case headers
        when Symbol
          { 'Accept' => MIME_TYPES[headers] }
        when String
          { 'Accept' => headers }
        when Hash
          headers.each { |k,v| headers[k] = MIME_TYPES[v] || v.to_s }
        else
          headers
      end
    end

    # Don't pull in all of Actionpack just for the Mime types
    MIME_TYPES = {
      xml:  'application/xml',
      json: 'application/json',
      html: 'text/html',
    }

    # Cpnvert input content

    def convert_content(content, headers)
      case content
        when Hash, Array
          headers['Content-Type'] ||= MIME_TYPES[:json]
          MultiJson.dump(content)

        when Nokogiri::HTML::Document, Nokogiri::HTML::DocumentFragment
            headers['Content-Type'] ||= MIME_TYPES[:html]
          content.to_html

        when Nokogiri::XML::Node
          headers['Content-Type'] ||= MIME_TYPES[:xml]
          content.to_xml

        else
          content

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
      case content_type
      when %r{^text/xml}, %r{^application/xml}
        Nokogiri::XML.parse(body)

      when %r{^text/html}
        Nokogiri::HTML.parse(body)

      when %r{application/json}
        MultiJson.load(body).with_indifferent_access

        else
          nil

      end
    end

  end

end