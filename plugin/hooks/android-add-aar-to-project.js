const fs = require("fs");
const path = require("path");

function addAarToLibs(context, platformRoot) {
    const libsDir = path.join(platformRoot, 'app/libs');
    const aarSrc = path.join(context.opts.plugin.dir, 'src/android/libs/sdk-release.aar');
    const aarDest = path.join(libsDir, 'sdk-release.aar');

    // Ensure the libs directory exists
    if (!fs.existsSync(libsDir)) {
        fs.mkdirSync(libsDir, { recursive: true });
        console.log('Created libs directory at ' + libsDir);
    }

    // Copy the .aar file
    fs.copyFileSync(aarSrc, aarDest);
    console.log('Copied sdk-release.aar to ' + aarDest);
}

function addAarToGradle(platformRoot) {
    const buildGradlePath = path.join(platformRoot, "app/build.gradle");

    // Check if the build.gradle file exists
    if (!fs.existsSync(buildGradlePath)) {
        console.error("build.gradle file not found at " + buildGradlePath);
        return;
    }

    let buildGradleContent = fs.readFileSync(buildGradlePath, "utf8");

    // Define the AAR dependency line
    const aarDependency = "implementation files('libs/sdk-release.aar')";

    // Find the correct dependencies block within the android section
    const androidBlockRegex = /android\s*{[^}]*}/gs;
    const dependenciesBlockRegex = /dependencies\s*{/g;

    let androidBlockMatch = buildGradleContent.match(androidBlockRegex);
    if (androidBlockMatch) {
        let androidBlockContent = androidBlockMatch[0];
        if (dependenciesBlockRegex.test(androidBlockContent)) {
            // Insert the AAR dependency inside the existing dependencies block within the android block
            androidBlockContent = androidBlockContent.replace(
                dependenciesBlockRegex,
                match => match + `\n    ${aarDependency}`
            );
        } else {
            // If there's no dependencies block within the android block, add one
            androidBlockContent = androidBlockContent.replace(
                /android\s*{/,
                match => match + `\n    dependencies {\n        ${aarDependency}\n    }`
            );
        }

        // Replace the android block in the original content with the modified content
        buildGradleContent = buildGradleContent.replace(androidBlockMatch[0], androidBlockContent);

        // Write the modified content back to build.gradle
        fs.writeFileSync(buildGradlePath, buildGradleContent, "utf8");
        console.log("Updated build.gradle to include sdk-release.aar in the correct dependencies block.");
    } else {
        console.error("No android block found in build.gradle, cannot add dependencies.");
    }
}

module.exports = function(context) {
    const platformRoot = path.join(context.opts.projectRoot, "platforms/android");

    return new Promise((resolve, reject) => {
        try {
            addAarToLibs(context, platformRoot);             // Add the .aar file to app/libs
            addAarToGradle(platformRoot);             // Add the .aar file to build.gradle
            resolve();
        } catch (error) {
            console.error("Error during build.gradle modification: ", error);
            reject(error);
        }
    });
};
