#/bin/bash

set -ex

### 
echo Make sure you have created the Repository on GitHub before proceeding...

echo

# Initialize Git for the Project Directory
git init

# Adds the files in the local repository and stages them for commit. To unstage a file, use 'git reset HEAD YOUR-FILE'
git add .

# Commits the tracked changes and prepares them to be pushed to a remote repository. To remove this commit and modify the file, use 'git reset --soft HEAD~1' and commit and add the file again.
git commit -m "First commit"

# Set the new remote
git remote add origin remoteURL

# Verifies the new remote URL
git remote -v

# Pushes the changes in your local repository up to the remote repository you specified as the origin
git push origin master

