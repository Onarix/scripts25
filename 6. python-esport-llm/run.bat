@echo off
pip install -r requirements.txt
for /f "tokens=1,2 delims==" %%a in (.env) do set %%a=%%b
python esports_chatbot.py
pause
