from faststream.confluent import KafkaBroker, KafkaMessage
from structlog import get_logger

from src.settings import settings
from src.events import UserEventSchema, MovieEventSchema, PaymentEventSchema
from src.utils import validate_message

logger = get_logger(__name__)
broker = KafkaBroker(settings.kafka_url)


@broker.subscriber(
    settings.user_events_topic,
    filter=lambda msg: validate_message(msg=msg.body, schema_class=UserEventSchema),
)
def users(body: str):
    logger.info(body)


@broker.subscriber(
    settings.movie_events_topic,
    filter=lambda msg: validate_message(msg=msg.body, schema_class=MovieEventSchema),
)
def movies(body: str):
    logger.info(body)


@broker.subscriber(
    settings.payment_events_topic,
    filter=lambda msg: validate_message(msg=msg.body, schema_class=PaymentEventSchema),
)
def payments(body: str):
    logger.info(body)
