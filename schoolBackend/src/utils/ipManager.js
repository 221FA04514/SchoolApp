const os = require('os');
const fs = require('fs');
const path = require('path');

function updateFrontendIp() {
  const interfaces = os.networkInterfaces();
  let currentIp = '127.0.0.1';

  // Find the first IPv4 address that's not internal (loopback)
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        currentIp = iface.address;
        // Prioritize Wi-Fi or Ethernet over virtual adapters if possible
        if (name.toLowerCase().includes('wi-fi') || name.toLowerCase().includes('ethernet')) {
          break;
        }
      }
    }
    if (currentIp !== '127.0.0.1' && (name.toLowerCase().includes('wi-fi') || name.toLowerCase().includes('ethernet'))) {
      break;
    }
  }

  const constantsPath = path.join(__dirname, '..', '..', '..', 'school_app', 'lib', 'core', 'constants.dart');
  
  if (fs.existsSync(constantsPath)) {
    try {
      const content = fs.readFileSync(constantsPath, 'utf8');
      const updatedContent = content.replace(
        /static const String baseUrl = "http:\/\/.*:5000";/,
        `static const String baseUrl = "http://${currentIp}:5000";`
      );
      
      if (content !== updatedContent) {
        fs.writeFileSync(constantsPath, updatedContent);
        console.log(`[IP Manager] Updated frontend baseUrl to http://${currentIp}:5000`);
      } else {
        console.log(`[IP Manager] Frontend baseUrl is already up to date: http://${currentIp}:5000`);
      }
    } catch (error) {
      console.error(`[IP Manager] Error updating frontend constants: ${error.message}`);
    }
  } else {
    console.warn(`[IP Manager] Frontend constants file not found at ${constantsPath}`);
  }
  
  return currentIp;
}

module.exports = { updateFrontendIp };
