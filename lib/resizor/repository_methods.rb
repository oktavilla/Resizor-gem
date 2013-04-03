module Resizor
  module RepositoryMethods
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def store image, options = {}
        repository.store image, options["id"]
      end

      def delete id
        repository.delete id
      end

      def find id
        repository.fetch id
      end

      def all options = {}
        repository.all options
      end

      def repository
        @repository ||= ImageRepository.new config
      end
    end
  end
end
