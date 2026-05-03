"""Integration tests against running services"""
import requests
import time

def unique_phone():
    return f"138{int(time.time() * 1000) % 100000000:08d}"

def unique_idcard():
    return f"110101199001{int(time.time() * 100) % 100000:05d}"

BASE_URL = "http://localhost"

# Service URLs
AUTH_URL = f"{BASE_URL}:8001"
ACCOUNT_URL = f"{BASE_URL}:8002"
FUND_URL = f"{BASE_URL}:8003"
PORTFOLIO_URL = f"{BASE_URL}:8004"
TRADE_URL = f"{BASE_URL}:8005"

# Test configuration
TEST_PASSWORD = "Test123!"


class TestServiceHealth:
    """Test all services are healthy"""

    def test_auth_service_health(self):
        response = requests.get(f"{AUTH_URL}/health", timeout=5)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "auth"

    def test_account_service_health(self):
        response = requests.get(f"{ACCOUNT_URL}/health", timeout=5)
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"

    def test_fund_service_health(self):
        response = requests.get(f"{FUND_URL}/health", timeout=5)
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"

    def test_portfolio_service_health(self):
        response = requests.get(f"{PORTFOLIO_URL}/health", timeout=5)
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"

    def test_trade_service_health(self):
        response = requests.get(f"{TRADE_URL}/health", timeout=5)
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"


class TestAuthService:
    """Test authentication service"""

    def test_register_success(self):
        """Test user registration with unique phone and ID"""
        phone = unique_phone()
        idcard = unique_idcard()
        response = requests.post(f"{AUTH_URL}/auth/register", json={
            "phone": phone,
            "id_card": idcard,
            "password": TEST_PASSWORD,
            "user_type": "direct_sales"
        }, timeout=5)
        assert response.status_code == 200, f"Registration failed: {response.text}"
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data

    def test_register_duplicate_phone_fails(self):
        """Test duplicate phone registration fails"""
        phone = unique_phone()
        idcard1 = unique_idcard()
        idcard2 = unique_idcard()

        # First registration should succeed
        resp1 = requests.post(f"{AUTH_URL}/auth/register", json={
            "phone": phone,
            "id_card": idcard1,
            "password": TEST_PASSWORD,
            "user_type": "direct_sales"
        }, timeout=5)
        assert resp1.status_code == 200, f"First registration failed: {resp1.text}"

        # Second registration with same phone should fail
        resp2 = requests.post(f"{AUTH_URL}/auth/register", json={
            "phone": phone,
            "id_card": idcard2,
            "password": TEST_PASSWORD,
            "user_type": "direct_sales"
        }, timeout=5)
        assert resp2.status_code == 400, f"Expected 400 for duplicate phone, got {resp2.status_code}"

    def test_login_phone(self):
        """Test phone login"""
        phone = unique_phone()
        idcard = unique_idcard()

        # Register first
        requests.post(f"{AUTH_URL}/auth/register", json={
            "phone": phone,
            "id_card": idcard,
            "password": TEST_PASSWORD,
            "user_type": "direct_sales"
        }, timeout=5)

        # Then login
        response = requests.post(f"{AUTH_URL}/auth/login", json={
            "login_type": "phone",
            "identifier": phone,
            "password": TEST_PASSWORD
        }, timeout=5)
        assert response.status_code == 200
        assert "access_token" in response.json()

    def test_login_id_card(self):
        """Test ID card login"""
        phone = unique_phone()
        idcard = unique_idcard()

        requests.post(f"{AUTH_URL}/auth/register", json={
            "phone": phone,
            "id_card": idcard,
            "password": TEST_PASSWORD,
            "user_type": "direct_sales"
        }, timeout=5)

        response = requests.post(f"{AUTH_URL}/auth/login", json={
            "login_type": "id_card",
            "identifier": idcard,
            "password": TEST_PASSWORD
        }, timeout=5)
        assert response.status_code == 200

    def test_login_wrong_password_fails(self):
        """Test login with wrong password fails"""
        phone = unique_phone()
        idcard = unique_idcard()

        requests.post(f"{AUTH_URL}/auth/register", json={
            "phone": phone,
            "id_card": idcard,
            "password": TEST_PASSWORD,
            "user_type": "direct_sales"
        }, timeout=5)

        response = requests.post(f"{AUTH_URL}/auth/login", json={
            "login_type": "phone",
            "identifier": phone,
            "password": "WrongPassword!"
        }, timeout=5)
        assert response.status_code == 401

    def test_refresh_token(self):
        """Test token refresh"""
        phone = unique_phone()
        idcard = unique_idcard()

        reg_response = requests.post(f"{AUTH_URL}/auth/register", json={
            "phone": phone,
            "id_card": idcard,
            "password": TEST_PASSWORD,
            "user_type": "direct_sales"
        }, timeout=5)
        assert reg_response.status_code == 200, f"Registration failed: {reg_response.text}"
        refresh_token = reg_response.json()["refresh_token"]

        response = requests.post(
            f"{AUTH_URL}/auth/refresh?refresh_token={refresh_token}",
            timeout=5
        )
        assert response.status_code == 200
        assert "access_token" in response.json()

    def test_get_current_user(self):
        """Test get current user info"""
        phone = unique_phone()
        idcard = unique_idcard()

        reg_response = requests.post(f"{AUTH_URL}/auth/register", json={
            "phone": phone,
            "id_card": idcard,
            "password": TEST_PASSWORD,
            "user_type": "direct_sales"
        }, timeout=5)
        assert reg_response.status_code == 200, f"Registration failed: {reg_response.text}"
        token = reg_response.json()["access_token"]

        response = requests.get(
            f"{AUTH_URL}/auth/me",
            headers={"Authorization": f"Bearer {token}"},
            timeout=5
        )
        assert response.status_code == 200
        assert "phone" in response.json()


