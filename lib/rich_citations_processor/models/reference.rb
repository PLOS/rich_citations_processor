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
  module Models

    class Reference < Base
      attr_accessor :id
      attr_accessor :number
      attr_accessor :original_citation
      attr_accessor :accessed_at

      attr_reader :cited_paper
      attr_reader :citation_groups

      delegate :uri,
               :uri_source,
               :bibliographic,
           to: :cited_paper

      def initialize(**attributes)
        @cited_paper     = CitedPaper.new
        @citation_groups = Collection.new(CitationGroup)

        super
      end

      def indented_inspect(indent='')
        groups = citation_groups.map { |group| group.id.inspect }
        groups = 'Citation Groups:[' + groups.join(', ') + ']'
        "Reference: #{id.inspect} [#{number}] #{groups} => #{cited_paper.inspect}"
      end
      alias :inspect :indented_inspect

    end
  end
end