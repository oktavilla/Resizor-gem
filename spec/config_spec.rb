require "spec_helper"

describe Resizor::Config do
  describe "#configured?" do
    before :each do
      subject.access_key = "access"
      subject.secret_key = "secret"
    end

    it "is configured with a access key and a secret key" do
      subject.configured?.should be_true
    end

    it "is not configured without an access key" do
      subject.access_key = nil
      subject.configured?.should be_false
    end

    it "is not configured without a secret key" do
      subject.secret_key = nil
      subject.configured?.should be_false
    end
  end

  it "defaults optimize_parallel_downloads to false" do
    subject.optimize_parallel_downloads?.should be_false
  end

  it "sets optimize for parallel downloads" do
    subject.optimize_parallel_downloads = true

    subject.optimize_parallel_downloads?.should be_true
  end

  it "defaults host" do
    subject.host.should eq("api.resizor.com")
  end

  it "sets the host" do
    subject.host = "new-api.bananas.org"

    subject.host.should eq("new-api.bananas.org")
  end
end
