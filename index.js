const { Main } = require('./main.js').Elm;

const isObject = (x = null) => {
  if (x === null) {
    return false;
  }

  return (x.constructor === 'object');
};

module.exports = (flags = {}) => {
  if (!isObject(flags)) {
    throw new Error('Initial model passed to Elm must be an object; instead of `require("elm-state-machine")(0)` try `require("elm-state-machine")({ n: 0 })`');
  }

  const program = Main.init({ flags });

  return {
    eval: (f, ...args) => new Promise((resolve) => {
      program.ports.outgoing.subscribe(message => resolve(message));
      program.ports.eval.send({
        f,
        args,
      });
    }),
    partial: (f, ...args) => data => new Promise((resolve) => {
      program.ports.outgoing.subscribe(message => resolve(message));
      program.ports.eval.send({
        f,
        args: [data].concat(args),
      });
    }),
    updateModel: (data, f = 'Dict.union', ...args) => new Promise((resolve) => {
      program.ports.outgoing.subscribe(message => resolve(message));
      program.ports.updateModel.send({
        f,
        args: [data].concat(args),
      });
    }),
    updateKey: (key, f, ...args) => new Promise((resolve) => {
      program.ports.outgoing.subscribe(message => resolve(message));
      program.ports.updateKey.send({
        key,
        f,
        args,
      });
    }),
  };
};
