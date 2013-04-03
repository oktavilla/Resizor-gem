require "spec_helper"

describe Resizor::ImageCollection do
  it "assigns attributes" do
    collection = Resizor::ImageCollection.new({
      "total_pages" => 2,
      "current_page" => 1,
      "total_images" => 3
    })

    collection.total_pages.should eq(2)
    collection.current_page.should eq(1)
    collection.total_images.should eq(3)
  end

  it "instantiates image objects" do
    image = stub "image_instance"
    image_attributes = stub "image_attributes"
    fake_image_klass = stub
    fake_image_klass.should_receive(:new).with(image_attributes).and_return image
    stub_const "Resizor::Image", fake_image_klass

    collection = Resizor::ImageCollection.new "images" => [ image_attributes ]
    collection.images.should eq([image])
  end

  it "enumerates images" do
    image = stub "image"
    collection = Resizor::ImageCollection.new Hash.new
    collection.stub :images => [ image ]

    collection.should be_a(Enumerable)
    collection.first.should eq(image)
    collection.each { |image_instance| image_instance.should eq(image) }
  end
end
