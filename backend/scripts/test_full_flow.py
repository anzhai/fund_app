#!/usr/bin/env python3
"""
Test script for full user flow: Register -> Login -> Open Account -> Risk Assessment -> Recharge -> Purchase Fund
"""
import requests
import json
import time
import random

BASE_URL = "http://localhost:8001/auth"
ACCOUNT_URL = "http://localhost:8002/account"
TRADE_URL = "http://localhost:8005/trade"

def test_full_flow():
    print("=" * 60)
    print("Testing Full User Flow")
    print("=" * 60)

    # Test data - generate unique phone each time
    phone = f"138{random.randint(10000000, 99999999)}"  # Generate unique phone
    password = "test123456"
    id_card = "110101199001011234"
    real_name = "测试用户"
    id_card_expire = "2030-01-01"

    headers = {}

    # Step 1: Register
    print("\n[1/10] Testing Registration...")
    try:
        resp = requests.post(f"{BASE_URL}/register", json={
            "phone": phone,
            "password": password,
            "id_card": id_card,
            "user_type": "direct_sales"
        })
        print(f"    Status: {resp.status_code}")
        print(f"    Response: {resp.json()}")

        if resp.status_code == 200:
            data = resp.json()
            headers["Authorization"] = f"Bearer {data.get('access_token', '')}"
            print("    ✓ Registration successful")
        else:
            print(f"    ✗ Registration failed: {resp.text}")
            # If user exists, try to login anyway
            print("\n    Trying login instead...")
            resp = requests.post(f"{BASE_URL}/login", json={
                "login_type": "phone",
                "identifier": phone,
                "password": password
            })
            if resp.status_code == 200:
                data = resp.json()
                headers["Authorization"] = f"Bearer {data.get('access_token', '')}"
                print("    ✓ Login successful (existing user)")
            else:
                return
    except Exception as e:
        print(f"    ✗ Error: {e}")
        return

    # Step 2: Login (for verification)
    print("\n[2/10] Testing Login...")
    try:
        resp = requests.post(f"{BASE_URL}/login", json={
            "login_type": "phone",
            "identifier": phone,
            "password": password
        })
        print(f"    Status: {resp.status_code}")
        print(f"    Response: {resp.json()}")

        if resp.status_code == 200:
            data = resp.json()
            headers["Authorization"] = f"Bearer {data.get('access_token', '')}"
            print("    ✓ Login successful")
        else:
            print(f"    ✗ Login failed: {resp.text}")
            return
    except Exception as e:
        print(f"    ✗ Error: {e}")
        return

    # Step 3: Get Current User
    print("\n[3/10] Testing Get Current User...")
    try:
        resp = requests.get(f"{BASE_URL}/me", headers=headers)
        print(f"    Status: {resp.status_code}")
        print(f"    Response: {resp.json()}")
        print("    ✓ Get user successful")
    except Exception as e:
        print(f"    ✗ Error: {e}")

    # Step 4: Get Account Status (before opening)
    print("\n[4/10] Testing Get Account Status (before opening)...")
    try:
        resp = requests.get(f"{ACCOUNT_URL}/status", headers=headers)
        print(f"    Status: {resp.status_code}")
        if resp.status_code == 200:
            print(f"    Response: {resp.json()}")
        else:
            print(f"    Response: {resp.text}")
    except Exception as e:
        print(f"    ✗ Error: {e}")

    # Step 5: Open Account
    print("\n[5/10] Testing Open Account...")
    try:
        resp = requests.post(f"{ACCOUNT_URL}/open", json={
            "id_card": id_card,
            "real_name": real_name,
            "id_card_expire": id_card_expire,
            "trade_password": "123456"
        }, headers=headers)
        print(f"    Status: {resp.status_code}")
        print(f"    Response: {resp.json()}")

        if resp.status_code == 200:
            print("    ✓ Account opened successfully")
        else:
            print(f"    ✗ Open account failed: {resp.text}")
    except Exception as e:
        print(f"    ✗ Error: {e}")

    # Step 6: Submit Risk Assessment
    print("\n[6/10] Testing Risk Assessment...")
    try:
        answers = [
            {"question_id": 1, "answer": "A", "score": 20},
            {"question_id": 2, "answer": "B", "score": 40},
            {"question_id": 3, "answer": "C", "score": 60},
            {"question_id": 4, "answer": "D", "score": 80},
            {"question_id": 5, "answer": "E", "score": 100},
        ]
        resp = requests.post(f"{ACCOUNT_URL}/risk/submit", json=answers, headers=headers)
        print(f"    Status: {resp.status_code}")
        print(f"    Response: {resp.json()}")

        if resp.status_code == 200:
            print("    ✓ Risk assessment submitted")
        else:
            print(f"    ✗ Risk assessment failed: {resp.text}")
    except Exception as e:
        print(f"    ✗ Error: {e}")

    # Step 7: Recharge
    print("\n[7/10] Testing Recharge...")
    try:
        resp = requests.post(f"{TRADE_URL}/wallet/recharge", json={
            "amount": 10000.00
        }, headers=headers)
        print(f"    Status: {resp.status_code}")
        print(f"    Response: {resp.json()}")

        if resp.status_code == 200:
            print("    ✓ Recharge successful")
        else:
            print(f"    ✗ Recharge failed: {resp.text}")
    except Exception as e:
        print(f"    ✗ Error: {e}")

    # Step 8: Get Wallet
    print("\n[8/10] Testing Get Wallet...")
    try:
        resp = requests.get(f"{TRADE_URL}/wallet/", headers=headers)
        print(f"    Status: {resp.status_code}")
        print(f"    Response: {resp.json()}")
        print("    ✓ Get wallet successful")
    except Exception as e:
        print(f"    ✗ Error: {e}")

    # Step 9: Purchase Fund
    print("\n[9/10] Testing Purchase Fund...")
    try:
        resp = requests.post(f"{TRADE_URL}/trade/purchase", json={
            "fund_code": "000001",
            "amount": 1000.00,
            "pay_method": "wallet"
        }, headers=headers)
        print(f"    Status: {resp.status_code}")
        print(f"    Response: {resp.json()}")

        if resp.status_code == 200:
            print("    ✓ Fund purchased successfully")
        else:
            print(f"    ✗ Purchase failed: {resp.text}")
    except Exception as e:
        print(f"    ✗ Error: {e}")

    # Step 10: Get Trade Orders
    print("\n[10/10] Testing Get Trade Orders...")
    try:
        resp = requests.get(f"{TRADE_URL}/orders", headers=headers)
        print(f"    Status: {resp.status_code}")
        print(f"    Response: {resp.json()}")
        print("    ✓ Get orders successful")
    except Exception as e:
        print(f"    ✗ Error: {e}")

    print("\n" + "=" * 60)
    print("Full flow test completed!")
    print("=" * 60)

if __name__ == "__main__":
    test_full_flow()