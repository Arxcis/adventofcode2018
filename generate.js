/**
 * Generate test-files, one for each day:
 *      dat01/test.js, day02/test.js
 */
const fs = require("fs")
const {enabledFilenames} = require("./test-util.js")


let files = fs.readdirSync(".", { withFileTypes: true })
let dayDirs = files.filter(file => file.isDirectory())
                   .filter(dir => /^day/.test(dir.name))


dayDirs.forEach(dir => {
    let abspath = `${__dirname}/${dir.name}`
    let dayFiles = fs.readdirSync(abspath, { withFileTypes: true })

    // .. If no testable file for a given day, dont generate tests
    if ((!dayFiles.some(file =>
            enabledFilenames.some(name =>
                name === file.name)))) {
        return;
    }

    let testableFiles = dayFiles.filter(file =>
        enabledFilenames.some(name => name === file.name))

    let testFile = `\
import test from 'ava'
import testUtil from '../test-util'
const dirpath = __dirname

${testableFiles.reduce((str, file) => {
    str += `test('${file.name}', async t => await testUtil['${file.name}'](t, dirpath))\n`
    return str
}, "")}`

    fs.writeFile(`${abspath}/test.js`, testFile, () =>
        console.log(`Generated ${dir.name}/test.js`))
})