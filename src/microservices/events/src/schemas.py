from pydantic import BaseModel, Field
from datetime import datetime


class MovieRequest(BaseModel):
    movie_id: int = Field(..., description='ID фильма')
    title: str = Field(..., description='Название фильма')
    action: str = Field(..., description='Действие: viewed, rated, bookmarked')
    user_id: int = Field(..., description='ID пользователя')
    timestamp: datetime | None = Field(None, description='Временная метка')


class UserRequest(BaseModel):
    user_id: int = Field(..., description='ID пользователя')
    username: str = Field(..., description='Имя пользователя')
    action: str = Field(..., description='Действие: logged_in, logged_out, registered')
    timestamp: datetime | None = Field(None, description='Временная метка')


class PaymentRequest(BaseModel):
    payment_id: int = Field(..., description='ID платежа')
    user_id: int = Field(..., description='ID пользователя')
    amount: float = Field(..., ge=0, description='Сумма платежа')
    status: str = Field(..., description='Статус: completed, pending, failed')
    timestamp: datetime | None = Field(None, description='Временная метка')
    method_type: str = Field(..., description='Тип оплаты: credit_card, paypal, etc')


class APIResponse(BaseModel):
    status: str
    message: str
    topic: str


class HealthCheckResponse(BaseModel):
    status: bool
