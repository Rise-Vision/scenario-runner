# Scenario Runner  [![Circle CI](https://circleci.com/gh/Rise-Vision/scenario-runner/tree/master.svg?style=svg)](https://circleci.com/gh/Rise-Vision/scenario-runner/tree/master)
### Introduction

The scenario runner will run e2e tests against configured target repositories.

This repository contains configuration scripts and data to run e2e tests from a virtual machine instance.
A [Google Compute Engine](https://cloud.google.com/compute/) instance is assumed.  If the VM is hosted on another platform there will be differences in the way environment variables and startup scripts are handled.

### Target Repository Requirements
Target repositories are configured in an instance environment variable named E2E_TARGETS.  The variable should contain target repository URLs separated by a pipe character. The URLs will be used in a `git clone` (eg: https://github.com/Rise-Vision/storage-client.git).  It is important to configure the **https** url scheme rather than **git** and the repository must be public or the runner won't be able to clone it.

Target repositories should contain their e2e tests and the tests should be executed with `npm run e2e`.  If any tests fail, a non-zero exit status should be returned from the npm command.

### Environment Variables
Any variables configured as instance metadata on the scenario runner machine instance will be available to the `npm run e2e` command as environment variables.  For example, username and password environment variables can be set on the VM instance and retrieved within the e2e tests of the target repository.  See `/package.json` and `/test/e2e/bootstrap.js' in the [Storage Client](https://github.com/Rise-Vision/storage-client) repository for a working example.  Notice that package.json calls nodejs with environment variable values which are then used in bootstrap.js.

For Google Compute Engine instances, the instance metadata can be configured through the [Google Developers Console](https://console.developers.google.com/project).

### Failed Test Notifications
The [run script](https://github.com/Rise-Vision/scenario-runner/blob/master/run.sh) is currently configured to send test failure notices using [RV-Logger](https://github.com/Rise-Vision/rv-logger).  For use outside of [Rise Vision](http://www.risevision.com), that section of the script will need to be removed or modified.

### Log output
The scenario runner will output the results of the npm run command to a file name E2E_OUTFILE in the target repository folder.  If the tests failed, the file will be saved as E2E_OUTFILE_[date & time of test run]. 

### Installation

 - Set up a vm with a scenario-runner user and add the required rsa keys to github, circle-ci, and the user's $HOME/.ssh directory
 - Add the startup script metadata to the VM instance if desired (see note below)
 - Add target repositories and any other environment variables to the instance metadata
 - Push to circle-ci

To automatically run the startup script at instance startup, add an instance metadata field as follows:
```
startup-script-url https://raw.githubusercontent.com/Rise-Vision/scenario-runner/master/startupscript.sh
```
See https://cloud.google.com/compute/docs/startupscript#googlecloudstorage


**Facilitator**

[Tyler Johnson](https://github.com/tejohnso "Tyler Johnson")
