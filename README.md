# visotype/node-elm-state [![Build Status](https://travis-ci.com/visotype/node-elm-state.svg?branch=master)](https://travis-ci.com/visotype/node-elm-state)

**Use an Elm program as a state container for a JS/Node application (experimental)**

## Why this?

The [Elm architecture](https://guide.elm-lang.org/architecture/)
is composed of a **model** (a
[statically typed](https://en.wikipedia.org/wiki/Type_system#Static_type_checking)
data structure), an **update** (a function that handles updates the model's
values), and a **view** (a template that renders HTML with the current model
values as inputs).

*visotype/node-elm-state* is a package for Node (and web application bundlers)
that lets you store your data model in an Elm program and update its values
through a JS-Elm interop with some built-in type safety features. This approach
gives you at least some of the benefits of Elm in avoiding type errors at run
time, while enabling you
  - to use other templating languages (like [Pug](https://www.npmjs.com/package/pug) or [Handlebars](https://www.npmjs.com/package/handlebars)) for HTML markup
  - to render simple templates without virtual-dom diffing
  - to use JavaScript to implement intended side effects triggered by model updates
  - to interact with your data model through a promise API.

You might be interested in this approach if you prefer the simplicity of the Elm
architecture to component-based architectures like
[React Redux](https://react-redux.js.org/),
but you find it cumbersome to write view templates and handle user inputs in
Elm. You might not like this approach if you think that type-safety guarantees
for inputs to and outputs from your data model are not enough, and you would
prefer that all of your application logic gets checked by the Elm compiler.


## Usage



## API
