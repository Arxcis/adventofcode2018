import test from 'ava';
import {
    testGo,
    testCpp,
    testBash,
} from '../util'

const dirpath = 'day01-chronal-calibration'
test(`${dirpath}/main.go`, t => testGo(t, dirpath))
test(`${dirpath}/main.cpp`, t => testCpp(t, dirpath))
test(`${dirpath}/main.bash`, t => testBash(t, dirpath))
