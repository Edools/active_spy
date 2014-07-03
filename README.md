# active_event

Watch for a method call in any class and run before/after callbacks.
You can even watch your Rails models for events (like create, update,
destroy), send these events to a event-runner instance and it redirect these
events to other apps that are subscrived for them. This gem also provides
classes that you can use to process the received events too.

## Examples

### Pure Ruby

```ruby
require 'active_event'

class Chair
  include ActiveEvent::Spy

  watch_method :break!

  def initialize
    @broken = false
  end

  def break!
    @broken = true
    puts 'Crack!!!'
  end
end

class ChairEvents < ActiveEvent::Base

    def before_break!
      puts 'OMG! You are going to break the chair!'
    end

    def after_break!
      puts 'You broke that chair, man.'
    end
end

ActiveEvent::SpyList.activate
Chair.new.break!
```

### Rails app

Create a `ProductEvent` class at  `RAILS_ROOT/app/events`
```ruby
class ProductEvents < ActiveEvent::Rails::Base
end
```

Declare ActiveEvent's `model_realm` and `watch_model_changes` methods
```ruby

class User < ActiveRecord::Base
  belong_to :project
  belongs_to :project_group

  model_realm { :project }
  watch_model_changes

  # ActiveEvent's payload_for method override
  #
  # def payload_for(method)
  #   { user: attributes }
  # end

  # ActiveEvent's realm method override
  #
  # def realm
  #   return project_group if project_group.admin == self
  #   project
  # end
end
```

You may override `payload_for(method)` and `realm` for more complex use cases.


## Contributing to active_event

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2014 Douglas Camata. See LICENSE.txt for
further details.

