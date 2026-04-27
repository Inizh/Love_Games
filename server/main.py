from fastapi import FastAPI , WebSocket , WebSocketDisconnect
from typing import List

app = FastAPI()

class ConnectionManager:

    def __init__(self):
        self.conn : List[WebSocket] = []

    async def connect(self , websocket : WebSocket):
        await websocket.accept()
        self.conn.append(websocket)

    def disconnect(self , websocket : WebSocket):
        self.conn.remove(websocket)

    async def broadcast(self , message):
        for i in self.conn:
            await i.send_text(message)


manager = ConnectionManager()

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket , client_id: str):
    await manager.connect(websocket)
    while True:
        try :
            data = await websocket.receive_text()
            await manager.broadcast(f"Message received: {data}")

        except WebSocketDisconnect:
            manager.disconnect(websocket)
            await manager.broadcast(f"Client {client_id} disconnected")
