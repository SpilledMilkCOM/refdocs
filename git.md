# Git Reference

# :computer: For best results use the command line
It might seem more complicated, but it leads to an understanding that will get you through any troubles you run in to.

# :arrow_down: Get it [here](https://git-scm.com/download/win).

#The most commonly used commands:
 Command | Description | Example |
|-----------|-----------|---------|
|git status | Tells you what is going on with your working folder | git status |
|git fetch  |     Updates your local repo from the remote, but doesn't modify your working folder.| git fetch |
|git add    |     Gets your changes ready to commit by staging them.| git add * |
|git commit |     Create a changeset stored in the local repo| git commit -m"commit message" |
|git pull   |     Update the files in your working folder from changes that were fetched.| git pull |
|git branch |   Create or switch branches.| git branch dev |
|git push   |    Send changesets to the remote server. | git push |

If you know how to use the above commands easily, then anything else can be looked up on the google at the time of need.  Additionally, some very useful commands that don't get used as often can be found below.

#Useful Commands:
 Command | Description | Example |
|-----------|-----------|---------|
|git remote| Manage interactions with tracked repositories|git remote add _name url_|
|git remote update|Refresh remote branches (on your machine) to match the server (remote). This will add or remove any remote branches defined in your local git. *(it basically cleans things up)* if used as shown in the example.| git remote update origin --prune|
|git reset|    Start over by wiping changes. Force it to cooperate as shown in the example. | git reset --hard HEAD |
|git reset|    You've made changes in `dev` and you can't push those changes due to the imposed restrictions.  You have already created a new local branch from `dev` so you don't lose the commits you want, but now your local `dev` is all messed up.  Execute the following commands:  | git fetch origin
| |Then... |git reset --hard origin/dev |
|git clean|    Remove untracked modifications too (reset just deals with tracked files).| git clean -df |
