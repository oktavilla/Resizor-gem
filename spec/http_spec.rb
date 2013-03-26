require "spec_helper"
require "resizor/http"
require 'webmock/rspec'

describe Resizor::HTTP do
  include WebMock

  describe ".post_multipart" do
    it "sends a MULTIPART POST to the url with the parameters as a query string" do
      pending
    end
  end

  describe ".get" do
    it "makes a GET request to the url with the parametes as a query string" do
      stub_request(:any, /example/).to_return body: "omg", status: 200
      response = Resizor::HTTP.get "http://example.com", key: "val"

      request(:get, "http://example.com/?key=val").should have_been_made
      response.should eq([200, "omg"])
    end
  end

  describe ".delete" do
    it "makes a DELETE request to the url with the parametes as a query string" do
      stub_request(:delete, /example/).to_return body: "", status: 204

      response = Resizor::HTTP.delete "http://example.com/some-path", key: "val"

      request(:delete, "http://example.com/some-path?key=val").should have_been_made
      response.should eq([204, nil])
    end
  end
end
