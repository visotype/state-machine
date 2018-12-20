const { Main } = require('./main.js').Elm;

module.exports = (flags) => {
  const program = Main.init({ flags });

  return {
    in: (message) => {
      program.ports.incoming.send(message);
    },
    out: (callback) => {
      program.ports.outgoing.subscribe(message => callback(message));
    },
  };
};
