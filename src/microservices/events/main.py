import uvicorn
from faststream.asgi import make_ping_asgi
from fastapi import FastAPI
from faststream.asgi import AsgiFastStream
from structlog import get_logger

from src.settings import settings
from src.stream import broker
from src.api import router

logger = get_logger(__name__)

app = FastAPI(title='Events Service API')
app.include_router(router)


@app.on_event('startup')
async def startup_event():
    try:
        await broker.start()
        logger.info('Kafka broker started successfully')
    except Exception as e:
        logger.error(f'Failed to start Kafka broker: {e}')


@app.on_event('shutdown')
async def shutdown_event():
    try:
        await broker.close()
        logger.info('Kafka broker closed successfully')
    except Exception as e:
        logger.error(f'Error closing Kafka broker: {e}')


if __name__ == '__main__':
    uvicorn.run(app, host=settings.APP_HOST, port=settings.APP_PORT)
