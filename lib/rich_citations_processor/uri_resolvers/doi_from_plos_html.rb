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

    class DoiFromPlosHtml < Individual

      protected

      def attempt?
        citing_uri.is_a?(URI::DOI) && citing_uri.provider == :plos
      end

      def identifier_for_reference(ref)
        ref_node = node_for_ref_id(ref.id)
        return unless ref_node.present?

        links_node = ref_node.css('> ul.find')
        return unless links_node.present?

        doi = links_node.first['data-doi']

        doi && URI.create(doi, type: :doi, source:'plos_html')
      end

      private

      def reference_nodes
        @reference_nodes ||= begin
          html = API::PLOS::get_web_page(citing_uri)
          html.css('ol.references li')
        end
      end

      def node_for_ref_id(ref_id)
        reference_nodes.find do |n|
          n.xpath("./a[@id = '#{ref_id}']").present?
        end
      end

    end
  end
end
