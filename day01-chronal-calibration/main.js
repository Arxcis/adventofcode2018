const fs = require('fs')
const stdin = fs.readFileSync(0)
const lines = stdin.toString().split('\n')

//
// Start puzzle:
//

const result = lines.reduce((prev, current) => prev + Number(current), 0)

//Return result
console.log(result)