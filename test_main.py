import requests

ENDPOINT = "https://todo.pixegami.io"

response = requests.get(ENDPOINT)
print(response)

data = response.json()
print(data)

def test_endpoint():
    response = requests.get(ENDPOINT)
    assert response.status_code == 200