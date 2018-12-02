const fs = require("fs")

let files = fs.readdirSync(".", { withFileTypes: true })
let dayDirs = files.filter(file => file.isDirectory())
                      .filter(dir => /^day/.test(dir.name))


dayDirs.forEach(folder => {
    let dayFiles = fs.readdirSync(`${__dirname}/${folder.name}`, { withFileTypes: true })
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
    fs.writeFile(`${__dirname}/${folder.name}/test.js`, testFile, () => console.log(`Generated ${folder.name}/test.js`))
})