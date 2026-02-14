const fs = require('fs');
const os = require('os');
const interfaces = os.networkInterfaces();
const addresses = [];
for (const k in interfaces) {
    for (const k2 in interfaces[k]) {
        const address = interfaces[k][k2];
        if (address.family === 'IPv4' && !address.internal) {
            addresses.push({ interface: k, address: address.address });
        }
    }
}
fs.writeFileSync('current_ip.txt', JSON.stringify(addresses, null, 2));
console.log('IP written to current_ip.txt');
