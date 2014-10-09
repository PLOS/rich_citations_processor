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

describe RichCitationsProcessor::Models::CitingPaper do

  describe "::new" do

    it "should create a CitingPaper" do
      expect(described_class.new).not_to be_nil
    end

    it "should accept uri and uri_source parameters" do
      instance = described_class.new(uri:'http://example.com/a', uri_source:'test')
      expect(instance).to have_attributes(uri:'http://example.com/a', uri_source:'test')
    end

  end

  describe '#inspect' do

    it "should return a valid inspection" do
      instance = described_class.new(uri:'http://example.com/a', uri_source:'test')
      expect(instance.inspect).to eq("Paper: [test] http://example.com/a\n  References[0]\n  Citation Groups[0]")
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should accept uri and uri_source parameters" do
      instance = described_class.new
      expect(instance.inspect).to eq("Unresolved Paper\n  References[0]\n  Citation Groups[0]")
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should include references and citation groups" do
      instance = described_class.new(uri:'http://example.com/a', uri_source:'test')
      instance.references.add(number:1, id:'ref-1')
      instance.citation_groups.add(id:'group-1')

      expect(instance.inspect).to eq("Paper: [test] http://example.com/a\n" +
                                     "  References[1]:\n    Reference: \"ref-1\" [1] Citation Groups:[] => Unresolved Paper\n" +
                                     "  Citation Groups[1]:\n    Citation Group: \"group-1\" References:[]")
      expect(instance.inspect).to eq(instance.indented_inspect)

    end

  end

end
