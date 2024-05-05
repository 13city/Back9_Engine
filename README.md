# Bug Bounty Recon Tools

![Recon in Action](back9.jpg)


## Overview
This project houses a suite of tools designed for the rigorous reconnaissance phase of bug bounty programs. Our tools automate the discovery and analysis of potential vulnerabilities across a wide array of target domains. Each script is crafted to streamline the process of finding, validating, and reporting potential security issues, leveraging sophisticated scanning and data transformation techniques.

## Features
- **Domain Subfinder**: Utilizes `subfinder` to recursively search for subdomains from root domain lists, crucial for uncovering attack surfaces that are often missed.
- **Domain Resolver**: Integrates `dnsx` for resolving subdomains to their respective IP addresses, allowing for further penetration testing stages.
- **Live Domain Checker**: Uses `httpx` to verify the accessibility of discovered domains, sorting out live targets from dormant ones.
- **Endpoint Analyzer**: Employs `Katana` to extract and analyze endpoints from live domains, pinpointing areas susceptible to web-based exploits.
- **Port Scanner**: Incorporates `Smap`, a robust port scanning tool that examines open ports, providing insights into possible entry points for deeper security audits.
- **JSON Reporting**: Features a custom function to convert scanned data into JSON format for easier integration with other tools and reporting systems.

## Scripts in Action

### Recon Script
The `recon.sh` script is the backbone of our toolkit. It orchestrates the complete reconnaissance process by executing the following steps for each target:

1. **Subdomain Discovery**: Runs `subfinder` against a list of root domains to gather potential subdomains.
2. **Domain Resolution**: Passes the discovered subdomains through `dnsx` to resolve them to IP addresses.
3. **Live Domain Filtering**: Checks the accessibility of resolved domains using `httpx` to identify active websites.
4. **Endpoint Collection**: Extracts actionable endpoints from live domains using `Katana`.
5. **Open Port Mapping**: Scans for open ports on the resolved domains using `Smap`, outlining potential vulnerabilities.
6. **Data Reporting**: Converts all gathered data into a structured JSON format, making it ready for further analysis or reporting.

### Usage
To run the scripts effectively, ensure all dependencies are installed and the script is executed from the root of the project directory:

    bash recon.sh

### Dependencies
- [subfinder](https://github.com/projectdiscovery/subfinder)
- [dnsx](https://github.com/projectdiscovery/dnsx)
- [httpx](https://github.com/projectdiscovery/httpx)
- [Katana](https://github.com/sectool/Katana)
- [Smap](https://github.com/sectool/Smap)
- [jq](https://stedolan.github.io/jq/)

## Contributing
Contributions to enhance the functionality or efficiency of these tools are welcome. Please submit pull requests or raise issues as needed. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE) file for details.

## Acknowledgments
Special thanks to all the contributors and the cybersecurity community for their insights and feedback that have helped shape this project.

---
For more detailed information on each script's functionality and additional configuration options, refer to the inline comments within each script file. Together, let's push the boundaries of security research and vulnerability discovery.
