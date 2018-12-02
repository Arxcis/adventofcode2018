import {
    testGo,
    testCpp,
    testBash,
} from '../test-util'

const dirpath = __dirname
testGo(dirpath)
testCpp(dirpath)
testBash(dirpath)
