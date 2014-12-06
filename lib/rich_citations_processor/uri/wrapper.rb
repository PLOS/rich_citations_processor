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

# Implements a wrapper around URIs that adds metadata
# It should look like a URI

module RichCitationsProcessor
  module URI

    class Wrapper
      attr_reader :uri
      attr_reader :source
      attr_reader :metadata

      delegate :full_uri,
               :to_uri,
               :as_json,
           to: :uri

      def initialize(uri, source:, **metadata)
        @uri      = uri
        @source   = source
        @metadata = metadata
      end

      def class
        uri.class
      end

      def ==(other)
        other = other.uri if other.is_a?(Wrapper)
        uri.==(other)
      end

      def with_metadata(source:nil, **metadata)
        source ||= @source
        raise ArgumentError.new('missing keyword: source') unless source

        @source = source
        @metadata.merge!(metadata)
        self
      end

      def inspect
        suffix = " [#{metadata_string}]" if metadata.present?
        "[#{source}] #{uri.inspect}#{suffix}"
      end

      def to_s
        uri.full_uri
      end

      def method_missing(method, *args)
        if metadata && metadata.has_key?(method)
          metadata[method]
        elsif uri.respond_to?(method)
          uri.send(method, *args)
        else
          super
        end
      end

      private

      def metadata_string
        metadata.present? ? metadata.map{ |k,v| "#{k}:#{v.nil? ? 'nil' : v}"}.join(';') : nil
      end

    end
  end
end
