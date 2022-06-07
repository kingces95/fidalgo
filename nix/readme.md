# Fidalgo Unix Shell Environment
This is a non-offical unix environment to support Fidalgo originally authored by `chrkin`. The shell 
- dogfoods Fidalgo; The shell is meant to be run from inside a fidalgo provisioned CloudPC.
- codifies the environment described in the team **wiki** and **one-note**.
- unifies in one environment a subset of the functionality of **PostMan**, **AzureDataExplorer**, and **Visual Studio**.
- provides an environment for **incrementally** running integration tests locally as they are run in the pipeline.
- eliminates excessive multi-factor authentication when switching between environments.
- allows for **sharing kusto queries** in a democratized format (see `azure-devtest-center/kusto`).
- allows for **sharing http requests templates** ala PostMan (see `azure-devtest-center/http`).
- allows for **sharing bookmarks** assoicated with the current shell environment.
- provides an environment for senior developers to **capture and share debug workflows** with junior developers.

See [philosophy](#philosophy) for administrative details.

# Overview
Proceed through the walk-throughs in the order. 
1. [Installation](#installation) - Environments, Personas, Accounts
2. [Postman](./md/postman.md) - Shared HTTP requests; Verfiy our resource provider returns the expected error message.

# Installation
To install the NIX shell:
1. From a [Windows](#windows) or [Mac](#mac) provision a CloudPC.
2. On the [CloudPC](#cloudpc) install Windows Subsystem for Linux (WSL2).
3. In [WSL2](#wsl2) sync `azure-devtest-center`.
4. Open the [azure-devtest-center](#azure-devtest-center) in VSCode.
5. Source [The NIX Shell](#the-nix-shell) environment `~/git/azure-devtest-center/nix/profile.sh`

## Windows
```cmd
REM install az cli > follow instructions
c:\> start https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

REM test az cli installation
c:\> az --version
azure-cli                         2.35.0

REM open az fidalgo extension release page > download latest version
c:\> start https://devdiv.visualstudio.com/OnlineServices/_wiki/wikis/OnlineServices.wiki/21260/Az-Cli
c:\> az extension add --upgrade --yes --only-show-errors --source %USERPROFILE%\downloads\fidalgo-0.3.2-py3-none-any.whl

REM login to PPE tenant with domain account (e.g. %USERNAME%@fidalgoppe010.onmicrosoft.com)
c:\> az login --tenant 8ab2df1c-ed88-4946-a8a9-e1bbb3e4d1fd

REM spinup virtual machine
c:\> az fidalgo dev virtual-machine create ^
    --dev-center=nix-%USERNAME%-ppe-my-dev-center ^
    --name=nix-chrkin-ppe-my-vm --pool-name=nix-chrkin-ppe-mypool ^
    --project-name=nix-chrkin-ppe-my-project ^
    --subscription=974ae608-fbe5-429f-83ae-924a64019bf3

REM wait for virtual machine to be provisioned
c:\> az fidalgo dev virtual-machine show ^
    --dev-center=nix-chrkin-ppe-my-dev-center ^
    --name=nix-%USERNAME%-ppe-my-vm ^
    --project-name=nix-chrkin-ppe-my-project

REM click "Download Remote Desktop" > subscribe > %USERNAME%@fidalgoppe010.onmicrosoft.com
c:\> start https://deschutes-ppe.microsoft.com
```
## CloudPC
```ps
# install vscode
ps> Start-Process https://code.visualstudio.com/download

# install WSL2 and reboot
ps> Enable-WindowsOptionalFeature -online -FeatureName "Microsoft-Windows-Subsystem-Linux;VirtualMachinePlatform" -All -NoRestart; Restart-Computer

# install VsCode extension for accessing WSL2 
ps> code --install-extension ms-vscode-remote.remote-wsl

# install ubuntu
ps> wsl --install -d Ubuntu

# disable adding win PATH to Ubuntu PATH
# https://stackoverflow.com/questions/51336147/how-to-remove-the-win10s-path-from-wsl 
```
```bash
# Enter your alias as username (e.g. chrkin)
Enter new UNIX username: chrkin
Enter password:

# Check that you entered your alias
$ echo $USER
chrkin

# create keypair
$ ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""

# add ado to known hosts (prevents prompting when cloning)
$ ssh-keyscan -t rsa ssh.dev.azure.com >> ~/.ssh/known_hosts

# add public key to ado; copy everything that cat emits to
# https://dev.azure.com/devdiv/_usersSettings/keys
$ cat ~/.ssh/id_rsa.pub
```
## azure-devtest-center
```bash
# clone repository
$ git clone git@ssh.dev.azure.com:v3/devdiv/OnlineServices/azure-devtest-center ~/git/azure-devtest-center

# install kusto cli
$ (cd ~/git/azure-devtest-center/nix; nuget install)
```
```bash
# open repository in vscode
$ code ~/git/azure-devtest-center/ &
# VSCode should open and in the lower left there should be a green box with the text ">< USL: Ubuntu"
```
```bash
# set default shell environment to bash
vscode > CTRL+SHIFT-P > Terminal: Select Default Profile > Select bash

# save files when the focus changes
vscode > CTRL+, > Save on focus > off -> onFocusChange

# configure useful shell keybindings
vscode > CTRL-SHIFT-P > Preferences: Open Keyboard Shortcuts (JSON) 

# Copy/Paste the below shortcuts to enable:
#   CTRL+` CTRL+` > Open/Close shell toggle
#   CTRL+` UP     > Fullscreen shell toggle
#   CTRL+SHFIT+`  > New shell
#   CTRL+` RIGHT  > Next shell
#   CTRL+` LEFT   > Previous shell
#   CTRL+` DOWN   > Run selected text in shell (super nice)
```
```json
// Place your key bindings in this file to override the defaultsauto[]
[
    {
        "key": "ctrl+` ctrl+`",
        "command": "workbench.action.terminal.toggleTerminal"
    },
    {
        "key": "ctrl+` up",
        "command": "workbench.action.toggleMaximizedPanel"
    },
    {
        "key": "ctrl+` right",
        "command": "workbench.action.terminal.focusNext"
    },
    {
        "key": "ctrl+` left",
        "command": "workbench.action.terminal.focusPrevious"
    },
    {
        "key": "ctrl+` down",
        "command": "workbench.action.terminal.runSelectedText"
    }
]
```
```bash
vscode> CTRL+` CTRL+` # open terminal
$ . ~/git/azure-devtest-center/nix/profile.sh

# Login using your alias (e.g. chrkin@microsoft.com)
WARNING: To sign in, use a web browser to open the page 
https://microsoft.com/devicelogin and enter the code EGW3WD6H3 to authenticate.

# Initialize your profile
Welcome! Please nitialize your profile.

Display name (e.g "Jane Doe") > Chris King  # used when creating accounts and initializing git
Time zone offset (e.g "-8") > -10           # PST=-8; used in kusto queries to display results in your timezone

# your IP block used when peering your subnet to the shared subnet hosting the domain controller.
Your IP block:    10.100.0.0/16.            
Your profile:     /home/chrkin/git/azure-devtest-center/nix/usr/janedoe/profile.sh
Enter fd-my-profile to edit your profile.

# add your own custom aliases
[PUBLIC] $ fd-my-profile                    # opens your profile.sh in vscode

# add: alias me="fd-my-profile"
# close profile.sh

[PUBLIC] $ fd-load                          # reload environment to pickup your new alias
[PUBLIC] $ me                               # use your new alias to re-open your profile.sh

# push and merge your profile and ip-allocation to reserver your IP range; Note the secret is excluded.
[PUBLIC] $ git config --global user.email "${USER}@microsoft.com"
[PUBLIC] $ git config --global user.name "${NIX_MY_DISPLAY_NAME}"
[PUBLIC] $ (cd ~/git/azure-devtest-center/; git checkout -b nix-${USER})
[PUBLIC] $ (cd ~/git/azure-devtest-center/; git add .; git commit -m "Add nix profile for ${USER}.")
[PUBLIC] $ (cd ~/git/azure-devtest-center/; git push --set-upstream origin nix-${USER})
```
# The NIX Shell
The nix shell is a collection of aliases, variables. 
## Aliases
Aliases constitute the public surface area of the nix. 
```bash
[PUBLIC] $ alias        # list all aliases
[PUBLIC] $ fd-          # auto-complete; hit tab twice to list aliases
```
## Variables
```bash
[PUBLIC] $ fd-nix       # dump variables prefixed with NIX_
```
## Reflection
Enter `fd-who` to see environment variables that establish your current Fidalgo identity.
```bash
[PUBLIC] $ fd-who
az    user            chrkin@microsoft.com                                           
az    user-id         55704deb-7b32-49c8-9b61-ab5dec3616cd                           
az    subscription    Project Fidalgo - VDI Dogfooding                               
az    subscription-id 0db9eb1b-4884-4027-9ad5-fea398c784c4                           
az    tenant-id       72f988bf-86f1-41af-91ab-2d7cd011db47                           
az    cloud           AzureCloud                                                     
env   fid             PUBLIC                                                         
env   cpc             PUBLIC                                                         
env   as              administrator                                                  
env   cli                                                                            
kusto token-url       https://help.kusto.windows.net                                 
kusto data-source     https://fidalgopublic.westus2.kusto.windows.net/               
kusto initial-catalog fidalgo-public                                                 
me    name            chrkin                                                         
me    profile         /home/chrkin/git/azure-devtest-center/nix/usr/chrkin/.profile.s
me    env-id          0   
```

## Accounts
You  need the following accounts. The team should have already created a set of **default** accounts for you. The others you will create next.

| Environment | Default | Type | Upn (example) | Admin | MFAx |
| - | - | - | - | - | - |
| public | x | domain | chrkin@microsoft.com |
| dogfood | x | domain | chrkin@microsoft.com | x
| dogfood-int | x | domain | chrkin@microsoft.com | x
| self-host | x | guest | chrkin@microsoft.com | x
| self-host | | domain | chrkin-admin@fidalgosh010.onmicrosoft.com | x | x
| self-host | x | domain | chrkin@fidalgosh010.onmicrosoft.com | | x
| ppe | x | guest | chrkin@microsoft.com | x
| ppe | | domain | chrkin-admin@fidalgoppe010.onmicrosoft.com | x | x
| ppe | x | domain | chrkin@fidalgoppe010.onmicrosoft.com | | x
| int | x | guest | chrkin@microsoft.com | x
| int | | domain | chrkin-admin@fidalgobeta.onmicrosoft.com | x | x
| int | x | domain | chrkin@fidalgobeta.onmicrosoft.com | | x

- None of the accounts have multi-factor authentication (MFA) disabled by default. We will disable MFA where possible by adding accounts to the `MFA Excluded Users` (MFAx) group. 

- You will be prompted to authenticate multipule times during this flow. Each time login with your microsoft account (e.g. chrkin@microsoft.com). 

- After compleating this flow, the environment will use the shared team secret you entered earlier to silently authenticate as you switch between environments.

```bash
[PUBLIC] $ fd-switch-to-selfhost-as-me      # login using guest account (e.g. chrkin@microsoft.com)
[SELFHOST me] $ fd-user-list                # you should have one user
chrkin@fidalgoppe010.onmicrosoft.com        # this is your domain user

# dsiable 2FA for your self-host domain user
[SELFHOST me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN}"  

# create administrator account
[SELFHOST me] $ fd-user-create 'admin'
[SELFHOST me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN_ADMIN}"
[SELFHOST me] $ fd-group-admin-add "${NIX_FID_UPN_DOMAIN_ADMIN}"

# verify your accounts
[SELFHOST me] $ fd-user-report | a2f  
chrkin-admin@fidalgosh010.onmicrosoft.com MFA-Excluded-Users Admins
chrkin@fidalgosh010.onmicrosoft.com       MFA-Excluded-Users  

# repeat for PPE
[SELFHOST me] $ fd-switch-to-ppe-as-me      # login using guest account (e.g. chrkin@microsoft.com)
[PPE me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN}"
[PPE me] $ fd-user-create 'admin'
[PPE me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN_ADMIN}"
[PPE me] $ fd-group-admin-add "${NIX_FID_UPN_DOMAIN_ADMIN}"
[PPE me] $ fd-user-report | a2f  

# repeat for INT
[PPE me] $ fd-switch-to-int-as-me           # login using guest account (e.g. chrkin@microsoft.com)
[INT me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN}"
[INT me] $ fd-user-create 'admin'
[INT me] $ fd-group-x2fa-add "${NIX_FID_UPN_DOMAIN_ADMIN}"
[INT me] $ fd-group-admin-add "${NIX_FID_UPN_DOMAIN_ADMIN}"
[INT me] $ fd-user-report | a2f

 # return to public
[INT me] $ fd-switch-to-public
[PUBLIC] $
```
## Environments
There are 5 **environments**. 
- Each environment is associated with a single Azure **tenant**.
- Each tenant exists in an Azure **cloud** (a collection of url endpoints). 
- The two clouds we use are **AzureCloud** and **Dogfood**. 
- See the tenants associated with AzureCloud [here](https://portal.azure.com/#settings/directory) and with Dogfood cloud [here](https://df.onecloud.azure-test.net ). 
  - Enter `fd-nix-env-www` to see other portals associated with the environment.
- Each environment contains azure resources that run 
  - **Fidalgo services** `dev-center`, `network-setting`, `pool`, etc
  - **CloudPC services** `virtual-network`, `subnet`, `vm`, etc
- All environmnts run both Fidalgo and CloudPC services in the same environment except dogfood. 
  - Dogfood hosts CloudPC services in selfhost or int.

| Fidalgo | CloudPC | Cloud | Tenant | Description |
| - | - | - | - | - |
| public    | public    | AzureCloud | 72f988bf-86f1-41af-91ab-2d7cd011db47 | No testing. |
| dogfood   | selfhost  | Dogfood    | f686d426-8d16-42db-81b7-ab578e110ccd | Developer testing of Fidalgo services. |
| dogfood-int   | int  | Dogfood    | f686d426-8d16-42db-81b7-ab578e110ccd | Developer testing of Fidalgo services. |
| selfhost  | selfhost    | AzureCloud | 003b06c3-d471-4452-9686-9e7f3ca85f0a | Supports developer testing in dogfood by hosting CloudPC resources. |
| ppe       | ppe    | AzureCloud | 8ab2df1c-ed88-4946-a8a9-e1bbb3e4d1fd | Integration testing. |
| n/a       | int    | AzureCloud | eb457173-3dfd-4145-bd18-68e25e0a10fa | Strictly dogfood backing. |
```bash
[PUBLIC] $ fd-switch-to-ppe                 # switch to ppe
[PPE] $ fd-who                              # reflect on ppe identity
[PPE] $ fd-switch-to-public                 # switch back to public
[PUBLIC] $ fd-login
```

## Personas
Each environment supports 5 personas. 

- Use the `fd-login-as-` family of commands to login as different personas within in an environment.

| Persona | Command | Description |
| - | - | - |
| me                    | `fd-login-as-me`                    | Used to create accounts for the other personas.
| administrator         | `fd-login`                          | Used to execute `az fidalgo admin` family of commands.
| developer             | `fd-login-as-developer`             | Used to execute `az fidalgo dev` family of commands.
| network-administrator | `fd-login-as-network-administrator` | Used to execute `az` commands to create dependent resources (e.g. `virtual-network`/`subnet`).
| vm-user               | `fd-login-as-vm-user`               | User assigned to own a CloudPC.

```bash
[PUBLIC] $ fd-login-as-developer            # administrator persona is the default 
[PUBLIC developer] $ fd-who                 # reflect on developer persona
[PUBLIC developer] $ fd-login               # developer persona
[PUBLIC] $ fd-login                         # switch back to administrator persona
```

## Environments x Personas x Accounts
Environments map personas with accounts.

| Environment | Persona | User Principal Name (example) | Switch
| - | - | - | - |
| public        | all                   | chrkin@microsoft.com                          | `fd-switch-to-public`
| ppe           | administrator         | chrkin-admin@fidalgoppe010.onmicrosoft.com    | `fd-switch-to-ppe`
| ppe           | developer, vm-user    | chrkin@fidalgoppe010.onmicrosoft.com          |
| ppe           | network-administrator | chrkin-admin@fidalgoppe010.onmicrosoft.com    | 
| int           | administrator         | chrkin-admin@fidalgobeta010.onmicrosoft.com   | `fd-switch-to-int`
| int           | developer, vm-user    | chrkin@fidalgobeta010.onmicrosoft.com         |
| int           | network-administrator | chrkin-admin@fidalgobeta010.onmicrosoft.com   | 
| selfhost      | administrator         | chrkin-admin@fidalgosh010.onmicrosoft.com     | `fd-switch-to-selfhost`
| selfhost      | developer, vm-user    | chrkin@fidalgosh010.onmicrosoft.com           | 
| selfhost      | network-administrator | chrkin-admin@fidalgosh010.onmicrosoft.com     | 
| dogfood       | administrator         | chrkin@microsoft.com                          | `fd-switch-to-dogfood`
| dogfood       | developer             | chrkin@microsoft.com                          |
| dogfood       | vm-user               | chrkin@fidalgosh010.onmicrosoft.com           |
| dogfood       | network-administrator | chrkin-admin@fidalgosh010.onmicrosoft.com     |
| dogfood-int   | administrator         | chrkin@microsoft.com                          | `fd-switch-to-dogfood-int`
| dogfood-int   | developer             | chrkin@microsoft.com                          |
| dogfood-int   | vm-user               | chrkin@fidalgobeta010.onmicrosoft.com         |
| dogfood-int   | network-administrator | chrkin-admin@fidalgobeta010.onmicrosoft.com   |
## Networking
Next you will setup a virtual network in each environment which you will reuse during tesing. 

- Each netwok will 
  - be peered to the domain controller for the environment.
  - use the domain controller as a DNS server.
  - use the IP block allocated to you above during profile initialization.

```bash
[PUBLIC] $ ppe
[PPE] $ fd-login-as-network-administrator
[PPE network-administrator] $ 
```
Next, follow [this](./tst/sh/my-vnet.sh) flow to create your virtual network.
```bash
# repeat for selfhost and int environments
[PPE network-administrator] $ selfhost
[SELFHOST network-administrator] $ int
[INT network-administrator] $ 
```

# Kusto

```bash
# test kusto authentication
[PUBLIC] $ dri-                             # hit tab twice to get listing            
[PUBLIC] $ dri-certificate-loaded           # see kusto query
[PUBLIC] $ dri-certificate-loaded | kusto   # execute kusto query against public
[PUBLIC] $ fd-switch-to-dogfood             # switch to dogfood
[DOGFOOD] $ dri-certificate-loaded | kusto  # execute kusto query against dogfood
```

# Philosophy
- Good ideas do not require force. 
  - Developers should not be forced to adopt workflows, they should be enticed.
    - No one, least of all me, is going to force anyone to use this workflow. I find it useful and hope you might too.
- Data should be democratized. 
  - The data should be stored in a form agnostic to a particular workflow. Developers should not be coereced to adopt a workflows because that is where the data is housed. 
    - For example, Kusto queries should be in standalone files with a `.kusto` extensionKusto queries should not be embedded as strings in bash shell scripts.
- That there exists a solution is (at least) as important as how it is implemented.
  - Why bash? For one, few people use WSL2 and so installation would not collide with existing workflows.
- Automation does not imply the project is inherently difficult to use.
  - That I automated generation of fidalgo cli scripts is not an implicit statement I find the fidalgo cli inherently difficult to use. I automate because I don't want to type because I want to avoid typos.
