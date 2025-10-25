from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_HOST: str = 'localhost'
    APP_PORT: int = 8082

    KAFKA_HOST: str = 'localhost'
    KAFKA_PORT: int = 9092

    # Topics
    movie_events_topic: str = 'movie-events'
    user_events_topic: str = 'user-events'
    payment_events_topic: str = 'payment-events'

    class Config:
        env_file = '.env'

    @property
    def kafka_url(self):
        return f'{self.KAFKA_HOST}:{self.KAFKA_PORT}'


settings = Settings()
