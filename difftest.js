const _exec = require('child_process').exec

const main = async () => {
    let diff = await exec('git diff --name-only master\n')
    let lines = diff.split('\n').filter(line => line)

    lines.forEach(async line => {
        let result = line.match(/(day\d\d[^\/]*\/)main.([a-z]*)/)
        if (!result){
            return;
        }
        let [_, day, language] = result
        await exec(`npm run ${language} ${day}`)
    })
}

const exec = commands => {
    return new Promise((resolve, reject) => {
        console.log(commands)
        _exec(commands, (err, stdout) => {
            console.log(stdout)
            if (err) {
                reject(err)
            } else {
                resolve(stdout)
            }
        });
    })
}

main().catch(err => {process.exit(1)})