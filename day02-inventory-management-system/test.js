import test from 'ava'
import {
    testGo,
    testCpp,
    testBash,
    testPython,
    testRust,
} from '../test-util'

const dirpath = __dirname
test('main.py', async t => await testPython(t, dirpath))
test.skip('main.go', async t => await testGo(t, dirpath))
test.skip('main.cpp', async t => await testCpp(t, dirpath))
test.skip('main.bash', async t => await testBash(t, dirpath))
test.skip('main.rs', async t => await testRust(t, dirpath))
