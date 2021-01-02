require 'minitest/autorun'
require 'process'
require 'log'
require 'parse_option'
require 'ring_core'


class RTest < Minitest::Test

  def setup
    r = CProcess.spawn('mkdir ../ring_test', false)
    assert r > 0
    Dir.chdir('../ring_test')
  end

  def test_ring_init
    parser = ParseOption.new
    in_error = parser.parse_option([ 'init',  'script'])
    assert in_error == false
    assert parser.command == :init
    assert parser.args.count == 1
    assert parser.args[0] == 'script'
    assert parser.simulate == false

    rc = RingCore.perform_initialize(parser.args, parser.simulate)
    #assert rc == true
  end

end
