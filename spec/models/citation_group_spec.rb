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

module RichCitationsProcessor::Models

  RSpec.describe CitationGroup do

    describe "::new" do

      it "should create a CitationGroup" do
        expect(described_class.new).not_to be_nil
      end

      it "should create a Reference with values" do
        instance = described_class.new(id:"2")
        expect(instance).to have_attributes(id:"2")
      end

    end

    describe "#inspect" do

      it "should return an inspection string" do
        instance = described_class.new(id:"2")
        instance.references.add(id:'r3')
        instance.references.add(id:'r1')

        expect(instance.inspect).to eq('Citation Group: "2" References:["r3", "r1"]')
        expect(instance.inspect).to eq(instance.indented_inspect)
      end

    end

  end

end
