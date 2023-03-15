Instructions
============

A summary of the instructions required to publish a Java package to the
[Central Repository](https://central.sonatype.org/), assuming the project is
hosted in a public repository on GitHub.

To simplify the instructions, in the following we assume that:

- `myorg` is the name of your GitHub organization (or user name)
- `myproject` is the name of the package to publish
- `1.1.1` is the version number of the package to deploy

Preparation
-----------

A first set of steps needs to be done only once for every GitHub user or
organization.

### Create a GPG key pair

    gpg --full-generate-key

Make sure to store the passphrase and key ID in a safe location. To retrieve
the key ID, you can type:

    gpg --list-secret-keys --keyid-format=long

You get an output like this:

    /Users/hubot/.gnupg/secring.gpg
    --------------------------------
    sec   rsa3072/E1418D7CD4B176AC 2023-03-07 [SC] [expires: 2024-08-28]
          E04990583ABAB92AFC84AE1DD1419C7CD4A176AC
    uid                 [ultimate] Hubot <hubot@example.com>
    ssb   rsa3072/9BEEDD702DD88228 2023-03-07 [E] [expires: 2024-08-28]

The (short) key ID in this case is E1418D7CD4B176AC.

In case you want to export the key to use on another machine, you can type:

    gpg --export-secret-key -a > secretkey.asc

On the other machine:

    gpg --import secretkey.asc
    gpg --edit-key <key-id> trust quit

And enter 5 (I trust ultimately).

### Publish the GPG public key

    gpg --keyserver keys.opengpg.org --send-keys <key-id>

Wait a few minutes for the key to become discoverable.

### Create an account on Central Repository

There are [instructions](https://central.sonatype.org/publish/publish-guide)
on how to register your GitHub user/organization to the Central Repository.

The first step is to [create an account](https://issues.sonatype.org/secure/Signup!default.jspa)
on Jira if you do not have one. Make sure you use the same address as the one
for which you created a GPG key above.

### Create a new ticket

Then, [create a new ticket](https://issues.sonatype.org/secure/CreateIssue.jspa?pid=10134&issuetype=21),
by making sure the issue type is *New Project*. Complete the fields:

- Summary: does not matter
- Group Id: `io.github.myorg`
- Project URL: `https://github.com/myorg/myproject` (or any other web site for
  the project)
- SCM url: `https://github.com/myorg/myproject.git`
- Username: your user name on the Jira platform

Your ticket will be given an ID, e.g. `OSSRH-12345`.

### Create a repository

You must prove that you are the owner of the username/organization. You do so
by creating a public repository on GitHub with the same name as the ticket ID.
Here it would be `myorg/OSSRH-12345`.

### Open the ticket

Go back to your ticket in the Jira platform. Wait until you get a message
asking you to create the aforementioned repository (may take from a few minutes
to a few days). Follow the instructions (which probably ask you to change the
issue's status to *Open*).

Deployment
----------

The next step are adapted from the
[instructions](https://central.sonatype.org/publish/publish-manual/)
for manual deployment.

### Prepare bundle

Prepare 4 files:

- `myproject-1.1.1.jar`
- `myproject-1.1.1-sources.jar`
- `myproject-1.1.1-javadoc.jar`
- `myproject-1.1.1.pom`

The latter file is the renamed `pom.xml` that contains declaration about
the project's name, author, etc. Make sure the version number in this file
exactly matches that of the filenames.

Each of these files must be signed. This can be done with:

    gpg -ab myproject-1.1.1.jar

If successful, this command creates a new file `myproject-1.1.1.jar.asc`.
Repeat this process for the three other files. To make sure the signature is
valid, you can also run:

    gpg --verify myproject-1.1.1.jar.asc

You then create a JAR file called `bundle.jar` that contains all 8 files
(the 4 original + the 4 signatures):

    jar -cvf bundle.jar <list of all files>

### Upload bundle

- Log into [OSSRH](https://s01.oss.sonatype.org/) and select *Staging Upload* in
the options on the right.
- Select **Artifact Bundle** from the *Upload Mode* dropdown.
- Select the `bundle.jar` file and click on **Upload Bundle**.

The 
