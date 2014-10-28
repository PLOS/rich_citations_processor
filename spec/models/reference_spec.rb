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

describe RichCitationsProcessor::Models::Reference do

  describe "::new" do

    it "should create a Reference" do
      expect(described_class.new).not_to be_nil
    end

    it "should create a Reference with values" do
      instance = described_class.new(number:2, id:'ref-id-2', original_citation:'Citation')
      expect(instance).to have_attributes(number:2, id:'ref-id-2', original_citation:'Citation')
    end

  end

  describe "#inspect" do

    it "should return an inspection string" do
      instance = described_class.new(number:2, id:'ref-id-2', original_citation:'Citation')
      instance.citation_groups.add(id:'g3')
      instance.citation_groups.add(id:'g1')

      expect(instance.inspect).to eq('Reference: "ref-id-2" [2] Citation Groups:["g3", "g1"] => Unresolved Paper')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should return an inspection string with a cited paper" do
      instance = described_class.new(number:2, id:'ref-id-2', original_citation:'Citation')
      instance.cited_paper.uri = TestURI.new('10.1234/4567', source:'crossref')

      expect(instance.inspect).to eq('Reference: "ref-id-2" [2] Citation Groups:[] => Paper: [crossref] http://dx.doi.org/10.1234/4567')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

  end

end
