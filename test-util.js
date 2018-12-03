const fs = require('fs')
const _exec = require('child_process').exec

//
// Interpreted languages
//
/* Go 1.11 */
exports['main.go'] = makeTest(dirpath => exec(`go run ${dirpath}/main.go $(cat ${dirpath}/input)`))

/* Bash 4.4 */
exports['main.bash'] = makeTest(dirpath => exec(`bash ${dirpath}/main.bash $(cat ${dirpath}/input)`))

/* Python 3.6 */
exports['main.py'] = makeTest(dirpath => exec(`python3 ${dirpath}/main.py $(cat ${dirpath}/input)`))

//
// Compiled languages
//
/* C++ 17 */
exports['main.cpp'] = makeTest(async dirpath => {

    await exec(`g++ -std=c++17 ${dirpath}/main.cpp -o ${dirpath}/main-cpp`)
    let output = await exec(`${dirpath}/main-cpp $(cat ${dirpath}/input)`)

    await exec(`rm ${dirpath}/main-cpp`)
    return output;
})

/* Rust */
exports['main.rs'] = makeTest(async dirpath => {

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
