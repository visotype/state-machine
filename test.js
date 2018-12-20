import test from 'ava';
import run from './index';

test('this', (t) => {
  const program = run({ x: 1 });

  t.truthy(program);
});
