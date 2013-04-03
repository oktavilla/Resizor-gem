require "spec_helper"

describe Resizor::Image do
  let :attributes do
    { :id => "abc123", :name => "giorgio-a-tsoukalos", "extension" => "jpg",
      "mime_type" => "image/jpeg", "height" => 693, "width" => 520,
      "file_size" => 102059, "created_at" => "2013-10-23T13:07:25Z" }
  end

  subject do
    Resizor::Image.new attributes
  end

  # Assert that attributes is assigned correctly

  its(:id) { should eq("abc123") }

  its(:name) { should eq("giorgio-a-tsoukalos") }

  its(:extension) { should eq("jpg") }

  its(:filename) { should eq("giorgio-a-tsoukalos.jpg") }

  its(:width) { should eq(520) }

  its(:height) { should eq(693) }

  its(:file_size) { should eq(102059) }

  its(:created_at) { should == Time.new(2013, 10, 23, 13, 7, 25, "+00:00") }
end
