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

    RSpec.describe DoiFromReference do

      subject do described_class.new( references:references, paper:paper) end

      let(:paper) do
        p = Models::CitingPaper.new
        p.references.add(id:   'pone.0032408-Fisher1')
        p
      end
      let(:references) do paper.references end
      let(:ref ) do references.first end

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

      it "should not add URIs if none are found" do
        ref.text = '<span><a href="not_a_url">text</a></span>'

        subject.resolve!

        expect( ref.candidate_uris).to be_empty
      end

    end

  end
end