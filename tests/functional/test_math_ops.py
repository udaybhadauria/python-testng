import pytest
from app.math_ops import add, subtract, multiply, divide

def test_add():
    assert add(3, 7) == 10

def test_subtract():
    assert subtract(10, 4) == 6

def test_multiply():
    assert multiply(2, 8) == 16

def test_divide():
    assert divide(10, 2) == 5
