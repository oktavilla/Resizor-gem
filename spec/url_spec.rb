
require "spec_helper"
require_relative "../lib/resizor/url"


describe Resizor::Url do
  subject do
    Resizor::Url.new api_version: 1, access_token: "token", secret_token: "my-secret-token"
  end

  its(:parallelize) { should be_false }
  its(:domain) { should eq("resizor.com") }
  its(:subdomain) { should eq("cdn") }

  it "combines the subdomain and domain to host" do
    subject.stub subdomain: "test"
    subject.stub domain: "example.com"

    subject.host.should eq("test.example.com")
  end

  describe "#generate" do
    it "returns the full url for the image version" do
      params = { id: "filename", format: "jpg", width: 500 }
      stub_signature params, "generated_signature"

      expected = "http://cdn.resizor.com/v1/token/filename.jpg?signature=generated_signature&width=500"
      url = subject.generate params

      url.should eq(expected)
    end

    it "dissalows unknown operations" do
      expect {
        subject.generate id: "filename", format: "jpg", operation: "rotate"
      }.to raise_exception(Resizor::Url::UnknownOperation)
    end

    describe "with parallelize settings" do
      before :each do
        subject.stub parallelize: true
      end

      it "calculates the subdomain from the generated path" do
        subject.should_receive(:parallelized_subdomain)
          .with("/v1/token/filename.jpg", "signature=generated_signature&width=500")
          .and_return "cdn-5"

        params = { id: "filename", format: "jpg", width: 500 }

        expected = "http://cdn-5.resizor.com/v1/token/filename.jpg?signature=generated_signature&width=500"
        stub_signature params, "generated_signature"

        url = subject.generate params

        url.should eq(expected)
      end
    end
  end

  describe "#signature" do
    it "uses Resizor::Signature to generate the signature param" do
      stub_const "Resizor::Signature", Class.new

      Resizor::Signature.should_receive(:generate)
        .with subject.secret_token, id: "an-id"

      subject.signature id: "an-id"
    end
  end

  it "calculates a parallelized subdomain" do
    fake_zlib = Class.new
    stub_const "Zlib", fake_zlib
    fake_zlib.should_receive("crc32").with("/path-some=query").and_return 10

    # We want a number between 1 and the maximum available domains
    expected_subdomain_number = 10 % 8 + 1
    subdomain = subject.parallelized_subdomain "/path", "some=query"

    subdomain.should eq("cdn-#{expected_subdomain_number}")
  end

  private

  def stub_signature args, result
    subject.should_receive(:signature).with(args).and_return result
  end
end
