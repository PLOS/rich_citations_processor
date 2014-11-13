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

module RichCitationsProcessor
  module Models

    class Collection
      include Enumerable

      delegate :each, :[],
               :first, :second, :third, :fourth, :fifth, :last,
               :length, :size, :count,
               :empty?, :present?,
               :include?,
           to: :@items

      def initialize(contained_class, ignore_duplicates:false)
        @contained_class   = contained_class
        @ignore_duplicates = ignore_duplicates
        @items = []
      end

      # Find a matching item. For example
      # references.for(number: 21)
      def for(key_value)
        key   = key_value.keys.first
        value = key_value[key]
        @items.find { |i| i.send(key) == value}
      end

      def add(*object_or_attributes)
        instance = convert_object(*object_or_attributes)

        if !include?(instance)
          @items << instance
          instance

        else
          raise DuplicateError.new("Duplicate object added to Collection") unless @ignore_duplicates
        end
      end

      def <<(items)
        raise ArgumentError.new("items is not enumerable") unless items.respond_to?(:each)

        items.each { |item| add( item ) }
      end

      def ==(other)
        if other.is_a?(Collection)
          items == other.items
        else
          items == other
        end
      end

      def inspect
        indented_inspect
      end

      def indented_inspect(indent='', name=@contained_class.to_s.demodulize.titleize.pluralize)
        result = "#{indent}#{name}[#{count}]"
        return result if (count == 0)

        indent = indent + '  '
        result << ":\n#{indent}"
        use_indented = first.respond_to?(:indented_inspect)
        result << map { |i| use_indented ? i.indented_inspect(indent) : indent + i.inspect }.join("\n#{indent}")
      end

      protected

      attr_reader :items

      # Input can be either an object of the correct type, empty,
      # an array of constructor arguments or a hash of arguments
      def convert_object(*object_or_attributes)
        if object_or_attributes.length == 0
          return @contained_class.new
        elsif object_or_attributes.length > 1
          return @contained_class.new(*object_or_attributes)
        else
          object_or_attributes = object_or_attributes.first
        end

        if object_or_attributes.is_a?(Hash)
          @contained_class.new(**object_or_attributes)

        else
          raise ArgumentError.new("Argument provided to Collection.add could not be converted to a #{@contained_class}") unless object_or_attributes.is_a?(@contained_class)
          object_or_attributes
        end
      end

    end
  end
end