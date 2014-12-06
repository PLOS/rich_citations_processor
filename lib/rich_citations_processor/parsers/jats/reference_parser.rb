# Copyright (c) 2014 Public Library of Science
#
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


require 'loofah'

module RichCitationsProcessor
  module Parsers
    class JATS
      class ReferenceParser

        attr_reader :document

        def initialize(document:)
          @document = document
        end

        def parse!
          reference_nodes.map do |number, node|
            id = node[:id]
            original_citation = clean_citation(node).to_s.strip
            Models::Reference.new(id: id, number:number, original_citation:original_citation)
          end
        end

        private

        def reference_nodes
          @reference_nodes ||= begin
            document.css('ref-list ref').map.with_index{ |node, index| [index+1, node] }.to_h
          end
        end

        # Convert Citation from JATS to HTML and remove the label node
        def clean_citation(xml_node)
          label = xml_node.css('label')
          label.remove if label.present?
          jats_to_html(xml_node)
        end

        def jats_to_html(node)
          return nil unless node.present?

          doc = Loofah.xml_fragment(node.to_s)
          doc.scrub!( JatsToHtml.new )
        end

      end
    end
  end
end