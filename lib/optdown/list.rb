#! /your/favourite/path/to/ruby
# -*- mode: ruby; coding: utf-8; indent-tabs-mode: nil; ruby-indent-level: 2 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Copyright (c) 2017 Urabe, Shyouhei
#
# Permission is hereby granted, free of  charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction,  including without limitation the rights
# to use,  copy, modify,  merge, publish,  distribute, sublicense,  and/or sell
# copies  of the  Software,  and to  permit  persons to  whom  the Software  is
# furnished to do so, subject to the following conditions:
#
#         The above copyright notice and this permission notice shall be
#         included in all copies or substantial portions of the Software.
#
# THE SOFTWARE  IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY  KIND, EXPRESS OR
# IMPLIED,  INCLUDING BUT  NOT LIMITED  TO THE  WARRANTIES OF  MERCHANTABILITY,
# FITNESS FOR A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  EVENT SHALL THE
# AUTHORS  OR COPYRIGHT  HOLDERS  BE LIABLE  FOR ANY  CLAIM,  DAMAGES OR  OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require_relative 'expr'
require_relative 'matcher'
require_relative 'list_item'

# @see http://spec.commonmark.org/0.28/#lists
class Optdown::List
  using Optdown::Matcher::Refinements

  # (see Optdown::Blocklevel#initialize)
  def initialize str, ctx
    first       = Optdown::ListItem.new str, ctx
    continue    = first.same_type_expr
    @children   = [ first ]
    @blank_seen = false
    until str.eos? do
      break unless str.match? continue
      while str.match? %r/#{Optdown::EXPR}\G\g<LINE:blank>/o do
        @blank_seen = true
        str.gets
      end
      item = Optdown::ListItem.new str, ctx
      @children << item
    end
  end

  # @see http://spec.commonmark.org/0.28/#loose
  # @return [true]  it is.
  # @return [false] it isn't.
  def tight?
    return (! @blank_seen) && @children.all?(&:tight?)
  end

  # @return [:ordered, :bullet, :task] type of the list.
  def type
    @children.first.type
  end

  # @return [String] start number (makes sense for ordered list)
  def start
    @children.first.order.sub %r/\A0+(?=\d)/, ''
  end
end
