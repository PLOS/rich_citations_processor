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

# class to help in grouping citations

module RichCitationsProcessor
  module Parsers
    class NLM

      class CitationGrouper

        HYPHEN_SEPARATORS = ["-", "\u2013", "\u2014"]
        ALL_SEPARATORS    = [',', ''] + HYPHEN_SEPARATORS

        attr_reader :paper

        def initialize(paper)
          @group_id  = 0
          @paper     = paper
          @last_node = :none
        end

        def add_citation(number, citation)
          start_group!(citation) if citation.previous_sibling != @last_node

          @last_node = citation

          if @hyphen_found
            add_range(number)
          else
            add_number(number)
            @last_number = number
          end

          parse_text_separators(citation)
        end

        private

        def add_range(range_end)
          range_start  = @last_number + 1
          @last_number = nil
          (range_start..range_end).each { |number| add_number(number) }
        end

        def add_number(number)
          reference = paper.references.for(number:number)
          raise ParseError.new("Refererence not found for number:#{number}") unless reference

          @current_group.references.add(reference)
          reference.citation_groups.add(@current_group)
        end

        def add_node(node)
          # @current_group[:nodes].push node
        end

        def start_group!(node)
          @current_group =  paper.citation_groups.add( id: next_group_id )
          @last_node     =  :none
        end

        def next_group_id
          @group_id += 1
          @group_id.to_s
        end

        def parse_text_separators(citation)
          @hyphen_found = false
          sibling = citation.next_sibling

          while is_separator?(sibling) do
            @last_node = sibling
            @hyphen_found ||= HYPHEN_SEPARATORS.include?(sibling.text.strip)
            sibling = sibling.next_sibling
          end
        end

        def is_separator?(node)
          return false unless node && node.text?
          return ALL_SEPARATORS.include?(node.text.strip)
        end

      end
    end
  end
end

