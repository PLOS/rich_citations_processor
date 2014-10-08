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
require 'nokogiri'

module RichCitationsProcessor
  module Parsers

    class NLM
      attr_reader :paper
      attr_reader :document

      def self.mime_types
        [
          'application/nlm+xml',
          'application/vnd.nlm+xml'
        ]
      end

      def initialize(document)
        @document = document.is_a?(Nokogiri::XML::Node) ? document : Nokogiri::XML.parse(document)
      end

      def parse
        @paper    = Models::CitingPaper.new

        parse_paper
        parse_references
        parse_citation_groups

        paper
      end

      private

      def parse_paper
        #@todo
      end

      def parse_references
        reference_nodes.each do |number, node|
          id = node[:id]
          original_citation = clean_citation(node).to_s.strip
          paper.references.add(id: id, number:number, original_citation:original_citation)
        end
      end

      def parse_citation_groups
        #@todo
      end

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
        doc.scrub!( JATSScrubber.new )
      end

      class JATSScrubber < Loofah::Scrubbers::Strip

        def scrub(node)
          return if node.text?

          node.name = node.name.downcase

          if node.name == 'ext-link' && node['ext-link-type'] == 'uri'
            url = node['xlink:href'] # ].xpath('@xlink:href', {'xlink' => 'http://www.w3.org/1999/xlink'})
            node.attribute_nodes.each(&:remove)
            node.name = 'a'
            node['href'] = url
          end

          case node.name

            # Convert some JATS nodes to classes

            when 'mixed-citation', 'element-citation'
              node.name = 'span'
              publication_type = node['publication-type']
              node.attribute_nodes.each(&:remove)
              node['class'] = 'citation'
              node['data-publicationtype'] = publication_type

            when 'name'
              node.name = 'span'
              node.attribute_nodes.each(&:remove)
              node['class'] = 'author'

            when 'surname', 'given-names', 'article-title', 'person-group',
                 'source', 'volume', 'fpage', 'lpage', 'comment',
                 'year', 'month', 'day'
              node.attribute_nodes.each(&:remove)
              node['class'] = node.name
              node.name = 'span'

            # Convert some HTML tags

            when 'italic', 'i', 'em'
              node.attribute_nodes.each(&:remove)
              node.name = 'em'

            when 'bold', 'b', 'strong'
              node.attribute_nodes.each(&:remove)
              node.name = 'strong'

            # Keep some as is

            when  'a', 'u', 'cite', 'q', 'mark', 'abbr', 'sub', 'sup', 's', 'wbr'
              # nothing but the scrubber does some cleaning

            else
              # Otherwise delete this node
              node.before(node.children)
              node.remove
              return

          end

          super

        end

      end

    end
  end
end