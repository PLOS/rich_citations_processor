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
          grouper = CitationGrouper.new(paper)

          citation_nodes.each do |citation|
            number = number_for_citation_node(citation)
            grouper.add_citation(number, citation)
          end
        end

        private

        def citation_nodes
          document.search('body xref[ref-type=bibr]')
        end

        def number_for_citation_node(xref_node)
          refid = xref_node['rid']
          ref   = paper.references.for(id:refid)
          raise ParserError.new("Reference not found for id:#{refid}") unless ref
          ref.number
        end

      end
    end
  end
end