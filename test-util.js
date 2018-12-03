const fs = require('fs')
const _exec = require('child_process').exec

const main_go = 'main.go'
const main_bash = 'main.bash'
const main_py = 'main.py'
const main_cpp = 'main.cpp'
const main_rs = 'main.rs'

exports.enabledFilenames = [
    main_go,
    main_py,
    main_cpp,
    main_rs,
]

//
// Interpreted languages
//
/* Go 1.11 */
exports[main_go] = makeTest(dirpath => exec(`cat ${dirpath}/input | go run ${dirpath}/main.go`))

/* Bash 4.4 */
exports[main_bash] = makeTest(dirpath => exec(`cat ${dirpath}/input | ${dirpath}/main.bash`))

/* Python 3.6 */
exports[main_py] = makeTest(dirpath => exec(`cat ${dirpath}/input | python3 ${dirpath}/main.py`))

//
// Compiled languages
//
/* C++ 17 */
exports[main_cpp] = makeTest(async dirpath => {

    await exec(`g++ -std=c++17 ${dirpath}/main.cpp -o ${dirpath}/main-cpp`)
    let output = await exec(`cat ${dirpath}/input | ${dirpath}/main-cpp`)

    await exec(`rm ${dirpath}/main-cpp`)
    return output;
})

/* Rust */
exports[main_rs] = makeTest(async dirpath => {

    await exec(`rustc ${dirpath}/main.rs -o ${dirpath}/main-rs -C debuginfo=0 -C opt-level=3`);
    let output = await exec(`cat ${dirpath}/input | ${dirpath}/main-rs`)
    await exec(`rm ${dirpath}/main-rs`)

    return output
})

function makeTest(producer) {
    return async (t, dirpath) => {
        try { 
            var expected = await readFile(`${dirpath}/output`) 
        } catch (e) { 
            t.fail(e) 
        }
        let output = await producer(dirpath)
        t.is(output, expected)
    }
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
