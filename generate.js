/**
 * Generate test-files, one for each day:
 *      dat01/test.js, day02/test.js
 */
const fs = require("fs")
const {enabledLanguages} = require("./test-util.js")


let files = fs.readdirSync(".", { withFileTypes: true })
let dayDirs = files.filter(file => file.isDirectory())
                   .filter(dir => /^day/.test(dir.name))


dayDirs.forEach(dir => {
    let abspath = `${__dirname}/${dir.name}`
    let dayFiles = fs.readdirSync(abspath, { withFileTypes: true })

    let testableFiles = dayFiles.filter(file =>
        enabledLanguages.some(language => file.name === `main.${language}`))

    // .. If no testable file for a given day, dont generate tests
    if (testableFiles.length === 0) {
        return;
    }

    let testFile = `\
import test from 'ava'
import testUtil from '../test-util'
const dirpath = __dirname

${testableFiles.reduce((str, file) => {
    const language = file.name.split('.')[1];
    str += `test('${language}', async t => await testUtil['${language}'](t, dirpath))\n`
    return str
}, "")}`

    fs.writeFile(`${abspath}/test.js`, testFile, () =>
        console.log(`Generated ${dir.name}/test.js`))

    fs.mkdir(`${abspath}/bin`, () => console.log(`Generated ${dir.name}/bin/`));
})