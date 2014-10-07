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

      delegate :each,
               :length, :size, :count,
               :include?,
           to: :@items

      def initialize(contained_class)
        @contained_class = contained_class
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
        if object_or_attributes.length == 0
          object_or_attributes = @contained_class.new
        elsif object_or_attributes.length > 1
          object_or_attributes = @contained_class.new(*object_or_attributes)
        else
          object_or_attributes = object_or_attributes.first
        end

        if object_or_attributes.is_a?(Hash)
          object_or_attributes = @contained_class.new(**object_or_attributes)
        end

        if ! object_or_attributes.is_a?(@contained_class)
          raise ArgumentError.new("Argument provided to Collection.add is not a #{@contained_class}")
        end

        # Don't allow duplicates
        if include?(object_or_attributes)
          raise ArgumentError.new("Duplicate object added to Collection")
        end

        @items << object_or_attributes
        object_or_attributes
      end
    end

  end
end