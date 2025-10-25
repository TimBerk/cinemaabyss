from pydantic_core._pydantic_core import ValidationError
from structlog import get_logger
import json

logger = get_logger(__name__)


def validate_message(msg: str, schema_class):
    """Фабрика фильтров для любой Pydantic схемы"""
    try:
        schema_class.model_validate_json(msg)
    except (json.JSONDecodeError, ValidationError) as err:
        return False
    return True
