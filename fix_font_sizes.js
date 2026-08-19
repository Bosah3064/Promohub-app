const fs = require('fs');
const path = require('path');

const directories = [
    'lib/presentation'
];

function processDirectory(dirPath) {
    if (!fs.existsSync(dirPath)) return;
    
    const files = fs.readdirSync(dirPath);
    for (const file of files) {
        const fullPath = path.join(dirPath, file);
        if (fs.statSync(fullPath).isDirectory()) {
            processDirectory(fullPath);
        } else if (fullPath.endsWith('.dart')) {
            processFile(fullPath);
        }
    }
}

function processFile(filePath) {
    let content = fs.readFileSync(filePath, 'utf8');
    let hasChanges = false;

    // Replacement map for sp sizes
    const replacements = {
        '32.sp': '34.0',
        '28.sp': '30.0',
        '24.sp': '28.0',
        '20.sp': '22.0',
        '18.sp': '20.0',
        '16.sp': '18.0',
        '15.sp': '16.0',
        '14.sp': '16.0',
        '13.sp': '15.0',
        '12.sp': '14.0',
        '11.sp': '13.0',
        '10.sp': '12.0',
        '8.sp': '10.0'
    };

    for (const [oldSp, newSp] of Object.entries(replacements)) {
        if (content.includes(oldSp)) {
            // regex to replace correctly, avoiding replacing 114.sp if we are looking for 14.sp
            const regex = new RegExp(`(?<![0-9])${oldSp.replace('.', '\\.')}`, 'g');
            if (regex.test(content)) {
                content = content.replace(regex, newSp);
                hasChanges = true;
            }
        }
    }

    if (hasChanges) {
        fs.writeFileSync(filePath, content, 'utf8');
        console.log(`Updated sizes in: ${filePath}`);
    }
}

for (const dir of directories) {
    processDirectory(dir);
}
