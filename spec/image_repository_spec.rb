require "spec_helper"
require_relative "../lib/resizor/image_repository"

describe Resizor::ImageRepository do
  before :each do
    stub_const "Resizor::HTTP", Class.new
  end

  let :config do
    stub :api_version => 666,
         :access_key => "my-token",
         :secret_key => "my-secret-token",
         :host => "api.resizor.com"
  end

  subject do
     Resizor::ImageRepository.new config
  end

  its(:host) { should eq("api.resizor.com") }

  its(:access_key) { should eq("my-token") }

  its(:secret_key) { should eq("my-secret-token") }

  its(:client_path) { should eq("/v666/my-token") }

  it_behaves_like "a signable object"

  describe "#store" do
    let :file_io do
      stub
    end

    let :expected_params do
      {
        id: "my-unique-id", file: file_io,
        signature: "123456789", timestamp: Time.new.to_i
      }
    end

    before :each do
      subject.should_receive(:signature).with({
        id: "my-unique-id", timestamp: Time.new.to_i
      }).and_return "123456789"
    end

    it "sends a multipart post with the file and a correct signature" do
      Resizor::HTTP.should_receive(:post_multipart)
        .with("api.resizor.com/v666/my-token/images.json", expected_params)
        .and_return [201, image_json_response]

      subject.store file_io, "my-unique-id"
    end

    it "returns an image response when successful" do
      Resizor::HTTP.stub post_multipart: [201, image_json_response]

      response = subject.store file_io, "my-unique-id"

      response.success?.should be_true
      response.image.attributes.should eq(image_attributes)
    end

    it "returns an error response if unsuccessful" do
      Resizor::HTTP.should_receive(:post_multipart).and_return [500, error_json_response]

      response = subject.store file_io, "my-unique-id"

      response.success?.should be_false
      response.errors.should eq(JSON.parse(error_json_response)["errors"])
    end
  end

  describe "fetch" do
    it "sends a GET request with the correct parameters" do
      subject.should_receive(:signature).with({
        id: "image-id",
        timestamp: Time.now.to_i
      }).and_return "987654321"

      Resizor::HTTP.should_receive(:get)
        .with("api.resizor.com/v666/my-token/images/image-id.json", {
          timestamp: Time.now.to_i, signature: "987654321"
        }).and_return [200, image_json_response]

      subject.fetch "image-id"
    end

    it "returns an image if found" do
      Resizor::HTTP.should_receive(:get).and_return [200, image_json_response]

      image = subject.fetch "image-id"

      image.attributes.should eq(image_attributes)
    end

    it "returns falsey if no image was found" do
      Resizor::HTTP.should_receive(:get).and_return [404, "{}"]

      image = subject.fetch "non-existant-id"

      image.should be_false
    end
  end

  describe "delete" do
    it "sends a http DELETE to resizor with the correct timestamp and signature" do
      subject.should_receive(:signature).with({
        id: "image-id",
        timestamp: Time.now.to_i
      }).and_return "987654321"

      Resizor::HTTP.should_receive(:delete).with("api.resizor.com/v666/my-token/images/image-id.json", {
        timestamp: Time.now.to_i, signature: "987654321"
      }).and_return [204, ""]

      response = subject.delete "image-id"

      response.should be_true
    end

    it "handles the sad path of delete (not found)" do
      Resizor::HTTP.stub :delete => [404, ""]

      response = subject.delete "image-id"

      response.should be_false
    end
  end

  describe "all" do
    it "returns an array of attributes for all available images" do
      json_response = <<-eos
        {
          "total_pages": 4, "current_page": 1,
          "total_images": 2000, "images": [#{image_json_response}]
        }
      eos

      subject.should_receive(:signature).with({
        timestamp: Time.new.to_i
      }).and_return "listing-signature"

      Resizor::HTTP.should_receive(:get)
        .with("api.resizor.com/v666/my-token/images.json", {
          timestamp: Time.now.to_i, signature: "listing-signature"
        }).and_return [200, json_response]

      image_collection = stub
      Resizor::ImageCollection.should_receive(:new)
        .with(JSON.parse(json_response))
        .and_return image_collection

      response = subject.all

      response.should eq(image_collection)
    end

    it "paginates" do
      subject.should_receive(:signature).with({
        timestamp: Time.new.to_i,
        page: 2
      }).and_return "paginated-listing-signature"

      Resizor::HTTP.should_receive(:get)
        .with("api.resizor.com/v666/my-token/images.json", {
          page: 2, timestamp: Time.now.to_i, signature: "paginated-listing-signature"
        }).and_return ["[{}]"]

      subject.all page: 2
    end

    it "handle a non 200 response"
  end

  private

  def image_json_response
    %q{
      {
        "image": {
          "id":1, "name":"i", "extension":"jpg", "mime_type":"image/jpeg",
          "height":500, "width":332, "file_size":666,
          "created_at":"2010-10-23T13:07:25Z"
        }
      }
    }
  end

  def image_attributes
    JSON.parse(image_json_response)["image"]
  end

  def error_json_response
    %q{
      { "errors": [ "Missing param" ] }
    }
  end
end
