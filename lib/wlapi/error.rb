module WLAPI

  class Error < StandardError; end

  class ExternalError < Error
    def initialize(e)
      msg = "Some external error occured:\n"
      msg << "#{e.class}: #{e.message}"        

      super(msg)
    end
  end

  class UserError < Error
  end
end
