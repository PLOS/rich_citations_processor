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

  RSpec.describe HTTPUtilities do

    shared_examples "all HTTP methods" do

      describe "requests" do

        it "should request a url" do
          stub_request(http_method, 'http://www.example.com/path')
          action('http://www.example.com/path')
        end

        it "should accept a ::URI instance" do
          stub_request(http_method, 'http://www.example.com/path')
          action( ::URI.parse('http://www.example.com/path') )
        end

        it "should request HTML content" do
          stub_request(http_method, 'http://www.example.com/path').with(headers:{'Accept' => 'text/html'})
          action('http://www.example.com/path', :html)
        end

        it "should request XML content" do
          stub_request(http_method, 'http://www.example.com/path').with(headers:{'Accept' => 'application/xml'})
          action('http://www.example.com/path', :xml)
        end

        it "should request JSON content" do
          stub_request(http_method, 'http://www.example.com/path').with(headers:{'Accept' => 'application/json'})
          action('http://www.example.com/path', :json)
        end

        it "should request a custom content type" do
          stub_request(http_method, 'http://www.example.com/path').with(headers:{'Accept' => 'application/custom'})
          action('http://www.example.com/path', 'application/custom')
        end

      end

      describe "responses" do

        it "should return an XML body if specified by the content type (application/xml)" do
          stub_request(http_method, 'http://www.example.com/path').to_return(body:'<root/>', headers:{'Content_Type'=>'application/xml'}).times(1)
          result = action('http://www.example.com/path', :json)
          expect(result).to be_a_kind_of(Nokogiri::XML::Document)
        end

        it "should return an XML body if specified by the content type (text/xml)" do
          stub_request(http_method, 'http://www.example.com/path').to_return(body:'<root/>', headers:{'Content_Type'=>'text/xml'}).times(1)
          result = action('http://www.example.com/path', :json)
          expect(result).to be_a_kind_of(Nokogiri::XML::Document)
        end

        it "should return an XML body if requested but no content type returned" do
          stub_request(http_method, 'http://www.example.com/path').to_return(body:'<root/>').times(1)
          result = action('http://www.example.com/path', :xml)
          expect(result).to be_a_kind_of(Nokogiri::XML::Document)
        end

        it "should return an HTML body if specified by the content type (text/html)" do
          stub_request(http_method, 'http://www.example.com/path').to_return(body:'<html><head></head><body></body></html>', headers:{'Content_Type'=>'text/html'}).times(1)
          result = action('http://www.example.com/path', :json)
          expect(result).to be_a_kind_of(Nokogiri::HTML::Document)
        end

        it "should return an HTML body if requested but no content type returned" do
          stub_request(http_method, 'http://www.example.com/path').to_return(body:'<html><head></head><body></body></html>').times(1)
          result = action('http://www.example.com/path', :html)
          expect(result).to be_a_kind_of(Nokogiri::HTML::Document)
        end

        it "should return JSON as a hash if specified by the content type" do
          stub_request(http_method, 'http://www.example.com/path').to_return(body:'{"a":1}', headers:{'Content_Type'=>'application/json'}).times(1)
          result = action('http://www.example.com/path', :xml)
          expect(result).to be_a_kind_of(Hash)
        end

        it "should return JSON as a hash if requested but no content type returned" do
          stub_request(http_method, 'http://www.example.com/path').to_return(body:'{"a":1}').times(1)
          result = action('http://www.example.com/path', :json)
          expect(result).to be_a_kind_of(Hash)
        end

        it "should return text if there is no content type or accept" do
          stub_request(http_method, 'http://www.example.com/path').to_return(body:'{"a":1}', headers:{'Content_Type'=>'application/unknown'}).times(1)
          result = action('http://www.example.com/path', 'application/custom')
          expect(result).to eq('{"a":1}')
        end

        it "should raise an exception" do
          stub_request(http_method, 'http://www.example.com/path').to_return(status:404).times(1)
          expect { action('http://www.example.com/path', 'application/custom') }.to raise_exception(Net::HTTPServerException)
        end

      end

      describe "retries" do

        it "should retry 3 times" do
          stub_request(http_method, 'http://www.example.com/path').to_return(status:502).times(3)
          expect(HTTPUtilities).to receive(:sleep).with( 5)
          expect(HTTPUtilities).to receive(:sleep).with(10)
          expect(HTTPUtilities).to receive(:sleep).with(15)
          expect(HTTPUtilities).to_not receive(:sleep)

          expect { action('http://www.example.com/path') }.to raise_exception(Net::HTTPFatalError)
        end

        it "should succeed during a retry" do
          stub_request(http_method, 'http://www.example.com/path').to_return(status:502).then.
                                                                   to_return(body:'Kalamazoo!')
          expect(HTTPUtilities).to receive(:sleep).with( 5)
          expect(HTTPUtilities).to_not receive(:sleep)

          result = action('http://www.example.com/path')
          expect(result).to eq('Kalamazoo!')
        end

      end

      describe "redirects" do

        it "should follow a location header if provided" do
          stub_request(http_method, 'http://url1.example.com/path').to_return(headers:{'Location'=>'http://url2.example.com/path'})
          stub_request(http_method, 'http://url2.example.com/path').to_return(body:'Content')

          result = action('http://url1.example.com/path')
          expect(result).to eq('Content')
        end

        it "should follow relative redirects" do
          stub_request(http_method, 'http://url1.example.com/path/abc' ).to_return(headers:{'Location'=>'def'})
          stub_request(http_method, 'http://url1.example.com/path/def').to_return(body:'Content')

          result = action('http://url1.example.com/path/abc')
          expect(result).to eq('Content')
        end

        it "should follow root relative redirects" do
          stub_request(http_method, 'http://url1.example.com/path/abc').to_return(headers:{'Location'=>'/def'})
          stub_request(http_method, 'http://url1.example.com/def'     ).to_return(body:'Content')

          result = action('http://url1.example.com/path/abc')
          expect(result).to eq('Content')
        end

        it "should redirect up to 3 times" do
          stub_request(http_method, 'http://url1.example.com/path').to_return(headers:{'Location'=>'http://url2.example.com/path'})
          stub_request(http_method, 'http://url2.example.com/path').to_return(headers:{'Location'=>'http://url3.example.com/path'})
          stub_request(http_method, 'http://url3.example.com/path').to_return(headers:{'Location'=>'http://url4.example.com/path'})
          stub_request(http_method, 'http://url4.example.com/path').to_return(body:'Content')

          result = action('http://url1.example.com/path')
          expect(result).to eq('Content')
        end

        it "should fail on over 3 redirects" do
          stub_request(http_method, 'http://url1.example.com/path').to_return(headers:{'Location'=>'http://url2.example.com/path'})
          stub_request(http_method, 'http://url2.example.com/path').to_return(headers:{'Location'=>'http://url3.example.com/path'})
          stub_request(http_method, 'http://url3.example.com/path').to_return(headers:{'Location'=>'http://url4.example.com/path'})
          stub_request(http_method, 'http://url4.example.com/path').to_return(headers:{'Location'=>'http://url5.example.com/path'})

          expect { action('http://url1.example.com/path') }.to raise_exception(Net::HTTPFatalError, "Too many redirects") { |ex| expect(ex.response).to eq(508) }
        end

        it "should fail on recursive redirects" do
          stub_request(http_method, 'http://url1.example.com/path').to_return(headers:{'Location'=>'http://url2.example.com/path'})
          stub_request(http_method, 'http://url2.example.com/path').to_return(headers:{'Location'=>'http://url1.example.com/path'})

          expect { action('http://url1.example.com/path') }.to raise_exception(Net::HTTPFatalError, "Recursive redirect") { |ex| expect(ex.response).to eq(508) }
        end

      end

    end

    context "For a POST" do

      def action(url, headers={})
        HTTPUtilities.post(url, 'some-content', headers)
      end

      def http_method
        :post
      end

      it_should_behave_like "all HTTP methods"

      it "should include content" do
        stub_request(http_method, 'http://www.example.com/path')
        action('http://www.example.com/path')
      end

    end

    context "For a GET" do

      def action(url, headers={})
        HTTPUtilities.get(url, headers)
      end

      def http_method
        :get
      end

      it_should_behave_like "all HTTP methods"

    end

  end

end