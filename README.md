# Part 1: Monitor in a Box!

```
    boxboxboxboxbox
    b             x
    b MONITORING! x
    b             x
    boxboxboxboxbox
```

Greetings, I'm Dan, and I'd like to welcome you into our box of monitoring!

## Getting Started

To get you started quickly, I'm going to demonstrate how MIB (monitoring in a
box) works, and how to use it, by having you run it in a staging environment.
At a high level, here's what we're going to create:

```
 The left side         @    The right side
------------------------------------------------------------
                       @
+------------------+   @    +-------------------------+
|  Installer       |   @    |  Master                 |
|  System          |   @    |  -Icinga2(R) Master     |
|  (You Are Here)  |   @    |  -Icingaweb             |
+------------------+   @    +-------------------------+
                 |     @      |
                 |     @      |
                 |-----@--->  +[open tcp port 22]
                 |     @      |
                 |     @      +[open tcp port 80,443] <--- Your web browser
                 |     @      |
                 |     @      +[open tcp port 5665] <-----ssl--+
                 |     @                                       |
                 |     @                                       |
                 |     @    +-------------------------+        |
                 |     @    |  Satellite              |---ssl--+
                 |     @    |  -Icinga2(R) Satellite  |
                 |     @    +-------------------------+
                 |     @      |
                 |     @      |
                 +-----@--->  +[open tcp port 22]
                       @
------------------------------------------------------------
                       figure 1
------------------------------------------------------------
```

The left side of this delightful ascii-artwork (fig. 1) depicts the system you
are using right now to read this very sentence -- the "Installer System". From
here, we'll create 2 virtual machines depicted on the right side, and then use
Ansible(R), a configuration management tool to complete the monitoring setup.

Our example monitoring system will consist of: A "Satellite" which is a system
(in production, each host of your infrastructure will become a satellite) that
runs a monitoring agent which reports all of its metrics to a "Master".  The
"Master" will be the central point at which all metrics are collected. In our
example, the "Master" system will also run the web applications that enable
status and data visualization and notifications.

### System Requirements
Installer system: Linux or MacOS
 - To run the virtualized staging example: Vagrant v1.8.7 or newer, Docker

Master & Satellite Systems: Ubuntu 14.04


### "Set up the Left Side"

We'll be working in our examples directory:

`cd examples`

1) Install vagrant and create the virtual machines using our Vagrantfile.

On Debian/Ubuntu, MacOS, CentOS, you'll need to install Vagrant from the
official source:

`Visit https://www.vagrantup.com/downloads.html`

Create your VMs:

`vagrant up`

2) Set up the Installer System. You may use our docker image as follows:

`docker run -w /root -h mib-installer -it stacktile/mib-installer`

or alternately (on Debian/Ubuntu), ensure that you have the following packages installed:

```
sudo apt install libssl-dev python-pip virtualenv

# create a python virtualenv
virtualenv . && source ./bin/activate

# install python requirements
pip install -r requirements.txt
```

### "Make the Left Side to set up the Right Side"

3) From either within your running docker container, or the virtual env you
created above in step 2, run the following:

`ansible-playbook -i inventory ../playbook-mib.yml`

At this point, you should see the logging output of ansible which performs the
heavy lifting of setting up all of the various components of your distributed
monitoring system. Grab a coffee (or a beer) for the next ~5 minutes and enjoy
the show.

### Take it for a spin:

4) Point your browser to `http://192.168.33.10/` (Note that you'll see SSL
warnings because we haven't yet reached the step where we create legitimate SSL
certificates. This comes in part 2)

The credentials for all the services that we've just set up can be found in ../credentials/ :

`cat ../credentials/icingaweb_admin_user`

They have also been placed into the /root/passwords directory of the Master server:

`ssh root@192.168.33.10 -o StrictHostKeyChecking=no "cat /root/passwords/icingaweb_admin_password"`

--------------------------------------------------------------------------------
Notice to our Beta Testers: All documentation beyond this point is still
Work-in-Progress
--------------------------------------------------------------------------------

### Your first running monitoring setup

- Disable the satellite, (disable network interface). Observe what happens
- Change a check and re-deploy

# Part 2: Taking Monitor in a Box out of its staging environment

## Ansible, Roles, and our Playbook.

- Ansible and the Role overview

- External Dependencies
 - DNS
 - Firewally and open ports
 - Mailserver
 - Meta-monitoring

## Adapting the Ansible inventory

## Some Ansible Best Practices

Always test playbooks before running on production inventory by using the
ansible-playbook options: --diff --check

--check will not make any changes on the hosts
--diff will display all changes that can be reported back

# Part 3: Finally, Monitor in a Box into production!

## Altering in Production

1) Create a production "Master" virtual machine: Ensure that it has a public ip address

2) Edit the ansible inventory to specify which hosts will be monitored and
which host will act as the icinga2 master and icingaweb interface:

`(your favorite editor) ./inventories/mib`



