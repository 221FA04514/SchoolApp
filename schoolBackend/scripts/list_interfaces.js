const fs = require('fs');
const os = require('os');
const interfaces = os.networkInterfaces();

let output = 'Available Interfaces:\n';
for (const name in interfaces) {
    output += `Interface: ${name}\n`;
    for (const address of interfaces[name]) {
        output += `  - ${address.family}: ${address.address} (Internal: ${address.internal})\n`;
    }
}

fs.writeFileSync('interfaces.txt', output);
console.log('Written to interfaces.txt');
