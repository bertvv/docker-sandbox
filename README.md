# Simple Docker host

The goal of this project is to provide a playground environment for Docker.

## Environment setup

1. Install necessary software:
    - [Git](https://git-scm.com/downloads) (including Git Bash on Windows)
    - [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (including the Extension Pack!)
    - [Vagrant](https://www.vagrantup.com/)
2. Optionally, create a fork of this repository
3. Clone this repository (or your own fork):
    ```
    $ git clone https://github.com/bertvv/docker-host
    ```
4. Enter the directory:
    ```
    $ cd docker-host
    ```
5. Start the environment:
    ```
    $ vagrant up
    ```

After the VM has booted and the provisioning is finished, you should be able to surf to <http://192.168.56.12:9090/> and see the login page of Cockpit, a dashboard for viewing system services. Log in with user name `vagrant` and password `vagrant`. You can see the running containers under the "Containers" category in the menu on the left.

