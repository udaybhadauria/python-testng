import pytest
from app.math_ops import divide

def test_divide_by_zero():
    with pytest.raises(ValueError):
        divide(10, 0)

def test_wrong_addition():
    assert (2 + 2) != 5
