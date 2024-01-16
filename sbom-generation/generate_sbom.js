
const { exec } = require('child_process');
const fs = require('fs');

const sbom = {
    bomFormat: 'CycloneDX',
    specVersion: '1.5',
    version: '1.1.1',
    metadata: {
        timestamp: new Date().toISOString(),
        component: getOsComponent()
    },
    components: []
}

const fieldSeperator = '|||';
const entrySeperator = '---END---';

start();
async function start() {
    const sbom = {
        bomFormat: 'CycloneDX',
        specVersion: '1.5',
        version: "1.0.0",
        metadata: {
            timestamp: new Date().toISOString(),
            component: await getOsComponent()
        },
        components: await getPackagesAsComponents()
    }

    // write sbom to sbom.json
    const basePath = process.env.SBOM_BASE_PATH || '/tmp';
    const fileName = process.env.SBOM_FILE_NAME || 'sbom.json';
    const sbomPath = `${basePath}/${fileName}`;
    console.log(`\nWriting SBOM to '${sbomPath}'`);
    fs.writeFileSync(sbomPath, JSON.stringify(sbom, null, 4));
}

async function getPackagesAsComponents(sbom) {
    const command = `dpkg-query -W -f '\${binary:Package}${fieldSeperator}\${Version}${fieldSeperator}\${binary:Summary}${fieldSeperator}\${Maintainer}${entrySeperator}'`;
    const dpkgOutput = await runCommand(command);
    let components = [];
    let packages = dpkgOutput.split(entrySeperator);

    console.log(`Total dpkg packages: ${packages.length}`);
    packages.forEach(pkg => {
        let pkgInfo = pkg.split(fieldSeperator);
        const name = pkgInfo[0];
        if (name) {
            let version = pkgInfo[1];
            // convert debian epoch version to semver version
            if (version?.includes(':')) {
                const semver = version.split(':')[1];
                version = semver;
            }

            let displayVersion = getDisplayVersion(version);

            console.log(`Package: ${name} v${version} (${displayVersion})`);

            components.push({
                name: name,
                version: version,
                description: pkgInfo[2],
                supplier: pkgInfo[3],
                type: 'application',
                properties: {
                    displayVersion: displayVersion,
                }
            });
        }
    });

    // sort components by name
    components = components.sort((a, b) => a.name.localeCompare(b.name));
    return components;
}

function getDisplayVersion(version) {
    let displayVersion = version;

    // parse semver major, minor
    const semverRegex = /^([0-9]+)\.([a-zA-Z0-9]+)[\.|\-]*(.*)?$/;
    const parsedVersion = version?.match(semverRegex);
    if (parsedVersion) {
        const major = parsedVersion[1];
        const minor = parsedVersion[2];
        const rest = parsedVersion[3];

        if (major) {
            displayVersion = major;
            if (minor) {
                displayVersion = `${displayVersion}.${minor}`;
            }

            if (rest) {
                displayVersion = `${displayVersion}.x`;
            }
        }
    }

    return displayVersion;
}

async function getOsComponent() {
    // read ubuntu version details from /etc/os-release file
    const osRelease = fs.readFileSync('/etc/os-release', 'utf8');
    const osReleaseLines = osRelease.split('\n');
    let osReleaseDetails = {};
    osReleaseLines.forEach(line => {
        const lineParts = line.split('=');
        osReleaseDetails[lineParts[0]] = lineParts[1]?.replace(/"/g, '');
    });

    console.log(`Operating System: ${osReleaseDetails['NAME']} ${osReleaseDetails['VERSION']}`);

    const kernelVersion = (await runCommand('uname -r')).trim();
    return {
        name: osReleaseDetails['NAME'],
        version: osReleaseDetails['VERSION'],
        type: 'operating-system',
        properties: {
            kernelVersion: kernelVersion,
        }
    };
}

async function runCommand(command) {
    return new Promise((resolve, reject) => {
        exec(command, (error, stdout, stderr) => {
            if (error) {
                console.error(`error: ${error.message}`);
                reject(error);
            }
            if (stderr) {
                console.error(`stderr: ${stderr}`);
                reject(stderr);
            }

            resolve(stdout);
        });
    });
}
