def serial(data) -> dict:
    return {
        "id": str(data["_id"]),
        "owner": str(data["owner"]),
        "username": str(data["username"]),
        "createdAt": str(data["createdAt"]),
    }
