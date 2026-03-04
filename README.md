# To Run Backend
python venv .venv
.venv/Scripts/activate
python -m pip install -r requirements.txt
python -m uvicorn main:app --reload

