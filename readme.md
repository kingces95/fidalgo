# Fidalgo Unix Shell Environment
A non-offical unix environment to support Fidalgo development. 

The shell 
- codifies the environment described in the team **wiki** and **one-note**.
- allows for **sharing kusto queries** in a democratized format (see `/kusto`).
- allows for **sharing http requests templates** ala PostMan (see `/http`).
- provides an environment for **incrementally** running integration tests locally as they are run in the pipeline.
- **eliminates excessive multi-factor authentication** when switching between environments.
- provides an environment for senior developers to **capture and share debug workflows** with junior developers.
- dogfoods Codespaces and DebBox.
- is optional (see [philosophy](nix/md/cpc.md)). 

# Codespace
Create a new codespace and enter the following in a bash terminal:
```bash
# hit CTRL+` to open a bash terminal
$ . profile.sh
```
Follow the onboarding flow.
# Hello World! 
Make a kusto query. Kusto queries are stored at `/kusto`.
```bash
# dump kusto query
[PUBLIC] $ fd-dri-certificate-active

# execute kusto query
[PUBLIC] $ fd-dri-certificate-active | fd-kusto-with-headers
```
# Incrementally run a test
- Open [`/nix/tst/sh/azure-ad.sh`](/nix/tst/sh/azure-ad.sh)
- Copy/Paste each line into the shell
```bash
[PUBLIC] $ fd-login-as-network-administrator
[PUBLIC] $ # ...
```
- After creating the dev-center, examine requests.
```bash
[PUBLIC] $ fd-dri-search-url ${NIX_ENV_PREFIX}-my-dev-center | fd-kusto | fd-line-fit

2022-06-08 09:17:11-AM 5017a21f91a322479d4d9f33d2ee0162 PUT  tm-centraluseuap.rp.fidalgo.azure.com /subscriptions/3de261df-f2d8-4c
```
- Dump the log trace for a request. Replace the operation id with an operation id taken from the result of the previous query.
```bash
[PUBLIC] $ fd-dri-stack 5017a21f91a322479d4d9f33d2ee0162 | fd-kusto | fd-line-fit
```
# Run the test again in dogfood
- Run test again, but this time in dogfood.
```bash
[PUBLIC] $ fd-switch-to-dogfood
[DOGFOOD] $ fd-login-as-network-administrator
[DOGFOOD] $ # ...
```
