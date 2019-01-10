const { Main } = require('./main.js').Elm;


const getModelFrom = program => () => new Promise((resolve, reject) => {
  program.ports.outgoing.subscribe(m => (
    m.resolve ? resolve(m.value) : reject(new TypeError(m.error))
  ));
  program.ports.getModel.send({});
});


const getKeyFrom = program => key => new Promise((resolve, reject) => {
  program.ports.outgoing.subscribe(m => (
    m.resolve ? resolve(m.value) : reject(new TypeError(m.error))
  ));
  program.ports.getKey.send(key);
});


const updateKeyFrom = program => (key, f, ...args) => new Promise((resolve, reject) => {
  program.ports.outgoing.subscribe(m => (
    m.resolve ? resolve(m.value) : reject(new TypeError(m.error))
  ));
  program.ports.updateKey.send(key, {
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

  const getModel = await getModelFrom(program);
  const getKey = await getKeyFrom(program);
  const updateKey = await updateKeyFrom(program);

  return {
    getModel,
    getKey,
    updateKey,
  };
};
