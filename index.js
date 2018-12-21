const { Main } = require('./main.js').Elm;

const isObject = (x = null) => {
  if (x === null) {
    return false;
  }

  return (x.constructor === Object);
};

module.exports = (flags = {}) => {
  if (!isObject(flags)) {
    throw new Error([
      'Initial model passed to Elm must be an object.',
      'Assuming you\'re importing this module as `elmStateMachine`,',
      'instead of `elmStateMachine(0)`, try `elmStateMachine({ value: 0 })``',
    ].join(' '));
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
