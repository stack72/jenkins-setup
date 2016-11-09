##Prerequisites:

* Packer
* Terraform

These can be installed using homebrew if you have it as follows:

```
brew tap unofficial-cask/hashicorp-tap git@github.com:unofficial-cask/hashicorp-tap.git

brew install packer

brew install terraform
```
The latest versions of each is fine.

##Running Instructions:

Set AWS Access Keys for use:

```
export AWS_ACCESS_KEY_ID=<my access key>
export AWS_SECRET_ACCESS_KEY=<my secret access key>
```

To Build the AMI for use in Terraform:
```
cd packer/
make ami
```

That will build an ami named `ubuntu-jenkins-master-<date>` in us-west-2

To build the environment:

```
cd ../terraform
make plan
```

That should give an output ending:

```
Plan: 16 to add, 0 to change, 0 to destroy.
```

Then apply the changes if correct:

```
make apply
```

The output should look as follows (ignore the yellow text in Terraform 0.7.9 - that's an experimental feature we run in the backgroud that has no bearing on your infra!)

```
Apply complete! Resources: 16 added, 0 changed, 0 destroyed.
```

We print the Jenkins Address to the output. Take that address and put it into the browser and you will see a message that looks as follows:

```
To ensure Jenkins is securely set up by the administrator, a password has been written to the log (not sure where to find it?) and this file on the server:
```

To get the key, use the terminal output `jenkins_ssh_instructions`

e.g.

```
ssh -i ssh/jenkins ubuntu@35.162.20.42
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Put that password into the screen et voila!
