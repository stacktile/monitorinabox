# About This Project
Monitor in a Box is a set of Ansible roles and supporting tools and code to
set-up a comprehensive application and infrastrucure monitoring solution based
on the master-satellite functionalities of Icinga2 and Icingaweb.

We designed Monitor in a box with a focus on:

* Simplicity to get started: A virtualized staging envirionment with
  one-command setup to clearly illustrate how all the components work together.
* Supporting dynamic cloud-based infrastructure
* Historical time-series based metrics collection with support for queries and
  browser-based trend analysis
* Sensible security: confidentiality and authentication of all metrics
  collection in transit 


To support this project and for more information on how to obtain additional
functionalities such as historical metrics collection using Graphite,
visualization via Grafana, Let's Encrypt support and more, please visit
https://solutions.stacktile.io/.

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
Note: we support additional os families/distributions in our paid offering at
https://solutions.stacktile.io


### "Set up the Left Side"

1) Ensure that you have vagrant v1.8.7 or newer installed with the command:

`vagrant --version`

If not, install vagrant and create the virtual machines using our Vagrantfile.

On Debian/Ubuntu, CentOS, MacOS, you'll need to install Vagrant from the
official source: https://www.vagrantup.com/downloads.html

Let's change into the examples directory and create the VMs:

```
cd examples
vagrant up
```

2) Set up the Installer System. You may use our docker image as follows:

`docker run -w /root -h mib-installer -it stacktile/mib-installer`

OR alternately ensure that you have the following packages installed:
(example commands for Debian/Ubuntu systems)

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
certificates. If you purchased Monitor in a Box Pro, we will address this with
Let's Encrypt in part 2)

The credentials for all the services that we've just set up can be found in ../credentials/ :

`cat ../credentials/icingaweb_admin_user`

They have also been placed into the /root/passwords directory of the Master server:

`ssh root@192.168.33.10 -o StrictHostKeyChecking=no "cat /root/passwords/icingaweb_admin_password"`

### Your first running monitoring setup

Now that we have our example monitoring system up and running, let's perform a
few simple experiments to demonstrate how everything works together. As we run
these experiments, keep the icingaweb dashboard running in your browser at
http://192.168.33.10/

1) Let's begin by examining the host checks presented at
https://192.168.33.10/monitoring/list/hosts. You should observe the following
three entries that were created for you by MIB.

- mibmaster.your.company
  - A ping check of the master that is conducted by the master on itself over
    the loopback network interface.
- mibsatellite.your.company
  - A ping check of the satellite that is conducted by the satellite on itself
    over the loopback network interface, the result of which is reported over
    the secure channel to the master.
- mibsatellite.your.company from mibmaster.your.company
  - A ping check of the satellite that is conducted over the network from the master

2) We will consume all free filesystem space on the satellite and observe the
reported changes for the metric for "disk space". Run the following command
from your installer system to temporarily create, and then remove a large file
"zero.txt" on the satellite system:

`ssh root@192.168.33.11 -o StrictHostKeyChecking=no "cat /dev/null > zero.txt; sleep 120; rm zero.txt"`

You should observe service warnings displayed in the browser for the "disk"
service belonging to the Zone "mibsatellite.your.company". After approximately 2 minutes,
the large file should be removed, and the status should return to "OK" for the
"disk" service.

3) Next, we will disable Disable the satellite entirely. From the installer
system, run the following command to shut down your satellite system.

`ssh root@192.168.33.11 -o StrictHostKeyChecking=no "shutdown now"`

Navigate your browser to https://192.168.33.10/monitoring/list/hosts.
Within 5 minutes (the default zone check interval), you should observe two
failing checks for "mibsatellite.your.company" and
"mibsatellite.your.company from mibmaster.your.company".


# Part 2: Taking Monitor in a Box out of its staging environment
In part 2, we will explain how to begin modifying MIB to work with your
existing infrastructure. While our goal is to provide a top-down explanation for how
to begin modifying our code to fit your specific needs, we do not intend to
fully replace the role of official ansible and Icinga2 project documentation.

## Ansible, Inventory, Roles, and our Playbook.
For those unfamiliar with Ansible configuration management, the key concepts to
understand before making any changes to our code are inventory, roles and our
playbook.

The inventory is a specification for which hosts are to be configured by
Ansible. We provide an inventory file in `inventories/mib` which provides a
starting point for you. This is where you can add entries for your own master
and satellite hosts. For each host added to the inventory, we expect that the
installation system has SSH access to that host as the root user. For more
details, see http://docs.ansible.com/ansible/intro_inventory.html.

Once your inventory file is customized, you can begin to modify the roles we
provide. Ansible roles are functional units of configuration management that
can combined and reused. Monitor in a Box is implemented as a collection of
the following roles that reside as directories in the `roles/` directory:

### common
We created the common role to run on every one of our Debian/Ubuntu systems to
provide a consistent environment.

### common-nginx
This role provides reusable secure nginx configuration which can be applied
everywhere nginx is used.

### icinga2-base
This role provides a minimal common set of Icinga set-up and configuration that
can be shared across any intended use of Icinga.

### icinga2-icingaweb
This role sets up the web interface for Icinga.

### icinga2-managedconf
This role is similar in purpose to the custom_config.yml included in the
icinga2-base role. It provides a way to specify checks to be run, however
unlike the icinga2-base role, these checks are only run on a sub-set of Icinga
instances as defined in the Ansible inventory.

### icinga2-master
This role transforms an icinga2-base system into one that implements the Icinga
master functionalities.

### icinga2-satellite
This role transforms an icinga2-base instance into one that implements the
Icinga satellite functionalities.

### postfix_local
This role provides a starting-point to enable mail delivery that Icinga can use
to send out notification emails.

The entry point for each one of these roles is the `tasks/main.yml` file within
each directory. Further documentation on each of our roles is provided in the
header of these files. The MIB Pro version includes additional roles for Let's
Encrypt and Grafana, whose files are also documented similarly in the header.
For more information on Ansible roles, see
http://docs.ansible.com/ansible/playbooks_roles.html#roles.

Finally, we provide a playbook which invokes each of the roles described above.
We provide the playbook file `playbook-mib.yml` which, when combined with the
inventory (as you invoked in part 1), provides the entrypoint for Monitor in a
Box.

## External Dependencies
Now that we have covered the highest level overview of the contents of Monitor
in a Box, we will ever so briefly detail the external dependencies required to
put your monitoring system into production.

### DNS
It is beyond the scope of our solution to detail exactly how DNS must be
configured, but at a bare minimum the icinga master server should have a DNS
entry so that a browser-accepted, valid SSL certificate may be obtained.

### Firewall and open ports
The necessary and required open tcp ports are illustrated in figure 1, above.
Please ensure that if your servers are subject to 3rd party firewalls or
security groups (e.g. from a cloud provider), that the illustrated ports are
open in accordance. 

### Mailserver and notifications
Your icinga master server must be able to send mail if you intend to receive
notifications via email. Icinga provides extreme reconfigurability with respect
to how, when and to whom notifications are sent. We provide a very basic
starting point: One admin user with the email address defined in
`roles/icinga2-base/defaults/main.yml` as `icinga_admin_email`. For more
information, see
https://docs.icinga.com/icinga2/latest/doc/module/icinga2/toc#!/icinga2/latest/doc/module/icinga2/chapter/monitoring-basics#notifications.

## Some Ansible Best Practices

Always test playbooks before running on production inventory by using the
ansible-playbook options: --diff --check

--check will not make any changes on the hosts
--diff will display all changes to files in a unified diff format
