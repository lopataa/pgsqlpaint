FROM postgres:17

# Install Python3, pip, PL/Python3u, and Pillow
RUN apt-get update && \
    apt-get install -y python3 python3-pip postgresql-plpython3-17 && \
    pip3 install Pillow --break-system-packages && \
    rm -rf /var/lib/apt/lists/*

# (Optional) Set environment variables if needed
ENV PYTHONUNBUFFERED=1
