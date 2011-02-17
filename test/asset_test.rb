require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class AssetTest < Test::Unit::TestCase
  context "A Asset" do
    setup do
      setup_resizor
      @asset = Resizor::Asset.new(:id => 10,
                                  :name => 'my_file.jpg',
                                  :mime_type => 'image/jpeg',
                                  :width => 200,
                                  :height => 300,
                                  :size => 123456)
    end
    should "have assigned attributes" do
      assert_equal @asset.id, 10
      assert_equal @asset.name, 'my_file.jpg'
      assert_equal @asset.mime_type, 'image/jpeg'
      assert_equal @asset.width, 200
      assert_equal @asset.height, 300
      assert_equal @asset.size, 123456
    end

    should 'generate url for size c200x300' do
      assert_equal 'http://resizor.test:80/assets/10.jpg?size=c200x300&token=b8bb7c4c7c4fc1006c904f011f32f50f69730e5e', @asset.url(:size => 'c200x300')
    end

    should 'generate url for size c200x300 format png' do
      assert_equal 'http://resizor.test:80/assets/10.png?size=c200x300&token=0cf27070e89c44a40aee85decca2cd2d98af1dc2', @asset.url(:size => 'c200x300', :format => 'png')
    end

    should 'generate resize token for size c200x300 and format jpg' do
      assert_equal 'b8bb7c4c7c4fc1006c904f011f32f50f69730e5e', @asset.resize_token_for(:size => 'c200x300', :format => 'jpg')
    end

    context 'when saving to resizor' do
      setup do
        @jpg_file = Tempfile.new('image.jpg')
        @asset.path = @jpg_file.path
      end
      teardown { @jpg_file.unlink }

      context 'on success' do
        setup do
          stub_http_request(:post, "https://resizor.test:443/assets.json").
            with { |request|
              request.body.include?("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg")
            }.
            to_return(:status => 201,
                      :body => '{"asset": { "id":1, "name":"i", "extension":"jpg", "mime_type":"image/jpeg", "height":7, "width":8, "file_size":9, "created_at":"2010-10-23T13:07:25Z"}}')
          @asset.save_to_resizor
        end

        should 'make create call to Resizor on save with file' do
          assert_requested(:post, "https://resizor.test:443/assets.json",
                           :times => 1) { |request|
                              request.body.include?("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg")
                            }
        end

        should 'assign data for new assets as attributes' do
          assert_equal 1, @asset.id
          assert_equal 'i.jpg', @asset.name
          assert_equal 'image/jpeg', @asset.mime_type
          assert_equal 7, @asset.height
          assert_equal 8, @asset.width
          assert_equal 9, @asset.size
        end
      end

      context 'on failure' do
        should 'return false' do
          stub_http_request(:post, "https://resizor.test:443/assets.json").to_return(:status => 422)
          assert !@asset.save_to_resizor
        end
      end
    end

    context 'when destroying an asset' do
      should 'make delete call to Resizor on destroy' do
        stub_http_request(:delete, "https://resizor.test:443/assets/10.json?api_key=test-api-key").to_return(:status => 200)
        @asset.destroy
        assert_requested :delete, "https://resizor.test:443/assets/10.json?api_key=test-api-key", :times => 1
      end

      should 'return true on success' do
        stub_http_request(:delete, "https://resizor.test:443/assets/10.json?api_key=test-api-key").to_return(:status => 200)
        assert @asset.destroy
      end

      should 'return false on failure' do
        stub_http_request(:delete, "https://resizor.test:443/assets/10.json?api_key=test-api-key").to_return(:status => 404)
        assert !@asset.destroy
      end
    end
  end
end
