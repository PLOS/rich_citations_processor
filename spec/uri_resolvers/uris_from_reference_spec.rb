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

    RSpec.describe UrisFromReference do

      subject do described_class.new( references:references, paper:paper) end

      let(:paper) do
        p = Models::CitingPaper.new
        p.references.add(id:   'pone.0032408-Fisher1')
        p
      end
      let(:references) do paper.references end
      let(:ref ) do references.first end

      it_should_behave_like 'a resolver'

      it "should extract a reference from href attributes" do
        ref.text = '<span><a href="http://dx.doi.org/10.1/23">text</a></span>'

        subject.resolve!

        expect( ref.candidate_uris).to eq(['http://dx.doi.org/10.1/23'])
        expect(ref.candidate_uris.first.source).to eq('reference')
      end

      it "should extract a reference from the text" do
        ref.text = 'some text containing a doi 10.1/23 ...">text</a></span>'

        subject.resolve!

        expect( ref.candidate_uris).to eq(['http://dx.doi.org/10.1/23'])
        expect(ref.candidate_uris.first.source).to eq('reference')
      end

      it "should extract multiple references with href's first" do
        ref.text = '<span> some text 10.1/11 <a href="http://dx.doi.org/10.1/22">http://dx.doi.org/10.1/33</a> http://dx.doi.org/10.1/44 </span>'

        subject.resolve!

        expect( ref.candidate_uris).to eq([
                                              'http://dx.doi.org/10.1/22',
                                              'http://dx.doi.org/10.1/11',
                                              'http://dx.doi.org/10.1/33',
                                              'http://dx.doi.org/10.1/44',
                                          ])
      end

      it "should extract references of different types from hrefs" do
        ref.text = '<span> <a href="http://dx.doi.org/10.1/22">22</a> <a href="http://isbn.openlibrary.org/1234567890123">22</a> </span>'

        subject.resolve!

        expect( ref.candidate_uris).to eq([
                                              'http://dx.doi.org/10.1/22',
                                              'http://isbn.openlibrary.org/1234567890123',
                                          ])
      end

      it "should extract references of different types from text" do
        ref.text = '.. http://dx.doi.org/10.1/22  isbn:1234567890123...'

        subject.resolve!

        expect( ref.candidate_uris).to eq([
                                              'http://dx.doi.org/10.1/22',
                                              'http://isbn.openlibrary.org/1234567890123',
                                          ])
      end

      it "should extract mixed references of different types from text and href" do
        ref.text = '<span>.. <a href="http://dx.doi.org/10.1/22">  isbn:1234567890123 </a>...</span>'

        subject.resolve!

        expect( ref.candidate_uris).to eq([
                                              'http://dx.doi.org/10.1/22',
                                              'http://isbn.openlibrary.org/1234567890123',
                                          ])
      end

      it "should only add a reference a single time" do
        ref.text = '<span> some text 10.1/11 <a href="http://dx.doi.org/10.1/11">http://dx.doi.org/10.1/11</a> http://dx.doi.org/10.1/11 </span>'

        subject.resolve!

        expect( ref.candidate_uris).to eq([
                                              'http://dx.doi.org/10.1/11',
                                          ])
      end

      it "should not add URIs if none are found" do
        ref.text = '<span><a href="not_a_url">text</a></span>'

        subject.resolve!

        expect( ref.candidate_uris).to be_empty
      end

    end

  end
end