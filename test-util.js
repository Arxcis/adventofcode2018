const fs = require('fs')
const _exec = require('child_process').exec

const inputFile = 'input'
const outputFile = 'output'
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
    main_bash
]

//
// Interpreted languages
//
/* Go 1.11 */
exports[main_go] = makeTest(dirpath => exec(`cat ${dirpath}/${inputFile} | go run ${dirpath}/${main_go}`))

/* Bash 4.4 */
exports[main_bash] = makeTest(dirpath => exec(`cat ${dirpath}/${inputFile} | ${dirpath}/${main_bash}`))

/* Python 3.6 */
exports[main_py] = makeTest(dirpath => exec(`cat ${dirpath}/${inputFile} | python3 ${dirpath}/${main_py}`))

//
// Compiled languages
//
/* C++ 17 */
exports[main_cpp] = makeTest(async dirpath => {
    const target = 'main-cpp'

    await exec(`g++ -std=c++17 ${dirpath}/${main_cpp} -o ${dirpath}/${target}`)
    let output = await exec(`cat ${dirpath}/${inputFile} | ${dirpath}/${target}`)
    await exec(`rm ${dirpath}/${target}`)

    return output;
})

/* Rust */
exports[main_rs] = makeTest(async dirpath => {
    const target = 'main-rs'

    await exec(`rustc ${dirpath}/${main_rs} -o ${dirpath}/${target} -C debuginfo=0 -C opt-level=3`);
    let output = await exec(`cat ${dirpath}/${inputFile} | ${dirpath}/${target}`)
    await exec(`rm ${dirpath}/${target}`)

    return output
})

function makeTest(producer) {
    return async (t, dirpath) => {
        try { 
            var expected = await readFile(`${dirpath}/${outputFile}`) 
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
