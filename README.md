# Install CHORUS v1 on Docker

<details>
  <summary>(Optional) Create a VM </summary>
  
  ### Heading
    1. Create a VM 
    Ubuntu 22.04
    500Gb Hard disk
    64Gb Ram
    Assign a public IP
    Create a domain name, eg "demo2.chorus-tre.ch"
    Connect via ssh
    2. Create a user with sudo privileges, ie "chorus"
    3. Login as "chorus"
</details>

### Requirements
1. Install docker from the official documentation on docker.com
    - Add yourself `sudo usermod -aG docker $USER`
2. `git clone git@github.com:CHORUS-TRE/v1-dockerized.git`
3. cd into the cloned folder 

### Setup
1. edit docker-compose.yml
2. replace all hostname with yours, like "demo2.chorus-tre.ch", keep port if single domain
    - if needed replace 8888 by 80
3. `docker compose up`
4. http://demo2.chorus-tre.ch:8888/login
5. use log in with "user" and "password"
6. To login as admin, use the "Log in with username or email", use "nextcloud_admin_user", "nextcloud_admin_password"