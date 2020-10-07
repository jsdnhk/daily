# Push the latest commit to the shared folder

param([string]$project_push="", [string]$project_shared="")
$current_dir = $pwd
$folder_push = ""
$folder_shared = ""
$status = 0
function Push-Shared([string]$project_push, [string]$project_shared) {
  $project_push = $project_push -eq "" ? $(split-path $pwd -leaf) : $project_push
  $path_push = $(join-path $folder_push $project_push)
  $project_shared = $project_shared -eq "" ? $project_push : $project_shared
  $path_shared = $(join-path $folder_shared $project_shared)
  echo "Clearing the git repo in ${path_shared}..."
  if (Test-Path $path_shared -PathType Any) {
    Remove-Item "${path_shared}\*" -Recurse -Force
  }
  echo "Cloning from ${path_push} to shared folder ..."
  git clone $path_push $path_shared
  echo "The shared folder files after pushing:"
  Get-ChildItem $path_shared
  echo "The shared folder git-log after pushing:"
  Set-Location $path_shared
  git log --graph -3
  echo "Hard pushing of project[$project_push] to shared completed!"
  Set-Location $current_dir
}

Push-Shared $project_push $project_shared
