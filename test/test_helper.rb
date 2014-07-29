require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

module TestHelper

  def execute(expectation, method, *args)
    begin
      result = VCR.use_cassette(method) do
        @api.send(method, *args)
      end
    rescue => error
      # Servers are unreliable, sometimes we get this reboot message.
      if error.message =~ /(Server shutdown in progress)|(404)/i
        result = expectation
        warn(error.message)
      else
        raise        
      end
    end

    check_response(result)
    assert_equal(expectation, result)

    result
  end

  def check_input(*args)
  end

  
  def check_response(response)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(response.any?)
  end
end
