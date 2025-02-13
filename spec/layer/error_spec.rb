require 'spec_helper'

describe Layer::Api::Error do
  describe ".from_response" do
    it 'should raise NotFound error when status is 404' do
      VCR.use_cassette('conversation') do
        layer = Layer::Api::Client.new

        expect {
          layer.get_conversation("notfound")
        }.to raise_error(Layer::Api::NotFound)
      end
    end

    it "should raise BadRequest error when status is 400" do
      response = {status: 400}
      expect {
        raise Layer::Api::Error.from_response(response)
      }.to raise_error(Layer::Api::BadRequest)
    end

    (500..599).each do |error|
      it "should raise ServerError when status is #{error}" do
        response = {status: error}
        expect {
          raise Layer::Api::Error.from_response(response)
        }.to raise_error(Layer::Api::ServerError)
      end
    end

    it "should return Error when status isn't found/handled" do
      expect {
        raise Layer::Api::Error.from_response({})
      }.to raise_error(Layer::Api::Error)
    end
  end

  describe ".initialize" do
    it "should set @response instance variable" do
      begin
        raise Layer::Api::Error.new({})
      rescue => e
        expect(e.response).to eq({})
      end
    end

    it "should build correct error message containing status & body" do
      status = '200'
      body = 'random_test_body'
      args = {
        status: status,
        body: body
      }
      error_msg = Layer::Api::Error.new(args).send(:build_error_message)
      expect(error_msg).to include(status)
      expect(error_msg).to include(body)
    end
  end
end
