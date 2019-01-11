import test from 'ava';
import {
  initialize,
  getModel,
  getKey,
  updateKey,
} from './index';


test('await chain', async (t) => {
  const initial = { a: 1, b: [2, 3], c: { x: 'hello', y: 'world' } };
  const program = await initialize(initial);

  const model0 = await getModel(program);
  const a0 = await getKey(program, 'a');

  await updateKey(program, 'a', '(+)', 1);
  const a1 = await getKey(program, 'a');
  const model1 = await getModel(program);

  await updateKey(program, 'a', '(+)', 1);
  const a2 = await getKey(program, 'a');
  const model2 = await getModel(program);

  await updateKey(program, 'c', 'Dict.union', { y: 'universe' });
  const model3 = await getModel(program);


  t.deepEqual(model0, initial);
  t.is(a0, 1);
  t.is(a1, 2);
  t.deepEqual(model1, Object.assign(initial, { a: 2 }));
  t.is(a2, 3);
  t.deepEqual(model2, Object.assign(initial, { a: 3 }));
  t.deepEqual(model3, { a: 3, b: [2, 3], c: { x: 'hello', y: 'universe' } });
});
