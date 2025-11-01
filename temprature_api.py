import http.client
import json
from datetime import datetime

# API endpoint information
HOST = "oracleapex.com"
API_PATH = "/ords/g3_data/iot/greenhouse/"

def get_greenhouse_data():
    try:
        print(f"Connecting to {HOST}{API_PATH}...")
        
        # Create a connection
        conn = http.client.HTTPSConnection(HOST)
        
        # Make request
        conn.request("GET", API_PATH)
        
        # Get response
        print("Waiting for response...")
        res = conn.getresponse()
        
        print(f"Response status: {res.status}")
        
        if res.status == 200:
            print("API call successful")
            
            # Read and decode response
            data = res.read()
            sensor_data = json.loads(data.decode("utf-8"))
            
            # Handle different response formats
            if isinstance(sensor_data, dict) and "items" in sensor_data:
                readings = sensor_data["items"]
                print("Found 'items' array in response")
            elif isinstance(sensor_data, dict):
                readings = [sensor_data]  # Single reading
                print("Processing single reading object")
            elif isinstance(sensor_data, list):
                readings = sensor_data
                print("Processing array of readings")
            else:
                print(f"Unexpected data format: {type(sensor_data)}")
                return
            
            # Process each reading
            if not readings:
                print("No sensor readings found")
                return
                
            print(f"Retrieved {len(readings)} sensor readings")
            
            for i, reading in enumerate(readings, 1):
                print(f"\nReading #{i}:")
                
                # Format timestamp if present
                if "timestamp" in reading:
                    ts = reading["timestamp"]
                    # If timestamp is a number, format it
                    if isinstance(ts, (int, float)):
                        reading_time = datetime.fromtimestamp(ts)
                        print(f"Time: {reading_time}")
                    else:
                        print(f"Time: {ts}")
                elif "timestamp_reading" in reading:
                    print(f"Time: {reading['timestamp_reading']}")
                    
                # Display temperature readings
                if "temperature_bmp280" in reading:
                    print(f"Temperature (BMP280): {reading['temperature_bmp280']}°C")
                if "temperature_dht22" in reading:
                    print(f"Temperature (DHT22): {reading['temperature_dht22']}°C")
                    
                # Display humidity and pressure
                if "humidity" in reading:
                    print(f"Humidity: {reading['humidity']}%")
                if "pressure" in reading:
                    print(f"Pressure: {reading['pressure']} hPa")
                if "altitude" in reading:
                    print(f"Altitude: {reading['altitude']} m")
                    
                # Display light sensor data
                if "light_raw" in reading:
                    print(f"Light (raw): {reading['light_raw']}")
                if "light_percent" in reading:
                    print(f"Light (%): {reading['light_percent']}%")
                    
                # Display flame sensor data
                if "flame_raw" in reading:
                    print(f"Flame (raw): {reading['flame_raw']}")
                if "flame_detected" in reading:
                    detected = "Yes" if reading["flame_detected"] else "No"
                    print(f"Flame detected: {detected}")
                    
                # Display gas sensors (MQ135, MQ2, MQ7)
                if "mq135_raw" in reading:
                    print(f"Air Quality (MQ135)")
                    print(f"  Raw: {reading['mq135_raw']}")
                    print(f"  Baseline: {reading['mq135_baseline']}")
                    print(f"  Drop: {reading['mq135_drop']}")
                    
                if "mq2_raw" in reading:
                    print(f"Flammable Gas (MQ2)")
                    print(f"  Raw: {reading['mq2_raw']}")
                    print(f"  Baseline: {reading['mq2_baseline']}")
                    print(f"  Drop: {reading['mq2_drop']}")
                    
                if "mq7_raw" in reading:
                    print(f"Carbon Monoxide (MQ7)")
                    print(f"  Raw: {reading['mq7_raw']}")
                    print(f"  Baseline: {reading['mq7_baseline']}")
                    print(f"  Drop: {reading['mq7_drop']}")
                
        else:
            print(f"API call failed with status {res.status}")
            
    except http.client.HTTPException as e:
        print(f"HTTP error occurred: {e}")
        print("\nTroubleshooting tips:")
        print("1. Check your internet connection")
        print("2. Verify the API endpoint is correct")
        print("3. Try accessing the URL in a web browser")
        print("4. The server might be down or restricting access")
    except json.JSONDecodeError:
        print("Failed to decode JSON response")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        # Close connection if it exists
        if 'conn' in locals():
            conn.close()

def main():
    print("Fetching greenhouse sensor data...")
    get_greenhouse_data()
    print("\nDone.")

if __name__ == "__main__":
    main()