module Resizor
  module ConfigurableMethods
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def config
        @config ||= Config.new
      end

      def configured?
        config.configured?
      end

      def configure &block
        yield(config) if block_given?
      end
    end
  end
end
