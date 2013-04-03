require "resizor/version"
require "resizor/api_version"
require "resizor/config"
require "resizor/http"
require "resizor/signature"
require "resizor/image"
require "resizor/image_collection"
require "resizor/image_repository"
require "resizor/url"
require "resizor/repository_methods"
require "resizor/configurable_methods"

module Resizor
  include ConfigurableMethods
  include RepositoryMethods
end
