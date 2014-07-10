# active_spy

Watch for a method call in any class and run before/after callbacks.
You can even watch your Rails models for events (like create, update,
destroy), send these events to a event-runner instance and it redirect these
events to other apps that are subscrived for them. This gem also provides
classes that you can use to process the received events too.

## Examples

### Pure Ruby

```ruby
require 'active_spy'

class Chair
  include ActiveSpy::Spy

  watch_method :break!

  def initialize
    @broken = false
  end

  def break!
    @broken = true
    puts 'Crack!!!'
  end
end

class ChairEvents < ActiveSpy::Base

    def before_break!
      puts 'OMG! You are going to break the chair!'
    end

    def after_break!
      puts 'You broke that chair, man.'
    end
end

ActiveSpy::SpyList.activate
Chair.new.break!
```

### Rails app

First of all, run the install generator: `rails g active_spy:install`.
This command will generate `config/initializers/active_spy.rb` and
`config/active_spy.yml`. You must edit the YAML file to use your own app
parameters.

Then, create a `ProductEvent` class at  `RAILS_ROOT/app/events`

```ruby
class ProductEvents < ActiveSpy::Rails::Base
end
```

Declare ActiveSpy's `model_realm`, `model_actor`, and `watch_model_changes`
methods in the model that is being watched:

```ruby

class User < ActiveRecord::Base
  belong_to :project
  belongs_to :project_group

  model_realm { :project }
  model_actor :get_actor
  watch_model_changes

  def get_actor
    self
  end

  # ActiveSpy's payload_for method override
  #
  # def payload_for(method)
  #   { user: attributes }
  # end

  # ActiveSpy's realm method override
  #
  # def realm
  #   return project_group if project_group.admin == self
  #   project
  # end
end
```

You may override `payload_for(method)`, `realm` and `actor` for more complex
use cases.

Now, when you can create, update or delete instances of User, a request will be
sent to the `event_host` and `event_port` defined in the configuration YAML file.
The body will be filled with a hash like this, as json:

```
{
  type:     'User',         # object's class name
  actor:    user.actor,     # object's actor (who made that action)
  realm:    user.realm,     # object's realm
  action: action            # the action executed in the object
  payload:  {
    user: user.attributes,  # a hash with the user attributes inside the 'user'
                            # key
  }
}
```

Just to remember, you can override `#realm`, `#actor` and `#payload_for(method)`
to suit your own needs.

#### Handling the request received by the event runner

To handle the request received by the event-runner, you will need to mount
the `ActiveSpy::Engine` in your `routes.rb` file:

```ruby
Rails.application.routes.draw do
  mount ActiveSpy::Engine => 'active_spy', as: :active_spy
end
```

Then, you need to create a listener class, inheriting from
`ActiveSpy::Rails::Listener` and named using the watched model's name
plus the `Listener` postfix, like this:

```ruby
class UserListener < ActiveSpy::Rails::Listener
end
```

The default behavior will automatically try to sync the model that was sent
with the app own database. If you need a different behavior, you can override
the `create`, `update` and `delete` methods to match your needs:

```ruby
class UserListener < ActiveSpy::Rails::Listener

  def create(object_type, payload, actor, realm)
  end

  def update(object_type, payload, actor, realm)
  end

  def destroy(object_type, payload, actor, realm)
  end
end
```

## Contributing to active_spy

* Check out the latest master to make sure the feature hasn't been implemented
  or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it
  and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to
  have your own version, or is otherwise necessary, that is fine, but please
  isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2014 Douglas Camata. See LICENSE.txt for
further details.

