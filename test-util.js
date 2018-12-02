const fs = require('fs')
const _exec = require('child_process').exec;


exports.testGo = async (t, dirpath) => {

    let input,expectedOutput
    try {
        expectedOutput = await readFile(dirpath+"/output")
        input = await readFile(dirpath+"/input")
                      .then(input => input.split('\n').join(' '))
    } catch (e) {t.fail(e)}

    let output = await exec(`go run ${dirpath}/main.go ${input}`)
    
    t.is(output, expectedOutput)
}

exports.testCpp = async (t, dirpath) => {

    let input,expectedOutput
    try {
        expectedOutput = await readFile(dirpath+"/output")
        input = await readFile(dirpath+"/input")
                      .then(input => input.split('\n').join(' '))
    } catch (e) {t.fail(e)}

    await exec(`g++ -std=c++17 ${dirpath}/main.cpp -o ${dirpath}/main`)
    let output = await exec(`${dirpath}/main ${input}`, {silent: true})
    await exec(`rm ${dirpath}/main`)

    t.is(output, expectedOutput)
}

exports.testBash = async (t, dirpath) => {

    let input,expectedOutput
    try {
        expectedOutput = await readFile(dirpath+"/output")
        input = await readFile(dirpath+"/input")
                      .then(input => input.split('\n').join(' '))
    } catch (e) {t.fail(e)}

    let output = await exec(`bash  ${dirpath}/main.bash ${input}`);
    
    t.is(output, expectedOutput)
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
            if (data) {
                resolve(data.toString())
            }
            reject(err)
        })
    })
}
