# Quadcopter Cybersecurity and Anomaly Detection

## Overview
This project is a complete machine learning solution for **anomaly detection** in quadcopters, addressing cybersecurity threats. It covers the **entire machine learning pipeline**, from **data generation to novel model development**, ensuring enhanced security against cyber-attacks.

## Project Goals
- Provide **higher security** for quadcopters and drones against **malicious cyber-attacks**.
- Generate and collect data using **MATLAB and Simulink**.
- Develop **novel deep learning models** for cyber-attack detection, identification, and isolation.
- Extend solutions to **multi-quadcopter networks** for robust anomaly detection.

## Data Generation
### 1. Quadcopter Modeling & Control
- **Quadcopter modeled from mathematical formulas** using **Simulink's State-Space block**.
- Implemented both **linear and non-linear** models.
- **Open-loop system** tested before designing **closed-loop controllers**.
- **PID controllers (single & cascaded)** used for **3D control over x, y, and z axes**.
- **Non-linear quadcopter modeled using fundamental Simulink blocks** (e.g., sin, cos functions).
- **Same controller applied to both linear & non-linear models**.
- Successfully implemented a **fully maneuverable, non-linear quadcopter** with local control.

### 2. Cybersecurity (Cyber-Attack Simulation)
- Implemented **three cyber-attacks:**
  - **Denial of Service (DoS)**
  - **False Data Injection (FDI)**
  - **Replay Attack**
- Cyber-attacks **implemented using MATLAB-Simulink combinations**.
- Utilized **Zero-Order Hold, Memory, and Delay blocks** to introduce attacks.
- Attacks applied to **both sensors and actuators**.

### 3. Scenario-Based Data Collection
- **Defined movement scenarios** for quadcopter flight paths.
- **Monte Carlo approach** used to generate **50 randomized scenarios**.
- Parameters randomized include **attack timing, movement paths, etc.**
- Sensor and actuator data collected from **Simulink to MATLAB**, stored as **CSV files**.

## Machine Learning for Cyber-Attack Detection
### 1. Base Model Selection
- **RNN-based models** selected due to the **time-series nature of the data**.
- **LSTM (Long Short-Term Memory)** chosen as the **best RNN-based model**.
- **Basic LSTM model implemented in Python (Google Colab)** for initial cyber-attack detection.

### 2. Novel Model Development
- **Multi-Output LSTM (MO-LSTM)** introduced with a **shared LSTM backbone and 3 output heads** for:
  - **Cyber-attack detection**
  - **Attack type identification**
  - **Affected component isolation**
- Models developed using **TensorFlow and Keras**.
- **MO-LSTM model successfully implemented and tested**.

## Extension to Multi-Quadcopter Networks
### 1. Dataset Generation for Networks
- **Number of quadcopters increased from 1 to 5** in **Simulink & MATLAB**.
- Adjusted **Simulink models and MATLAB scripts** accordingly.
- **50 new Monte Carlo scenarios generated** for multi-quadcopter simulations.
- Sensor & actuator data **transferred to MATLAB and converted into CSV files** with automatic attack labels.

### 2. MI-MO LSTM Model (Multi-Input, Multi-Output LSTM)
- **Previous MO-LSTM model worked well for single quadcopter** with **10 features**.
- To handle **multiple quadcopters**, a **new adaptable model** was designed:
  - **Multiple input heads** for **each quadcopter's sensor & actuator data**.
  - **Shared LSTM backbone** to extract common patterns.
  - **Three output heads** for detection, identification, and isolation.
- **Tested with 2 to 5 quadcopters** – results showed strong detection performance.
- **Model named MI-MO LSTM (Multi-Input, Multi-Output LSTM)**.

## Results & Future Work
- **High detection accuracy** achieved for both **single and multi-quadcopter scenarios**.
- **Model successfully detects, identifies, and isolates cyber-attacks**.
- Future work includes:
  - **Deploying models on real-world UAVs**.
  - **Expanding dataset with additional attack types**.
  - **Optimizing real-time processing capabilities**.
