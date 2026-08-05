#!/bin/bash
set -e

DIR="assets/img/posts/oslogclient"
mkdir -p "$DIR"

curl -L "https://cdn.hashnode.com/res/hashnode/image/upload/v1693617205691/b130dea1-682e-4771-a7cf-e2f39df01d4d.png" -o "$DIR/cover.png"
curl -L "https://cdn.hashnode.com/res/hashnode/image/upload/v1693818181381/902c055f-6f59-471e-aec0-8607ba15bde6.png" -o "$DIR/architecture-overview.png"
curl -L "https://cdn.hashnode.com/res/hashnode/image/upload/v1693819473439/a4d995f9-5d90-4054-b6bb-723857518753.jpeg" -o "$DIR/control-flow-sequence.jpeg"

echo "All 3 images downloaded to $DIR"