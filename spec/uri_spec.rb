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

  RSpec.describe URI do

    describe '::create' do

      it "should create an appropriate instance" do
        instance = URI.create('10.123/456', type:'doi' )
        expect( instance ).to be_a(URI::DOI)
        expect( instance ).to have_attributes(full_uri:'http://dx.doi.org/10.123/456')
      end

      it "should return nil if it cannot create an appropriate instance" do
        instance = URI.create('10.123/456', type:'unknown_type' )
        expect( instance ).to be_nil
      end

    end

    describe '::Lookup' do

      it 'can lookup the id class for a type' do
        expect(URI.lookup(:doi)).to eq( URI::DOI)
        expect(URI.lookup!(:doi)).to eq( URI::DOI)
      end

      it 'can lookup the id with a string' do
        expect(URI.lookup('doi')).to eq( URI::DOI)
      end

      it 'returns nil if the id type is not found' do
        expect( URI.lookup('anything') ).to be_nil
      end

      it 'raises an exception if the id type is not found' do
        expect{ URI.lookup!('anything') }.to raise_exception
      end

    end

    describe "::from_uri" do

      it "should parse a possible URI" do
        expect(URI::DOI ).to receive(:from_uri).and_return(nil)
        expect(URI::ISBN).to receive(:from_uri).and_return(:isbn)

        expect(URI.from_uri('uri')).to eq(:isbn)
      end

      it "should stop parsing once a URI is found" do
        expect(URI::DOI ).to receive(:from_uri).and_return(:doi)
        expect(URI::ISBN).not_to receive(:from_uri)

        expect(URI.from_uri('uri')).to eq(:doi)
      end

      it "should return nil if no URI matches" do
        expect(URI::DOI ).to receive(:from_uri).and_return(nil)
        expect(URI::ISBN).to receive(:from_uri).and_return(nil)

        expect(URI.from_uri('uri')).to be_nil
      end

    end

    describe "::from_text" do

      it "should return an array of concatenated URIs" do
        expect(URI::DOI ).to receive(:from_text).and_return( ['doi1', 'doi2'] )
        expect(URI::ISBN).to receive(:from_text).and_return( ['isbn1', 'isbn2'] )

        expect(URI.from_text('some text')).to eq( ['doi1', 'doi2', 'isbn1', 'isbn2'] )
      end

      it "should always call al URI parsers" do
        expect(URI::DOI ).to receive(:from_text)
        expect(URI::ISBN).to receive(:from_text)

        URI.from_text('some text')
      end

      it "should remove nil elements" do
        expect(URI::DOI ).to receive(:from_text).and_return( nil )
        expect(URI::ISBN).to receive(:from_text).and_return( ['isbn1', 'isbn2'] )

        expect(URI.from_text('some text')).to eq( [ 'isbn1', 'isbn2'] )
      end

      it "should return an empty array if nothing is returned" do
        expect(URI::DOI ).to receive(:from_text).and_return( nil )
        expect(URI::ISBN).to receive(:from_text).and_return( nil )

        expect(URI.from_text('some text')).to eq( [] )
      end

    end

  end

end
