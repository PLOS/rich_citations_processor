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

module RichCitationsProcessor::URI

  RSpec.describe Registry do

    class Class1; def self.priority; 1; end; def self.foo; end end
    class Class5; def self.priority; 2; end; def self.bar; end end
    class Class9; def self.priority; 3; end; def self.foo; end end

    class Class2; def self.priority; 3; end; def foo; end; end
    class Class3; def self.priority; 3; end; def bar; end; end

    describe '#Lookup' do

      it 'can lookup the id class for a type' do
        expect(Registry.lookup(:doi)).to eq( DOI)
        expect(Registry.lookup!(:doi)).to eq( DOI)
      end

      it 'can lookup the id with a string' do
        expect(Registry.lookup('doi')).to eq( DOI)
      end

      it 'returns nil if the id type is not found' do
        expect( Registry.lookup('anything') ).to be_nil
      end

      it 'raises an exception if the id type is not found' do
        expect{ Registry.lookup!('anything') }.to raise_exception
      end

    end

    describe "#classes" do

      before do
        Registry.reset!
      end
      after do
        Registry.reset!
      end

      it "should return a list of URI classes" do
        expect( Registry.classes ).to eq([
                                              DOI,
                                              ISBN,
                                              Test,
                                              TestURI,
                                         ] )
      end

      it "should sort URIs by priority" do
        allow(Registry).to receive(:load_classes).and_return( [Class1, Class5, Class9] )
        expect(Registry.classes).to eq([Class1, Class5, Class9])

        allow(Registry).to receive(:load_classes).and_return( [Class9, Class5, Class1] )
        expect(Registry.classes).to eq([Class1, Class5, Class9])
      end

      it "should sort URIs by name" do
        allow(Registry).to receive(:load_classes).and_return( [Class1, Class2, Class3] )
        expect(Registry.classes).to eq([Class1, Class2, Class3])

        allow(Registry).to receive(:load_classes).and_return( [Class3, Class2, Class1] )
        expect(Registry.classes).to eq([Class1, Class2, Class3])
      end

      it "should sort by priority before name" do
        allow(Registry).to receive(:load_classes).and_return( [Class9, Class5, Class3, Class2, Class1] )
        expect(Registry.classes).to eq([Class1, Class5, Class2, Class3, Class9])
      end

    end

    describe "#classes_that_respond_to" do

      before do
        Registry.reset!
      end
      after do
        Registry.reset!
      end

      it "should sort URIs by priority" do
        allow(Registry).to receive(:load_classes).and_return( [Class1, Class5, Class9, Class2, Class3] )
        expect(Registry.classes_that_respond_to(:foo)).to eq([Class1, Class9])
      end

    end

  end

end