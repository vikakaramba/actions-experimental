GitHub Actions experimental repositry
==========

## Tips


### Run local
Use [nektos/act: Run your GitHub Actions locally 🚀](https://github.com/nektos/act)
[Workflow runs \| GitHub Developer Guide](https://developer.github.com/v3/actions/workflow-runs/)


### API with curl
```sh
# https://developer.github.com/v3/actions/workflow-runs/#list-workflow-runs
curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOS}/actions/workflows/${workflow_id}/runs"

# https://developer.github.com/v3/actions/workflow-runs/#get-a-workflow-run
curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOS}/actions/runs/${run_id}"

# https://developer.github.com/v3/actions/workflow-runs/#get-workflow-run-usage  ※public beta
curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOS}/actions/runs/${run_id}/timing"
```


[Artifacts \| GitHub Developer Guide](https://developer.github.com/v3/actions/artifacts/)


```sh
# https://developer.github.com/v3/actions/artifacts/#list-artifacts-for-a-repository
curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOS}/actions/artifacts"

# https://developer.github.com/v3/actions/artifacts/#list-workflow-run-artifacts
run_id=xxx
curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOS}/actions/runs/${run_id}/artifacts"

# https://developer.github.com/v3/actions/artifacts/#get-an-artifact
artifact_id=xxx
curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOS}/actions/artifacts/${artifact_id}"

# https://developer.github.com/v3/actions/artifacts/#download-an-artifact
# curl -v -L -u octocat:$token -o Rails.zip "https://api.github.com/repos/octo-org/octo-repo/actions/artifacts/30209828/zip"
curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOS}/actions/artifacts/${artifact_id}/:archive_format"

# https://developer.github.com/v3/actions/artifacts/#delete-an-artifact
curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOS}/actions/artifacts/${artifact_id}"

```

[Gists \| GitHub Developer Guide](https://developer.github.com/v3/gists/)

```sh
# https://developer.github.com/v3/gists/#list-gists-for-a-user
curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/users/${GITHUB_OWNER}/gists"

# https://developer.github.com/v3/gists/#get-a-gist
gist_id=xxx
curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/gists/${gist_id}"
```
