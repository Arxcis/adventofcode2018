const fs = require('fs')
const test = require('ava')
const shell = require('shelljs')

exports.testGo = dirpath => {
    test('main.go', async t => {

        let output = await readFile(dirpath+"/output")
        let input = await readFile(dirpath+"/input")

        input = input.split('\n').join(' ')

        let result = shell.exec(`go run ${dirpath}/main.go ${input}`, {silent: true}).stdout
        if (result !== output) {
            t.fail(`${result} !== \n${output}`)
        }
        t.pass()
    });
}

exports.testCpp = dirpath => {

    test('main.cpp', async t => {

        let output = await readFile(dirpath+"/output")
        let input = await readFile(dirpath+"/input")

        input = input.split('\n').join(' ')

        shell.exec(`g++ -std=c++17 ${dirpath}/main.cpp -o ${dirpath}/main`, {silent: true})
        let result = shell.exec(`${dirpath}/main ${input}`, {silent: true}).stdout
        shell.rm(`${dirpath}/main`)

        if (result !== output) {
            t.fail(`${result} !== \n${output}`)
        }
        t.pass()
    })
}

exports.testBash = dirpath => {

    test('main.bash', async t => {

        let output = await readFile(dirpath+"/output")
        let input = await readFile(dirpath+"/input")

        input = input.split('\n').join(' ')

        let result = shell.exec(`bash  ${dirpath}/main.bash ${input}`, {silent: true}).stdout
        if (result !== output) {
            t.fail(`${result} !== \n${output}`)
        }
        t.pass()

    });
}


const readFile = (dirpath) => {
    return new Promise((resolve, reject) => {
        fs.readFile(dirpath, function (err, data) {
            if (err) {
                reject(err)
            }
            resolve(data.toString())
        })
    })
}
