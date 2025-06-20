# Install CHORUS v1 on Docker

<details>
  <summary>Requirements</summary>
  
- Ubuntu 22.04 or 24.04
    - (Only OS tested, other linux with cgroups v2 might work)
- 500Gb Storage
- 64Gb Ram
- Docker with root access 
    - (container must run in privileged mode)
</details>

<br>

<details>
  <summary><b style="font-size:1.25em;">(Optional) Create a VM</b></summary>
  
### Heading
1. Create a VM
    - Ubuntu 22.04 or 24.04
    - 500Gb Hard disk
    - 64Gb Ram
    - 16 VCPU
    - Assign a public IP
    - Create a domain name, eg "demo.chorus-tre.ch"
    - Connect via ssh
2. Create a user with sudo privileges, ie "chorus"
3. Login as "chorus"

</details>

### Install requirements
1. Install docker from the official documentation on docker.com
    - Add yourself `sudo usermod -aG docker $USER`
2. `git clone git@github.com:CHORUS-TRE/v1-dockerized.git`
3. cd into the cloned folder 

### Setup
1. Edit docker-compose.yml
2. Replace all hostname with yours, like "demo.chorus-tre.ch", keep port if single domain
    - If needed replace 8888 by 80
3. `docker compose up`
4. http://demo.chorus-tre.ch:8888/login
5. Login with the default user
    - Use log in with "user" and "password"
    - in the following screen you can change the inital password
6. To login as the nextcloud admin
    - use the "Log in with username or email", 
    - use "nextcloud_admin_user" pasword "nextcloud_admin_password"
7. To add a user and administrate keycloak
    - login in the keycloak url, 
    - login with "admin" password "admin" 
    - and create the users under the hip realm

## License and Usage Restrictions

Any use of the software for purposes other than academic research, including for commercial purposes, shall be requested in advance from [CHUV](mailto:pactt.legal@chuv.ch).

## Acknowledgments

This project has received funding from the Swiss State Secretariat for Education, Research and Innovation (SERI) under contract number 23.00638, as part of the Horizon Europe project “EBRAINS 2.0”.
