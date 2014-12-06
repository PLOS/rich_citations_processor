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

require 'spec_helper'
require_relative 'shared'

module RichCitationsProcessor
  module URIResolvers

    RSpec.describe CrossRef do

      subject do described_class.new( references:references, paper:paper) end

      let(:paper) do
        p = Models::CitingPaper.new
        p.uri = URI::DOI.new('10.1371/journal.pone.0046843')
        p.references.add(id:'red1', original_citation:'cite 1')
        p.references.add(id:'ref2', original_citation:'cite 2')
        p
      end
      let(:references) { paper.references }

      def expect_request(body = {'query_ok' => false})
        stub_request(:post, 'http://search.crossref.org/links').to_return(body: body.to_json)
      end

      it_should_behave_like 'a resolver'

      it "should call the crossref API" do
        expect_request.with(body: '["cite 1","cite 2"]').times(1)
        subject.resolve!
      end

      it "should fill in the results" do
        expect_request('query_ok' => true,
                       'results' => [
                           { 'match' => true, 'doi' => '10.1111/2222', 'score' => 5.6733 },
                           { 'match' => true, 'doi' => '10.1111/3333', 'score' => 3.1234 }
                       ])

        subject.resolve!

        expect( references.first.candidate_uris).to eq(['http://dx.doi.org/10.1111/2222'])
        expect( references.second.candidate_uris).to eq(['http://dx.doi.org/10.1111/3333'])
      end

      it "should set the source correctly" do
        expect_request('query_ok' => true,
                       'results' => [
                           { 'match' => true, 'doi' => '10.1111/2222', 'score' => 5.6733 },
                           { 'match' => true, 'doi' => '10.1111/3333', 'score' => 3.1234 }
                       ])

        subject.resolve!

        expect( references.first.candidate_uris.first.source).to eq('crossref')
      end

      it "should set the extended data" do
        expect_request('query_ok' => true,
                       'results' => [
                           { 'match' => true, 'doi' => '10.1111/2222', 'score' => 5.6733 },
                           { 'match' => true, 'doi' => '10.1111/3333', 'score' => 3.1234 }
                       ])

        subject.resolve!

        expect( references.first.candidate_uris.first.metadata).to eq(score:5.6733)
      end

      it "should do nothing if query_ok is false" do
        expect_request('query_ok' => false,
                       'results' => [
                           { 'match' => true, 'doi' => '10.1111/2222', 'score' => 5.6733 },
                           { 'match' => true, 'doi' => '10.1111/3333', 'score' => 3.1234 }
                       ])

        subject.resolve!

        expect( references.first.candidate_uris).to eq([])
      end

      it "should do nothing if match is false" do
        expect_request('query_ok' => false,
                       'results' => [
                           { 'match' => false, 'doi' => '10.1111/2222', 'score' => 5.6733 },
                           { 'match' => true,  'doi' => '10.1111/3333', 'score' => 3.1234 }
                       ])

        subject.resolve!

        expect( references.first.candidate_uris).to eq([])
      end

      it "should do nothing if the score is less than 2.5" do
        expect_request('query_ok' => false,
                       'results' => [
                           { 'match' => true,  'doi' => '10.1111/2222', 'score' => 2.4999 },
                           { 'match' => true,  'doi' => '10.1111/3333', 'score' => 3.1234 }
                       ])

        subject.resolve!

        expect( references.first.candidate_uris).to eq([])
      end

      it "should call the crossref API in blocks of 50" do
        (3..52).each { |i| paper.references.add(id:"ref{i}", original_citation:"cite #{i}")}

        first_body ='[' + ( 1..50).map { |i| "\"cite #{i}\""}.join(',') + ']'
        expect_request.with(body: first_body).times(1)
        second_body='[' + (51..52).map { |i| "\"cite #{i}\""}.join(',') + ']'
        expect_request.with(body:second_body).times(1)

        subject.resolve!
      end

      it "should not attempt to fetch references that have already been fetched" do
        references.first.candidate_uris.add( URI::DOI.new('10.1234/5678'), source:'test')

        expect_request.with(body: '["cite 2"]')

        subject.resolve!
      end


      describe "handling references with jats tagged html" do

        let(:reference) { references.first }

        before do
          references.delete_at(1)
        end

        it "should reformat html to text" do
          html = <<-HTML.strip_heredoc
            <span class='citation'>
              <span class='source'>SOURCE</span> stuff
              <span class='issue'>ISSUE</span> stuff
              <span class='lpage'>99</span> stuff
              <span class='fpage'>42</span> stuff
              <span class='article-title'>TITLE</span> stuff
              <span class='elocation-id'>EID</span> stuff
              <span class='year'>YEAR</span> stuff
              <span class='volume'>VOLUME</span> stuff
              <span class='collaborator'>COLLAB</span> stuff
              <span class='author'> stuff
                <span class='surname'>
                   FORD
                </span> stuff
                <span class='given-names'>
                   H
                </span> stuff
              </span> stuff
              <span class='author'> stuff
                <span class='surname'>
                   SMITH
                </span> stuff
              </span> stuff
            </span>
          HTML
          reference.original_citation = html

          expect_request.with(body: '["H. FORD, SMITH, COLLAB, TITLE, SOURCE, vol. VOLUME, no. ISSUE, pp. 42-99, eEID, YEAR"]')
          subject.resolve!
        end

        it "should ignore missing values" do
          html = <<-HTML.strip_heredoc
            <span>
              <span class='article-title'>TITLE</span> stuff
            </span>
          HTML
          reference.original_citation = html

          expect_request.with(body: '["TITLE"]')
          subject.resolve!
        end

        it "should show a page ranget" do
          html = <<-HTML.strip_heredoc
            <span class='citation'>
              <span class='lpage'>99</span> stuff
              <span class='fpage'>42</span> stuff
            </span>
          HTML
          reference.original_citation = html

          expect_request.with(body: '["pp. 42-99"]')
          subject.resolve!
        end

        it "should show a single page" do
          html = <<-HTML.strip_heredoc
            <span class='citation'>
              <span class='fpage'>42</span> stuff
            </span>
          HTML
          reference.original_citation = html

          expect_request.with(body: '["pp. 42"]')
          subject.resolve!
        end

        it "should include an author with an initalized first name" do
          html = <<-HTML.strip_heredoc
            <span>
              <span class='author'> stuff
                <span class='surname'>
                   FORD
                </span> stuff
                <span class='given-names'>
                   HJ
                </span> stuff
              </span> stuff
            </span>
          HTML
          reference.original_citation = html

          expect_request.with(body: '["H. J. FORD"]')
          subject.resolve!
        end

        it "should include an author with a full first name" do
          html = <<-HTML.strip_heredoc
            <span>
              <span class='author'> stuff
                <span class='surname'>
                   FORD
                </span> stuff
                <span class='given-names'>
                   Harrison
                </span> stuff
              </span> stuff
            </span>
          HTML
          reference.original_citation = html

          expect_request.with(body: '["Harrison FORD"]')
          subject.resolve!
        end

        it "should include an author with a no first name" do
          html = <<-HTML.strip_heredoc
            <span>
              <span class='author'> stuff
                <span class='surname'>
                   FORD
                </span> stuff
              </span> stuff
            </span>
          HTML
          reference.original_citation = html

          expect_request.with(body: '["FORD"]')
          subject.resolve!
        end

      end

    end

  end
end