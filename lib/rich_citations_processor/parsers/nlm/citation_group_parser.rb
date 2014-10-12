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

module RichCitationsProcessor
  module Parsers
    class NLM
      class CitationGroupParser

        attr_reader :paper
        attr_reader :document

        def initialize(document:, paper:)
          @document = document
          @paper    = paper
        end

        def parse!
          grouper = CitationGrouper.new(self)

          citation_nodes.each do |citation|
            number = number_for_citation_node(citation)
            grouper.add_citation(number, citation)
          end
        end

        # callbacks from citation grouper

        def reference_for_number(number)
          paper.references.for(number:number)
        end

        def new_citation_group(id:, context:)
          group = paper.citation_groups.add(id:id)

          group.section       = section_title_for_citation_node(context)
          group.word_position = word_position_for_citation_node(context)

          group
        end

        private

        def body
          @body ||= document.at_css('body')
        end

        def citation_nodes
          body.css('xref[ref-type=bibr]')
        end

        def number_for_citation_node(xref_node)
          refid = xref_node['rid']
          ref   = paper.references.for(id:refid)
          raise ParserError.new("Reference not found for id:#{refid}") unless ref
          ref.number
        end

        # Get the outermost section title
        def section_title_for_citation_node(node)
          title = nil

          while node && defined?(node.parent) && (node != body)
            if node.name == 'sec'
              title_node = node.css('> title')
              title = title_node.text if title_node.present? && title_node.text
            end

            node = node.parent
          end

          title
        end

        def word_position_for_citation_node(node)
          XMLUtilities.text_before(body, node).word_count + 1
        end

      end
    end
  end
end