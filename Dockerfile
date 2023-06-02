# Dockerfileは、docker-compose.ymlでいうWeb（app）にあたるところの設定を行うファイルである

FROM ruby:3.0
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -y nodejs yarn \
    && mkdir /nesage_app

# webまたはappコンテナ内の「/nesage_app」ディレクトリ以下に、以下のファイルたちをインストールする
WORKDIR /nesage_app

COPY Gemfile /nesage_app/Gemfile
COPY Gemfile.lock /nesage_app/Gemfile.lock
RUN bundle install
COPY . /nesage_app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]