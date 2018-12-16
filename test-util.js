const fs = require('fs')
const _exec = require('child_process').exec
const {performance} = require('perf_hooks');

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
/* Go 1.11 */
exports[go] = makeTestCompiled({
    compiler: dirpath =>
        exec(`go build  -o ${dirpath}/bin/main-${go} ${dirpath}/main.${go}`),

    runner: dirpath => exec(`cat ${dirpath}/${input_file} | ${dirpath}/bin/main-${go}`),
});

/* C++ 17 */
exports[cpp] = makeTestCompiled({
    compiler: dirpath => 
        exec(`g++ -std=c++17 -O3 ${dirpath}/main.${cpp} -o ${dirpath}/bin/main-${cpp}`),

    runner: dirpath => exec(`cat ${dirpath}/${input_file} | ${dirpath}/main-${cpp}`),
})

/* Rust */
exports[rust] = makeTestCompiled({
    compiler: dirpath => 
        exec(`\
cargo build\
    --manifest-path ${dirpath}/main.${rust}/Cargo.toml\
    --release\
    --quiet`),

    runner: async dirpath => {
        let output = await exec(`\
cat ${dirpath}/input |\
    ${dirpath}/main.${rust}/target/release/advent_of_code*`);

        await exec(`cargo clean --manifest-path ${dirpath}/main.${rust}/Cargo.toml`)
        return output
    }
})

function makeTestCompiled({compiler, runner}) {
    const runnerTest = makeTest(runner);

    return async (t, dirpath) => {
        const t0 = performance.now();
        try {
            await compiler(dirpath)
        } catch (e) {
            t.fail(e)
        }
        const t1 = performance.now();
        await runnerTest(t, dirpath);
        t.log(`Compiler: ${(t1 - t0).toPrecision(6)}ms`)
    }
}

function makeTest(runner) {
    return async (t, dirpath) => {
        try { 
            var expected = await readFile(`${dirpath}/${output_file}`)
            expected = expected.split('\n').filter(expected => expected)
        } catch (e) { 
            t.fail(e) 
        }

        const t0 = performance.now();
        try {
            var output = await runner(dirpath)
            output = output.split('\n').filter(output => output)
        } catch (e) {
            t.fail(e)
        }
        const t1 = performance.now();

        t.not(output.length, 0)
        t.true(output.length <= expected.length)

        for (let i = 0; i < output.length; ++i) {
            t.is(output[i], expected[i])
            t.log(`${i+1}: ${output[i]} ${output[i] === expected[i]? '===' : '!=='} ${expected[i]}`)
        }
        t.log(`Runner  : ${(t1 - t0).toPrecision(6)}ms`)
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