class TestFundService:
    """Test fund service"""

    def test_list_funds(self):
        """Test list all funds"""
        response = requests.get(f"{FUND_URL}/fund/", timeout=5)
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_seed_funds(self):
        """Test seed mock data"""
        response = requests.post(f"{FUND_URL}/fund/seed", timeout=5)
        assert response.status_code == 200

    def test_get_fund(self):
        """Test get single fund"""
        # Seed mock data first
        requests.post(f"{FUND_URL}/fund/seed", timeout=5)

        response = requests.get(f"{FUND_URL}/fund/000001", timeout=5)
        if response.status_code == 200:
            data = response.json()
            assert "fund_code" in data
            assert "fund_name" in data

    def test_get_fund_nav_history(self):
        """Test get fund NAV history"""
        response = requests.get(f"{FUND_URL}/fund/000001/nav-history?days=7", timeout=5)
        assert response.status_code == 200
        assert isinstance(response.json(), list)


class TestAccountService:
    """Test account service"""

    def test_risk_questions(self):
        """Test get risk assessment questions"""
        response = requests.get(f"{ACCOUNT_URL}/risk/questions", timeout=5)
        assert response.status_code in [200, 404]


class TestTradeService:
    """Test trade service"""

    def test_wallet_info(self):
        """Test get wallet info"""
        response = requests.get(f"{TRADE_URL}/trade/wallet?user_id=1", timeout=5)
        assert response.status_code in [200, 404]

    def test_orders_empty(self):
        """Test get orders for non-existent user"""
        response = requests.get(f"{TRADE_URL}/trade/orders?user_id=999999", timeout=5)
        assert response.status_code == 200
        assert isinstance(response.json(), list)


class TestPortfolioService:
    """Test portfolio service"""

    def test_list_portfolios_empty(self):
        """Test list portfolios for non-existent user"""
        response = requests.get(f"{PORTFOLIO_URL}/portfolio/?user_id=999999", timeout=5)
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_portfolio_detail_not_found(self):
        """Test get portfolio detail for non-existent portfolio"""
        response = requests.get(f"{PORTFOLIO_URL}/portfolio/999999?user_id=1", timeout=5)
        assert response.status_code in [200, 404]


class TestE2EBusinessFlow:
    """End-to-end business flow tests"""

    def test_complete_user_journey(self):
        """Test complete user journey: register -> login -> browse funds -> check account"""
        phone = unique_phone()
        idcard = unique_idcard()

        # 1. Register user
        reg_response = requests.post(f"{AUTH_URL}/auth/register", json={
            "phone": phone,
            "id_card": idcard,
            "password": TEST_PASSWORD,
            "user_type": "direct_sales"
        }, timeout=5)
        assert reg_response.status_code == 200, f"Registration failed: {reg_response.text}"
        token = reg_response.json()["access_token"]

        # 2. Login
        login_response = requests.post(f"{AUTH_URL}/auth/login", json={
            "login_type": "phone",
            "identifier": phone,
            "password": TEST_PASSWORD
        }, timeout=5)
        assert login_response.status_code == 200

        # 3. Get current user
        me_response = requests.get(
            f"{AUTH_URL}/auth/me",
            headers={"Authorization": f"Bearer {token}"},
            timeout=5
        )
        assert me_response.status_code == 200
        user_data = me_response.json()
        user_id = user_data["id"]

        # 4. Browse funds
        funds_response = requests.get(f"{FUND_URL}/fund/", timeout=5)
        assert funds_response.status_code == 200

        # 5. Seed funds
        requests.post(f"{FUND_URL}/fund/seed", timeout=5)

        # 6. Check wallet
        wallet_response = requests.get(f"{TRADE_URL}/trade/wallet?user_id={user_id}", timeout=5)
        assert wallet_response.status_code in [200, 404]

        # 7. Check orders
        orders_response = requests.get(f"{TRADE_URL}/trade/orders?user_id={user_id}", timeout=5)
        assert orders_response.status_code == 200

        print(f"\n✓ E2E test passed for user_id={user_id}")

    def test_fund_browse_flow(self):
        """Test fund browsing flow"""
        # Seed mock data
        seed_response = requests.post(f"{FUND_URL}/fund/seed", timeout=5)
        assert seed_response.status_code == 200

        # List funds
        funds = requests.get(f"{FUND_URL}/fund/", timeout=5)
        assert funds.status_code == 200

        # Get fund detail
        fund_code = "000001"
        detail = requests.get(f"{FUND_URL}/fund/{fund_code}", timeout=5)
        if detail.status_code == 200:
            data = detail.json()
            assert "fund_name" in data
            assert "nav" in data

        # Get NAV history
        history = requests.get(f"{FUND_URL}/fund/{fund_code}/nav-history?days=30", timeout=5)
        assert history.status_code == 200

        print(f"\n✓ Fund browse flow passed, found {len(funds.json())} funds")