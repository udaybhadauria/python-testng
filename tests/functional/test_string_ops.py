from app.string_ops import to_upper, reverse_string, is_palindrome

def test_to_upper():
    assert to_upper("hello") == "HELLO"

def test_reverse_string():
    assert reverse_string("world") == "dlrow"

def test_is_palindrome_true():
    assert is_palindrome("rotator")

def test_is_palindrome_false():
    assert not is_palindrome("python")

def test_split():
    assert "hello world".split() == ["hello", "world"]
