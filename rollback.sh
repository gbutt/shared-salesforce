#!/bin/bash -e

ROLLBACK_BRANCH=__rollback_branch

# get revert commits param
# examples:
#   HEAD          //reverts last commit
#   HEAD~1        //reverts next to last commit
#   HEAD~2..HEAD  //reverts last two commits - not the same as HEAD~1
REVERT_COMMITS=$1

# use revert to create a rollback commit
git revert --no-edit $REVERT_COMMITS

# push rollback commit to origin to kick off CI/CD
# git push

# create a rollback branch
git checkout -B $ROLLBACK_BRANCH

# revert the rollback commit
git revert --no-edit HEAD