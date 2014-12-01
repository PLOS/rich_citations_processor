# Copyright (c) 2014 Public Library of Science

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

module Spec
  module Builders

    module JATS

      def parts
        @parts ||= {}
      end

      def article_id(id, type=:doi)
        nodes = parts[:id_nodes] ||= ''
        nodes <<  "<article-id pub-id-type='#{type}'>#{id}</article-id>"
      end

      def id_nodes(nodes)
        parts[:id_nodes] = nodes
      end

      def refs(*refs)
        (parts[:refs] ||= []).concat(refs)
      end

      def meta (meta)
        (parts[:meta] ||= '') << meta
      end

      def body (body)
        (parts[:body] ||= '') << body
      end

      def cite(number)
        "<xref ref-type='bibr' rid='ref-#{number}'>[#{number}]</xref>"
      end

      def ref_nodes
        if parts[:refs]
          parts[:refs].map.with_index{ |r,i| "<ref id='ref-#{i+1}'>#{r}</ref>" }.join
        end
      end

      def xml
        xml = <<-EOS
          <root>
            <front>
              #{parts[:id_nodes]}
              <article-meta>#{parts[:meta]}</article-meta>
            </front>
            <body>#{parts[:body]}</body>
            <back>
              <ref-list>#{ref_nodes}</ref-list>
            </back>
          </root>
        EOS

        Nokogiri::XML::Document.parse(xml)
      end

    end
  end
end
