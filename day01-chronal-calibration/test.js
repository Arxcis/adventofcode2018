import test from 'ava'
import {
    testGo,
    testCpp,
    testBash,
    testRust,
} from '../test-util'

const dirpath = __dirname
test('main.go', async t => await testGo(t, dirpath))
test('main.cpp', async t => await testCpp(t, dirpath))
test('main.bash', async t => await testBash(t, dirpath))
//test('main.rs', async t => await testRust(t, dirpath))
