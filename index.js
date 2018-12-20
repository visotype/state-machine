const { Main } = require('./main.js').Elm;

module.exports = (flags) => {
  const program = Main.init({ flags });
  const elm = {};

  elm.in = (message) => {
    program.ports.incoming.send(message);
  };

  elm.out = (callback) => {
    program.ports.outgoing.subscribe(message => callback(message));
  };

  elm.eval = async ({ data, op = 'identity', args = [] }) => new Promise((resolve) => {
    program.ports.outgoing.subscribe(message => resolve(message));
    program.ports.incoming.send({ data, op, args });
  });

  return elm;
};
