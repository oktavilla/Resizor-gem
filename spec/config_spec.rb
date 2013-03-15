require "spec_helper"
require_relative "../lib/resizor/config"

describe Resizor.config do
  before :each do
    Resizor.config.access_key = "my-access.key"
    Resizor.config.secret_key = "my-secret.key"
  end

  it "is configured" do
    Resizor.config.configured?.should be_true
    Resizor.configured?.should be_true
  end

  it "is not configured without an access key" do
    Resizor.config.access_key = nil
    Resizor.configured?.should be_false
  end

  it "is not configured without a secret key" do
    Resizor.config.secret_key = nil
    Resizor.configured?.should be_false
  end

  it "knows if to optimize for parallel downloads" do
    Resizor.config.optimize_parallel_downloads.should be_false

    Resizor.config.optimize_parallel_downloads = true
    Resizor.config.optimize_parallel_downloads?.should be_true

    Resizor.config.optimize_parallel_downloads = false
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
