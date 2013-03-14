require "spec_helper"
require_relative "../lib/resizor/image_repository"

describe Resizor::ImageRepository do
  subject do
    Resizor::ImageRepository.new api_version: 666, access_token: "my-token", secret_token: "my-secret-token"
  end

  its(:host) { should eq("api.resizor.com") }

  its(:access_token) { should eq("my-token") }

  its(:secret_token) { should eq("my-secret-token") }

  its(:client_path) { should eq("/v666/my-token") }

  it "uses Resizor::Signature to generate signatures" do
    stub_const "Resizor::Signature", Class.new

    Resizor::Signature.should_receive(:generate)
      .with subject.secret_token, id: "an-id"

    subject.generate_signature id: "an-id"
  end

  describe "store" do
    it "sends a multipart post with the file and a correct signature" do
      file_io = stub

      expected_params = {
        id: "my-unique-id", file: file_io,
        signature: "123456789", timestamp: Time.new.to_i
      }

      subject.should_receive(:generate_signature).with({
        id: "my-unique-id", timestamp: Time.new.to_i
      }).and_return "123456789"

      Resizor::HTTP.should_receive(:post_multipart)
        .with("api.resizor.com/v666/my-token/assets.json", expected_params)
        .and_return [201, image_json_response]

      response_attributes = subject.store file_io, "my-unique-id"

      response_attributes.should eq(image_attributes)
    end

    it "handles the sad path"
  end

  describe "fetch" do
    it "returns the attributes for a found image" do
      subject.should_receive(:generate_signature).with({
        id: "image-id",
        timestamp: Time.new.to_i
      }).and_return "987654321"

      Resizor::HTTP.should_receive(:get)
        .with("api.resizor.com/v666/my-token/assets/image-id.json", {
          timestamp: Time.now.to_i, signature: "987654321"
        }).and_return [200, image_json_response]

      response = subject.fetch "image-id"

      response.should eq(image_attributes)
    end

    it "handles the sad path"
  end

  describe "all" do
    it "returns an array of attributes for all available images" do
      json_response = <<-eos
        {
          "total_pages": 4, "current_page": 1,
          "total_images": 2000, "images": [#{image_json_response}]
        }
      eos

      subject.should_receive(:generate_signature).with({
        timestamp: Time.new.to_i
      }).and_return "listing-signature"

      Resizor::HTTP.should_receive(:get)
        .with("api.resizor.com/v666/my-token/assets.json", {
          timestamp: Time.now.to_i, signature: "listing-signature"
        }).and_return [200, json_response]

        response = subject.all

        response["total_pages"].should eq(4)
        response["current_page"].should eq(1)
        response["total_images"].should eq(2000)
        response["images"].should eq([image_attributes])
    end

    it "paginates" do
      subject.should_receive(:generate_signature).with({
        timestamp: Time.new.to_i,
        page: 2
      }).and_return "paginated-listing-signature"

      Resizor::HTTP.should_receive(:get)
        .with("api.resizor.com/v666/my-token/assets.json", {
          page: 2, timestamp: Time.now.to_i, signature: "paginated-listing-signature"
        }).and_return ["[{}]"]

      subject.all page: 2
    end
  end

  private

  def image_json_response
    %q{
      { "id":1, "name":"i", "extension":"jpg", "mime_type":"image/jpeg",
        "height":500, "width":332, "file_size":666,
        "created_at":"2010-10-23T13:07:25Z" }
    }
  end

  def image_attributes
    JSON.parse image_json_response
  end
end
