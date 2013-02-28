# encoding: utf-8

module CarrierWave
  module Uploader
    module Url
      extend ActiveSupport::Concern
      include CarrierWave::Uploader::Configuration

      ##
      # === Returns
      #
      # [String] the location where this file is accessible via a url
      #
      def url(options = {})
        url =
          if file.respond_to?(:url) and not file.url.blank?
            file.method(:url).arity == 0 ? file.url : file.url(options)
          elsif file.respond_to?(:path)
            path = file.path.gsub(File.expand_path(root), '')

            (base_path || "") + path
          end

        uri_encode_url(url)
      end
      alias_method :to_s, :url

      ##
      # === Returns
      #
      # [Hash] the locations where this file and versions are accessible via a url
      #
      def as_json(options = nil)
        h = { :url => url }
        h.merge Hash[versions.map { |name, version| [name, { :url => version.url }] }]
      end

      ##
      # FIXME to_xml should work like to_json, but this is the best we've been able to do so far.
      # This hack fixes issue #337.
      #
      # === Returns
      #
      # [nil]
      #
      def to_xml(options = nil)
      end

    private

      def uri_encode_url(url)
        if url = URI.parse(url)
          url.path = uri_encode_path(url.path)
          url.to_s
        end
      rescue URI::InvalidURIError
        nil
      end

      def uri_encode_path(path)
        # based on Ruby < 2.0's URI.encode
        safe_string = URI::REGEXP::PATTERN::UNRESERVED + '\/'
        unsafe = Regexp.new("[^#{safe_string}]", false)

        path.gsub(unsafe) do
          us = $&
          tmp = ''
          us.each_byte do |uc|
            tmp << sprintf('%%%02X', uc)
          end
          tmp
        end
      end

    end # Url
  end # Uploader
end # CarrierWave
