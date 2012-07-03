require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleGCM::Sender" do
  subject { SimpleGCM::Sender.new(api_key: "fake_api_key") }
  context "#send" do
    context "The message is processed successfully" do
      it "returns a SimpleGCM::Response with message_id" do
        message_id = "1:08"
        subject.connection.builder.adapter :test do |stub|
          stub.post('/gcm/send') { [200, {}, "id=#{message_id}"] }
        end
        reponse = subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new)
        reponse.message_id.should == message_id
      end
      it "returns a SimpleGCM::Response with message_id and registration_id" do
        message_id = "1:2342"
        registration_id = "32"
        subject.connection.builder.adapter :test do |stub|
          stub.post('/gcm/send') { [200, {}, "id=#{message_id}\nregistration_id=#{registration_id}"] }
        end
        reponse = subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new)
        reponse.message_id.should == message_id
        reponse.registration_id.should == registration_id
      end
    end
    context "The message is not processed due errors" do
      %w(MissingRegistration InvalidRegistration MismatchSenderId NotRegistered MessageTooBig).each do |error|
        it "raises a SimpleGCM::Error::#{error}" do
          subject.connection.builder.adapter(:test){ |stub| stub.post('/gcm/send') { [200, {}, "Error=#{error}"] } }
          expect {  subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new) }.to raise_error(SimpleGCM::Error.const_get(error))
        end
      end
      it "raises a SimpleGCM::Error::AuthenticationError if return status is 401" do
        subject.connection.builder.adapter(:test){ |stub| stub.post('/gcm/send') { [401, {}, ""] } }
        expect {  subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new) }.to raise_error(SimpleGCM::Error::AuthenticationError)
      end
      it "raises a SimpleGCM::Error::ServerUnavailable if return status is 500" do
        subject.connection.builder.adapter(:test){ |stub| stub.post('/gcm/send') { [500, {}, ""] } }
        expect {  subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new) }.to raise_error(SimpleGCM::Error::ServerUnavailable)
      end
      it "raises a SimpleGCM::Error::ServerUnavailable if return status is 503" do
        subject.connection.builder.adapter(:test){ |stub| stub.post('/gcm/send') { [503, {}, ""] } }
        expect {  subject.send(:registration_id => "fake_registration_id", :message => SimpleGCM::Message.new) }.to raise_error(SimpleGCM::Error::ServerUnavailable)
      end
    end
  end

end
