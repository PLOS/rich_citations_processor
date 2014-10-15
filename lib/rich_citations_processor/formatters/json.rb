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

#@note: This is very rough it is intended to be replaced by Erik's formatting classes

require 'multi_json'

module RichCitationsProcessor
  module Formatters

    class JSON
      attr_reader :citing_paper

      def initialize(citing_paper)
        @citing_paper = citing_paper
      end

      def format(options={})
        MultiJson.dump( as_structured_hash, options)
      end

      # turn the paper into a hash/array structure
      def as_structured_hash
        paper(citing_paper)
      end

      protected

      def paper(paper)
        hash = {
          'uri_source'      => paper.uri_source,
          'uri'             => paper.uri,
          'bibliographic'   => bibliographic_metadata(paper),
          'word_count'      => paper.word_count,
          'references'      => references(paper.references),
          'citation_groups' => citation_groups(paper.citation_groups)
        }

        hash.compact
      end

      def bibliographic_metadata(paper)
        metadata = paper.bibliographic.deep_dup

        # Merge in the authors
        metadata['author'] = authors(paper.authors)
        metadata.compact.presence
      end

      def authors(authors)
        authors.map { |a| author(a) }.presence
      end

      def author(author)
        {
            'given'       => author.given,
            'family'      => author.family,
            'literal'     => author.literal,
            'email'       => author.email,
            'affiliation' => author.affiliation
        }.compact!
      end

      def references(references)
        references.map { |r| reference(r) }.presence
      end

      def reference(reference)
        hash = {
            'id'                => reference.id,
            'number'            => reference.number,
            'uri_source'        => reference.uri_source,
            'uri'               => reference.uri,
            'accessed_at'       => reference.uri,
            'original_citation' => reference.original_citation,
            'bibliographic'     => bibliographic_metadata(reference.cited_paper),
            'citation_groups'   => id_list(reference.citation_groups)
        }.compact
      end

      def citation_groups(citation_groups)
        citation_groups.map { |cg| citation_group(cg) }.presence
      end

      def citation_group(citation_group)
        {
            'id'            => citation_group.id,
            'section'       => citation_group.section,
            'word_position' => citation_group.word_position,
            'context'       => citation_group_context(citation_group),
            'references'    => id_list(citation_group.references)
        }.compact
      end

      def citation_group_context(citation_group)
        {
          'truncated_before' => citation_group.truncated_before,
          'text_before'      => citation_group.text_before,
          'citation'         => citation_group.citation,
          'text_after'       => citation_group.text_after,
          'truncated_after'  => citation_group.truncated_after
        }.compact.presence
      end

      def id_list(list)
        list.map { |item| item.id }.presence
      end

    end
  end
end
