![](https://ga-dash.s3.amazonaws.com/production/assets/logo-9f88ae6c9c3871690e33280fcf557f33.png)

#Rails: Error-Handling & Validations

### Why is this important?
<!-- framing the "why" in big-picture/real world examples -->
*This workshop is important because:*

Error-handling is a critical part of web development. One one hand developers need to ensure their applications validate input and raise errors appropriately. On the other hand it is also important design a good user experience for when these errors occur.

### What are the objectives?
<!-- specific/measurable goal for students to achieve -->
*After this workshop, developers will be able to:*

- Use built-in ActiveRecord validation methods to validate database entries.
- Display errors in the view using Rails `flash` messages.
- Set breakpoints to check your assumptions

### Where should we be now?
<!-- call out the skills that are prerequisites -->
*Before this workshop, developers should already be able to:*

- Construct a basic Rails application

##Error Handling

**The best error-handling strategy is a combination of both [client-side](https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Forms/Data_form_validation) and server-side validations.**

Client-side validations ensure a good *user experience* by providing real-time, inline feedback on the user input. Server-side validations are **essential** for maintaining *database integrity*, especially if the client-side validations are ever compromised or purposely circumvented.

Today we'll be focusing on server-side validations in Rails, using [Active Record Validations](http://guides.rubyonrails.org/active_record_validations.html).

##Airplane App

For the purposes of this workshop there is a Rails app, `airplane-app` inside the repo that demonstrates the below examples.

The application was generated with: `rails new airplane-app -T -B -d postgresql` in order to prevent Rails from automatically creating tests (`-T`), prevent it from automatically bundling (`-B`), and set the database postgres (`-d postgresql`).

>Be sure to `bundle`, `rake db:create db:migrate`, and have postgres running before launching the application.

## Model Validations

Validations provide security against invalid or harmful data entering into the database. ActiveRecord provides a [convenient and easy set of built-in methods](http://guides.rubyonrails.org/active_record_validations.html) for validating model attributes, as well as the ability to define custom validator methods. An example of a built-in validation:

**app/models/airplane.rb**

```ruby
class Airplane < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true, length: {minimum: 6}
end
```

>Here, the model is told to validate itself before saving to the database. The `validates` method takes the model as it's first argument and configuration options as the remaining arguments.

In `rails console`, if you try adding a new airplane to the database where a name is

* not present
* a duplicate
* fewer than 6 characters

you'll get an error causing a `ROLLBACK`. Try, `Airplane.create(name: "747")`, which is a name of only three characters and see what happens.

What if you call `Airplane.create!(name: "747")`? What's the difference?

Alternatively, we can check any piece of data we are about to save with the `.valid?` method. So, instead if immediately calling`.create`. In that case, we can create a `.new` airplane instance in memory (without saving it to the database), then asking if it's `.valid?` before calling `.save`.

```bash
> airplane = Airplane.new(name: "747")
=> #<Airplane id: nil, name: "747", description: nil, created_at: nil, updated_at: nil>
> airplane.valid?
=> false
```

The [`.valid?`](http://guides.rubyonrails.org/active_record_validations.html#valid-questionmark-and-invalid-questionmark) method returns `true` if the new record passes the model validations and `false` if it fails any validations.

Moreover, we can call [`.errors.full_messages`](http://guides.rubyonrails.org/active_record_validations.html#errors-add) to returns an array of user-friendly error messages, which is very useful and will be helpful for our user experience later.

```bash
> airplane.errors.full_messages
=> ["Name is too short (minimum is 6 characters)"]
```

Let's look at how we can display the error messages to the user so they know what went wrong if their input doesn't pass our validations.

###Challenge: Duplicates

Get the `airplane.errors.full_messages` to return `["Name has already been taken"]`

## Handling Errors in Controllers

You `airplanes#create` we' `.new` and `.save` to better handle the error.

```ruby
#
# app/controllers/airplanes_controller.rb
#

class AirplanesController < ApplicationController

  def create
    airplane = airplane.new(airplane_params)
    if airplane.save
      redirect_to airplane_path(airplane)
    else
      redirect_to new_airplane_path
    end  
  end
  
  private 
  
  def airplane_params
    params.require(:airplane).permit(:name, :description)
  end
  
end
```

After the refactor, if a user tries to add an invalid airplane, they get redirected to `airplanes_new_path` (the form to create a new airplane) so they can try again. The last piece of the error-handling user flow is to  display flash messages to show these errors to the user.

## Error Handling in Views: Flash Messages

Rails comes with [built-in flash messages](http://api.rubyonrails.org/classes/ActionDispatch/Flash.html)! If you want to send a flash message, you need to touch the controller and view.

The `flash` hash is a hash of key/value pairs. We'll set a key-value pair on the `flash` hash in the controller, and render the message from the `flash` hash in the view. The most common keys for `flash` are `:notice` for general information and/or success messages and `:error` for error messages.

We can implement `flash[:error]` in our `airplanes#create` controller method like this:

```ruby
#
# app/controllers/airplanes_controller.rb
#

class AirplanesController < ApplicationController

  def create
    airplane = airplane.new(airplane_params)
    if airplane.save
      redirect_to airplane_path(airplane)
    else
      # save error messages to flash hash, with :error key
      flash[:error] = airplane.errors.full_messages.join(", ")
      redirect_to new_airplane_path
    end  
  end
  
  private 
  
  def airplane_params
    params.require(:airplane).permit(:name, :description)
  end

end
```

Just one last step! We've sent `flash` to the view, but we haven't rendered it yet. Let's do that in our `application.html.erb` layout, so we can render flash messages in *every* view:

```html
<!-- app/views/layouts/application.html.erb -->

<!DOCTYPE html>
<html>
<head>
  ...
</head>
<body>
  <!-- display flash messages above the yield block -->
  <% flash.each do |name, msg| %>
    <div><%= msg %></div>
  <% end %>

  <%= yield %>

</body>
</html>
```

## Error Pages

<img src="github-500.png" alt="github error status 500 page" height=300>

>_GitHub's Error Status 500 Page_

Sometimes, things go wrong.  Rails has default error pages set up for 404, 422, and 500 errors, inside the `app/public` directory.  

## Challenges

Now that you've seen how to implement validations, propagate the Active Record errors from your database models to the controller, and then pass the errors into the view, it's your turn!

You're working on the structure of an app for a vet clinic to track owners and pets!  See [this repo](https://github.com/sf-wdi-27-28/rails_validations_errors) for the starter code and challenges.

## Resources

* [Active Record Validation Docs](http://guides.rubyonrails.org/active_record_validations.html)

