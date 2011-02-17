require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class IntegrationTest < Test::Unit::TestCase

  context 'Including Resizor in a Rails project' do
    setup do
      setup_resizor
    end

    should 'add has_resizor_asset to ActiveRecord::Base' do
      assert ActiveRecord::Base.methods.include?('has_resizor_asset')
    end
  end

  context 'A ActiveRecord model that has_resizor_asset' do
    setup do
      build_model
      @item = Item.new(:name => 'my test item')
    end

    context 'with a file attached' do
      setup do
        @image_fixture_path = File.join(File.dirname(__FILE__), 'fixtures', 'image.jpg')
        File.open(@image_fixture_path, 'w') {|f| f.write('JPEG data') }
        @file = File.new(@image_fixture_path, 'rb')
        @item.image = @file
        stub_http_request(:post, "https://resizor.test:443/assets.json").
                          with { |request| request.body.include?("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg") }.
                          to_return(:status => 201, :body => '{"asset": { "id":1, "name":"i", "extension":"jpg", "mime_type":"image/jpeg", "height":7, "width":8, "file_size":9, "created_at":"2010-10-23T13:07:25Z"}}')
        stub_http_request(:delete, "https://resizor.test:443/assets/1.json?api_key=test-api-key").to_return(:status => 200)
      end

      teardown { File.unlink(@image_fixture_path) if File.exists?(@image_fixture_path) }

      should 'save attached asset to Resizor on save' do
        assert @item.save
        assert_requested(:post, "https://resizor.test:443/assets.json", :times => 1) do |request|
          request.body.include?("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg")
        end
      end

      should 'set assigned resizor data to asset fields' do
        @item.save
        @item.reload
        assert_equal '1', @item.image_resizor_id
        assert_equal 'i.jpg', @item.image_name
        assert_equal 'image/jpeg', @item.image_mime_type
        assert_equal 9, @item.image_size
        assert_equal 8, @item.image_width
        assert_equal 7, @item.image_height
      end

      should 'copy attributes when another resizor asset is assigned to asset attribute' do
        @item.save
        @another_item = Item.create(:name => 'The second item')
        @another_item.image = @item.image
        @another_item.save
        assert_equal @item.image_resizor_id, @another_item.image_resizor_id
        assert_equal @item.image_name, @another_item.image_name
        assert_equal @item.image_mime_type, @another_item.image_mime_type
        assert_equal @item.image_size, @another_item.image_size
        assert_equal @item.image_width, @another_item.image_width
        assert_equal @item.image_height, @another_item.image_height
      end

      should 'return true for #image?' do
        @item.save
        assert @item.image?
      end


      should 'clear asset fields when assets is deleted' do
        @item.save
        assert @item.image.destroy
        [:image_resizor_id, :image_name, :image_mime_type, :image_size, :image_width, :image_height].each do |_attr|
          assert_nil @item.send(_attr)
        end
        assert_requested :delete, "https://resizor.test:443/assets/1.json?api_key=test-api-key", :times => 1
      end

      should 'delete resizor asset when model instance is deleted' do
        @item.save
        @item.reload
        assert @item.destroy
        assert_requested :delete, "https://resizor.test:443/assets/1.json?api_key=test-api-key", :times => 1
      end

    end

    should 'should work with no attachment set' do
      assert_nothing_raised do
        @item.save
      end
    end

    should 'return false when no attachment is set' do
      @item.save
      assert !@item.image?
    end
  end

end
