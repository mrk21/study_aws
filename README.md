# study_aws

This repository is used to be studying AWS

## Introduction

You need to follow the steps listed below in order to set up basic environment.

### Install aws cli tools

```sh
$ sudo pip install awscli
$ aws configure
AWS Access Key ID [None]: your key
AWS Secret Access Key [None]: your secret key
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

#### Refer to

* [AWS コマンドラインインターフェイス](https://aws.amazon.com/jp/cli/)
* [AWS CLI のインストールと設定 - Amazon Kinesis](http://docs.aws.amazon.com/ja_jp/kinesis/latest/dev/kinesis-tutorial-cli-installation.html)
* [Getting Set Up with the AWS Command Line Interface - AWS Command Line Interface](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html#cli-signup)
* [AWS CLIのインストールから初期設定メモ - Qiita](http://qiita.com/n0bisuke/items/1ea245318283fa118f4a)

### Install Ruby AWS SDK

```sh
$ rbenv install
$ gem install bundler
$ bundle install --path=vendor/bundle
```

#### Refer to

* [AWS SDK for Ruby | アマゾン ウェブ サービス（AWS 日本語）](https://aws.amazon.com/jp/sdk-for-ruby/)
* [AWS SDK for Ruby(V2)を利用して、Amazon S3を操作する - Qiita](http://qiita.com/itayan/items/112f23cbff13e49cdb53)
