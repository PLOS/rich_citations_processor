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
      class CitationGroupParser < CitationGrouper

        attr_reader :document

        def initialize(document:, paper:)
          @document = document
          super(paper)
        end

        def parse!
          citation_nodes.each do |citation_node|
            number = number_for_citation_node(citation_node)
            add_citation(number, citation_node)
            parse_text_separators(citation_node)
          end

          finished!
        end

        private

        def start_new_group?(citation_node)
          citation_node.previous_sibling != citation_contexts.last
        end

        def end_group!(citation_group)
          first_node = citation_contexts.first
          citation_group.section       = section_title_for_citation_node(first_node)
          citation_group.word_position = word_position_for_citation_node(first_node)
        end

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

        # This doesn't handle markup currently ( [a]<i>,</>[b])
        def parse_text_separators(citation)
          sibling = citation.next_sibling

          while sibling && sibling.text? && is_separator?(sibling) do
            add_citation_context(sibling)
            check_for_hyphen!(sibling.text)
            sibling = sibling.next_sibling
          end
        end

      end
    end
  end
end