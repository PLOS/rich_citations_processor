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

module RichCitationsProcessor::URIResolvers

  RSpec.describe Registry do

    class DontAdd < Base; abstract!; def self.inherited(subclass); end; end
    class ClassA < DontAdd; abstract!; end

    class Class1 < DontAdd; def self.priority; 1; end; end
    class Class5 < DontAdd; def self.priority; 2; end; end
    class Class9 < DontAdd; def self.priority; 3; end; end

    class Class2 < DontAdd; def self.priority; 3; end; end
    class Class3 < DontAdd; def self.priority; 3; end; end


    describe '#resolver_classes' do

      it "should return a list of URIResolver classes" do
        expect( Registry.resolver_classes ).to eq([
                                                     DoiFromPlosHtml,
                                                     CrossRef,
                                                     DoiFromReference
                                                  ])


      end

      it "should not return abstract classes" do
        allow(Registry).to receive(:load_classes).and_return( [Class1, ClassA] )
        expect(Registry.resolver_classes).to eq([Class1])
      end

      it "should sort resolvers by priority" do
        allow(Registry).to receive(:load_classes).and_return( [Class1, Class5, Class9] )
        expect(Registry.resolver_classes).to eq([Class1, Class5, Class9])

        allow(Registry).to receive(:load_classes).and_return( [Class9, Class5, Class1] )
        expect(Registry.resolver_classes).to eq([Class1, Class5, Class9])
      end

      it "should sort resolvers by name" do
        allow(Registry).to receive(:load_classes).and_return( [Class1, Class2, Class3] )
        expect(Registry.resolver_classes).to eq([Class1, Class2, Class3])

        allow(Registry).to receive(:load_classes).and_return( [Class3, Class2, Class1] )
        expect(Registry.resolver_classes).to eq([Class1, Class2, Class3])
      end

      it "should sort by priority before name" do
        allow(Registry).to receive(:load_classes).and_return( [Class9, Class5, Class3, Class2, Class1] )
        expect(Registry.resolver_classes).to eq([Class1, Class5, Class2, Class3, Class9])
      end

    end

    describe '#return an instantiated list of resolvers' do

      it "should return a list of URIResolver classes" do
        classes   = Registry.resolver_classes
        instances = Registry.resolvers(paper: 'paper', references:'references')

        instances.zip(classes).each do |i, c|
          expect(i.class).to eq(c)
        end
      end

    end

  end

end