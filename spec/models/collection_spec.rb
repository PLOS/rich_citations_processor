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
  
  RSpec.describe Collection do
  
    class CollectionTestItem
      attr_reader :attributes
      def initialize(*a); @attributes=a; end
      def ==(other); self.attributes == other.attributes; end
      def property; attributes.first; end
      def indented_inspect(*); property; end
    end
  
    let(:coll) { described_class.new(CollectionTestItem)}
    let(:filled_coll) { coll.add CollectionTestItem.new(1); coll.add CollectionTestItem.new(3); coll.add CollectionTestItem.new(2); coll }
  
    describe "::new" do
  
      it "should create a Collection" do
        expect(described_class.new(Object)).not_to be_nil
      end
  
    end
  
    describe "#add" do
  
      it "should add an item" do
        i = CollectionTestItem.new
        expect { coll.add(i) }.not_to raise_error
        expect(coll.to_a).to eq([i])
      end
  
      it "should fail when adding  a duplicate item" do
        coll = described_class.new(CollectionTestItem)

        i1 = CollectionTestItem.new(1)
        expect { coll.add(i1) }.not_to raise_error
        i2 = CollectionTestItem.new(1)
        expect { coll.add(i2) }.to raise_error(DuplicateError)
      end

      it "adding a duplicate item should not affect the collection" do
        coll = described_class.new(CollectionTestItem)

        i1 = CollectionTestItem.new(1)
        expect { coll.add(i1) }.not_to raise_error
        i2 = CollectionTestItem.new(1)
        expect { coll.add(i2) }.to raise_error(DuplicateError)

        expect(coll.length).to eq(1)
        expect(coll.first).to eq(i1)
      end

      it "should not not fail when adding  a duplicate item if allow_duplicates is true" do
        coll = described_class.new(CollectionTestItem, ignore_duplicates:true)

        i1 = CollectionTestItem.new(1)
        expect { coll.add(i1) }.not_to raise_error
        i2 = CollectionTestItem.new(1)
        result = nil
        expect { result = coll.add(i2) }.not_to raise_error

        expect(result).to be_nil
      end

      it "adding a duplicate item should not affect the collection" do
        coll = described_class.new(CollectionTestItem, ignore_duplicates:true )

        i1 = CollectionTestItem.new(1)
        expect { coll.add(i1) }.not_to raise_error
        i2 = CollectionTestItem.new(1)
        expect { coll.add(i2) }.not_to raise_error

        expect(coll.length).to eq(1)
        expect(coll.first).to eq(i1)
      end

      it "should add an item from multiple arguments" do
        result = nil
        expect { result = coll.add(1,2,3) }.not_to raise_error
        expect( result ).to be_a_kind_of(CollectionTestItem)
        expect( result.attributes).to eq([1, 2, 3])
      end
  
      it "should add an item from a hash or named parameters" do
        result = nil
        expect { result = coll.add(a:1, b:2) }.not_to raise_error
        expect( result ).to be_a_kind_of(CollectionTestItem)
        expect( result.attributes).to eq([{a:1, b:2}])
      end
  
      it "should succeed if no parameters are passed" do
        result = nil
        expect { result = coll.add }.not_to raise_error
        expect( result ).to be_a_kind_of(CollectionTestItem)
      end
  
      it "should fail if a different class is added" do
        i = Object.new
        expect { coll.add(i) }.to raise_error(ArgumentError)
      end
  
    end
  
    describe "# <<" do
  
      it "should add items from an array of test items" do
        expected = [ CollectionTestItem.new(1), CollectionTestItem.new(2) ]
        coll << expected
  
        expect(coll.to_a).to eq(expected)
      end
  
      it "should add items from another collection" do
        other = described_class.new(CollectionTestItem)
        other.add( CollectionTestItem.new(1) )
        other.add( CollectionTestItem.new(2) )
        coll << other
  
        expected = [ CollectionTestItem.new(1), CollectionTestItem.new(2) ]
        expect(coll.to_a).to eq(expected)
      end
  
      it "should add items from an array of hashes" do
        coll << [ {a:1}, {b:2}]
  
        expected = [ CollectionTestItem.new({a:1}), CollectionTestItem.new({b:2}) ]
        expect(coll.to_a).to eq(expected)
      end
  
      it "should append items" do
        coll.add( CollectionTestItem.new(1))
  
        coll << [ CollectionTestItem.new(2), CollectionTestItem.new(3) ]
  
        expected = [ CollectionTestItem.new(1), CollectionTestItem.new(2), CollectionTestItem.new(3) ]
        expect(coll.to_a).to eq(expected)
      end
  
      it "should fail when adding  a duplicate item but add any preceding items" do
        coll.add( CollectionTestItem.new(1))
  
        expect { coll << [ CollectionTestItem.new(2), CollectionTestItem.new(1), CollectionTestItem.new(4) ] }.to raise_exception
  
        expected = [ CollectionTestItem.new(1), CollectionTestItem.new(2) ]
        expect(coll.to_a).to eq(expected)
      end
  
    end
  
    describe "#for" do
  
      it "should find an item based on any field" do
        result = filled_coll.for(property: 3)
        expect(result).not_to be_nil
        expect(result.property).to eq(3)
  
        result = filled_coll.for(attributes: [2])
        expect(result).not_to be_nil
        expect(result.attributes).to eq([2])
      end
  
      it "should return nil if an item is not found" do
        result = filled_coll.for(property: 9)
        expect(result).to be_nil
      end
  
    end
  
    describe "Array like operations" do
  
      it "should handle basic operations" do
        expect(filled_coll.length).to eq(3)
        expect(filled_coll.size  ).to eq(3)
        expect(filled_coll.count ).to eq(3)
  
        expect( filled_coll.include?( CollectionTestItem.new(3) ) ).to be_truthy
        expect( filled_coll.include?( CollectionTestItem.new(4) ) ).to be_falsey
  
        results = []
        filled_coll.each { |i| results << i.property }
        expect(results).to eq( [ 1, 3, 2 ] )
  
        results = filled_coll.map { |i| i.property }
        expect(results).to eq( [ 1, 3, 2 ] )
  
        expect(filled_coll.first.property).to eq(1)
        expect(filled_coll.second.property).to eq(3)
        # expect(filled_coll.third.property).to eq(2)
        expect(filled_coll.last.property).to eq(2)
      end
  
    end
  
    describe "#inspect" do
  
      it "should return an inspection string" do
        expect(filled_coll.inspect).to eq("Collection Test Items[3]:\n  1\n  3\n  2")
        expect(filled_coll.inspect).to eq(filled_coll.indented_inspect)
      end
  
      it "should return an inspection string for an empty collection" do
        expect(coll.inspect).to eq('Collection Test Items[0]')
        expect(coll.inspect).to eq(coll.indented_inspect)
      end
  
      it "should handle nested module names" do
        module Nested
          class WidgetFactory < CollectionTestItem; end
        end
        coll = described_class.new(Nested::WidgetFactory)
        coll.add( Nested::WidgetFactory.new(1) )
        expect(coll.inspect).to eq("Widget Factories[1]:\n  1")
        expect(coll.inspect).to eq(coll.indented_inspect)
      end
  
      it "should add extra indentation" do
        expect(filled_coll.indented_inspect('  ')).to eq("  Collection Test Items[3]:\n    1\n    3\n    2")
      end
  
      it "should take a custom name" do
        expect(filled_coll.indented_inspect('  ', 'Widgets')).to eq("  Widgets[3]:\n    1\n    3\n    2")
      end
  
    end
  
  end

end  