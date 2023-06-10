FROM ruby:3.0.6

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    nodejs

# yarnのインストール
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -y yarn

# 必要なファイルをコピーしてGemをインストール
WORKDIR /nesage_app
COPY Gemfile /nesage_app/Gemfile
COPY Gemfile.lock /nesage_app/Gemfile.lock
RUN bundle install

# アプリケーションのファイルをコピー
COPY . /nesage_app

# entrypoint.shのコピーと実行許可の設定
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# コンテナのエントリーポイントとして設定
ENTRYPOINT ["entrypoint.sh"]

# ポートの公開
EXPOSE 3000

# Railsサーバーの起動コマンド
CMD ["rails", "server", "-b", "0.0.0.0"]
