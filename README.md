# Learn Ruby... Now
## With the [Neo](http://www.neo.com) Ruby Koans online
###[http://koans.heroku.com](http://koans.heroku.com)

The Koans walk you along the path to enlightenment in order to learn Ruby. The goal is to learn the Ruby language, syntax, structure, and some common functions and libraries. We also teach you culture. Testing is not just something we pay lip service to, but something we live. It is essential in your quest to learn and do great things in the language.

Use the library to begin learning ruby from the comfort of your favorite browser without
having to install ruby, git or fight any of the other various platform specific issues
that keep you from taking that all important first step into a larger world.

With the Ruby Koans Online, you can dip your big toe into a larger world no matter
where you are or what you're doing. So what are you waiting for? Try the Ruby Koans
Online now and take your first step into the wonderful world of Ruby.

## Development Setup

### Ruby Dependencies

The koans currently run on ree 1.8.7. Ruby gem dependencies are handled by [bundler](http://gembulder.com). To install all the necessary gems, run `bundle install`.

### Node.js Dependencies

Dependecies are handled by [npm](http://npmjs.org/). Ruby Koans Online is tested using [zombie.js](http://zombie.labnotes.org/). To install all the necessary packages, run `npm install`.

### Development

To start the development server, run `rackup` and point your browser to `localhost:9292`

Alternatively, you could use `rerun`. This reloads the app for you when changes are detected.

`rerun -p "**.*.{rb,ru,haml,css,js,yml}" rackup`

#### Running the tests:

1. Start the app using `rackup`. Ensure it's running on port `9292` (the default).
2. Run `node suite.js`.

## Contributing

Fork the project, make your fix, add some tests, and send a pull request!
