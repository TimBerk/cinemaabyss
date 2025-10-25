workspace "Cinema" "Учебный проект для YP" {

    !identifiers hierarchical

    model {
        user = person "Пользователь" {
            tags "Person"
        }
        manager = person "Менеджер" {
            tags "Person"
        }

        api_gateway = element "API Gateway" "Kong" "" "Service"
        kafka = element "Kafka" "Broker" "" "Service"
        rabbit_mq = element "RabbitMQ" "Broker" "" "Service"

        bank_client = element "Bank" "" "" "External"
        recommendation_platform = element "Рекомендательная система" "" "" "External"
        notification_platform = element "Внешние сервисы уведомлений" "" "" "External"

        rabbit_mq -> recommendation_platform "Запросы/просмотры клиентов" "AMPQ"

        client_frontend = softwareSystem "FE application" {
            description "Клиент для web application"

            tags "FE"

            user -> this "Просматривает, ищет и покупает фильмы"
            manager -> this "Управляет каталогом"
        }

        client_frontend -> api_gateway "Запросы клиента" "HTTP"

        auth = softwareSystem "Пользователи" {
            description "Сервис для управления пользователями, их профилями, ролями и правами"

            server = container "Сервер" {
                technology "Python, FastAPI"
            }

            database = container "База данных" {
                tags "Database"

                technology "PostgreSQL"

                server -> this "Пользователи и их профили" "SQL"
            }

            api_gateway -> this "Запрашивает информацию о пользователе" "HTTP"

            this -> kafka "Уведомление об изменении профиля" "TCP"
        }

        catalog = softwareSystem "Каталог" {
            description "Сервис для управления каталогом фильмов"

            server = container "Сервер" {
                technology "Python, FastAPI"
            }

            database = container "База данных" {
                tags "Database"

                technology "PostgreSQL"

                server -> this "Мета информация о фильтмах" "SQL"
            }

            s3 = container "Object Storage" {
                tags "Database"

                technology "MinIO"

                server -> this "Медиа информацию" "HTTP"
            }

            search = container "Search" {
                tags "Database"

                technology "ElasticSearch"

                server -> this "Поисковой запрос" "HTTP"
            }

            api_gateway -> this "Запрашивает информацию о фильмах" "HTTP"
            this -> rabbit_mq "Информация о запросах пользователя" "AMPQ"
            this -> kafka "Уведомление о новых фильмах" "TCP"
        }

        stream = softwareSystem "Streaming" {
            description "Сервис для показа фильмов"

            server = container "Сервер" {
                technology "Python, FastAPI"
            }

            database = container "База данных" {
                tags "Database"

                technology "PostgreSQL"

                server -> this "Мета данные о видео" "SQL"
            }

            s3 = container "Object Storage" {
                tags "Database"

                technology "MinIO"

                server -> this "Запрашивает чанк видео-файла" "SQL"
            }

            api_gateway -> this "Запрашивает информацию о видео" "HTTP"
            this -> rabbit_mq "Информация о просмотрах пользователя" "AMPQ"
        }

        billing = softwareSystem "Billing" {
            description "Сервис для управления финансами"

            server = container "Сервер" {
                technology "Python, FastAPI"
            }

            database = container "База данных" {
                tags "Database"

                technology "PostgreSQL"

                server -> this "Оплаченные счета, подписки, скидки" "SQL"
            }

            s3 = container "Object Storage" {
                tags "Database"

                technology "MinIO"

                server -> this "Сгенерированные чеки" "SQL"
            }

            api_gateway -> this "Запрашивает информацию о транзакциях, подписках, скидках" "HTTP"
            this -> bank_client "Перенаправляет запросы на оплату услуг" "HTTP"
            this -> kafka "Уведомление о подписках/счетах" "TCP"
        }

        notification = softwareSystem "Уведомления" {
            description "Сервис для управления уведомлениями, их отправкой через разные каналы"

            server = container "Сервер" {
                technology "Python, FastAPI"
            }

            database = container "База данных" {
                tags "Database"

                technology "PostgreSQL"

                server -> this "Информация об уведомлениях/попытках отправки" "SQL"
            }

            api_gateway -> this "Запрашивает информацию о последних уведомлениях" "HTTP"

            kafka -> this "Данные пользователя" "TCP"
            kafka -> this "Рассылка о фильмах" "TCP"
            kafka -> this "Информация о подписках/счетах" "TCP"
        }

        notification -> notification_platform "Отправка уведомлений" "HTTP"

    }

    views {
        systemlandscape "SystemLandscape" {
            include * recommendation_platform
            autolayout lr
        }

        theme default

        styles {
            element "Service" {
                shape RoundedBox
                background #438CD4
                color #ffffff
            }

            element "FE" {
                shape WebBrowser
            }

            element "Database" {
                shape cylinder
                background #438CD4
                color #ffffff
            }

            element "External" {
                shape RoundedBox
            }
        }
    }
}