require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleGCM::Sender" do
  subject { SimpleGCM::Sender.new(api_key: "fake_api_key") }
  def stub_response(response)
    subject.connection_maker = lambda do |options|
      ::Faraday.new(options).tap do |c|
        c.builder.adapter :test do |stub|
          stub.post('/gcm/send') {  response }
        end
      end
    end
  end
  context "#send" do
    context "The message is processed successfully" do
      it "returns a SimpleGCM::Response with message_id" do
        message_id = "1:08"
        stub_response([200, {}, "id=#{message_id}"])
        reponse = subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new) 
        reponse.message_id.should == message_id
      end
      it "returns a SimpleGCM::Response with message_id and registration_id" do
        message_id = "1:2342"
        registration_id = "32"
        stub_response([200, {}, "id=#{message_id}\nregistration_id=#{registration_id}"])
        reponse = subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new)
        reponse.message_id.should == message_id
        reponse.registration_id.should == registration_id
      end
    end
    context "The message is not processed due errors" do
      %w(MissingRegistration InvalidRegistration MismatchSenderId NotRegistered MessageTooBig).each do |error|
        it "raises a SimpleGCM::Error::#{error}" do
          stub_response([200, {}, "Error=#{error}"])
          expect {  subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new) }.to raise_error(SimpleGCM::Error.const_get(error))
        end
      end
      it "raises a SimpleGCM::Error::AuthenticationError if return status is 401" do
        stub_response([401, {}, ""])
        expect {  subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new) }.to raise_error(SimpleGCM::Error::AuthenticationError)
      end
      it "raises a SimpleGCM::Error::ServerUnavailable if return status is 500" do
        stub_response([500, {}, ""])
        expect {  subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new) }.to raise_error(SimpleGCM::Error::ServerUnavailable)
      end
      it "raises a SimpleGCM::Error::ServerUnavailable if return status is 503" do
        stub_response([503, {}, ""])
        expect {  subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new) }.to raise_error(SimpleGCM::Error::ServerUnavailable)
      end
    end
  end
  context "#multicast" do
    context "The messages are processed successfully" do
      it "returns a SimpleGCM::Multicast with response content" do
        message_id = "1:08"
        body = { "multicast_id" => 108,
          "success" => 1,
          "failure" => 0,
          "canonical_ids" => 0,
          "results" => [
            { "message_id" => "1:08" }
          ]
        }.to_json
        stub_response([200, {"Content-Type" => "application/json"}, body])
        multicast = subject.multicast(:to => "fake_registration_id", :message => SimpleGCM::Message.new)
        multicast.success.should == 1
        multicast.failure.should == 0
        multicast.canonical_ids.should == 0
        multicast.results.should == [{ :message_id => "1:08" }]
      end
      it "returns a SimpleGCM::Multicast with response content and errors" do
        message_id = "1:08"
        body = { "multicast_id" => 216,
          "success" => 3,
          "failure" => 3,
          "canonical_ids" => 1,
          "results" => [
            { "message_id" => "1:0408" },
            { "error" => "Unavailable" },
            { "error" => "InvalidRegistration" },
            { "message_id" => "1:1516" },
            { "message_id" => "1:2342", "registration_id" => "32" },
            { "error" => "NotRegistered"}
          ]
        }.to_json
        stub_response([200, {"Content-Type" => "application/json"}, body])
        multicast = subject.multicast(:to => %w(a b c), :message => SimpleGCM::Message.new)
        multicast.success.should == 3
        multicast.failure.should == 3
        multicast.canonical_ids.should == 1
        multicast.results.should == [{ :message_id => "1:0408" },
          { :error => "Unavailable" },
          { :error => "InvalidRegistration" },
          { :message_id => "1:1516" },
          { :message_id => "1:2342", :registration_id => "32" },
          { :error => "NotRegistered"}
        ]
      end
    end

    it "when reponse status is 503, it returns a SimpleGCM::Multicast with Unavailable errors" do
      stub_response([503, {"Content-Type" => "application/json"}, ""])
      multicast = subject.multicast(:to => %w(a b c), :message => SimpleGCM::Message.new)
      multicast.success.should == 0
      multicast.failure.should == 3
      multicast.canonical_ids.should == 0
      multicast.results.should == [{ :error => "Unavailable" }] * 3
    end

  it "when reponse status is 500, it returns a SimpleGCM::Multicast with Unavailable errors" do
      stub_response([500, {"Content-Type" => "application/json"}, ""])
      multicast = subject.multicast(:to => %w(a b c), :message => SimpleGCM::Message.new)
      multicast.success.should == 0
      multicast.failure.should == 3
      multicast.canonical_ids.should == 0
      multicast.results.should == [{ :error => "Unavailable" }] * 3
    end
  end
end
