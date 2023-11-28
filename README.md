# SBOM Generation Policy

This branch defines a shell script that can be used to generate the software bill of materials (SBOM) for a dev container in GitHub Codespaces. The script generates and updates the SBOM every 20 seconds, and automatically runs when integrated via the host setup script policy.

## Configuring the policy

1. Ensure you have access to the Host Setup Policy feature.
2. Fork this repository into the organization where you want to apply the policy.
3. Navigate to the Codespaces policies for your organization.
    <img width="1721" alt="Screenshot 2023-11-28 at 07 22 15" src="https://github.com/muto-org/vm-configuration/assets/4679612/0c65331c-465c-4f22-b0bd-861120e3494f">
4. Create a new host setup policy, specifying the path to the `install.sh` script on the `container` branch of the repository you forked into your organization.
    <img width="1728" alt="Screenshot 2023-11-28 at 07 22 35" src="https://github.com/muto-org/vm-configuration/assets/4679612/d4f18104-b0ff-42eb-a3d9-9458b4b8ef61">
5. Verify the policy is properly configured. The URL displayed should be: `https://github.com/<your-org-login>/vm-configuration/blob/container/install.sh`
    <img width="1726" alt="Screenshot 2023-11-28 at 07 23 26" src="https://github.com/muto-org/vm-configuration/assets/4679612/6523ac31-ca41-43ab-8d39-50a6c01e4f97">
6. Select the repositories within your organization where you want this policy to apply. You can choose a specific set of repositories, or all repositories.

## Testing the Policy
1. Go to a repository where the newly configured policy applies.
2. Create a new codespace.
3. The SBOM is generated in the `/tmp/sbom.json` file. Use `code /tmp/sbom.json` to open the file in VS Code
    <img width="1726" alt="Screenshot 2023-11-28 at 07 30 48" src="https://github.com/muto-org/vm-configuration/assets/4679612/99f901a1-8ec6-43d5-a3a3-c472c5cd5ec3">
4. To test the update, try installing a package that is not listed in the `sbom.json` file (e.g. `sudo apt update && sudo apt-get install cowsay`). When the script runs again, the `sbom.json` file will include this newly installed package.
