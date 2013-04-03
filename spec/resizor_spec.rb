require "spec_helper"
require "tempfile"

describe Resizor do
  describe ".repository" do
    it "is a ImageRepository with the current config" do
      Resizor.instance_variable_set "@repository", nil

      repo = stub
      Resizor::ImageRepository.should_receive(:new).with(Resizor.config).and_return repo
      Resizor.repository.should eq(repo)
    end
  end

  describe ".store" do
    it "returns a successful response with the stored image" do
      repository_response, file = stub("response"), stub("file")
      Resizor.repository.should_receive(:store).with(file, "the-id").and_return repository_response

      response = Resizor.store file, "id" => "the-id"

      response.should eq(repository_response)
    end
  end

  describe ".delete" do
    it "delegates to the repository and returns the response" do
      Resizor.repository.should_receive(:delete).with("an-image-id").and_return true

      response = Resizor.delete "an-image-id"

      response.should be_true
    end
  end

  describe ".find" do
    it "delegates to the repository and returns the response" do
      image = stub
      Resizor.repository.should_receive(:fetch).with("an-image-id").and_return image

      response = Resizor.find "an-image-id"

      response.should eq(image)
    end
  end

  describe ".all" do
    it "delegates to the repository and returns the response" do
      image_collection = stub
      Resizor.repository.should_receive(:all).with("page" => 1).and_return image_collection

      response = Resizor.all "page" => 1
      response.should eq(image_collection)
    end
  end

  describe ".config" do
    it "delegates configured? to the config" do
      Resizor.config.stub :configured? => "cat!"
      Resizor.configured?.should eq("cat!")
    end

    it "allow setting the config variables in a block form" do
      Resizor.configure do |config|
        config.access_key = "my-new-access-key"
        config.secret_key = "my-new-secret-key"
      end

      Resizor.config.access_key.should eq("my-new-access-key")
      Resizor.config.secret_key.should eq("my-new-secret-key")
    end
  end
end
