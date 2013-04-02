require "resizor/version"

module Resizor

  class Response

    def success?
      true
    end
  end

  def self.store asset, options = {}

    Response.new
  end

end
