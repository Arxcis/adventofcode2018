var fs = require('fs')

var stdin = fs.readFileSync(0)
var lines = stdin.toString().split('\n')

//
// Part 1
//

// Parse claims
let claims = []
lines.forEach(line => {
    if (!line) return

    const [_, id, left, top, width, height] = line.match(/^#(\d+) @ (\d+),(\d+): (\d+)x(\d+)$/)
    claims.push({
        id: parseInt(id), 
        left: parseInt(left), 
        top: parseInt(top), 
        width: parseInt(width), 
        height: parseInt(height)})
})
// Compute height and width of fabric
let fabricWidth = Math.max(...claims.map(claim => claim.left + claim.width + 1))
let fabricHeight = Math.max(...claims.map(claim => claim.top + claim.height + 1))

// Make arrays to fit fabric, set all to zero
let fabric = new Array(fabricHeight)
for (let y = 0; y < fabricHeight; ++y) {
    fabric[y] = new Array(fabricWidth)
    for (let x = 0; x < fabricWidth; ++x) {
        fabric[y][x] = 0
    }
}

// Count how many times squares are covered by claims
for (let c = 0; c < claims.length; ++c) {
    let claim = claims[c]
    for (let y = 0; y < claim.height; ++y) {
        for (let x = 0; x < claim.width; ++x) {
            fabric[claim.top+y][claim.left+x] += 1
        }
    }
}

// Count how many times a square was cover twice or more
let count = 0
for (let y = 0; y < fabricHeight; ++y) {
    for (let x = 0; x < fabricWidth; ++x) {
        if (fabric[y][x] > 1) {
            count += 1
        }
    }
}

console.log(count)


//
// Part 2
//
// Find a claim which is not covered by any other claim
let foundId = 0
for (let c = 0; c < claims.length && !foundId; ++c) {
    let claim = claims[c]
    let exlusiveCount = 0
    for (let y = 0; y < claim.height; ++y) {
        for (let x = 0; x < claim.width; ++x) {
            if (fabric[claim.top+y][claim.left+x] === 1) {
                exlusiveCount += 1
            }
        }
    }

    if (exlusiveCount === claim.height*claim.width) {
        foundId = claim.id
    }
}

console.log(foundId)

