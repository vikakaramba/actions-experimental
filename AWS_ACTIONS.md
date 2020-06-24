## aws-actionsの実例

### Fargateへのデプロイ
See: https://dev.classmethod.jp/articles/github-actions-fargate-deploy/


#### セットアップ

1. Dockerfileを用意（nginxが動くだけのものでOK）
2. AWS consoleでECSクラスタを Fargate で作成（`exmerimental-fargate-cluster`）
    - 新しいVPCを作成する（デフォルトVPCを流用すると、後で削除する際にメンドイ為） `10.90.0.0/16`
    - Container Insights を有効にしておく（試したい為）
3. ~~クラスタで作成されたVPCのサブネットはpublic（作成時に選べない）、且つサービス作成時に選択出来るサブネットがprivateのみ、という仕様でconflictしてしまっているので、別途VPC内にprivateサブネットを作成する~~  ___何かpuiblic subnetでもイケた___
    - ~~~AWS consoleからVPCを開く　※作成したVPCに名前をつけておく（ついでに）`exmerimental-fargate-cluster-vpc`~~~
    - ~~~サブネットを作成する。azはa, cで、それぞれ未使用CIDRを割り当てて作成~~~
4. AWS consoleでECRリポジトリを作成（`githubactions-nginx`）
5. AWS consoleでこのactionを試すためのIAMユーザーを作成
    - `AmazonECS_FullAccess`, `AmazonEC2ContainerRegistryFullAccess` ポリシーを付与しておく
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


actions workflowをpull_request起動にしてみて、prを作成してみると、、、

- deploy stepが `##[error]arn:aws:ecs:ap-northeast-1:***:service/spot-ecs is MISSING` というエラーでコケる
  - これは結局、「先にtask jsonでtaskは作られるが、serviceは作られない」事に起因していて、1回コケるのはやむを得ないのでは？？
- しょうがないので、このtaskに紐付くserviceをAWS consoleの タスク定義 から作って再トライ
  - 起動タイプは `FARGATE`, サービス名は `githubactions-nginx-service` タスクの数は取り敢えず `1`, サブネットは `ALBでも割り当てるpublicなもの2つ`, ロードバランシングは `ALB`（要・別途作成）, ロードバランス用のコンテナ `nginxのコンテナを追加しておく, ターゲットグループ名はALB作成時に（ルーティング作成時に）作るもの`
- ALB: 名前 `githubactions-nginx-service-alb`, VPC `Fargateクラスタ用に作成したVPC`, AZ `2つ、サブネットはVPC内のpublicなやつ`, SG `task定義適用時に作成された 80 ポートを許可しているSG`, ルーティング `ghactions-nginx-service-alb-tg` `ターゲットグループの種類は IP で。`
- 作成したサービス名をactions yamlに設定して再トライ

See: [Amazon ECS の動的ポートマッピングをセットアップする](https://aws.amazon.com/jp/premiumsupport/knowledge-center/dynamic-port-mapping-ecs/)
