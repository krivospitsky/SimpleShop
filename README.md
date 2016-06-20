shop
====

Для развертывания окружения разработчика надо поставить:

* Ruby 2.0.0
* Postgresql 9.3+ или SQLite
* ImageMagick

Скопировать конфиги:

    cp config/database.yml.sample config/database.yml

Исправить данные подключения к базе данных в `config/database.yml`

Для забивания базы необходимыми данными с нуля выполнить:

    rake db:seed
