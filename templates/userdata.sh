#!/bin/bash
# Update system packages
apt-get update -y

# Install nginx and curl
apt-get install -y nginx curl

# Create web root if not exists
mkdir -p /var/www/html

while [ $RETRIES -gt 0 ]; do
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
            -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
                    http://169.254.169.254/latest/meta-data/instance-id)
  AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
               http://169.254.169.254/latest/meta-data/placement/availability-zone)

  if [[ -n "$INSTANCE_ID" && -n "$AZ" ]]; then
    break
  fi
  sleep 2
  RETRIES=$((RETRIES-1))
done
# Write custom index.html
cat > /var/www/html/index.html <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Hey There</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet">
  <style>
    body {
      margin: 0;
      font-family: "Inter", sans-serif;
      background: linear-gradient(135deg, #0f172a, #0b1220);
      color: #e6eef8;
      height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
    }
    h1 {
      font-size: 3rem;
      font-weight: 800;
      background: linear-gradient(90deg, #9AE6B4 0%, #34D399 100%);
      -webkit-background-clip: text;
      background-clip: text;
      color: transparent;
      margin-bottom: 1rem;
    }
    p {
      font-size: 1rem;
      color: #a5b4fc;
      margin: 4px 0;
    }
  </style>
</head>
<body>
  <h1>Hey There 👋</h1>
  <p><strong>Instance ID:</strong> <span style="color:#a5b4fc;">${INSTANCE_ID}</span></p>
  <p><strong>Availability Zone:</strong> <span style="color:#a5b4fc;">${AZ}</span></p>

</body>
</html>
EOF

# Enable and start nginx
systemctl enable nginx
systemctl restart nginx
