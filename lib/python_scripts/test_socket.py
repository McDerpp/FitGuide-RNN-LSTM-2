# things tend to change based on the frames received by the socket
# >number_of_bytes_image
# >height
# >width



# if preview camera is [MEDIUM]    (!!too pixelated!!)
# expected total number of bytes = 115200
# y_plane total number bytes =  76800
# u_plane total number bytes =  19200
# v_plane total number bytes =  19200
# width = 320
# height = 240


# if preview camera is [HIGH]    (!!good quality but more bytes to process!!)
# expected total number of bytes = 
# y_plane total number bytes =  921600
# u_plane total number bytes =  230400
# v_plane total number bytes =  230400
# width = 1280
# height = 720


# change accordingly here

width = 1280
height = 720

y_size = 921600
u_size = 230400
v_size = 230400

number_of_bytes_image =  y_size + u_size + v_size + 1

import socket
import threading
import cv2
import numpy as np

def handle_client(clientsocket, address):
    print(f'Connection from {address} has been established')
    clientsocket.send(bytes("Welcome to the server", 'utf-8'))
    
    data = b""  # Initialize data buffer
    extracted_data = b""
    # number_of_bytes_image = 115200 + 1
    decoded = []
    decoded_temp = []



    
    while True:
        chunk = clientsocket.recv(number_of_bytes_image)
        if not chunk:
            break
        
        data += chunk  # Append the received chunk to the data buffer
        print("data accumulation-> ",len(data))

        # !!!!!!!!CHANGE THIS!!!!!!!!!!!!!!!!!!!!
        if len(data) >= number_of_bytes_image:
            extracted_data = data[:number_of_bytes_image]
            data = data[number_of_bytes_image:]           
            decoded_temp = extracted_data.decode('utf-8').split(",")

            decoded += decoded_temp
            print("OUT!")

        print("data decoded-> ",len(decoded))
        if len(decoded) >= number_of_bytes_image:
            print("IN!")
            process_data(decoded[:number_of_bytes_image])

    clientsocket.close()
    print(f'Connection from {address} has been closed')

def process_data(data): 
    # width = 320
    # height = 240
    temp_processed_int = []
    temp = []
    temp_non_integer = ['[',']',' ','  ']
    cleaned_str = ''

    # y_size = 76800
    # u_size = 19200
    # v_size = 19200

    # temp_interleave = np.empty(u_size + v_size)


# data cleaning part
    for invidividual_bytes in data:
        try:
            temp_processed_int.append(np.uint8(invidividual_bytes))
        except:
            
            if invidividual_bytes == '' or invidividual_bytes == ' ' :
                continue

            elif ']' in invidividual_bytes and '[' in invidividual_bytes:
                temp = invidividual_bytes.split('][')
                temp_processed_int.append(np.uint8(temp[0]))
                temp_processed_int.append(np.uint8(temp[1]))

            elif ']' in invidividual_bytes or '[' in invidividual_bytes:
                temp = invidividual_bytes.replace("[", "").replace("]", "")
                temp_processed_int.append(np.uint8(temp))

            else:
                for individual_char in invidividual_bytes:
                    if individual_char in temp_non_integer:
                        cleaned_str = invidividual_bytes.strip(individual_char)
                        temp_processed_int.append(cleaned_str)
                cleaned_str = ''

    print("y_Start",temp_processed_int[0])

    print("y_end",temp_processed_int[y_size - 1])

    print("y_end",temp_processed_int[y_size])
    print("y_end",temp_processed_int[y_size + 1])
    print("y_end",temp_processed_int[y_size + 2])

    print("y_end",temp_processed_int[y_size + 3])
    print("y_end",temp_processed_int[y_size + 4])

    print("temp_processed_int --->",len(temp_processed_int))
            
    y_plane = np.array(temp_processed_int[:y_size])
    u_plane = np.array(temp_processed_int[y_size:y_size + u_size])
    v_plane = np.array(temp_processed_int[y_size + u_size :y_size + u_size + v_size]) 


# no need to interleave for this version
    # for x in range(u_plane.size):
    #     temp_interleave[2 * x] = u_plane[x]
    #     temp_interleave[2 * x + 1] = v_plane[x] 
    # result_image = np.zeros((height, width, 3), dtype=np.uint8)
    # cv2.cvtColorTwoPlane(y_plane,temp_interleave,result_image,int(cv2.COLOR_YUV2RGB_NV12))
    
    

    y_plane = y_plane.reshape(height, width)
    u_plane = u_plane.reshape(height // 2, width // 2)
    v_plane = v_plane.reshape(height // 2, width // 2)

    u_plane = cv2.resize(u_plane, (width, height), interpolation=cv2.INTER_NEAREST)
    v_plane = cv2.resize(v_plane, (width, height), interpolation=cv2.INTER_NEAREST)




    yuv_image = cv2.merge([y_plane, u_plane, v_plane])
    print("MERGED!")

    # bgr_image = cv2.cvtColor(yuv_image, cv2.COLOR_YUV2RGBA_NV12)
    # bgr_image = cv2.cvtColor(yuv_image, cv2.COLOR_YUV2BGR_I444)




    print("dtype!->",y_plane.dtype)
    cv2.imshow('YUV420 to BGR', y_plane)
    cv2.waitKey(0)
    cv2.destroyAllWindows()




    #     # Display or save the RGB image
    # cv2.imshow("RGB Image", imagetest)
    # cv2.waitKey(0)
    # cv2.destroyAllWindows()




s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(("127.0.0.1", 1234))
s.listen(20)

print("Server is listening for connections...")

while True:
    clientsocket, address = s.accept()
    
    print(clientsocket)
    client_thread = threading.Thread(target=handle_client, args=(clientsocket, address))
    client_thread.start()
