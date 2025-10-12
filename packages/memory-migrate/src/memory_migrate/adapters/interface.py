from typing import Iterable

from datamodel_code_generator import JSONSerializable


class Adapter:
    name: str

    def export(self, **kwargs) -> Iterable[JSONSerializable]:
        raise NotImplementedError
