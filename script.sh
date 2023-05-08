#!/bin/bash

reposLocation="$HOME/Developer/social-novapro"
# reposLocation="~/git/social-media"
# cd "$reposLocation"
# follow name of repo
repos=("social-backend" "social-frontend-plain")
# repos=("https://github.com/social-novapro/social-backend" "https://github.com/social-novapro/social-frontend-plain")

currentCommits=()

cloneRepos() {
    for repo in ${repos[@]}
    do
        cd ./repos
        git clone $repo
    done
}

currentCommits() {
    for (( i=1; i<=${#repos[@]}; i++ ))
    do
        cd "${reposLocation}/${repos[i-1]}"
        currentCommits[i]=$(git rev-parse HEAD)
        echo "Current commit for ${repos[i-1]}: ${currentCommits[i]}"
    done
}

programLoop() {
    while true
    do
        checkForCommits

        sleep 5
    done
}

checkForCommits() {
    for (( i=1; i<=${#repos[@]}; i++ ))
    do
        cd "${reposLocation}/${repos[i-1]}"

        latest_commit=$(git rev-parse HEAD)
        last_commit=${currentCommits[i]}

        if [ "$latest_commit" != "$last_commit" ]
        then
            echo "New commit detected! ${repos[i-1]} : ${latest_commit} vs ${last_commit}"
            echo "Pulling latest changes"
            git pull

            echo "Building"
            if [ "${repos[i-1]}" == "social-backend" ]
            then
                echo "Building backend"
                cd "${reposLocation}/${repos[i-1]}"
                npm install
                docker build -t novapro/interact_api . 
                # docker tag novapro/interact_api registry.xnet.com:5000/novapro/interact_api:latest
                # docker push registry.xnet.com:5000/novapro/interact_api
                docker run -p 5002:5002 --name interact_api -d novapro/interact_api
            else
                echo "Building frontend"
                cd "${reposLocation}/${repos[i-1]}"
                docker build -t novapro/interact . 
                # docker tag novapro/interact registry.xnet.com:5000/novapro/interact:latest
                # docker push registry.xnet.com:5000/novapro/interact
                docker run -p 5500:433 --name interact -d novapro/interact 
            fi

            currentCommits[i]=$(git rev-parse HEAD)

            # Code to update your application goes here
        else 
            echo "No new commits ${repos[i-1]} : ${latest_commit}"
        fi

    done
}



currentCommits
sleep 5
programLoop
# for i in "${!repos[@]}"
# do
#   currentCommits+=("${commitMessages[i]// /$'\n'}")
# done

# Get the hash of the last commit
