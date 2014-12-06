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

module RichCitationsProcessor

  # The input to a URI is an identifier but it is returned as a Full URI

  module URI
    extend self

    # Create a URI based on an identifier
    def create(identifier, type:)
      klass = lookup(type)
      klass && klass.new(identifier)
    end

    def from_uri(uri)
      classes_that_can_parse_uris.each do |uri_class|
        instance = uri_class.from_uri(uri)
        return instance if instance
      end

      nil
    end

    def from_text(text)
      classes_that_can_parse_text.flat_map do |uri_class|
        uri_class.from_text(text) || []
      end
    end

    def lookup(type)
      Registry.lookup(type)
    end

    def lookup!(type)
      Registry.lookup!(type)
    end

    private

    def classes_that_can_parse_uris
      @uri_parsers ||= Registry.classes_that_respond_to(:from_uri)
    end

    def classes_that_can_parse_text
      @text_parsers ||= Registry.classes_that_respond_to(:from_text)
    end

  end
end