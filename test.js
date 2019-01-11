import test from 'ava';
import {
  initialize,
  getModel,
  getKey,
  updateKey,
} from './index';


test('await chain produces serial updates', async (t) => {
  const model0 = { a: 1, b: [2, 3], c: { x: 'hello', y: 'world' } };
  const program = await initialize(model0);

  const model1 = await getModel(program);
  const a1 = await getKey(program, 'a');

  const model2 = await updateKey(program, 'a', '(+)', 1);
  const a2 = await getKey(program, 'a');

  const model3 = await updateKey(program, 'a', '(+)', 1);
  const a3 = await getKey(program, 'a');

  const model4 = await updateKey(program, 'c', 'Dict.union', { y: 'universe' });
  const a4 = await getKey(program, 'c');

  await updateKey(program, 'a', 'always.int', -1);
  const a5 = await getKey(program, 'a');


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
  const program = await initialize(model0);

  await t.throwsAsync(
    updateKey(program, 'a', 'always', 1),
    { instanceOf: TypeError },
  );

  await t.throwsAsync(
    updateKey(program, 'a', 'String.length'),
    { instanceOf: TypeError },
  );
});
