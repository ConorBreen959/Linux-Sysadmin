#!/bin/bash

if [[ $1 != "--init" ]] && [[ $1 != "--run" ]]; then

    printf "================================================================\n\n"
    printf "Automatic Project Commit Tool\n\n"
    printf "  This tool is designed to push multiple projects to their current branch on Git.\n"
    printf "  Be warned, it is not designed as a fully automated solution for managing version control, so make sure your projects are on the correct branch and anything you don't want committed is in .gitignore.\n\n"
    echo "****************************************************************"
    printf "\n\n"
    printf "Usage Flags:\n\n"
    printf -- "  --init :\tUsed to update the list of projects stored in a text file project_list.txt.\n"
    printf "\t\tYou can either add new projects to the list or replace the current list. Any more complex editing of this list can be done with a text editor.\n\n"
    printf -- "  --run  :\tThis flag commits and pushes the current project list. The user can specify a commit message for each project, or use the default which is set at the top of the script.\n\n"
    printf "================================================================\n\n"

fi


if [[ ! -f project_list.txt ]]; then
    touch project_list.txt
fi


default_commit_message="End of day commit"


function get_full_path() {
    user=$(echo $USER)
    full_path=$(find /home/$user -maxdepth 2 -name $1 -type d)
    echo $full_path
}


function yes_no() {
    read -p "[Y]/[N] " answer
    if [[ $answer != "Y" ]] && [[ $answer != "N" ]]; then
        printf "Sorry, please enter a valid answer.\n"
        yes_no
    fi
}


function collect_projects() { 
    printf "Enter project name(s):\n\n"
    projects=()
    read var
    projects+=($var)
    while [[ $var != "done" ]]; do
        read var
        projects+=($var)

    done
    projects=( "${projects[@]/done}" )
    printf "\n"
    project_base_dirs=()
    for project in ${projects[@]}; do
        project_dir=$(get_full_path $project)
        if [[ -z $project_dir ]]; then
            printf "No project found, please check project name.\n"
        else
            project_base_dirs+=($project_dir)
        fi
    done
}


function commit_project() {
    $1
    cd $project
    branch=$(git rev-parse --abbrev-ref HEAD)
    git add .
    git commit -m $2
    git push -u origin $branch
}

if [[ $1 == "--init" ]]; then
    
    printf "================================================================\n\n"
    printf "Initialising project selection for automatic git commit\n\n"
    printf "Current project list is:\n\n"
    for name in $(cat project_list.txt); do
        echo $(basename $name)
    done
    printf "\n"
    printf "\nWould you like to add new projects to the existing list?\n\n"
    yes_no
    if [[ $answer == "Y" ]]; then
        collect_projects
        printf "%s\n" "${project_base_dirs[@]}" >> project_list.txt
    elif [[ $answer == "N" ]]; then
        printf "Would you like to choose new projects?\n\n"
        yes_no
        if [[ $answer == "Y" ]]; then
            collect_projects
            printf "%s\n" "${project_base_dirs[@]}" > project_list.txt
        else
            printf "No projects selected, bailing out\n"
        fi
    fi
    printf "Chosen projects:\n\n"
    for name in $(cat project_list.txt); do
        echo $(basename $name)
    done
fi

if [[ $1 == "--run" ]]; then

    printf "================================================================\n\n"
    printf "Committing chosen projects...\n\n"
    for project in $(cat project_list.txt); do
        basename=$(basename $project)
        read -r -p "${basename}: " commit_message
        if [[ -z $commit_message ]]; then
            commit_message=$default_commit_message
        fi
        commit_project $project $commit_message
    done
fi

