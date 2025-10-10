from fastapi import status, APIRouter, HTTPException
from structlog import get_logger

from src.stream import broker
from src.settings import settings
from src.schemas import APIResponse, MovieRequest, PaymentRequest, UserRequest, HealthCheckResponse
from src.events import MovieEventSchema, MovieEvent, UserEventSchema, UserEvent, PaymentEvent, PaymentEventSchema

router = APIRouter(prefix='/api/events')
logger = get_logger(__name__)


@router.get('/health')
async def check_health() -> HealthCheckResponse:
    return HealthCheckResponse(status=True)


@router.post('/movie', response_model=APIResponse, status_code=status.HTTP_201_CREATED)
async def send_movie_event(request: MovieRequest):
    try:
        logger.info('Movie', data=request, dump=request.model_dump())
        event = MovieEventSchema(data=MovieEvent(**request.model_dump()))
        logger.info('Movie event', data=event, dump=event.model_dump())

        await broker.publish(event.json(), topic=settings.movie_events_topic)

        return APIResponse(
            status='success',
            message='Movie event sent to Kafka',
            topic='movie_events',
        )
    except Exception as e:
        logger.error('Send to kafka', topic=settings.movie_events_topic, error=e)
        raise HTTPException(status_code=500, detail=f'Error sending movie event: {str(e)}')


@router.post('/user', response_model=APIResponse, status_code=status.HTTP_201_CREATED)
async def send_user_event(request: UserRequest):
    try:
        logger.info('User', data=request)
        event = UserEventSchema(data=UserEvent(**request.model_dump()))

        await broker.publish(event.json(), topic=settings.user_events_topic)

        return APIResponse(
            status='success',
            message='User event sent to Kafka',
            topic='user_events',
        )
    except Exception as e:
        logger.error('Send to kafka', topic=settings.user_events_topic, error=e)
        raise HTTPException(status_code=500, detail=f'Error sending user event: {str(e)}')


@router.post('/payment', response_model=APIResponse, status_code=status.HTTP_201_CREATED)
async def send_payment_event(request: PaymentRequest):
    try:
        logger.info('Payment', data=request)
        event = PaymentEventSchema(data=PaymentEvent(**request.model_dump()))
        await broker.publish(event.json(), topic=settings.payment_events_topic)

        return APIResponse(
            status='success',
            message='Payment event sent to Kafka',
            topic='payment_events',
        )
    except Exception as e:
        logger.error('Send to kafka', topic=settings.payment_events_topic, error=e)
        raise HTTPException(status_code=500, detail=f'Error sending payment event: {str(e)}')
