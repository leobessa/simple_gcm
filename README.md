# gcm (Google Cloud Messaging)

gcm sends push notifications to Android devices via google [gcm](http://developer.android.com/guide/google/gcm/index.html).

##Installation

```console
$ gem install gcm
```

##Requirements

An Android device running 2.2 or newer, its registration token, and a google API Key registered for gcm.

##Usage

Sending one notification at a time:

```ruby
require 'gcm'
sender  = GCM::Sender.new(api_key: "your_api_key")
message = GCM::Message.new(:data => {alert => "your message"})
begin
  result  = sender.send(:registration_id => "your_phone_registration_id", :message => message)
  puts result.message_id
  puts result.registration_id
rescue GCM::Error::MissingRegistration => e; puts e
rescue GCM::Error::InvalidRegistration => e; puts e
rescue GCM::Error::MismatchSenderId => e; puts e
rescue GCM::Error::NotRegistered => e; puts e
rescue GCM::Error::MessageTooBig => e; puts e
rescue GCM::Error::AuthenticationError => e; puts e
rescue GCM::Error::ServerUnavailable => e; puts e
rescue GCM::Error::Unkown => e; puts e
rescue Exception => e
end
```


## Contributing to gcm
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Leonardo Bessa. See LICENSE.txt for
further details.

