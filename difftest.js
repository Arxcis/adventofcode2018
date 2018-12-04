const _exec = require('child_process').exec

const main = async () => {

    console.log("\n--- Diffing branch with master ---\n")
    console.log('git diff --name-only master')

    let diff = await exec('git diff --name-only master\n')
    console.log(diff)
    let lines = diff.split('\n').filter(line => line)

    lines.forEach(async line => {
        let [_, day, language] = line.match(/(day\d\d[^\/]*\/)main.([a-z]*)/)
        console.log(`npm run ${language} ${day}`)
        console.log(await exec(`npm run ${language} ${day}`))
    })
}

const exec = commands => {
    return new Promise(resolve => {
        _exec(commands, (err, stdout) => {
            resolve(stdout)
        });
    })
}

main()