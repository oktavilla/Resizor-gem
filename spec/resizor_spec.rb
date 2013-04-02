require "spec_helper"
require "tempfile"
describe Resizor do
  describe ".store" do
    it "returns a successful response with the stored asset" do
      stored_asset = stub
      file = Tempfile.new "cats"
      response = Resizor.store file
    end
  end
end
