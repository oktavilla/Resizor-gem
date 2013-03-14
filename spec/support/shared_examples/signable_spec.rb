shared_examples "a signable object" do

  it "responds to secret token" do
    subject.should respond_to(:secret_token)
  end

  describe "#signature" do
    it "uses Resizor::Signature to generate the signature param" do
      stub_const "Resizor::Signature", Class.new

      Resizor::Signature.should_receive(:generate)
        .with subject.secret_token, id: "an-id"

      subject.signature id: "an-id"
    end
  end

end
