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

module RichCitationsProcessor
  module URIResolvers

    class CrossRef < Grouped

      protected

      def self.priority
        200
      end

      GROUP_SIZE=50

      def resolve_references!(ref_collection)
        texts = ref_collection.map do |ref| search_text_for(ref) end
        response = HTTPUtilities.post(API_URL, texts, :json)
        return unless response['query_ok']

        response['results'].each_with_index do |result, i|
          next unless include_result?(result)
          ref = ref_collection[i]
          uri = uri_for_result(result)
          ref.add_candidate_uri(uri)
        end

      end

      # Cross-ref is slow so only search if we don't already have a DOI
      def filtered_references
        super.select  do |ref|
          ref.candidate_uris.for(class:URI::DOI).nil?
        end
      end

      private

      # cf  http://search.crossref.org/help/api#match
      API_URL = 'http://search.crossref.org/links'

      # Results with a lower score from the crossref.org will be ignored
      MIN_CROSSREF_SCORE = 2.5 #@TODO: Keeping this value high to force skips for testing

      def include_result?(result)
        result && result['match'] && result['score'] && result['score'] >= MIN_CROSSREF_SCORE
      end

      def uri_for_result(result)
        doi = URI::DOI.new(result['doi'])
        URI.add_metadata(doi, source:'crossref', score:result['score'])
      end

      def search_text_for(ref)
        fragment = Nokogiri::HTML::DocumentFragment.parse(ref.original_citation)

        formatted_for_crossref(fragment) || fragment.text
      end

      # https://github.com/PLOS/developer-scripts/blob/master/citedArticle/populateCitationDoiFromCrossRef.py
      def formatted_for_crossref(html_fragment)

        parts = {}

        parts['names'] = formatted_names_for_crossref(html_fragment)

        {'article-title'=>'',
         'source'       =>'',
         'volume'       => 'vol. ',
         'issue'        => 'no. ',
         'fpage'        => 'pp. ',
         'elocation-id' => 'e',
         'year'         => '',
        }.each do |name, prefix|
           node = html_fragment.at_xpath(".//*[@class='#{name}']")
           parts[name] = prefix + node.text.strip if node.present? && node.text.present?
         end

        # special case for the last page
        lpage = html_fragment.at_xpath(".//*[@class='lpage']")
        if parts['fpage'] && lpage.present? && lpage.text.present?
          parts['fpage'] += "-#{lpage.text}"
        end

        parts.values.compact.join(', ').presence
      end

      def formatted_names_for_crossref(html_fragment)

        names = html_fragment.xpath(".//*[@class='author']").map do |node|
          surname = node.xpath("*[@class='surname']").text
          if surname.present?
            given_names = node.xpath("*[@class='given-names']").text
            if given_names.present?
              [given_names.strip.as_given_names, surname.strip].join(' ')
            else
              surname.strip
            end
          end

        end

        collaborators = html_fragment.xpath(".//*[@class='collaborator']").map do |node|
          node.text.strip.presence
        end

        (names + collaborators).compact.join(', ').presence
      end

    end
  end
end
