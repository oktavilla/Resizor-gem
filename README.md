# Resizor

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'resizor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resizor

## Usage

Save a file 

    file = File.open "my-image.jpg"
    response = Resizor.store file, { id: "cats" }
    if response.success?
      asset = response.asset
      puts asset.to_h { id: "cats", mime_type: "image/jpeg" … }
    else
      raise response.errors # ["Invalid credentials"]
    end

Delete a file

    response = Resizor.delete "cats"
    if response.success?
      puts "file deleted"
    else
      raise "unable to delete cats, #{response.errors}"
    end

Find a file

    asset = Resizor.find "cats"
    if asset
      puts asset.to_h # { id: "cats", mime_type: "image/jpeg" … }
    else
      raise "could not find asset"
    end

Fetch all stored files

    assets = Resizor.all page: 2, per_page: 25

    puts assets.page # 2
    puts assets.total_pages # 5
    puts assets.total_items # 110

    assets.each do |asset|
      puts asset.id
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
