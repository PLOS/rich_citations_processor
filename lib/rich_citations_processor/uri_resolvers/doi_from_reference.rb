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
  module URIResolvers

    class DoiFromReference < Base

      def resolve!
        filtered_references.each do |ref| resolve_reference(ref) end
      end

      protected

      def self.priority
        30
      end

      def resolve_reference(ref)
        fragment = Nokogiri::HTML::DocumentFragment.parse(ref.original_citation)

        # Find URIs in href attributes
        nodes = fragment.xpath('.//*[@href]')
        nodes.each do |node|
          href = node['href'].to_s
          uri = URI::DOI.from_uri(href, source:'reference')
          ref.add_candidate_uri(uri)
        end

        # Find URIs in the text
        text = fragment.text
        uris = URI::DOI.from_text(text, source:'reference')
        uris && uris.each do |uri| ref.add_candidate_uri(uri) end
      end

      private

    end
  end
end
