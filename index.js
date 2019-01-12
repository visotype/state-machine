const { Main } = require('./main.js').Elm;


const initialize = model => new Promise((resolve, reject) => {
  const isObject = (x = null) => {
    if (x === null) {
      return false;
    }

    return (x.constructor === Object);
  };

  if (isObject(model)) {
    resolve(Main.init({ flags: model }));
  } else {
    reject(new TypeError('Initial model passed to Elm must be an object.'));
  }
});

const getModel = machine => new Promise((resolve, reject) => {
  const callback = (m) => {
    if (m.resolve) {
      machine.ports.outgoing.unsubscribe(callback);
      resolve(m.value);
    } else {
      reject(new TypeError(m.error));
    }
  };

  machine.ports.outgoing.subscribe(callback);
  machine.ports.getModel.send({});
});


const getKey = (machine, key) => new Promise((resolve, reject) => {
  const callback = (m) => {
    if (m.resolve) {
      machine.ports.outgoing.unsubscribe(callback);
      resolve(m.value);
    } else {
      reject(new TypeError(m.error));
    }
  };

  machine.ports.outgoing.subscribe(callback);
  machine.ports.getKey.send({ key });
});


const updateKey = (machine, key, f, ...args) => new Promise((resolve, reject) => {
  const callback = (m) => {
    if (m.resolve) {
      machine.ports.outgoing.unsubscribe(callback);
      resolve(m.value);
    } else {
      reject(new TypeError(m.error));
    }
  };

  machine.ports.outgoing.subscribe(callback);
  machine.ports.updateKey.send({ key, f, args });
});


module.exports = {
  initialize,
  getModel,
  getKey,
  updateKey,
};
