# Notes:
#  Copyright 2016 Hewlett-Packard Development Company, L.P.
#
#  Permission is hereby granted, free of charge, to any person obtaining a
#  copy of this software and associated documentation files (the "Software"),
#  to deal in the Software without restriction, including without limitation
#  the rights to use, copy, modify, merge, publish, distribute, sublicense,
#  and/or sell copie of the Software, and to permit persons to whom the
#  Software is furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper([
  '../node_modules/hubot-enterprise/src/0_bootstrap.coffee',
  '../src/octane.coffee'])

describe 'octane', ->
  this.timeout 10000
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

#  it 'responds to octane create', ->
#    @room.user.say('alice', '@hubot octane create ticket').then =>
#      expect(@room.messages).to.eql [
#        ['alice', '@hubot octane create ticket']
#        ['hubot', '@alice in octane create ticket']
#      ]
#
#  it 'hears octane update', ->
#    @room.user.say('bob', 'octane update ticket').then =>
#      expect(@room.messages).to.eql [
#        ['bob', 'octane update ticket']
#        ['hubot', 'in octane update ticket']
#      ]
