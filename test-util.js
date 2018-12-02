const fs = require('fs')
const _exec = require('child_process').exec;


exports.testGo = async (t, dirpath) => {

    try { var expected = await readFile(`${dirpath}/output`) } catch (e) { t.fail(e) }

    let output = await exec(`go run ${dirpath}/main.go $(cat ${dirpath}/input)`)
    
    t.is(output, expected)
}

exports.testCpp = async (t, dirpath) => {

    try { var expected = await readFile(`${dirpath}/output`) } catch (e) { t.fail(e) }

    await exec(`g++ -std=c++17 ${dirpath}/main.cpp -o main-cpp`)
    let output = await exec(`./main-cpp $(cat ${dirpath}/input)`)
    await exec(`rm main-cpp`)

    t.is(output, expected)
}

exports.testBash = async (t, dirpath) => {

    try { var expected = await readFile(`${dirpath}/output`) } catch (e) { t.fail(e) }

    let output = await exec(`bash ${dirpath}/main.bash $(cat ${dirpath}/input)`);
    
    t.is(output, expected)
}

exports.testPython = async (t, dirpath) => {

    try { var expected = await readFile(`${dirpath}/output`) } catch (e) { t.fail(e) }

    let output = await exec(`python3 ${dirpath}/main.py $(cat ${dirpath}/input)`);
    
    t.is(output, expected)
}

exports.testRust = async (t, dirpath) => {

    try { var expected = await readFile(`${dirpath}/output`) } catch (e) { t.fail(e) }

    await exec(`rustc ${dirpath}/main.rs -o main-rs`);
    let output = await exec(`./main-rs  $(cat ${dirpath}/input)`)
    await exec(`rm main-rs`)

    t.is(output, expected)
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
