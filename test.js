import test from 'ava';
import program from './index';


test('getModel', async (t) => {
  const initial = { a: 1, b: [2, 3], c: { x: 'hello', y: 'world' } };
  const { getModel } = program(initial);
  const model = await getModel();

  t.deepEqual(model, initial);
});
