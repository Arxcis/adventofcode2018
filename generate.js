const fs = require("fs")

let files = fs.readdirSync(".", { withFileTypes: true })
let dayDirs = files.filter(file => file.isDirectory())
                   .filter(dir => /^day/.test(dir.name))


dayDirs.forEach(dir => {
    let abspath = `${__dirname}/${dir.name}`

    let dayFiles = fs.readdirSync(abspath, { withFileTypes: true })
    let mainFiles = dayFiles.filter(file => file.isFile())
                            .filter(file => /^main./.test(file.name))

    let testFile = `\
import test from 'ava'
import testUtil from '../test-util'
const dirpath = __dirname

${mainFiles.reduce((str, main) => {
    str += `test('${main.name}', async t => await testUtil['${main.name}'](t, dirpath))\n`
    return str
}, "")}`

    fs.writeFile(`${abspath}/test.js`, testFile, () => console.log(`Generated ${dir.name}/test.js`))
})