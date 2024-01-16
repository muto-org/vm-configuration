# Using Microsoft Defender in GitHub Codespaces

This repository contains setup and configuration scripts to enable usage of Microsoft Defender with GitHub Codespaces via the Host Configuration policy. **Note:** This policy is currently in beta, so before starting you'll need to ensure you have access to this feature.

## Pre-requisites
1. An organization in GitHub that is [configured to own codespaces](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/choosing-who-owns-and-pays-for-codespaces-in-your-organization#choosing-who-owns-and-pays-for-codespaces) that are created on its repositories
2. Access to the Host Configuration policy private beta on the organization
3. Access to Microsoft Defender for Endpoint (you can sign up for a free trial [here](https://www.microsoft.com/en-us/security/business/endpoint-security/microsoft-defender-endpoint))

## Getting Started
### Getting your license information
1. Create a version of this template repository in your organization's account. This should be the organization that has access to the Host Configuration policy in GitHub Codespaces.
2. Log into your [Microsoft Security admin panel](https://security.microsoft.com)
3. Navigate to **Settings > Endpoints > Device Management > Onboarding**
    ![Screenshot 2023-10-31 at 14 29 26](https://github.com/muto-org/defender-demo-template/assets/4679612/312f2d3e-79f3-4992-b599-ffd3a22531a7)
    ![Screenshot 2023-10-31 at 14 29 34](https://github.com/muto-org/defender-demo-template/assets/4679612/224134e1-7480-4e47-8861-22b5285345ab)
4. Select **Linux Server** as your operating system
    ![Screenshot 2023-10-31 at 14 29 50](https://github.com/muto-org/defender-demo-template/assets/4679612/180a61f9-de6d-4c96-8ee1-bf4fb430af7d)
5. Click **Download Onboarding Package**. Unzip the downloaded file, which should be called `MicrosoftDefenderATPOnboardingLinuxServer.py`
6. Rename this file to `onboarding.py`, and push it to the repository you created in step 1

**Note:** This file contains your license information for Microsoft Defender, so we recommend keeping this repository private.

### Configuring your host setup policy for Microsoft Defender
1. Go to your organization's Codespace policies
    ![Screenshot 2023-10-31 at 14 37 50](https://github.com/muto-org/defender-demo-template/assets/4679612/a180336e-bbe8-4843-8e19-d800cc7161b1)
2. Create a new policy, and add a **Host Setup** constraint
    ![Screenshot 2023-10-31 at 14 38 32](https://github.com/muto-org/defender-demo-template/assets/4679612/b52ac45e-4140-4b5f-bbf2-a8b28f751e09)
3. Configure this constraint to point to the `setup.sh` file in the repository you created in the previous step
    ![Screenshot 2023-10-31 at 14 39 44](https://github.com/muto-org/defender-demo-template/assets/4679612/1ce9e7e2-0c30-4810-979c-db233937e54b)
4. (Optional but recommended) Select which repositories you want to apply this policy to. If you select **All Repositories** it will automatically run on every codespace create or resume in this organization once the policy is created, so if there is active codespace development in this organization it is recommended to specify a test repository rather than applying to all.


### Testing your setup
Once you have completed the policy setup and configured your license, you can now test to ensure everything is working properly. To test, create a codespace on a repository within your organization. If you targeted a specific set of repositories in your host setup policy, you must create a codespace in one of these targeted repositories for the policy to take effect.

Once you have created a codespace, go to your [Microsoft Security admin panel](https://security.microsoft.com) to see detailed information about the codespace flow into Defender. This may take a few minutes.