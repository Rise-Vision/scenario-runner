# Scenario Runner  [![Circle CI](https://circleci.com/gh/Rise-Vision/scenario-runner/tree/master.svg?style=svg)](https://circleci.com/gh/Rise-Vision/scenario-runner/tree/master)
## Introduction

Runs e2e scenario tests from an external client machine.
Will clone repositories configured in targets.txt
Target repositories will be run with npm run e2e
Errors will be alerted in Hipchat and emailed.

## Installation

 - Set up a vm to use the startup script contained in this repository
 - Make sure rsa keys are shared between github, circle-ci, and the vm
 - Add target repositories to the target file
 - Push to circle-ci

**Facilitator**

[Tyler Johnson](https://github.com/tejohnso "Tyler Johnson")
