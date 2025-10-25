workspace {

    model {

        group enterprise {

            user = person "Пользователь" {
                tags "Person"
            }
            manager = person "Менеджер" {
                tags "Person"
            }

            bank_client = element "Bank" "" "" "External"
            recommendation_platform = element "Рекомендательная система" "" "" "External"
            notification_platform = element "Внешние сервисы уведомлений" "" "" "External"

            cinemaSystem = softwareSystem "Стриминговый сервис" {

                api_gateway = container "API Gateway" "Kong" "" "Service"
                kafka = container "Kafka" "Broker" "" "Service"
                rabbit_mq = container "RabbitMQ" "Broker" "" "Service"

                rabbit_mq -> recommendation_platform "Запросы/просмотры клиентов" "AMPQ"

                client_frontend = container "SPA application" {
                    description "Клиент для web application"

                    tags "FE" "Browser"

                    user -> this "Просматривает, ищет и покупает фильмы"
                    manager -> this "Управляет каталогом"
                }

                client_frontend -> api_gateway "Запросы клиента" "HTTP"

                group "Пользователи" {

                    user_server = container "User service" {
                        technology "Python, FastAPI"
                    }

                    user_database = container "User DB" {
                        tags "Database"

                        technology "PostgreSQL"

                        user_server -> this "Пользователи и их профили" "SQL"
                    }

                    api_gateway -> user_server "Запрашивает информацию о пользователе" "HTTP"

                    user_server -> kafka "Уведомление об изменении профиля" "TCP"
                }

                group "Уведомления" {
                    notification_server = container "Сервер" {
                        technology "Python, FastAPI"
                    }

                    notification_database = container "База данных" {
                        tags "Database"

                        technology "PostgreSQL"

                        notification_server -> this "Информация об уведомлениях/попытках отправки" "SQL"
                    }

                    api_gateway -> notification_server "Запрашивает информацию о последних уведомлениях" "HTTP"

                    kafka -> notification_server "Данные пользователя" "TCP"
                    kafka -> notification_server "Рассылка о фильмах" "TCP"
                    kafka -> notification_server "Информация о подписках/счетах" "TCP"
                }

                group "Каталог" {
                    catalog_server = container "Catalog service" {
                        technology "Python, FastAPI"
                    }

                    catalog_database = container "Catalog DB" {
                        tags "Database"

                        technology "PostgreSQL"

                        catalog_server -> this "Мета информация о фильтмах" "SQL"
                    }

                    catalog_s3 = container "Catalog S3" {
                        tags "Database"

                        technology "MinIO"

                        catalog_server -> this "Медиа информацию" "HTTP"
                    }

                    catalog_search = container "Catalog Search" {
                        tags "Database"

                        technology "ElasticSearch"

                        catalog_server -> this "Поисковой запрос" "HTTP"
                    }

                    api_gateway -> catalog_server "Запрашивает информацию о фильмах" "HTTP"
                    catalog_server -> rabbit_mq "Информация о запросах пользователя" "AMPQ"
                    catalog_server -> kafka "Уведомление о новых фильмах" "TCP"
                }

                group "Стриминг" {
                    stream_server = container "Stream Service" {
                        technology "Python, FastAPI"
                    }

                    stream_database = container "Stream DB" {
                        tags "Database"

                        technology "PostgreSQL"

                        stream_server -> this "Мета данные о видео" "SQL"
                    }

                    stream_s3 = container "Stream S3" {
                        tags "Database"

                        technology "MinIO"

                        stream_server -> this "Запрашивает чанк видео-файла" "SQL"
                    }

                    api_gateway -> stream_server "Запрашивает информацию о видео" "HTTP"
                    stream_server -> rabbit_mq "Информация о просмотрах пользователя" "AMPQ"
                }

                group "Биллинг" {
                    billing_server = container "Billing Service" {
                        technology "Python, FastAPI"
                    }

                    billing_database = container "Billing DB" {
                        tags "Database"

                        technology "PostgreSQL"

                        billing_server -> this "Оплаченные счета, подписки, скидки" "SQL"
                    }

                    billing_s3 = container "Billing S3" {
                        tags "Database"

                        technology "MinIO"

                        billing_server -> this "Сгенерированные чеки" "SQL"
                    }

                    api_gateway -> billing_server "Запрашивает информацию о транзакциях, подписках, скидках" "HTTP"
                    billing_server -> bank_client "Перенаправляет запросы на оплату услуг" "HTTP"
                    billing_server -> kafka "Уведомление о подписках/счетах" "TCP"
                }

                notification_server -> notification_platform "Отправка уведомлений" "HTTP"

            }
        }
    }

    views {

        systemContext cinemaSystem "Context" {
            include * recommendation_platform
            autoLayout lr
        }

        container cinemaSystem "Container" {
            include *
            autoLayout tb
        }

        theme default

        styles {
            element "External" {
                background #999999
                color #ffffff
            }
            element "Database" {
                shape Cylinder
            }
            element "Browser" {
                shape WebBrowser
            }
        }
    }
}