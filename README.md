# ssh_configurator

<a href="https://discord.gg/UA5eb5SsAh">
        <img src="https://img.shields.io/discord/1183477399208345771?color=blue8&label=Discord&logo=discord&style=for-the-badge"
            alt="chat on Discord"></a>

This script sets up a secure SSH environment on a fresh, unconfigured Debian-based system. It generates a random port for SSH access, configures password authentication options, installs UFW (Uncomplicated Firewall) and Fail2Ban for enhanced security, and adds the specified public key for SSH access.

## Features

- Generates a random port for SSH access to enhance security.
- Configures password authentication options (can disable password access).
- Installs and configures UFW to manage firewall rules.
- Installs and configures Fail2Ban to protect against brute-force attacks.
- Adds the specified public key for secure SSH login.

## Prerequisites

- A fresh, unconfigured Debian-based system (e.g., Debian, Ubuntu).
- Root privileges to install packages and modify system configurations.

## Usage

1. **Download the script:**

   using `curl`
   ```bash
   curl https://raw.githubusercontent.com/atarwn/ssh_configurator/refs/heads/main/ssh_configurator.sh -o ssh_configurator.sh
   ```
   or `wget`
   ```bash
   wget https://raw.githubusercontent.com/atarwn/ssh_configurator/refs/heads/main/ssh_configurator.sh
   ```


2. **Make the script executable:**

   ```bash
   chmod +x ssh_setup.sh
   ```

3. **Run the script with your public key as an argument:**

   ```bash
   sudo ./ssh_setup.sh "your-public-key"
   ```

   Alternatively, you can run the script without arguments, and it will prompt you to enter your public key:

   ```bash
   sudo ./ssh_setup.sh
   ```

4. **Follow the on-screen prompts:**
   - Confirm that you want to continue with the setup.
   - The script will ask if you want to disable password authentication.
   - If asked to restart any services, just press Enter.
   - If a warning appears that the command may terminate the SSH connection, just continue the operation (write `y`).

5. **For help or usage information:**

   You can view help information by running:

   ```bash
   sudo ./ssh_setup.sh --help
   ```

## Important Notes

- This script should ONLY be run on a fresh, unconfigured system.
- If you have changed any settings in SSH, UFW, or Fail2Ban, it is recommended not to run this script.
- For support or inquiries, find me via [https://ya.ru/search/?text=atarwn](https://ya.ru/search/?text=atarwn)
  - or go to the [issues](https://github.com/atarwn/ssh_configurator/issues)

## License

This project is licensed under the BSD Zero Clause License - see the [LICENSE](LICENSE) file for details.
