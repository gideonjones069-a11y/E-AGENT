from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
import sqlite3
from passlib.context import CryptContext

app = FastAPI()

# =====================================================
# PASSWORD HASHING
# =====================================================

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)

# =====================================================
# DATABASE SETUP
# =====================================================

def init_db():
    conn = sqlite3.connect("eagent.db")
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
        )
    """)

    conn.commit()
    conn.close()

init_db()

# =====================================================
# MODELS
# =====================================================

class User(BaseModel):
    name: str
    email: str
    password: str


class LoginUser(BaseModel):
    email: str
    password: str


class RiskRequest(BaseModel):
    policy: str
    subpolicy: Optional[str] = ""
    answers: Dict[str, Any] = {}

# =====================================================
# AUTH SYSTEM (UPGRADED)
# =====================================================

@app.post("/register")
def register(user: User):
    conn = sqlite3.connect("eagent.db")
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM users WHERE email = ?",
        (user.email,)
    )

    existing = cursor.fetchone()

    if existing:
        conn.close()
        raise HTTPException(
            status_code=400,
            detail="User already exists"
        )

    hashed_password = pwd_context.hash(user.password)

    cursor.execute(
        "INSERT INTO users (name,email,password) VALUES (?,?,?)",
        (
            user.name,
            user.email,
            hashed_password
        )
    )

    conn.commit()
    conn.close()

    return {
        "message": "User registered successfully"
    }


@app.post("/login")
def login(user: LoginUser):
    conn = sqlite3.connect("eagent.db")
    cursor = conn.cursor()

    cursor.execute(
        "SELECT id,name,email,password FROM users WHERE email = ?",
        (user.email,)
    )

    found = cursor.fetchone()
    conn.close()

    if not found:
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials"
        )

    user_id = found[0]
    name = found[1]
    email = found[2]
    hashed_password = found[3]

    if not pwd_context.verify(user.password, hashed_password):
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials"
        )

    return {
        "message": "Login successful",
        "user": {
            "id": user_id,
            "name": name,
            "email": email
        }
    }

# =====================================================
# CYBER MODEL
# =====================================================

def calculate_cyber_probability(a):
    score = 0.0

    weights = {
        "mfa": 0.15,
        "patching": 0.10,
        "firewall": 0.10,
        "training": 0.05,
        "endpoint": 0.05,
        "remote": 0.05,
        "third_party": 0.05,
        "public_apps": 0.15,
        "cloud": 0.05,
        "incidents": 0.25
    }

    if not a.get("mfa", True):
        score += weights["mfa"]

    if not a.get("patching", True):
        score += weights["patching"]

    if not a.get("firewall", True):
        score += weights["firewall"]

    if not a.get("training", True):
        score += weights["training"]

    if not a.get("endpoint", True):
        score += weights["endpoint"]

    if a.get("remote", False):
        score += weights["remote"]

    if a.get("third_party", False):
        score += weights["third_party"]

    if a.get("public_apps", False):
        score += weights["public_apps"]

    if a.get("cloud", False):
        score += weights["cloud"]

    incidents = float(a.get("incidents", 0))
    score += min(incidents * 0.1, weights["incidents"])

    return min(max(score, 0.05), 1.5)


def calculate_cyber_impact(a):
    score = 0.0

    revenue = float(a.get("revenue", 50)) / 100.0
    records = float(a.get("records", 10000)) / 50000.0
    downtime = float(a.get("downtime_cost", 100000)) / 500000.0

    score += revenue * 0.4
    score += records * 0.3
    score += downtime * 0.3

    if a.get("sensitive_data", False):
        score *= 1.3

    if a.get("international", False):
        score *= 1.2

    if a.get("fines", False):
        score *= 1.2

    if a.get("response_plan", False):
        score *= 0.85

    if a.get("soc", False):
        score *= 0.85

    if a.get("backups", False):
        score *= 0.80

    return min(max(score, 0.1), 3.0)

# =====================================================
# GENERIC MODELS
# =====================================================

def simple_probability(a):
    return 0.45


def simple_impact(a):
    return 1.20

# =====================================================
# PRICING + RESERVE
# =====================================================

def calculate_premium(probability, impact):
    expected_loss = probability * impact

    base_rate = 10000
    premium = base_rate * expected_loss * 1.3

    risk_score = expected_loss * 100

    return min(risk_score, 95), premium


def calculate_reserve(probability, impact):
    expected_loss = probability * impact
    return expected_loss * 200000

# =====================================================
# MAIN CALCULATOR
# =====================================================

@app.post("/calculate")
def calculate_risk(data: RiskRequest):
    a = data.answers

    if data.policy == "Cyber":
        probability = calculate_cyber_probability(a)
        impact = calculate_cyber_impact(a)
    else:
        probability = simple_probability(a)
        impact = simple_impact(a)

    risk_score, premium = calculate_premium(
        probability,
        impact
    )

    reserve = calculate_reserve(
        probability,
        impact
    )

    return {
        "policy": data.policy,
        "risk_score": round(risk_score),
        "risk_level":
            "High" if risk_score > 70 else
            "Medium" if risk_score > 40 else
            "Low",
        "premium": round(premium),
        "reserve": round(reserve),
        "probability": round(probability, 2),
        "impact": round(impact, 2)
    }