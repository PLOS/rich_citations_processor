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

require 'loofah'

#Convert JATS XML to HTML but keep enough structure to be used by later steps

module RichCitationsProcessor
  module Parsers
    class NLM

      class JatsToHtml < Loofah::Scrubbers::Strip

        def scrub(node)
          return if node.text?

          node.name = node.name.downcase

          if node.name == 'ext-link' && node['ext-link-type'] == 'uri'
            url = node['xlink:href'] # ].xpath('@xlink:href', {'xlink' => 'http://www.w3.org/1999/xlink'})
            node.attribute_nodes.each(&:remove)
            node.name = 'a'
            node['href'] = url
          end

          case node.name

            # Convert some JATS nodes to classes

            when 'mixed-citation', 'element-citation'
              node.name = 'span'
              node['data-publicationtype'] = node['publication-type']
              node.remove_attributes except:['data-publicationtype']
              node['class'] = 'citation'

            when 'article-title', 'elocation-id',
                 'collab', 'name', 'surname', 'given-names', 'person-group',
                 'source', 'volume', 'issue',
                 'fpage', 'lpage', 'comment',
                 'year', 'month', 'day',
                'publisher-name'
              node.remove_attributes
              node['class'] = CLASS_RENAMES[node.name] || node.name
              node.name = 'span'

            # Convert some HTML tags

            when 'italic', 'i', 'em'
              node.remove_attributes
              node.name = 'em'

            when 'bold', 'b', 'strong'
              node.remove_attributes
              node.name = 'strong'

            # Keep some as is

            when  'a', 'u', 'cite', 'q', 'mark', 'abbr', 'sub', 'sup', 's', 'wbr'
              # nothing but the scrubber does some cleaning

            else
              # Otherwise delete this node
              node.replace_with_children
              return

          end

          super

        end

        CLASS_RENAMES = {
            'name'   => 'author',
            'collab' => 'collaborator'
        }
      end

    end
  end
end