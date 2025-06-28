# Copyright 2025 Julien PORTALIER
# Distributed under the Apache-2.0 LICENSE

require "./location"

module XML
  class Error < Exception
    getter location : Location

    def initialize(@message : String, @location : Location)
    end

    def message : String
      "#{@message} at line #{@location.line} column #{@location.column}"
    end
  end
end
