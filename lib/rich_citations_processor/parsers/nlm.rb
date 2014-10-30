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

      def parse!
        @paper    = Models::CitingPaper.new

        parse_document_identifier
        parse_metadata
        parse_authors
        parse_references
        parse_citation_groups

        paper
      end

      private

      def parse_document_identifier
        identifier_nodes = document.css('front article-id')

        paper.uri = identifier_nodes.lazy.map do |node|
          type  = node['pub-id-type']
          ident = node.text.strip
          URI.create(ident, type:type, source:'document')
        end.find(&:present?)

      end

      def parse_metadata
        # paper.bibliographic[:title] = document.at_css('article-meta article-title').try(:content).try(:strip)

        paper.word_count = word_count
      end

      def parse_authors
        paper.authors << AuthorParser.new(document:document).parse!
      end

      def parse_references
        paper.references << ReferenceParser.new(document:document).parse!
      end

      def parse_citation_groups
        paper.citation_groups << CitationGroupParser.new(document:document, references:paper.references).parse!
      end

      def word_count
        XMLUtilities.text(body).word_count
      end

      def body
        @body ||= document.at_css('body')
      end

    end
  end
end