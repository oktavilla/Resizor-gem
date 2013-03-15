
require "spec_helper"
require_relative "../lib/resizor/url"


describe Resizor::Url do
  subject do
    Resizor::Url.new api_version: 1, access_token: "token", secret_token: "my-secret-token"
  end

  it_behaves_like "a signable object"

  its(:domain) { should eq("resizor.com") }

  its(:subdomain) { should eq("cdn") }

  it "delegates optimize_parallel_downloads to the config" do
    fake_config = stub :optimize_parallel_downloads? => "why yes of course"
    Resizor.stub(config: fake_config)

    subject.optimize_parallel_downloads?.should eq("why yes of course")
  end

  describe "#host" do
    before :each do
      subject.stub subdomain: "test"
      subject.stub domain: "example.com"
    end

    it "combines the subdomain and domain to host" do
      subject.host.should eq("test.example.com")
    end

    it "allows a sudomain to be passed in" do
      subject.host("test-1").should eq("test-1.example.com")
    end
  end

  describe "#generate" do
    it "returns the resizor url for an image" do
      params = { id: "filename", format: "jpg", width: 500 }
      stub_signature params, "generated_signature"

      expected = "http://cdn.resizor.com/v1/token/filename.jpg?signature=generated_signature&width=500"
      url = subject.generate params

      url.should eq(expected)
    end

    it "throws an error if the operation is unknown" do
      expect {
        subject.generate id: "filename", format: "jpg", operation: "unknown-rotate"
      }.to raise_exception(Resizor::Url::UnknownOperation)
    end

    describe "with parallelize settings" do
      before :each do
        subject.stub :optimize_parallel_downloads? => true
      end

      it "calculates the subdomain from the generated path" do
        subject.should_receive(:parallelized_subdomain)
          .with("/v1/token/filename.jpg", "signature=generated_signature&width=500")
          .and_return "cdn-5"

        params = { id: "filename", format: "jpg", width: 500 }
        stub_signature params, "generated_signature"

        url = subject.generate params

        url.should eq("http://cdn-5.resizor.com/v1/token/filename.jpg?signature=generated_signature&width=500")
      end
    end
  end

  describe "scale" do
    it "delegates to generate with the scale operation" do
      subject.should_receive(:generate)
        .with(operation: "scale", width: 200)
        .and_return("expected-url")

      url = subject.scale width: 200

      url.should eq("expected-url")
    end
  end

  describe "crop" do
    it "delegates to generate with the crop operation" do
      subject.should_receive(:generate)
        .with(operation: "crop", width: 200, height: 100)
        .and_return("expected-url")

      url = subject.crop width: 200, height: 100

      url.should eq("expected-url")
    end
  end

  it "calculates a parallelized subdomain" do
    fake_zlib = Class.new
    stub_const "Zlib", fake_zlib
    fake_zlib.should_receive("crc32").with("/path-some=query").and_return 10

    # We want a number between 1 and the maximum available domains
    expected_subdomain_number = 10 % Resizor::Url::AVAILABLE_SUBDOMAINS + 1
    subdomain = subject.parallelized_subdomain "/path", "some=query"

    subdomain.should eq("cdn-#{expected_subdomain_number}")
  end

  private

  def stub_signature args, result
    subject.should_receive(:signature).with(args).and_return result
  end
end
