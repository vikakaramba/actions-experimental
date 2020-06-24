GitHub Actions experimental repositry
==========


## aws-actionsの実例

### Fargateへのデプロイ
[docker build \-t test\-nginx\. && docker run \-p 8080:80 test\-nginx](https://dev.classmethod.jp/articles/github-actions-fargate-deploy/)


セットアップ

1. Dockerfileを用意（nginxが動くだけのものでOK）
2. AWS consoleでECSクラスタを Fargate で作成（`exmerimental-fargate-cluster`）
    - 新しいVPCを作成する（デフォルトVPCを流用すると、後で削除する際にメンドイ為） `10.90.0.0/16`
    - Container Insights を有効にしておく（試したい為）
3. ~~クラスタで作成されたVPCのサブネットはpublic（作成時に選べない）、且つサービス作成時に選択出来るサブネットがprivateのみ、という仕様でconflictしてしまっているので、別途VPC内にprivateサブネットを作成する~~  ___何かpuiblic subnetでもイケた___
    - ~~~AWS consoleからVPCを開く　※作成したVPCに名前をつけておく（ついでに）`exmerimental-fargate-cluster-vpc`~~~
    - ~~~サブネットを作成する。azはa, cで、それぞれ未使用CIDRを割り当てて作成~~~
4. AWS consoleでECRリポジトリを作成（`githubactions-nginx`）
5. AWS consoleでこのactionを試すためのIAMユーザーを作成
    - `AmazonECS_FullAccess`, `AmazonEC2ContainerRegistryFullAccess` ポリシーを付与しておく￥
6. タスク定義のjsonを作成（task-definition.json）。内容はファイルを参照
    - 参考: [タスク定義テンプレート(Fargate)](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/create-task-definition.html#task-definition-template)
    - AWS consoleから実施する場合は、[タスク定義の作成 \- Amazon Elastic Container Service](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/create-task-definition.html) や [タスク定義の作成 \- Amazon ECS](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/create-task-definition.html) を参照
7. 公式 aws-actions から落としてきたaction yamlを修正する
    - region
    - REPOSITORY
    - container-name
    - service
    - cluster
8. githubのsettingsから2つのシークレットを登録
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY


actions workflowをpull_request起動にしてみて、prを作成してみる
→ deploy stepが `##[error]arn:aws:ecs:ap-northeast-1:***:service/spot-ecs is MISSING` というエラーでコケる
→ これは結局、「先にtask jsonでtaskは作られるが、serviceは作られない」事に起因していて、1回コケるのはやむを得ないのでは？？
→ しょうがないので、このtaskに紐付くserviceをAWS consoleの タスク定義 から作って再トライ。起動タイプは `FARGATE`, サービス名は `githubactions-nginx-service` タスクの数は取り敢えず `1`, サブネットは `ALBでも割り当てるpublicなもの2つ`, ロードバランシングは `ALB`（要・別途作成）, ロードバランス用のコンテナ `nginxのコンテナを追加しておく, ターゲットグループ名はALB作成時に（ルーティング作成時に）作るもの`
→ ALB: 名前 `githubactions-nginx-service-alb`, VPC `Fargateクラスタ用に作成したVPC`, AZ `2つ、サブネットはVPC内のpublicなやつ`, SG `task定義適用時に作成された 80 ポートを許可しているSG`, ルーティング `ghactions-nginx-service-alb-tg` `ターゲットグループの種類は IP で。`
→ 作成したサービス名をactions yamlに設定して再挑戦！

See: [Amazon ECS の動的ポートマッピングをセットアップする](https://aws.amazon.com/jp/premiumsupport/knowledge-center/dynamic-port-mapping-ecs/)


## Tips


### Run local
Use [nektos/act: Run your GitHub Actions locally 🚀](https://github.com/nektos/act)


### API with curl

[Workflow runs \| GitHub Developer Guide](https://developer.github.com/v3/actions/workflow-runs/)

```sh
# https://developer.github.com/v3/actions/workflow-runs/#list-workflow-runs
workflow_id=xxx
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

#### jq

sample.json

```json
{
  "id": 123456789,
  "node_id": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXMzE2",
  "head_branch": "fix-ci",
  "head_sha": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "run_number": 46,
  "event": "pull_request",
  "status": "completed",
  "conclusion": "success",
  "workflow_id": 987654,
  "url": "https://api.github.com/repos/goldeneggg/structil/actions/runs/23456789",
  "html_url": "https://github.com/goldeneggg/structil/actions/runs/23456789",
  "pull_requests": [
    {
      "url": "https://api.github.com/repos/goldeneggg/structil/pulls/19",
      "id": 334455667,
      "number": 19,
      "head": {
        "ref": "fix-ci",
        "sha": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "repo": {
          "id": 445566778,
          "url": "https://api.github.com/repos/goldeneggg/structil",
          "name": "structil"
        }
      },
      "base": {
        "ref": "master",
        "sha": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "repo": {
          "id": 556677889,
          "url": "https://api.github.com/repos/goldeneggg/structil",
          "name": "structil"
        }
      }
    }
  ],
  "created_at": "2020-06-12T01:03:59Z",
  "updated_at": "2020-06-12T01:11:20Z"
}
```


```sh
# get only "id"
$ cat sample.json | jq '.id'
123456789

# get only "id" and "node_id"
$ cat sample.json | jq '. | {id, node_id}'
{
  "id": 123456789,
  "node_id": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXMzE2"
}

# get list "pull_request"
$ cat sample.json | jq '.pull_requests'
[
  {
    "url": "https://api.github.com/repos/goldeneggg/structil/pulls/19",
    "id": 334455667,
    "number": 19,
    "head": {
      "ref": "fix-ci",
      "sha": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "repo": {
        "id": 445566778,
        "url": "https://api.github.com/repos/goldeneggg/structil",
        "name": "structil"
      }
    },
    "base": {
      "ref": "master",
      "sha": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "repo": {
        "id": 556677889,
        "url": "https://api.github.com/repos/goldeneggg/structil",
        "name": "structil"
      }
    }
  }
]

# get element index 0 from list "pull_request"
$ cat sample.json | jq '.pull_requests[0]'
{
  "url": "https://api.github.com/repos/goldeneggg/structil/pulls/19",
  "id": 334455667,
  "number": 19,
  "head": {
    "ref": "fix-ci",
    "sha": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "repo": {
      "id": 445566778,
      "url": "https://api.github.com/repos/goldeneggg/structil",
      "name": "structil"
    }
  },
  "base": {
    "ref": "master",
    "sha": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "repo": {
      "id": 556677889,
      "url": "https://api.github.com/repos/goldeneggg/structil",
      "name": "structil"
    }
  }
}

# get nested element from element index 0 from list "pull_request"
$ cat sample.json | jq '.pull_requests[0].head.ref'
"fix-ci"
```
