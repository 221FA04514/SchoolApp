const fs = require('fs');
const os = require('os');
const path = require('path');

// 1. Get Local IP
const interfaces = os.networkInterfaces();
let localIp = '127.0.0.1';

// Priority list for interfaces
const preferredInterfaces = ['Wi-Fi', 'Ethernet', 'Wi-Fi 2', 'Ethernet 2'];

// Function to find IP
function findIp() {
    // 1. Try preferred interfaces first
    for (const name of preferredInterfaces) {
        if (interfaces[name]) {
            for (const address of interfaces[name]) {
                if (address.family === 'IPv4' && !address.internal) {
                    return address.address;
                }
            }
        }
    }

    // 2. Fallback to any non-internal IPv4
    for (const name in interfaces) {
        for (const address of interfaces[name]) {
            if (address.family === 'IPv4' && !address.internal) {
                return address.address;
            }
        }
    }
    return '127.0.0.1';
}

localIp = findIp();

console.log(`Detected Local IP: ${localIp}`);

// 2. Paths
const backendIpFile = path.join(__dirname, '..', 'current_ip.txt');
const flutterConstantsFile = path.join(__dirname, '..', '..', 'school_app', 'lib', 'core', 'constants.dart');

// 3. Update backend current_ip.txt
try {
    fs.writeFileSync(backendIpFile, localIp);
    console.log(`Updated ${backendIpFile}`);
} catch (err) {
    console.error(`Error writing to ${backendIpFile}:`, err);
}

// 4. Update Flutter constants.dart
try {
    if (fs.existsSync(flutterConstantsFile)) {
        let content = fs.readFileSync(flutterConstantsFile, 'utf8');
        // Regex to replace http://<old-ip>:5000 with http://<new-ip>:5000
        const newContent = content.replace(/http:\/\/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:5000/, `http://${localIp}:5000`);

        if (content !== newContent) {
            fs.writeFileSync(flutterConstantsFile, newContent);
            console.log(`Updated ${flutterConstantsFile}`);
        } else {
            console.log('constants.dart is already up to date.');
        }
    } else {
        console.error(`File not found: ${flutterConstantsFile}`);
    }
} catch (err) {
    console.error(`Error updating constants.dart:`, err);
}
