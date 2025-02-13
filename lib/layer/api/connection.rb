module Layer
  module Api
    module Connection
      def connection
        @connection ||= Faraday.new(url: base_url) do |faraday|
          faraday.headers = default_layer_headers
          faraday.request  :url_encoded
          faraday.adapter  Faraday.default_adapter
          faraday.use Middleware::ApiErrors
        end
      end

      def get(url, options = {})
        call(:get, url, options)
      end

      def post(url, options = {})
        call(:post, url, options)
      end

      def patch(url, options = {})
        call(:patch, url, options)
      end

      def delete(url)
        call(:delete, url, options = {})
      end

      def call(method, url, options = {})
        response = run_request(method, url, options)
        response.body.empty? ? nil : JSON.parse(response.body)
      end

      def run_request(method, url, options = {})
        connection.run_request(
          method,
          url,
          options[:body],
          options[:headers]
        )
      end
    end
  end
end
