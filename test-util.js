const fs = require('fs')
const _exec = require('child_process').exec

const input_file = 'input'
const output_file = 'output'
const target_cpp = 'main-cpp'

const go = 'go';
const bash = 'bash';
const python = 'py';
const cpp = 'cpp';
const rust = 'rs';
const node = 'js';

exports.enabledLanguages = [
    go,
    bash,
    python,
    cpp,
    rust,
    node
]

//
// Interpreted languages
//
/* Go 1.11 */
exports[go] = makeTest(dirpath =>
    exec(`cat ${dirpath}/${input_file} | go run ${dirpath}/main.${go}`))

/* Bash 4.4 */
exports[bash] = makeTest(dirpath =>
    exec(`cat ${dirpath}/${input_file} | bash ${dirpath}/main.${bash}`))

/* Python 3.6 */
exports[python] = makeTest(dirpath =>
    exec(`cat ${dirpath}/${input_file} | python3 ${dirpath}/main.${python}`))

/* Node 11 */
exports[node] = makeTest(dirpath =>
    exec(`cat ${dirpath}/${input_file} | node ${dirpath}/main.${node}`))

//
// Compiled languages
//
/* C++ 17 */
exports[cpp] = makeTest(async dirpath => {

    await exec(`g++ -std=c++17 -O3 ${dirpath}/main.${cpp} -o ${dirpath}/main-${cpp}`)
    let output = await exec(`cat ${dirpath}/${input_file} | ${dirpath}/main-${cpp}`)
    await exec(`rm ${dirpath}/main-${cpp}`)

    return output;
})

/* Rust */
exports[rust] = makeTest(async dirpath => {

    let output = await exec(`\
cat ${dirpath}/input |\
cargo run \
--manifest-path ${dirpath}/main.${rust}/Cargo.toml \
--release \
--quiet`);

    await exec(`cargo clean --manifest-path ${dirpath}/main.${rust}/Cargo.toml`)
    return output
})

function makeTest(producer) {
    return async (t, dirpath) => {
        try { 
            var expected = await readFile(`${dirpath}/${output_file}`)
            expected = expected.split('\n').filter(expected => expected)
        } catch (e) { 
            t.fail(e) 
        }
        try {
            var output = await producer(dirpath)
            output = output.split('\n').filter(output => output)
        } catch (e) {
            t.fail(e)
        }

        t.not(output.length, 0)
        t.true(output.length <= expected.length)

        for (let i = 0; i < output.length; ++i) {
            t.is(output[i], expected[i])
            t.log(`${output[i]} ${output[i] === expected[i]? '===' : '!=='} ${expected[i]} ${i+1} of ${expected.length}`)
        }
        t.pass()
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
