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

    describe '#create' do

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

    describe '#Lookup' do

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

  end

end
