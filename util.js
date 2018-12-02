const fs = require('fs')
const shell = require('shelljs')

const readInput = (dirpath) => {
    return new Promise((resolve, reject) => {
        fs.readFile(dirpath + "/input", function (err, data) {
            if (err) {
                reject(err)
            }
            resolve(data.toString())
        })
    })
}

const readOutput = (dirpath) => {
    return new Promise((resolve, reject) => {
        fs.readFile(dirpath + "/output", function (err, data) {
            if (err) {
                reject(err)
            }
            resolve(data.toString())
        })
    })
}

exports.testGo = async (t, dirpath) => {
    let output = await readOutput(dirpath)
    let input = await readInput(dirpath)
    
    input = input.split('\n').join(' ')

    let result = shell.exec(`go run ${dirpath}/main.go ${input}`, {silent: true}).stdout
    if (result !== output) {
        t.fail(`${result} !== \n${output}`)
    }
    t.pass()
}

exports.testCpp = async (t, dirpath) => {
    let output = await readOutput(dirpath)
    let input = await readInput(dirpath)

    input = input.split('\n').join(' ')

    let result = shell.exec(
        `clang++ -std=c++17 ${dirpath}/main.cpp -o ${dirpath}/main && ${dirpath}/main ${input}`, {silent: true}).stdout

    if (result !== output) {
        t.fail(`${result} !== \n${output}`)
    }
    t.pass()
}

exports.testBash = async (t, dirpath) => {
    let output = await readOutput(dirpath)
    let input = await readInput(dirpath)

    input = input.split('\n').join(' ')

    let result = shell.exec(`bash  ${dirpath}/main.bash ${input}`, {silent: true}).stdout
    if (result !== output) {
        t.fail(`${result} !== \n${output}`)
    }
    t.pass()
}
