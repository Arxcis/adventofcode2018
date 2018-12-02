import test from 'ava'
import {
    testGo,
    testCpp,
    testBash,
    testPython,
} from '../test-util'

const dirpath = __dirname
//test('main.go', async t => await testGo(t, dirpath))
//test('main.cpp', async t => await testCpp(t, dirpath))
//test('main.bash', async t => await testBash(t, dirpath))
test('main.py', async t => await testPython(t, dirpath))
