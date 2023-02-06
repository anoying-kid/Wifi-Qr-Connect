import os
# import the opencv library
import cv2
# define a video capture object
vid = cv2.VideoCapture(0)
detector = cv2.QRCodeDetector()
while True:
    # Capture the video frame by frame
    ret, frame = vid.read()
    data, bbox, straight_qrcode = detector.detectAndDecode(frame)
    if len(data) > 0:
        print(data)
        output = data
        break
    cv2.imshow('Press q to quit', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
# After the loop release the cap object
vid.release()
# Destroy all the windows
cv2.destroyAllWindows()

try:
    data = output.split(':')
except NameError:
    pass
else:
    ssid = data[2][:data[2].find(';')]
    password = data[4][:data[4].find(';')]
    os.system('networksetup -setairportpower en0 on')
    os.system(f'networksetup -setairportnetwork en0 {ssid} {password}')