# LoadManagement
An app to analyze imu data and video. Overview of training load.

## Upload data
To be compatible with the app, each recording must be uploaded as a folder with the following structure:

```
Recording_Name/  
├── sensor1/  
│ ├── acc_data.csv  
│ ├── gyro_data.csv  
│ └── magn_data.csv  
├── sensor2/  
│ ├── acc_data.csv  
│ ├── gyro_data.csv  
│ └── magn_data.csv  
├── sensor3/  
│ └── ...  
├── video1.mp4  
├── video2.mp4  
...  
```

## 🔹 Folder Naming
- The top-level folder (`Recording_Name`) should describe the session or user.  
  **Example:** `session_2025_05_25_userA/`

## 🔹 Sensor Subfolders
- Each sensor must be placed in its own subfolder (e.g., `sensor1`, `sensor2`, etc.).
- Use consistent naming across recordings.

## 🔹 Required Files per Sensor
Each sensor folder must include the following files:

| File Name        | Description                   |
|------------------|-------------------------------|
| `acc_data.csv`   | Accelerometer data            |
| `gyro_data.csv`  | Gyroscope data                |
| `magn_data.csv`  | Magnetometer data             |

### CSV Format Requirements:
- Columns: `Timestamp,AccX,AccY,AccZ` or `Timestamp,GyroX,GyroY,GyroZ` or `Timestamp,MagnX,MagnY,MagnZ`
- Consistent sampling rate across files

---

## Video Files
The videos will be filtered by created time so in case they are not in correct order check the created date header of the video.



Example recording is provided called "Example data".

# Contact
If any questions about this repository or the project please contact the creator at: asmundur31@gmail.com
