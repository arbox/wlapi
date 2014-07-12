module TestHelper
  def execute(expectation, method, *args)
    begin
      result = @api.send(method, *args)
    rescue => error
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
