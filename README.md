# visotype/state-machine [![Build Status](https://travis-ci.com/visotype/state-machine.svg?branch=master)](https://travis-ci.com/visotype/state-machine)

**Use an Elm program as a state machine for a JS/Node application (experimental)**


## Concept: A multi-language implementation of the Elm architecture

The [Elm architecture](https://guide.elm-lang.org/architecture/)
is composed of a **model** (a
[statically typed](https://en.wikipedia.org/wiki/Type_system#Static_type_checking)
data structure), an **update** (a function that handles updates the model's
values), and a **view** (a template that renders HTML with the current model
values as inputs).

*visotype/state-machine* is a package for Node (and web application bundlers)
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

```
const { initialize, updateKey } = require('state-machine');

(async () => {
  try {
    const model0 = {
      a: 1,
      b: [2, 3],
      c: { x: 'hello', y: 'world' },
    };

    const machine = await initialize(model0);

    const model1 = await updateKey(machine, 'a', '(+)', 1);
    const model2 = await updateKey(machine, 'b', 'Array.push.int', 4);
    const model3 = await updateKey(machine, 'c', 'Dict.union', { y: 'universe' });

    console.log([model0, model1, model2, model3]);
  } catch (error) {
    console.log(error.message);
  }
})();

```

## API

### initialize(model)

Returns a promise for a state machine. The actual return value is an object that
provides an interface to a compiled Elm program via message-passing functions.

**model**

*Type: object*

The state machine's initial model. The initial model must contain all of the
keys that your application will use. Each key can have a different JavaScript
value type, but a `number` must remain a `number`, an `array` must remain an
`array`, and so on.

### getModel(machine)

Returns a promise for the state machine's current model.

**machine**

*Type: object(function)*

A state machine that has been initialized with a model.

### getKey(machine, key)

Returns a promise for the value of a key the state machine's current model.

**machine**

*Type: object(function)*

A state machine that has been initialized with a model.

**key**

*Type: string*

A key in the state machine's model.

### updateKey(program, key, f, ...args)

Returns a promise for the state machine's updated model.

**machine**

*Type: object(function)*

A state machine that has been initialized with a model.

**key**

*Type: string*

A key in the state machine's model.

**f**

*Type: string*

The name of an Elm function to apply to the value at the selected key. The
module name should be included, as in `'String.length'` or `'List.append'`, but
may be omitted for functions in the Basics module like `'negate'` or `'round'`.
Operators should be enclosed in parentheses like `'(+)'` or `'(::)'`. Only
functions that return the same type as the selected key are allowed. Some
functions are only allowed when an extension is provided to specify expected
types, as in `'always.string'` or `'Array.push.int'`. See below for a full list
of allowed functions.

**args**

Arguments to *f*. Types must correspond to the Elm function's type signature.
The selected key's value is appended as the last (rightmost) argument. Will
return a rejected promise if there are too many or too few arguments or type
decoding fails.


## Allowed function names

- `'(+)'` or `'Basics.(+)'`
- `'(-)'` or `'Basics.(-)'`
- `'(*)'` or `'Basics.(*)'`
- `'(/)'` or `'Basics.(/)'`
- `'(//)'` or `'Basics.(//)'`
- `'(^)'` or `'Basics.(^)'`
- `'round'` or `'Basics.round'`
- `'floor'` or `'Basics.floor'`
- `'ceiling'` or `'Basics.ceiling'`
- `'truncate'` or `'Basics.truncate'`
- `'not'` or `'Basics.not'`
- `'(&&)'` or `'Basics.(&&)'`
- `'(||)'` or `'Basics.(||)'`
- `'xor'` or `'Basics.(xor)'`
- `'modby'` or `'Basics.modby'`
- `'remainderBy'` or `'Basics.remainderBy'`
- `'negate'` or `'Basics.negate'`
- `'abs'` or `'Basics.abs'`
- `'clamp'` or `'Basics.clamp'`
- `'sqrt'` or `'Basics.sqrt'`
- `'logBase'` or `'Basics.logBase'`
- `'degrees'` or `'Basics.degrees'`
- `'radians'` or `'Basics.radians'`
- `'turns'` or `'Basics.turns'`
- `'cos'` or `'Basics.cos'`
- `'sin'` or `'Basics.sin'`
- `'tan'` or `'Basics.tan'`
- `'acos'` or `'Basics.acos'`
- `'asin'` or `'Basics.sin'`
- `'atan'` or `'Basics.atan'`
- `'atan2'` or `'Basics.atan2'`
- `'identity'` or `'Basics.identity'`
- `'always.string'` or `'Basics.always.string'`
- `'always.char'` or `'Basics.always.char'`
- `'always.int'` or `'Basics.always.int'`
- `'always.float'` or `'Basics.always.float'`
- `'always.list'` or `'Basics.always.list'`
- `'always.array'` or `'Basics.always.array'`
- `'always.dict'` or `'Basics.always.dict'`
- `'Array.set.string'`
- `'Array.set.char'`
- `'Array.set.int'`
- `'Array.set.float'`
- `'Array.push.string'`
- `'Array.push.char'`
- `'Array.push.int'`
- `'Array.push.float'`
- `'Array.append.string'`
- `'Array.append.char'`
- `'Array.append.int'`
- `'Array.append.float'`
- `'Array.slice'`
- `'Bitwise.and'`
- `'Bitwise.or'`
- `'Bitwise.xor'`
- `'Bitwise.complement'`
- `'Bitwise.shiftLeftBy'`
- `'Bitwise.shiftRightBy'`
- `'Bitwise.shiftRightZfBy'`
- `'Char.toUpper'`
- `'Char.toLower'`
- `'Char.toLocaleUpper'`
- `'Char.toLocaleLower'`
- `'Dict.insert'`
- `'Dict.remove'`
- `'Dict.union'`
- `'Dict.intersect'`
- `'Dict.diff'`
- `'(::)'` or `'List.(::)'`
- `'List.reverse'`
- `'List.append'`
- `'List.intersperse'`
- `'List.tail'`
- `'List.take'`
- `'List.drop'`
- `'Set.insert.string'`
- `'Set.insert.char'`
- `'Set.insert.int'`
- `'Set.insert.float'`
- `'Set.remove.string'`
- `'Set.remove.char'`
- `'Set.remove.int'`
- `'Set.remove.float'`
- `'Set.union.string'`
- `'Set.union.char'`
- `'Set.union.int'`
- `'Set.union.float'`
- `'Set.intersect.string'`
- `'Set.intersect.char'`
- `'Set.intersect.int'`
- `'Set.intersect.float'`
- `'Set.diff.string'`
- `'Set.diff.char'`
- `'Set.diff.int'`
- `'Set.diff.float'`
- `'String.reverse'`
- `'String.repeat'`
- `'String.replace'`
- `'String.append'`
- `'String.slice'`
- `'String.left'`
- `'String.right'`
- `'String.dropLeft'`
- `'String.dropRight'`
- `'String.cons'`
- `'String.toUpper'`
- `'String.toLower'`
- `'String.pad'`
- `'String.padLeft'`
- `'String.padRight'`
- `'String.trim'`
- `'String.trimLeft'`
- `'String.trimRight'`
