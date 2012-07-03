require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GCM::Sender" do
  subject { GCM::Sender.new(api_key: "fake_api_key") }
  context "#send" do
    context "The message is processed successfully" do
      it "returns a GCM::Response with message_id" do
        message_id = "1:08"
        subject.connection.builder.adapter :test do |stub|
          stub.post('/gcm/send') { [200, {}, "id=#{message_id}"] }
        end
        m = GCM::Message.new(:registration_id => "fake_registration_id", :data => {})
        reponse = subject.send(m)
        reponse.message_id.should == message_id
      end
      it "returns a GCM::Response with message_id and registration_id" do
        message_id = "1:2342"
        registration_id = "32"
        subject.connection.builder.adapter :test do |stub|
          stub.post('/gcm/send') { [200, {}, "id=#{message_id}\nregistration_id=#{registration_id}"] }
        end
        m = GCM::Message.new(:registration_id => "fake_registration_id", :data => {})
        reponse = subject.send(m)
        reponse.message_id.should == message_id
        reponse.registration_id.should == registration_id
      end
    end
    context "The message is not processed due errors" do
      %w(MissingRegistration InvalidRegistration MismatchSenderId NotRegistered MessageTooBig).each do |error|
        it "raises a GCM::Error::#{error}" do
          subject.connection.builder.adapter(:test){ |stub| stub.post('/gcm/send') { [200, {}, "Error=#{error}"] } }
          m = GCM::Message.new(:registration_id => "fake_registration_id", :data => {})
          expect {  subject.send(m) }.to raise_error(GCM::Error.const_get(error))
        end
      end
      it "raises a GCM::Error::AuthenticationError if return status is 401" do
        subject.connection.builder.adapter(:test){ |stub| stub.post('/gcm/send') { [401, {}, ""] } }
        m = GCM::Message.new(:registration_id => "fake_registration_id", :data => {})
        expect {  subject.send(m) }.to raise_error(GCM::Error::AuthenticationError)
      end
      it "raises a GCM::Error::ServerUnavailable if return status is 500" do
        subject.connection.builder.adapter(:test){ |stub| stub.post('/gcm/send') { [500, {}, ""] } }
        m = GCM::Message.new(:registration_id => "fake_registration_id", :data => {})
        expect {  subject.send(m) }.to raise_error(GCM::Error::ServerUnavailable)
      end
      it "raises a GCM::Error::ServerUnavailable if return status is 503" do
        subject.connection.builder.adapter(:test){ |stub| stub.post('/gcm/send') { [503, {}, ""] } }
        m = GCM::Message.new(:registration_id => "fake_registration_id", :data => {})
        expect {  subject.send(m) }.to raise_error(GCM::Error::ServerUnavailable)
      end
    end
  end

end
