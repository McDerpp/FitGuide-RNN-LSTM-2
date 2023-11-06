# import asyncio
# import websockets
# print('initiating')

# async def handle_frame_processing(websocket, path):
#     # while True:
#     #     frame_data = await websocket.recv()
#     #     # print('RECEIVED--------------------->', frame_data)
#     #     # processed_frame = process_frame(frame_data)  # Process the frame
#     #     await websocket.send(frame_data)
#     async for message in websocket:
#         print(f"Received: {message}")
#         # Process the received message if needed
#         response = "Server received: " + message
#         await websocket.send(response)

# async def handle_notifications(websocket, path):
#     while True:
#         notification_data = await websocket.recv()
#         # Handle the notification data
#         # For demonstration, let's print the received notification
#         print("Received notification:", notification_data)

# start_frame_processing_server = websockets.serve(handle_frame_processing, "localhost", 8765)
# start_notifications_server = websockets.serve(handle_notifications, "localhost", 8768)

# asyncio.get_event_loop().run_until_complete(start_frame_processing_server)
# asyncio.get_event_loop().run_until_complete(start_notifications_server)
# asyncio.get_event_loop().run_forever()









# import asyncio
# import websockets
# print('test')

# async def echo(websocket, path):
#     print('in echo')
#     async for message in websocket:
#         print(message)
#         await websocket.send(message)

# start_server = websockets.serve(echo, "localhost", 8765)

# asyncio.get_event_loop().run_until_complete(start_server)
# asyncio.get_event_loop().run_forever()



import asyncio
import websockets

# async def echo(websocket, path):
#     async for message in websocket:
#         await websocket.send(message)
#         print('received')

async def echo(websocket, path):
    async for message in websocket:  # This loop receives messages from the client
        print(f"Received: {message}")  # Debug statement to print the received message
        # Process the received message if needed
        response = "Server received: " + message
        await websocket.send(response)  # This sends a response back to the client


start_server = websockets.serve(echo, "localhost", 8765)
print('testsetstse')

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
