from uuid import UUID, uuid4
from pydantic import BaseModel, Field, field_validator
from datetime import datetime


def get_current_time() -> str:
    return datetime.now().isoformat()


class BaseEvent(BaseModel):
    event_id: UUID = Field(default_factory=uuid4)
    event_version: str = 'v1'
    event_name: str
    produced_at: str = Field(default_factory=get_current_time)

    @field_validator('event_id', mode='before')
    @classmethod
    def validate_uuid(cls, v):
        if v is None:
            return uuid4()
        if isinstance(v, str):
            try:
                return UUID(v)
            except ValueError:
                raise ValueError
        return v


class MovieEvent(BaseModel):
    movie_id: int = Field(..., description='ID фильма')
    title: str = Field(..., description='Название фильма')
    action: str = Field(..., description='Действие: viewed, rated, bookmarked')
    user_id: int = Field(..., description='ID пользователя')


class UserEvent(BaseModel):
    user_id: int = Field(..., description='ID пользователя')
    username: str = Field(..., description='Имя пользователя')
    action: str = Field(..., description='Действие: logged_in, logged_out, registered')
    timestamp: datetime | None = Field(None, description='Временная метка')


class PaymentEvent(BaseModel):
    payment_id: int = Field(..., description='ID платежа')
    user_id: int = Field(..., description='ID пользователя')
    amount: float = Field(..., description='Сумма платежа')
    status: str = Field(..., description='Статус: completed, pending, failed')
    timestamp: datetime | None = Field(None, description='Временная метка')
    method_type: str = Field(..., description='Тип оплаты: credit_card, paypal, etc')


class UserEventSchema(BaseEvent):
    event_name: str = 'UserEvent'
    data: UserEvent


class MovieEventSchema(BaseEvent):
    event_name: str = 'MovieEvent'
    data: MovieEvent


class PaymentEventSchema(BaseEvent):
    event_name: str = 'PaymentEvent'
    data: PaymentEvent
