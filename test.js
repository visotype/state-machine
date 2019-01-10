import test from 'ava';
import program from './index';


test('getModel', async (t) => {
  const initial = { a: 1, b: [2, 3], c: { x: 'hello', y: 'world' } };
  const { getModel } = await program(initial);
  const model = await getModel();
  console.log(model);
  console.log(initial);

  t.deepEqual(model, initial);
});
