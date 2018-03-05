VkontakteApi.configure do |config|
  # параметры, необходимые для авторизации средствами vkontakte_api
  # (не нужны при использовании сторонней авторизации)
  # config.app_id       = '5526187'
  # config.app_secret   = 'ECnVSdn5k9yybJXfq1gk'
  # config.redirect_uri = 'http://example.com/oauth/callback'

  # faraday-адаптер для сетевых запросов
  # config.adapter = :net_http
  # HTTP-метод для вызова методов API (:get или :post)
  # config.http_verb = :post
  # параметры для faraday-соединения
  # config.faraday_options = {
  #   ssl: {
  #     ca_path:  '/usr/lib/ssl/certs'
  #   },
  #   proxy: {
  #     uri:      'http://proxy.example.com',
  #     user:     'foo',
  #     password: 'bar'
  #   }
  # }
  # максимальное количество повторов запроса при ошибках
  # работает только если переключить http_verb в :get
  # config.max_retries = 2

  # логгер
  # config.logger        = Rails.logger
  # config.log_requests  = true  # URL-ы запросов
  # config.log_errors    = true  # ошибки
  # config.log_responses = false # удачные ответы

  # используемая версия API
  config.api_version = '5.21'
end