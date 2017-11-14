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

require 'test-unit'
require 'simplecov'
require 'stackprof'

SimpleCov.start do
  add_filter 'test/'
  add_filter 'vendor/'
end

END { StackProf.results }
class Test::Unit::TestCase
  prepend Module.new {
    def setup
      super
      StackProf.start raw: true, out: '/tmp/stackprof.dump'
    end

    def teardown
      super
      StackProf.stop
    end
  }
end

# Optdown::EXPR has literally hundreds of  named captures.  By matching against
# it a MatchData will contain all of them. This is almost impossible to inspect
# at one sight.  However the captures tends to be nil; which means most of them
# do not make sense  at once.  We can cut nil captures  from the inspect output
# for better readability.
class MatchData
  prepend Module.new {
    def inspect
      str = super
      names.each do |nam|
        str.gsub! %r/\s+#{Regexp.quote(nam)}:nil\b/, ''
      end
      return str
    end
  }
end

# So do Regexps.
class Regexp
  prepend Module.new {
    def inspect
      str = super
      str.gsub! %r/\n\(\?\<SP\>.+\)\{0\}\n/m, '...'
      return str
    end
  }
end
