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

  RSpec.describe URI::ISBN do

    describe '::matches?' do

      it "should match with symbols" do
        expect( URI::ISBN.matches?('absolutely anything', type: :isbn) ).to be_truthy
      end

    end

    describe '::from_uri' do

      it "should parse an ISBN from a URL" do
        uri = URI::ISBN.from_uri('http://isbn.openlibrary.org/10-123-4567-X', source:'foo')
        expect(uri.raw_isbn).to eq('10-123-4567-X')
      end

      it "should return nil when an ISBN could not be parsed" do
        expect( URI::ISBN.from_uri('http://isbn.openlibrary.org/10-123456') ).to be_nil
        expect( URI::ISBN.from_uri('http://isbn.foo.org/10.123-4567-X') ).to be_nil
        expect( URI::ISBN.from_uri('10-123-4567-X') ).to be_nil
        expect( URI::ISBN.from_uri('some text') ).to be_nil
      end

    end

    describe '::from_text' do

      it "should parse a ISBN from text" do
        uris = URI::ISBN.from_text('http://isbn.openlibrary.org/978-10-123-4567-X', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/978101234567X'] )
      end

      it "should parse multiple ISBNs from text" do
        uris = URI::ISBN.from_text('http://isbn.openlibrary.org/10-123-444-44 http://isbn.openlibrary.org/10-123-555-55', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012344443', 'http://isbn.openlibrary.org/9781012355555'] )
      end

      it "should parse a ISBN 10 in URI format" do
        uris = URI::ISBN.from_text('somethinghttp://isbn.openlibrary.org/10-123-4567-9', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
      end

      it "should parse a ISBN 13 in URI format" do
        uris = URI::ISBN.from_text('somethinghttp://isbn.openlibrary.org/978-10-123-4567-9', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
      end

      it "should parse a ISBN 10 in prefix format" do
        uris = URI::ISBN.from_text('isbn: 10-123-4567-9', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
        uris = URI::ISBN.from_text('isbn:10-123-4567-9', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
      end

      it "should parse a ISBN 13 in prefix format" do
        uris = URI::ISBN.from_text('isbn: 978-10-123-4567-9', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
        uris = URI::ISBN.from_text('isbn:978-10-123-4567-9', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
      end

      it "should parse a ISBN in prefix format at the start of a string" do
        uris = URI::ISBN.from_text('isbn:10-123-4567-9', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
      end
      
      it "should parse a ISBN in prefix format after white-space" do
        uris = URI::ISBN.from_text(' isbn:10-123-4567-9', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
      end
      
      it "should parse a ISBN in prefix format after punctuation" do
        uris = URI::ISBN.from_text('.isbn:10-123-4567-9', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
      end
      
      it "should parse a ISBN in prefix format at the end of a string" do
        uris = URI::ISBN.from_text('isbn:10-123-4567-9', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
      end
      
      it "should parse a ISBN in prefix format ended by white-space" do
        uris = URI::ISBN.from_text('isbn:10-123-4567-9 ', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
      end
      
      it "should parse a ISBN in prefix format ended by punctuation" do
        uris = URI::ISBN.from_text('isbn:10-123-4567-9? But then there were', source:'foo')
        expect(uris).to eq( ['http://isbn.openlibrary.org/9781012345679'] )
      end
      
      it "should return nil when a ISBN could not be parsed" do
        expect( URI::ISBN.from_text('some text without an ISBN', source:'foo') ).to be_nil
      end

    end

    describe '#full_uri' do

      it "should return the full uri as an ISBN 13 without dashes" do
        uri = URI::ISBN.new('123-456-789-X', source:'test')
        expect( uri.full_uri ).to eq('http://isbn.openlibrary.org/9781234567897')
      end

    end

    describe 'isbn' do

      it "should return the gathered (raw) isbn" do
        uri = URI::ISBN.new('12-345-6789-0', source:'test')
        expect( uri.raw_isbn ).to eq('12-345-6789-0')
      end

      it "should cleanup an existing isbn_13" do
        uri = URI::ISBN.new('111-3-16-148410-7', source:'test')
        expect( uri.isbn_13 ).to eq('1113161484107')
      end

      it "should calculate the isbn 13" do
        uri = URI::ISBN.new('3-16-148410-X', source:'test')
        expect( uri.isbn_13 ).to eq('9783161484100')

        uri = URI::ISBN.new('0-306-40615-X', source:'test')
        expect( uri.isbn_13 ).to eq('9780306406157')
      end

      it "should not change ISBNs that are already 13" do
        uri = URI::ISBN.new('111-3-16-148410-1', source:'test')
        expect( uri.isbn_13 ).to eq('1113161484101')
      end

      it "should cleanup an existing isbn_10" do
        uri = URI::ISBN.new('3-16-148410-7', source:'test')
        expect( uri.isbn_10 ).to eq('3161484107')
      end

      it "should calculate the isbn 10" do
        uri = URI::ISBN.new('978-030640615-9', source:'test')
        expect( uri.isbn_10 ).to eq('0306406152')
      end

      it "should just return ISBNs that don't have the standard 978 prefix" do
        uri = URI::ISBN.new('123-030640615-9', source:'test')
        expect( uri.isbn_10 ).to eq('1230306406159')
      end

    end

    describe "comparison" do

      it "should compare isbn_10's" do
        a = URI::ISBN.new('12-345-6787-0', source:'test')
        b = URI::ISBN.new('12-345-6789-0', source:'test')
        c = URI::ISBN.new('12-345-6789-0', source:'test')

        expect(a).not_to eq(c)
        expect(b).to     eq(c)
      end

      it "should compare isbn_13's" do
        a = URI::ISBN.new('111-12-345-6787-0', source:'test')
        b = URI::ISBN.new('111-12-345-6789-0', source:'test')
        c = URI::ISBN.new('111-12-345-6789-0', source:'test')

        expect(a).not_to eq(c)
        expect(b).to     eq(c)
      end

      it "should compare an isbn_13 with an isbn_10" do
        a = URI::ISBN.new('978-12-345-6789-7', source:'test')
        b = URI::ISBN.new('12-345-6789-0', source:'test')

        expect(a).to eq(b)
        expect(b).to eq(a)

        a = URI::ISBN.new('978-12-345-6789-0', source:'test')
        b = URI::ISBN.new('12-345-6789-X', source:'test')

        expect(a).to eq(b)
        expect(b).to eq(a)
      end

    end

  end

end