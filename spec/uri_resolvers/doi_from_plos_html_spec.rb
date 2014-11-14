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

module RichCitationsProcessor
  module URIResolvers

    RSpec.describe DoiFromPlosHtml do

      subject do described_class.new( references:references, paper:paper) end

      let(:paper) do
        p = Models::CitingPaper.new
        p.uri = URI::DOI.new('10.1371/journal.pone.0046843', source:'test')
        p.references.add(id:'pone.0032408-Fisher1')
        p.references.add(id:'pone.0032408-Hartter1')
        p
      end
      let(:references) do paper.references end

      def expect_request
        stub_request(:get, 'http://dx.doi.org/10.1371/journal.pone.0046843').
            to_return(body: get_fixture('journal.pone.0032408.html'))
      end

      it "should fetch the references" do
        expect_request

        subject.resolve!

        expect( references.first.candidate_uris).to eq(['http://dx.doi.org/10.1016/j.ecolecon.2006.05.020'])
        expect( references.second.candidate_uris).to eq(['http://dx.doi.org/10.1017/s0030605310000141'])
      end

      it "should set the source correctly" do
        expect_request

        subject.resolve!

        expect( references.first.candidate_uris.first.source).to eq('plos_html')
      end

      it "should not add references that aren't found" do
        expect_request
        paper.references.first.id = 'pone.4032408-UNKOWN'

        subject.resolve!

        expect( references.first.candidate_uris).to eq([])
      end

      it "should not fetch references that exist but don't have a link" do
        expect_request
        paper.references.first.id = 'pone.0032408-Terborgh1'

        subject.resolve!

        expect( references.first.candidate_uris).to eq([])
      end

      it "should not add references that don't have a DOI" do
        expect_request
        paper.references.first.id = 'pone.0032408-Rudnick1'

        subject.resolve!

        expect( references.first.candidate_uris).to eq([])
      end

      it "should only fetch the HTML page once" do
        expect_request.times(1)

        subject.resolve!
      end

      it "should not do anything for non PLOS DOIs" do
        paper.uri = URI::DOI.new('10.9999/journal.pone.0046843', source:'test')

        subject.resolve!

        expect( references.first.candidate_uris).to eq([])
        expect( references.second.candidate_uris).to eq([])
      end

    end

  end
end