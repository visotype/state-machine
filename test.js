import test from 'ava';
import {
  initialize,
  getModel,
  getKey,
  updateKey,
} from './index';


test('await chain produces serial updates', async (t) => {
  const model0 = { a: 1, b: [2, 3], c: { x: 'hello', y: 'world' } };
  const machine = await initialize(model0);

  const model1 = await getModel(machine);
  const a1 = await getKey(machine, 'a');

  const model2 = await updateKey(machine, 'a', '(+)', 1);
  const a2 = await getKey(machine, 'a');

  const model3 = await updateKey(machine, 'a', '(+)', 1);
  const a3 = await getKey(machine, 'a');

  const model4 = await updateKey(machine, 'c', 'Dict.union', { y: 'universe' });
  const a4 = await getKey(machine, 'c');

  await updateKey(machine, 'a', 'always.int', -1);
  const a5 = await getKey(machine, 'a');


  t.deepEqual(model1, model0);
  t.is(a1, 1);

  t.deepEqual(model2, Object.assign(model0, { a: 2 }));
  t.is(a2, 2);

  t.deepEqual(model3, Object.assign(model0, { a: 3 }));
  t.is(a3, 3);

  t.deepEqual(model4, { a: 3, b: [2, 3], c: { x: 'hello', y: 'universe' } });
  t.is(a4.y, 'universe');

  t.is(a5, -1);
});

test('only type-preserving functions allowed', async (t) => {
  const model0 = { a: 'hello' };
  const machine = await initialize(model0);

  await t.throwsAsync(
    updateKey(machine, 'a', 'always', 1),
    { instanceOf: TypeError },
  );

  await t.throwsAsync(
    updateKey(machine, 'a', 'String.length'),
    { instanceOf: TypeError },
  );
});
