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

    class CitationGroup
      attr_accessor :id
      attr_accessor :section
      attr_accessor :word_position

      attr_accessor :truncated_before
      attr_accessor :text_before
      attr_accessor :text
      attr_accessor :text_after
      attr_accessor :truncated_after

      attr_reader :references

      def initialize(id:nil)
        @references = Collection.new(Reference)

        @id = id
      end

      def indented_inspect(indent='')
        refs = references.map { |ref| ref.id.inspect }
        refs = 'References:[' + refs.join(', ') + ']'
        "Citation Group: #{id.inspect} #{refs}"
      end
      alias :inspect :indented_inspect

    end
  end
end