const _exec = require('child_process').exec
const { enabledLanguages } = require("./test-util.js")

const main = async () => {
    let diff = await exec('git diff --name-only master\n').catch(err =>
        {process.exitCode = 1})
    let lines = diff.split('\n').filter(line => line)

    lines.forEach(async line => {

        let match = enabledLanguages.some(language =>
            line.match(`(day\\d\\d[^\\/]+\\/)main.(${language})`))

        if (!match) {
            return;
        }
        let [_, day, language] = match
        await exec(`npm run ${language} ${day}`).catch(err =>
            {process.exitCode = 1})
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

main().catch(err => {process.exitCode = 1})