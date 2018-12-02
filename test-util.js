const test = require('ava')
const fs = require('fs')
const _exec = require('child_process').exec;

exports.testGo = dirpath => {
    test(`main.go`, async t => {

        let output = await readFile(dirpath+"/output")
        let input = await readFile(dirpath+"/input")

        input = input.split('\n').join(' ')

        let result = await exec(`go run ${dirpath}/main.go ${input}`)
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

        await exec(`g++ -std=c++17 ${dirpath}/main.cpp -o ${dirpath}/main`)
        let result = await exec(`${dirpath}/main ${input}`, {silent: true})
        await exec(`rm ${dirpath}/main`)

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

        let result = await exec(`bash  ${dirpath}/main.bash ${input}`);

        if (result !== output) {
            t.fail(`${result} !== \n${output}`)
        }
        t.pass()

    });
}

const exec = commands => {
    return new Promise(resolve => {
        _exec(commands, (err, stdout) => {
            resolve(stdout)
        });
    })
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
