# Stage 1: Build stage
FROM python:3.10-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev gcc && \
    rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# Stage 2: Runtime stage
FROM python:3.10-slim

WORKDIR /app

# Copy only the virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install runtime dependencies (just libpq for psycopg2)
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq5 && \
    rm -rf /var/lib/apt/lists/*

# Copy application files
COPY app.py .
COPY templates/ ./templates/
COPY entrypoint.sh .

# Set permissions and expose port
RUN chmod +x entrypoint.sh
EXPOSE 5000

# Runtime commands
ENTRYPOINT ["./entrypoint.sh"]
CMD ["python", "app.py"]
