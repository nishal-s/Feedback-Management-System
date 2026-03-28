import pytest
from app import app, db

@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    
    with app.test_client() as client:
        with app.app_context():
            db.create_all()
        yield client

def test_index_renders_successfully(client):
    """Test that the home page loads correctly."""
    response = client.get('/')
    assert response.status_code == 200
    assert b"FeedOps" in response.data

def test_login_page_renders(client):
    """Test that the login page loads correctly."""
    response = client.get('/login')
    assert response.status_code == 200
    assert b"Login" in response.data

def test_register_page_renders(client):
    """Test that the register page loads correctly."""
    response = client.get('/register')
    assert response.status_code == 200
    assert b"Register" in response.data
