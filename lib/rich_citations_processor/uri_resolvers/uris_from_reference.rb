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


# This resolver attempts to find any type of parseable URI
# From a reference href attributes and text

module RichCitationsProcessor
  module URIResolvers

    class UrisFromReference < Base

      def resolve!
        filtered_references.each do |ref| resolve_reference(ref) end
      end

      protected

      def self.priority
        10000
      end

      def resolve_reference(ref)
        fragment = Nokogiri::HTML::DocumentFragment.parse(ref.original_citation)

        resolve_from_href(ref, fragment)
        resolve_from_text(ref, fragment.text)
      end

      private

      # Find URIs in href attributes
      def resolve_from_href(ref, fragment)
        href_nodes = fragment.xpath('.//*[@href]')
        uri_classes = uri_classes_that_can_parse_uris

        uri_classes.each do |uri_class|
          href_nodes.each do |node|
            href_value = node['href'].to_s

            uri = uri_class.from_uri(href_value, source:'reference')
            ref.add_candidate_uri(uri)

          end
        end
      end

      # Find URIs in the text
      def resolve_from_text(ref, text)
        uri_classes = uri_classes_that_can_parse_text

        uri_classes.each do |uri_class|
          uris = uri_class.from_text(text, source:'reference')
          uris && uris.each do |uri| ref.add_candidate_uri(uri) end
        end

      end

      def uri_classes_that_can_parse_text
        URI::Registry.classes_that_respond_to(:from_text)
      end

      def uri_classes_that_can_parse_uris
        URI::Registry.classes_that_respond_to(:from_uri)
      end

    end
  end
end
