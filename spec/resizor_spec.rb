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
      image, file = stub("image"), stub("file")
      Resizor.repository.should_receive(:store).with(file, "the-id").and_return image

      response = Resizor.store file, "id" => "the-id"

      response.should eq(image)
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
