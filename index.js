const { Main } = require('./main.js').Elm;


const getModel = program => () => new Promise((resolve, reject) => {
  program.ports.outgoing.subscribe(m => (
    m.resolve ? resolve(m.value) : reject(new TypeError(m.error))
  ));
  program.ports.getModel.send();
});


const getKey = program => key => new Promise((resolve, reject) => {
  program.ports.outgoing.subscribe(m => (
    m.resolve ? resolve(m.value) : reject(new TypeError(m.error))
  ));
  program.ports.getKey.send(key);
});


const updateKey = program => (key, f, ...args) => new Promise((resolve, reject) => {
  program.ports.outgoing.subscribe(m => (
    m.resolve ? resolve(m.value) : reject(new TypeError(m.error))
  ));
  program.ports.updateKey.send({
    key,
    f,
    args,
  });
});


module.exports = async (initial) => {
  const isObject = (x = null) => {
    if (x === null) {
      return false;
    }

    return (x.constructor === Object);
  };

  const program = await new Promise((resolve, reject) => {
    if (isObject(initial)) {
      resolve(Main.init(initial));
    } else {
      reject(new TypeError('Initial model passed to Elm must be an object.'));
    }
  });

  return {
    getModel: getModel(program),
    getKey: getKey(program),
    updateKey: updateKey(program),
  };
};
