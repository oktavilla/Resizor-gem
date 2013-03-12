require "spec_helper"
require_relative "../lib/resizor/signature"

describe Resizor::Signature do

  it "generates a parameter string sorted by the param keys" do
    signature = Resizor::Signature.new "coils-everywhere", foo: "bar", bar: "foo"
    signature.parameter_string.should eq("bar=foo&foo=bar")
  end

  it "removes file from the parameter string" do
    signature = Resizor::Signature.new "coils-everywhere", foo: "bar", file: "some-file"
    signature.parameter_string.should eq("foo=bar")
  end

  it "calculates the signature string from the access key and params using HMAC" do
    signature = Resizor::Signature.new "coils-everywhere", id: "kitteh", foo: "bar"
    signature.generate.should eq("11b2891786589063e38140b96a144182c1ae8eff")
  end

  describe "#generate" do
    it "is a short form for creating a signature string" do
      secret = "coils-everywhere"
      params = { id: "kitteh", foo: "bar" }

      signature_string = Resizor::Signature.new(secret, params).generate

      Resizor::Signature.generate(secret, params).should eq(signature_string)
    end
  end

end
