#!/bin/bash
pip install -r requirements.txt
export $(grep -v '^#' .env | xargs)
python3 esports_chatbot.py
