# RabbitRPC

RabbitRPC helps in the rapid development of ruby services and their RPC
invocation over RabbitMQ in a service-oriented architecture.

## Installation

Add this line to your application's Gemfile:

    gem 'rabbit_rpc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rabbit_rpc

## Getting Started

Rabbit-RPC can be broadly divided into two parts. EventMachine servers that
consume messages over RabbitMQ and an RPC invocation interface used for
producing messages.

### Implementing Services(RabbitMQ Consumers)

Services can easily be defined via Rabbit-RPC.

```ruby
class AuthorizationService
  class << self

    def auth(email, pass)
      {
        ok:    true,
        email: email,
        pass:  pass
      }
    end
  end
end
```

Once the services have been implemented and are loaded into loaded into
the global namespace, the service can then establish a connection with
RabbitMQ and start consuming messages.

```ruby
RabbitRPC::Connection.new(QUEUE_NAME, QUEUE_ADDRESS).listen!
```

Methods expected to send a response back to the RPC invocator,
will encode the response message and produce them on a callback queue.

Methods defined with the "one_way" prefix will not send a response back
to the RPC invocator. 

### RPC Invocation

RPC invocations, whether they're for services to communicate with one
another or for the user facing web server(Rails or Sinatra) to
communicate with the various services can be defined on an individual
basis. The reasoning behind this is that each service does not
necessarily need access to all other services and their corresponding
methods

By default, Rabbit-RPC expects a rabbit_rpc.yml file to present in the config
folder of the ruby app.This YAML file contains a definition of the names
of the services(queue names), their corresponding RabbitMQ URLs and
which method calls should exist.

```yml
UserService:
  address: amqp://localhost:5672
  methods:
    User: create, read, delete
    Authorization: auth

EntertainmentService
  address: amqp://localhost:5672
  methods:
    Movie: likes
    Music: likes
```

Rabbit-RPC relies on some conventions for it to work. 
 - The names of the services and their RabbitMQ queue names are the same.
 - A service might be responsible for multiple functionaly. For the YAML
   example above, the UserService is responsible for both the CRUD and
   authentication of users. The service object is they key, and its
   methods are provided by comma serperated values.
 - Unless a method is defined with a "one_way" prefix, the RPC client
   will wait for a a response in a synchronous fashion.

```ruby
  RabbitRPC::Config.initialize!
  RabbitRPC::Client::UserService::Authorization.auth 'username', 'password'
  => {"ok"=>true, "email"=>"username", "password"=>"password"}

  RabbitRPC::Client::UserService::User.one_way_send_mail
  => nil
```

## Example

A sample implementation of a service and RPC invocation can be seen [here.](https://github.com/sohaibbhatti/rabbit_rpc_example)

## Contributing

As with all gems in their infancy. Rabbit-RPC is in a skeletal state. Some
of the code especially related to the Synchronous connection can be
optimized.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
