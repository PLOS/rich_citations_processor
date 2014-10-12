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

    class CitationGrouper

      HYPHEN_SEPARATORS = ["-", "\u2013", "\u2014"]
      ALL_SEPARATORS    = [',', ''] + HYPHEN_SEPARATORS

      attr_reader :paper
      attr_reader :citation_contexts
      attr_reader :current_group
      attr_reader :hyphen_found

      def initialize(paper)
        @group_id  = 0
        @paper     = paper
      end

      def add_citation(number, citation_context)
        if !current_group || start_new_group?(citation_context)
          end_group!(current_group) if current_group
          start_group!
        end

        add_citation_context( citation_context )

        if hyphen_found
          add_reference_range(number)
        else
          add_reference(number)
          @last_number = number
        end
      end

      def finished!
        end_group!(current_group) if current_group
      end

      def is_separator?(text)
        text  = text.to_s.strip
        ALL_SEPARATORS.include?(text)
      end

      def check_for_hyphen!(text)
        found_hyphen! if is_hyphen?(text)
      end

      def is_hyphen?(text)
        HYPHEN_SEPARATORS.include?(text.strip)
      end

      def found_hyphen!
        @hyphen_found = true
      end

      def add_citation_context(context)
        citation_contexts << context
      end

      protected

      def start_new_group?(citation_context)
        raise NotImplementedError.new("start_new_group? not implemented")
      end

      def start_group!
        @current_group     = paper.citation_groups.add( id: next_group_id )
        @citation_contexts = []
      end

      def end_group!(citation_group)
      end

      private

      def add_reference_range(range_end)
        range_start  = @last_number + 1
        @last_number = nil
        (range_start..range_end).each do |number|
          add_reference(number)
        end
      end

      def add_reference(number)
        @hyphen_found = false
        reference = paper.references.for(number:number)
        raise ParseError.new("Refererence not found for number:#{number}") unless reference

        # Update references -> citation groups and citation groups -> references
        current_group.references.add(reference)
        reference.citation_groups.add(@current_group)
      end

      def next_group_id
        @group_id += 1
        @group_id.to_s
      end

    end
  end
end

