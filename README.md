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
      image = response.image
      puts image.to_h { id: "cats", mime_type: "image/jpeg" … }
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

    image = Resizor.find "cats"
    if image
      puts image.to_h # { id: "cats", mime_type: "image/jpeg" … }
    else
      raise "could not find image"
    end

Fetch all stored files

    images = Resizor.all page: 2, per_page: 25

    puts images.page # 2
    puts images.total_pages # 5
    puts images.total_items # 110

    images.each do |image|
      puts image.id
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
