# InsightsCI
Collection of helper files for CI process for Insights FRA Reports

# generate_tag.sh
Use this script to automatically update and tag a new version of your npm module as BrightspaceGitHubReader.
This script is expected to run during a Travis build. By default this script will update the minor version of your npm module. By using either **[increment major]** or **[increment patch]** notation inside your merge message, you can overwrite the default version upgrade of minor to the position of your choice. 

#### Travis Configuration
Ensure your travis configuration has the following lines.

```travis.yml
before_script:
# Clone the repository 
- git clone https://github.com/jmurray87/InsightsCI.git CI
# Make this script an executable
- chmod +x CI/generate_tag.sh

script:
# Name of your repository
- export REPO_NAME=YOUR-REPO-NAME
# Call this script to update and tag the version of your npm module
- "./CI/generate_tag.sh"
# Let travis know that this branch has been tagged.
- export TRAVIS_TAG=`git tag --points-at HEAD | head -n1`

env:
  global:
  # GITHUB_RELEASE_TOKEN (YourEncryptedToken) - for release/tagging process
  # This token should be generated from the BrightspaceGitHubReader
  - secure: YourEncryptedToken
  
branches:
  except:
  # Regex to stop CI from running on tag commits and branches
  - "/^v?[0-9]+\\.[0-9]+\\.[0-9]+.*$/"
```

#### Repository Configuration
Ensure that the BrightspaceGitHubReader Github user has write access to the repository you are applying this script to. Also make sure the personal access token it has generated has the correct permissions.

# queue-ci-message.js - [Orcavengers]
Use this script if the FRA is only using a package.json file and needs to be deployed and tested with Mastiff. You will require a **.publish_options.js** file in the root of your repository, as well as **"iron_mq": "^0.9.2"** as a devDependency. To run this script use the command ``` node queue-ci-message.js```. This will place a message into Iron.io, update the LE to use the new FRA version, and kick of a test via Mastiff.

#### Travis Configuration
Ensure your travis configuration has the following lines.

```travis.yml
env:
  global
  #IRON_IO_TOKEN (encryptedToken) - for iron io queue usage
  #IRON_IO_ID (encryptedID) - for iron io queue usage
  - secure: encryptedToken
  - secure: encryptedID
```

#### Sample .publish_options.js file

```.json
module.exports = {
  "files": "./dist/**",
  "moduleType": "app",
  "targetDirectory": <YOUR_REPO_NAME>,
  "creds": {
    "key": <KEY_TO_PUBLISH_TO_CDN>,
    "secretVar": process.env.SECRET_KEY
  },
  "version": process.env.TRAVIS_TAG
};

```