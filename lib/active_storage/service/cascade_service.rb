# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'

module ActiveStorage
  class Service
    class CascadeService < Service
      attr_reader :primary, :secondary

      delegate :upload, :update_metadata, :delete, :delete_prefixed, :url_for_direct_upload, :headers_for_direct_upload,
               to: :primary

      def self.build(primary:, secondary:, configurator:, **_options) #:nodoc:
        new(
          primary: configurator.build(primary),
          secondary: configurator.build(secondary)
        )
      end

      def initialize(primary:, secondary:)
        @primary = primary
        @secondary = secondary
      end

      # Return the content of the file at the +key+.
      def download(key)
        service(key).download(key)
      end

      # Return the partial content in the byte +range+ of the file at the +key+.
      def download_chunk(key, range)
        service(key).download_chunk(key, range)
      end

      # Return +true+ if a file exists at the +key+.
      def exist?(key)
        primary.exist?(key) || secondary.exist?(key)
      end

      # Returns a signed, temporary URL for the file at the +key+. The URL will be valid for the amount
      # of seconds specified in +expires_in+. You most also provide the +disposition+ (+:inline+ or +:attachment+),
      # +filename+, and +content_type+ that you wish the file to be served with on request.
      def url(key, expires_in:, disposition:, filename:, content_type:)
        service(key)
          .url(key, expires_in: expires_in, disposition: disposition, filename: filename, content_type: content_type)
      end

      def method_missing(method_name, *arguments, &block)
        if primary.respond_to?(method_name)
          primary.send(method_name, *arguments, &block)
        else
          super
        end
      end

      def respond_to?(method_name, include_private = false)
        primary.respond_to?(method_name, include_private) || super
      end

      private

      def service(key)
        primary.exist?(key) ? primary : secondary
      end
    end
  end
end
