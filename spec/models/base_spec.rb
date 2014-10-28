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

describe RichCitationsProcessor::Models::Base do

  class ModelTestClass < RichCitationsProcessor::Models::Base
    attr_accessor  :attrib_1
    attr_accessor  :attrib_2
    attr_reader    :atrrib_r
    attr_writer    :attrib_w
  end

  describe "::new" do

    it "should create an Object" do
      expect(ModelTestClass.new).not_to be_nil
    end

    it "should create an object with values" do
      instance = ModelTestClass.new(attrib_1:'Value 1', attrib_2:'Value 2')
      expect(instance).to have_attributes(attrib_1:'Value 1', attrib_2:'Value 2')

      instance = ModelTestClass.new(attrib_2:'Value 2')
      expect(instance).to have_attributes(attrib_1:nil, attrib_2:'Value 2')

      instance = ModelTestClass.new(attrib_1:'Value 1')
      expect(instance).to have_attributes(attrib_1:'Value 1', attrib_2:nil)
    end

    it "should fail for non existent attributes" do
      expect { ModelTestClass.new(unknown_attrib_1:'Value') }.to raise_exception(ArgumentError)
    end

    it "should fail for read-pnly attributes" do
      expect { ModelTestClass.new(attrib_r:'Value') }.to raise_exception(ArgumentError)
    end

    it "should succeed for write-only attributes" do
      instance = nil
      expect { instance = ModelTestClass.new(attrib_w:'Value W') }.not_to raise_exception
      expect(instance.instance_variable_get(:@attrib_w)).to eq('Value W')
    end

  end

  describe "#assign_attributes!!" do

    it "should create an object with values" do
      instance = ModelTestClass.new
      instance.assign_attributes!(attrib_1:'Value 1', attrib_2:'Value 2')
      expect(instance).to have_attributes(attrib_1:'Value 1', attrib_2:'Value 2')

      instance = ModelTestClass.new
      instance.assign_attributes!(attrib_2:'Value 2')
      expect(instance).to have_attributes(attrib_1:nil, attrib_2:'Value 2')

      instance = ModelTestClass.new
      instance.assign_attributes!(attrib_1:'Value 1')
      expect(instance).to have_attributes(attrib_1:'Value 1', attrib_2:nil)
    end

    it "should fail for non existent attributes" do
      instance = ModelTestClass.new
      expect {  instance.assign_attributes!(unknown_attrib_1:'Value') }.to raise_exception(ArgumentError)
    end

    it "should fail for read-pnly attributes" do
      instance = ModelTestClass.new
      expect {  instance.assign_attributes!(attrib_r:'Value') }.to raise_exception(ArgumentError)
    end

    it "should succeed for write-only attributes" do
      instance = ModelTestClass.new
      expect {  instance.assign_attributes!(attrib_w:'Value W') }.not_to raise_exception
      expect(instance.instance_variable_get(:@attrib_w)).to eq('Value W')
    end

  end

  describe "#inspect" do

    it "should return an inspection string" do
      instance = ModelTestClass.new(attrib_1:'Value 1', attrib_2:'Value 2')

      expect(instance.indented_inspect).to eq('Model Test Class: Attrib 1: "Value 1", Attrib 2: "Value 2"')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should return only non-nil values" do
      instance = ModelTestClass.new(attrib_1:nil, attrib_2:'Value 2')

      expect(instance.indented_inspect).to eq('Model Test Class: Attrib 2: "Value 2"')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should ignore values with only a writer" do
      instance = ModelTestClass.new(attrib_1:nil, attrib_2:'Value 2', attrib_w:'Value W')

      expect(instance.indented_inspect).to eq('Model Test Class: Attrib 2: "Value 2"')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should ignore values with only a reader" do
      instance = ModelTestClass.new(attrib_1:nil, attrib_2:'Value 2')
      instance.instance_variable_set(:@attrib_r, 'Value R')

      expect(instance.indented_inspect).to eq('Model Test Class: Attrib 2: "Value 2"')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

  end

end
